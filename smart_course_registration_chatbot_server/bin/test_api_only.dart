import 'package:serverpod/serverpod.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/endpoints.dart';

void main(List<String> args) async {
  // 1. Khởi tạo Server trong chế độ test
  final pod = Serverpod(args, Protocol(), Endpoints());
  final session = await pod.createSession();

  print('--- ĐANG TEST API: getMyCurriculum ---');

  try {
    // 2. Lấy thử sinh viên đầu tiên trong DB để test
    var student = await Student.db.findFirstRow(session);
    
    if (student == null) {
      print('LỖI: Không tìm thấy sinh viên nào trong DB. Hãy chạy bin/seed_data.dart trước!');
      return;
    }

    print('Đang lấy chương trình đào tạo của sinh viên: ${student.studentCode}');

    // 3. Gọi logic của API trực tiếp (không qua mạng)
    // Lấy thông tin phiên bản
    var version = await CurriculumVersion.db.findById(session, student.curriculumVersionId);
    var curriculum = await Curriculum.db.findById(session, version!.curriculumId);
    
    // Lấy danh sách môn học
    var items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(version.id!),
    );

    print('\n--- KẾT QUẢ API TRẢ VỀ ---');
    print('Ngành học: ${curriculum!.name}');
    print('Phiên bản: ${version.versionCode}');
    print('Số lượng môn học: ${items.length}');
    
    for (var i = 0; i < items.length; i++) {
      var course = await Course.db.findById(session, items[i].courseId);
      print('${i + 1}. ${course!.name} (${course.credits} tín chỉ) - Học kỳ: ${items[i].semester}');
    }
    print('--------------------------');
    print('API HOẠT ĐỘNG TỐT!');

  } catch (e) {
    print('API LỖI: $e');
  } finally {
    await session.close();
    // Dừng tiến trình
    print('Kết thúc test.');
    return;
  }
}
