import 'dart:io';

import 'package:smart_course_registration_chatbot_server/src/services/ai/rag_service.dart';

Future<void> main() async {
  try {
    await RagService.generateEmbeddingCache();
  } catch (error, stackTrace) {
    stderr.writeln('Không thể tạo embedding cache: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  }
}
