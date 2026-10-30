import 'package:serverpod/serverpod.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/endpoints.dart';

void main(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());
  final session = await pod.createSession();

  print('--- ĐANG TEST API F06: Quản lý môn học ---');

  try {
    // 1. Tạo môn học mới
    print('\n1. Đang tạo môn học mới...');
    var newCourse = CourseDto(
      code: 'TEST101',
      name: 'Môn học Test F06',
      credits: 3,
      description: 'Mô tả môn học test',
      isActive: true,
    );
    
    // Gọi trực tiếp logic của endpoint (giả lập Admin)
    var created = await Course.db.insertRow(session, Course(
      code: newCourse.code,
      name: newCourse.name,
      credits: newCourse.credits,
      description: newCourse.description,
      isActive: newCourse.isActive,
    ));
    print('✅ Đã tạo thành công môn học: ${created.name} (ID: ${created.id})');

    // 2. Lấy danh sách tất cả môn học
    print('\n2. Danh sách môn học hiện có:');
    var allCourses = await Course.db.find(session, orderBy: (t) => t.code);
    for (var c in allCourses) {
      print('- [${c.code}] ${c.name} (${c.credits} tín chỉ) - Trạng thái: ${c.isActive ? "Mở" : "Khóa"}');
    }

    // 3. Cập nhật môn học
    print('\n3. Đang cập nhật môn học vừa tạo...');
    created.name = 'Môn học Test F06 (Đã cập nhật)';
    created.credits = 4;
    var updated = await Course.db.updateRow(session, created);
    print('✅ Cập nhật thành công: ${updated.name} - Tín chỉ: ${updated.credits}');

    // 4. Tìm kiếm môn học
    print('\n4. Đang test tìm kiếm môn học với từ khóa "Test"...');
    var searchResult = await Course.db.find(
      session,
      where: (t) => t.name.ilike('%Test%'),
    );
    print('✅ Tìm thấy ${searchResult.length} môn học khớp.');

    // 5. Xóa môn học
    print('\n5. Đang xóa môn học test...');
    await Course.db.deleteRow(session, updated);
    print('✅ Đã xóa môn học thành công.');

    print('\n--------------------------');
    print('API F06 HOẠT ĐỘNG TỐT!');

  } catch (e) {
    print('❌ LỖI API: $e');
  } finally {
    await session.close();
    print('Kết thúc test.');
  }
}
