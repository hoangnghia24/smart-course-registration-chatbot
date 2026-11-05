import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'app/smart_course_app.dart';
import 'features/auth/data/f01_auth_gateway.dart';

import 'features/course_lookup/course_lookup_repository_scope.dart';
import 'features/course_lookup/data/serverpod_course_lookup_repository.dart';

import 'features/curriculum_lookup/curriculum_lookup_repository_scope.dart';
import 'features/curriculum_lookup/data/serverpod_curriculum_lookup_repository.dart';

late final Client client;
late String serverUrl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  serverUrl = await getServerUrl();
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Quan trọng: hoàn tất khôi phục session trước khi hỏi account.me().
  try {
    await client.auth.initialize();
  } catch (_) {
    // Có thể máy chủ đang offline; hiển thị Login thay vì làm sập ứng dụng.
  }

  runApp(
  CurriculumLookupRepositoryScope(
    repository: ServerpodCurriculumLookupRepository(client),
    child: CourseLookupRepositoryScope(
      repository: ServerpodCourseLookupRepository(client),
      child: SmartCourseApp(
        f01Gateway: ServerpodF01AuthGateway(client),
      ), 
    ),
  ),
);
}
