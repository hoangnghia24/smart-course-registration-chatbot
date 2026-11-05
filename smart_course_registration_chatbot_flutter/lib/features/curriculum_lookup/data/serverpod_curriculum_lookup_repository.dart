import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'curriculum_lookup_repository.dart';

/// Dùng cùng Client Serverpod đã khôi phục session F01; không tạo Client mới.
class ServerpodCurriculumLookupRepository implements CurriculumLookupRepository {
  ServerpodCurriculumLookupRepository(Client client)
      : _getMyCurriculum = client.student.getMyCurriculum;

  /// Hữu ích khi kiểm thử adapter mà không cần server thực.
  const ServerpodCurriculumLookupRepository.fromRpc(this._getMyCurriculum);

  final Future<CurriculumDetailsDto?> Function() _getMyCurriculum;

  @override
  Future<CurriculumDetails?> getMyCurriculum() async {
    final dto = await _getMyCurriculum();
    if (dto == null) return null;

    final courses = dto.items.map((item) {
      return CurriculumCourse(
        code: item.course.code,
        name: item.course.name,
        credits: item.course.credits,
        semester: item.semester,
        isRequired: item.isRequired,
        description: item.course.description,
      );
    }).toList(growable: false)
      ..sort((a, b) {
        final bySemester = a.semester.compareTo(b.semester);
        return bySemester != 0 ? bySemester : a.code.compareTo(b.code);
      });

    return CurriculumDetails(
      code: dto.curriculum.code,
      name: dto.curriculum.name,
      majorCode: dto.curriculum.majorCode,
      versionCode: dto.version.versionCode,
      effectiveYear: dto.version.effectiveYear,
      versionStatus: dto.version.status,
      items: courses,
    );
  }
}
