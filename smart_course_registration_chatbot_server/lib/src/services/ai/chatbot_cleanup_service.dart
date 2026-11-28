import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class ChatbotCleanupService {
  static Future<void> cleanup(Session session) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 24));
    await ChatbotConversation.db.deleteWhere(
      session,
      where: (t) => t.updatedAt <= cutoff,
    );
  }

  /// Dùng cho triển khai một tiến trình server. Không chạy chồng các lần dọn.
  static Timer start(Serverpod pod) {
    var running = false;
    Future<void> run() async {
      if (running) return;
      running = true;
      Session? session;
      try {
        session = await pod.createSession();
        await cleanup(session);
      } catch (error) {
        // Không log nội dung hội thoại.
        session?.log('Chatbot cleanup failed: ${error.runtimeType}',
            level: LogLevel.error);
      } finally {
        try {
          await session?.close();
        } finally {
          running = false;
        }
      }
    }
    unawaited(run());
    return Timer.periodic(const Duration(hours: 1), (_) => unawaited(run()));
  }
}
