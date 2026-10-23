
import 'dart:convert';
import 'package:serverpod/serverpod.dart';

class AppHealthRoute extends Route {
  @override
  Future<Result> handleCall(
    Session session,
    Request request,
  ) async {
    try {
      await session.db.unsafeQuery('SELECT 1');

      return Response.ok(
        body: Body.fromString(
          jsonEncode({
            'status': 'ok',
            'service': 'smart-course-registration-chatbot',
            'database': 'connected',
          }),
          mimeType: MimeType.json,
        ),
      );
    } catch (_) {
      return Response(
        503,
        body: Body.fromString(
          jsonEncode({
            'status': 'error',
            'database': 'unavailable',
          }),
          mimeType: MimeType.json,
        ),
      );
    }
  }
}
