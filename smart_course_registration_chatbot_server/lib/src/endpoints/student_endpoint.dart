import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../security/account_guard.dart';

class StudentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CurriculumDetailsDto?> getMyCurriculum(Session session) async {
    // 1. Lấy thông tin UserAccount đang đăng nhập (Sử dụng AccountGuard chuẩn của dự án)
    final userAccount = await AccountGuard.require(session);

    // 2. Lấy thông tin Student để biết curriculumVersionId
    var student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(userAccount.id!),
    );
    if (student == null) return null;

    // 3. Lấy thông tin chi tiết khung chương trình
    var version = await CurriculumVersion.db.findById(session, student.curriculumVersionId);
    if (version == null) return null;

    var curriculum = await Curriculum.db.findById(session, version.curriculumId);
    if (curriculum == null) return null;

    // 4. Lấy danh sách các môn học trong khung
    var items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(version.id!),
      orderBy: (t) => t.semester,
    );

    var itemDetails = <CurriculumItemDetailDto>[];
    for (var item in items) {
      var course = await Course.db.findById(session, item.courseId);
      if (course != null) {
        // Chuyển đổi từ Course (Server Entity) sang CourseItemDto (Shared DTO)
        itemDetails.add(CurriculumItemDetailDto(
          course: CourseItemDto(
            code: course.code,
            name: course.name,
            credits: course.credits,
            description: course.description,
          ),
          semester: item.semester,
          isRequired: item.isRequired,
        ));
      }
    }

    // 5. Trả về DTO tổng hợp đã map dữ liệu
    return CurriculumDetailsDto(
      curriculum: CurriculumDto(
        code: curriculum.code,
        name: curriculum.name,
        majorCode: curriculum.majorCode,
      ),
      version: CurriculumVersionDto(
        versionCode: version.versionCode,
        effectiveYear: version.effectiveYear,
        status: version.status,
      ),
      items: itemDetails,
    );
  }
}
