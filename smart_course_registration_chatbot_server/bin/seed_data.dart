// ignore_for_file: avoid_print

import 'dart:io';
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/endpoints.dart';
import 'package:serverpod/serverpod.dart';

void main(List<String> args) async {
  // Thay thế null bằng Endpoints() để fix lỗi
  final pod = Serverpod(args, Protocol(), Endpoints());
  final session = await pod.createSession();

  print('Đang khởi tạo dữ liệu mẫu...');

  try {
    // 1. Tạo môn học mẫu
    var course1 = Course(
      code: 'CS101',
      name: 'Nhập môn lập trình',
      credits: 3,
      isActive: true,
    );
    var course2 = Course(
      code: 'CS102',
      name: 'Cấu trúc dữ liệu',
      credits: 4,
      isActive: true,
    );

    // Lưu và lấy lại đối tượng đã có ID
    course1 = await Course.db.insertRow(session, course1);
    course2 = await Course.db.insertRow(session, course2);

    // 2. Tạo khung chương trình
    var curriculum = Curriculum(
      code: 'CNTT',
      name: 'Công nghệ thông tin',
      majorCode: '7480201',
      status: 'active',
    );
    var savedCur = await Curriculum.db.insertRow(session, curriculum);

    // 3. Tạo phiên bản khung
    var version = CurriculumVersion(
      curriculumId: savedCur.id!,
      versionCode: 'V2024',
      effectiveYear: 2024,
      status: 'active',
    );
    var savedVer = await CurriculumVersion.db.insertRow(session, version);

    // 4. Thêm môn học vào khung
    await CurriculumItem.db.insertRow(
      session,
      CurriculumItem(
        curriculumVersionId: savedVer.id!,
        courseId: course1.id!,
        semester: 1,
        isRequired: true,
      ),
    );

    await CurriculumItem.db.insertRow(
      session,
      CurriculumItem(
        curriculumVersionId: savedVer.id!,
        courseId: course2.id!,
        semester: 2,
        isRequired: false,
      ),
    );

    print('--- Đã nạp dữ liệu thành công! ---');
    print('ID Phiên bản khung vừa tạo là: ${savedVer.id}');
    print(
      'LƯU Ý: Bạn cần dùng pgAdmin hoặc công cụ DB gán ID này vào cột curriculumVersionId của sinh viên trong bảng app_student.',
    );
  } catch (e) {
    print('Lỗi khi nạp dữ liệu: $e');
  } finally {
    await session.close();
    exit(0);
  }
}
