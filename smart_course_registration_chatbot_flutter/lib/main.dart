import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'app/smart_course_app.dart';

/// Client Serverpod dùng chung cho các màn hình khi kết nối API thật.
/// Tuần 6, giao diện đăng nhập hiện vẫn dùng DemoAuthController.
late final Client client;

/// URL backend được đọc từ --dart-define hoặc assets/config.json.
late String serverUrl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Giữ nguyên cơ chế cấu hình/khởi tạo Serverpod đang có trong dự án.
  serverUrl = await getServerUrl();

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  // Giữ cách khởi tạo từ main.dart ban đầu; chưa phải luồng đăng nhập thật.
  client.auth.initialize();

  // Điểm khởi chạy chính: Login demo -> Dashboard theo vai trò -> Chatbot.
  runApp(const SmartCourseApp());
}
