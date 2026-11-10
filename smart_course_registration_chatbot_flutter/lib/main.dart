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
import 'features/academic_progress/academic_progress_repository_scope.dart';
import 'features/academic_progress/data/serverpod_academic_progress_repository.dart';
import 'features/admin/course_management/data/course_management_repository_scope.dart';
import 'features/admin/course_management/data/serverpod_course_management_repository.dart';

// Entry point dùng một Client duy nhất cho F01, F03, F04, F23 và F06.
late final Client client;
late String serverUrl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  serverUrl = await getServerUrl();
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  try {
    await client.auth.initialize();
  } catch (_) {
    // Không làm sập app nếu server chưa khởi động; F01 hiển thị trạng thái đăng nhập.
  }

  // Tất cả repository dùng chung client và phiên xác thực.
  // Scope F23 phải ở bên trên SmartCourseApp để Dashboard con truy cập được.
  runApp(
    CourseLookupRepositoryScope(
      repository: ServerpodCourseLookupRepository(client),
      child: CurriculumLookupRepositoryScope(
        repository: ServerpodCurriculumLookupRepository(client),
        child: AcademicProgressRepositoryScope(
          repository: ServerpodAcademicProgressRepository(client),
          child: CourseManagementRepositoryScope(
            repository: ServerpodCourseManagementRepository(client),
            child: SmartCourseApp(
              f01Gateway: ServerpodF01AuthGateway(client),
            ),
          ),
        ),
      ),
    ),
  );
}
