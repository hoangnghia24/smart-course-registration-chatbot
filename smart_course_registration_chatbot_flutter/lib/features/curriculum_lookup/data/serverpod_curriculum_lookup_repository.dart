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
        groupCode: item.groupCode,
        groupName: item.groupName,
        groupOrder: item.groupOrder,
        itemOrder: item.itemOrder,
      );
    }).toList(growable: false)
      ..sort(_compareCurriculumCourses);

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

/// Sắp theo thứ tự khối kiến thức, sau đó theo thứ tự môn trong CTĐT.
/// Dữ liệu thiếu thứ tự sẽ được xếp sau, không tự đoán thứ tự khối.
int _compareCurriculumCourses(CurriculumCourse a, CurriculumCourse b) {
  const last = 0x7fffffff;
  final byGroup = (a.groupOrder ?? last).compareTo(b.groupOrder ?? last);
  if (byGroup != 0) return byGroup;
  final aGroup = (a.groupCode ?? a.groupName ?? '').trim();
  final bGroup = (b.groupCode ?? b.groupName ?? '').trim();
  final byName = aGroup.compareTo(bGroup);
  if (byName != 0) return byName;
  final byItem = (a.itemOrder ?? last).compareTo(b.itemOrder ?? last);
  if (byItem != 0) return byItem;
  final bySemester = a.semester.compareTo(b.semester);
  return bySemester != 0 ? bySemester : a.code.compareTo(b.code);
}
