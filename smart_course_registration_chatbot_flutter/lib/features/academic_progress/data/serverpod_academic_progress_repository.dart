import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'academic_progress_repository.dart';

/// Nhận lại cùng Client đã có session từ F01.
/// Không tạo Client/phiên đăng nhập mới và không dùng dữ liệu giả runtime.
class ServerpodAcademicProgressRepository implements AcademicProgressRepository {
  ServerpodAcademicProgressRepository(Client client)
      : _getProgress = client.academic.getMyProgress;

  const ServerpodAcademicProgressRepository.fromRpc(this._getProgress);

  final Future<AcademicProgressDto?> Function() _getProgress;

  @override
  Future<AcademicProgressDetails?> getMyProgress() async {
    final dto = await _getProgress();
    if (dto == null) return null;

    final mapped = dto.courses.map((item) {
      return AcademicCourseProgress(
        code: item.course.code,
        name: item.course.name,
        credits: item.course.credits,
        semester: _intOrNull(item.semester),
        isRequired: item.isRequired,
        groupCode: item.groupCode,
        groupName: item.groupName,
        groupOrder: _intOrNull(item.groupOrder),
        itemOrder: _intOrNull(item.itemOrder),
        status: item.status,
        statusDetail: item.statusDetail,
        score: _doubleOrNull(item.score),
        scoreStatus: item.scoreStatus,
      );
    }).toList(growable: false)
      ..sort(_compareCourses);

    return AcademicProgressDetails(
      curriculumVersionId: _intOrNull(dto.curriculumVersionId),
      totalCredits: _intOrNull(dto.totalCredits),
      earnedCredits: _intOrNull(dto.earnedCredits),
      remainingCredits: _intOrNull(dto.remainingCredits),
      creditStatus: dto.creditStatus,
      gpa: _doubleOrNull(dto.gpa),
      gpaStatus: dto.gpaStatus,
      courses: mapped,
    );
  }
}

int? _intOrNull(Object? value) => value is num ? value.toInt() : null;
double? _doubleOrNull(Object? value) => value is num ? value.toDouble() : null;

int _compareCourses(AcademicCourseProgress a, AcademicCourseProgress b) {
  const last = 0x7fffffff;
  final aHasGroup = (a.groupCode ?? a.groupName ?? '').trim().isNotEmpty;
  final bHasGroup = (b.groupCode ?? b.groupName ?? '').trim().isNotEmpty;
  if (aHasGroup != bHasGroup) return aHasGroup ? -1 : 1;
  final byGroup = (a.groupOrder ?? last).compareTo(b.groupOrder ?? last);
  if (byGroup != 0) return byGroup;
  final byGroupName = (a.groupCode ?? a.groupName ?? '')
      .compareTo(b.groupCode ?? b.groupName ?? '');
  if (byGroupName != 0) return byGroupName;
  final byItem = (a.itemOrder ?? last).compareTo(b.itemOrder ?? last);
  if (byItem != 0) return byItem;
  final bySemester = (a.semester ?? last).compareTo(b.semester ?? last);
  return bySemester != 0 ? bySemester : a.code.compareTo(b.code);
}
