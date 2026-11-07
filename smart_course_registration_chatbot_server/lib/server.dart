import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/app_health_route.dart';
import 'src/services/auth/email_verification_service.dart';
import 'src/services/auth/dev_seed_accounts.dart';
import 'src/services/seed/dev_seed_sample_data.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());
  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      ServerSideSessionsConfigFromPasswords(
        defaultSessionLifetime: Duration(days: 14),
        defaultSessionInactivityTimeout: Duration(days: 7),
      ),
    ],
    identityProviderBuilders: [
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: sendRegistrationCode,
        sendPasswordResetVerificationCode: sendPasswordResetCode,
      ),
    ],
    authUsersConfig: AuthUsersConfig(
      onBeforeAuthUserCreated:
          (
            session,
            scopes,
            blocked, {
            required transaction,
          }) {
            return (scopes: <Scope>{}, blocked: true);
          },
    ),
  );
  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));
  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );
  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }
  pod.webServer.addRoute(
    AppHealthRoute(),
    '/health',
  );
  // Start the server and apply pending schema migrations BEFORE demo seeding.
  await pod.start();

  // Automatically seed demo COURSES only in development mode.
  // The seeder itself checks whether the course catalog already contains data.
  // It is safe to call on every startup: existing rows are never overwritten.
  if (pod.runMode == 'development') {
    final session = await pod.createSession();
    try {
      await DevSeedSampleData.run(session);

      // Account provisioning remains opt-in because it requires secrets.
      if (Platform.environment['APP_ENV'] == 'development' &&
          Platform.environment['ALLOW_DEV_SEED'] == 'true') {
        await DevSeedAccounts.run(session);
      }
    } finally {
      await session.close();
    }
  }
}
