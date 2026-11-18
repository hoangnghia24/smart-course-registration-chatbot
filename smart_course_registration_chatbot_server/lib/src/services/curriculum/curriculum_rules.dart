import '../../generated/protocol.dart';

/// F07 - Quy tac nghiep vu thuan (khong truy cap DB) cho quan ly CTDT.
///
/// Tach rieng de kiem thu don vi khong can PostgreSQL.

/// Trang thai phien ban CTDT.
abstract final class CurriculumVersionStatus {
  static const draft = 'DRAFT';
  static const published = 'PUBLISHED';
  static const archived = 'ARCHIVED';

  static const all = {draft, published, archived};
}

/// Trang thai chuong trinh dao tao.
abstract final class CurriculumProgramStatus {
  static const active = 'ACTIVE';
  static const inactive = 'INACTIVE';
}

/// Ma hanh dong ghi vao AuditLog.
abstract final class CurriculumAuditAction {
  static const curriculumCreated = 'CURRICULUM_CREATED';
  static const versionCreated = 'CURRICULUM_VERSION_CREATED';
  static const versionDraftSaved = 'CURRICULUM_VERSION_DRAFT_SAVED';
  static const versionPublished = 'CURRICULUM_VERSION_PUBLISHED';
  static const versionArchived = 'CURRICULUM_VERSION_ARCHIVED';
  static const versionDeleted = 'CURRICULUM_VERSION_DELETED';
  static const studentVersionChanged = 'STUDENT_CURRICULUM_VERSION_CHANGED';
  static const studentAdmissionYearUpdated = 'STUDENT_ADMISSION_YEAR_UPDATED';
}

abstract final class CurriculumLimits {
  static const maxCodeLength = 30;
  static const maxNameLength = 200;
  static const maxSemester = 12;
  static const maxTotalCredits = 400;
  static const minYear = 1990;
  static const maxYear = 2100;
  static const maxItems = 300;
  static const maxGroups = 50;
  static const maxReasonLength = 500;
}

AppException _err(String code, String message) =>
    AppException(code: code, message: message);

/// Chuan hoa ma: bo khoang trang dau/cuoi, viet hoa.
String normalizeCode(String raw) => raw.trim().toUpperCase();

String requireCode(String raw, {required String field}) {
  final code = normalizeCode(raw);
  if (code.isEmpty || code.length > CurriculumLimits.maxCodeLength) {
    throw _err(
      'INVALID_${field}_CODE',
      'Mã phải có từ 1 đến ${CurriculumLimits.maxCodeLength} ký tự.',
    );
  }
  if (!RegExp(r'^[A-Z0-9][A-Z0-9._-]*$').hasMatch(code)) {
    throw _err(
      'INVALID_${field}_CODE',
      'Mã chỉ gồm chữ, số và các ký tự . _ -',
    );
  }
  return code;
}

String requireName(String raw, {required String field}) {
  final name = raw.trim();
  if (name.isEmpty || name.runes.length > CurriculumLimits.maxNameLength) {
    throw _err(
      'INVALID_${field}_NAME',
      'Tên phải có từ 1 đến ${CurriculumLimits.maxNameLength} ký tự.',
    );
  }
  return name;
}

int requireYear(int year, {required String code}) {
  if (year < CurriculumLimits.minYear || year > CurriculumLimits.maxYear) {
    throw _err(
      code,
      'Năm phải trong khoảng ${CurriculumLimits.minYear}'
      '-${CurriculumLimits.maxYear}.',
    );
  }
  return year;
}

void requirePositiveId(int id, {required String code}) {
  if (id <= 0) throw _err(code, 'ID không hợp lệ.');
}

/// Chi DRAFT duoc sua noi dung.
void ensureEditable(String status) {
  if (status != CurriculumVersionStatus.draft) {
    throw _err(
      'VERSION_LOCKED',
      'Phiên bản đã công bố hoặc lưu trữ, không thể chỉnh sửa. '
          'Hãy tạo phiên bản mới.',
    );
  }
}

/// Chi phien ban PUBLISHED moi duoc gan cho sinh vien.
void ensureAssignable(String status) {
  if (status != CurriculumVersionStatus.published) {
    throw _err(
      'VERSION_NOT_PUBLISHED',
      'Chỉ được gán phiên bản đã công bố chính thức.',
    );
  }
}

/// Noi dung ban nhap da duoc chuan hoa.
class NormalizedDraft {
  NormalizedDraft({
    required this.versionCode,
    required this.effectiveYear,
    required this.totalCreditsRequired,
    required this.groups,
    required this.items,
  });

  final String versionCode;
  final int effectiveYear;
  final int? totalCreditsRequired;
  final List<AdminCurriculumGroupDto> groups;
  final List<AdminCurriculumItemDto> items;
}

/// Kiem tra va chuan hoa noi dung ban nhap.
///
/// Ban nhap cho phep chua du (chua co tong tin chi, chua co mon);
/// cac dieu kien day du duoc kiem tra khi cong bo.
NormalizedDraft validateDraftInput(CurriculumDraftInput input) {
  final versionCode = requireCode(input.versionCode, field: 'VERSION');
  final effectiveYear = requireYear(
    input.effectiveYear,
    code: 'INVALID_EFFECTIVE_YEAR',
  );

  final total = input.totalCreditsRequired;
  if (total != null && (total < 1 || total > CurriculumLimits.maxTotalCredits)) {
    throw _err(
      'INVALID_TOTAL_CREDITS',
      'Tổng tín chỉ phải từ 1 đến ${CurriculumLimits.maxTotalCredits}.',
    );
  }

  if (input.groups.length > CurriculumLimits.maxGroups) {
    throw _err('TOO_MANY_GROUPS', 'Quá nhiều khối kiến thức.');
  }
  if (input.items.length > CurriculumLimits.maxItems) {
    throw _err('TOO_MANY_ITEMS', 'Quá nhiều học phần.');
  }

  final groups = <AdminCurriculumGroupDto>[];
  final groupCodes = <String>{};
  for (final g in input.groups) {
    final code = requireCode(g.groupCode, field: 'GROUP');
    if (!groupCodes.add(code)) {
      throw _err('DUPLICATE_GROUP', 'Mã khối kiến thức "$code" bị trùng.');
    }
    if (g.groupOrder < 0) {
      throw _err('INVALID_GROUP_ORDER', 'Thứ tự khối không hợp lệ.');
    }
    groups.add(
      AdminCurriculumGroupDto(
        groupCode: code,
        groupName: requireName(g.groupName, field: 'GROUP'),
        groupOrder: g.groupOrder,
      ),
    );
  }

  final items = <AdminCurriculumItemDto>[];
  final courseIds = <int>{};
  for (final item in input.items) {
    requirePositiveId(item.courseId, code: 'INVALID_COURSE_ID');
    if (!courseIds.add(item.courseId)) {
      throw _err('DUPLICATE_COURSE', 'Một môn học chỉ xuất hiện một lần.');
    }
    if (item.semester < 1 || item.semester > CurriculumLimits.maxSemester) {
      throw _err(
        'INVALID_SEMESTER',
        'Học kỳ dự kiến phải từ 1 đến ${CurriculumLimits.maxSemester}.',
      );
    }
    final order = item.itemOrder;
    if (order != null && order < 0) {
      throw _err('INVALID_ITEM_ORDER', 'Thứ tự học phần không hợp lệ.');
    }
    final rawGroup = item.groupCode;
    String? groupCode;
    if (rawGroup != null && rawGroup.trim().isNotEmpty) {
      groupCode = normalizeCode(rawGroup);
      if (!groupCodes.contains(groupCode)) {
        throw _err(
          'UNKNOWN_GROUP',
          'Học phần tham chiếu khối "$groupCode" không tồn tại.',
        );
      }
    }
    // Client khong duoc tu dat ten/ma/tin chi: server se dien tu Course.
    items.add(
      AdminCurriculumItemDto(
        courseId: item.courseId,
        semester: item.semester,
        isRequired: item.isRequired,
        groupCode: groupCode,
        itemOrder: order,
      ),
    );
  }

  return NormalizedDraft(
    versionCode: versionCode,
    effectiveYear: effectiveYear,
    totalCreditsRequired: total,
    groups: groups,
    items: items,
  );
}

/// Du lieu toi thieu cua mot hoc phan de kiem tra cong bo.
class PublishItemFact {
  const PublishItemFact({
    required this.courseCode,
    required this.credits,
    required this.isRequired,
    required this.courseActive,
  });

  final String courseCode;
  final int? credits;
  final bool isRequired;
  final bool courseActive;
}

/// Kiem tra phien ban du dieu kien cong bo chinh thuc.
void validatePublishable({
  required int? totalCreditsRequired,
  required List<PublishItemFact> items,
}) {
  if (items.isEmpty) {
    throw _err('EMPTY_VERSION', 'Phiên bản chưa có học phần nào.');
  }
  if (totalCreditsRequired == null) {
    throw _err(
      'TOTAL_CREDITS_REQUIRED',
      'Cần nhập tổng tín chỉ tốt nghiệp trước khi công bố.',
    );
  }

  final inactive = items.where((i) => !i.courseActive).map((i) => i.courseCode);
  if (inactive.isNotEmpty) {
    throw _err(
      'INACTIVE_COURSE',
      'Các môn đã ngừng hoạt động: ${inactive.join(', ')}.',
    );
  }

  final missingCredits = items.where((i) => i.credits == null);
  if (missingCredits.isNotEmpty) {
    throw _err(
      'MISSING_CREDITS',
      'Thiếu số tín chỉ cho: '
          '${missingCredits.map((i) => i.courseCode).join(', ')}.',
    );
  }

  final all = items.fold<int>(0, (s, i) => s + i.credits!);
  final required = items
      .where((i) => i.isRequired)
      .fold<int>(0, (s, i) => s + i.credits!);

  if (totalCreditsRequired < required) {
    throw _err(
      'TOTAL_CREDITS_TOO_LOW',
      'Tổng tín chỉ ($totalCreditsRequired) nhỏ hơn tổng tín chỉ '
          'môn bắt buộc ($required).',
    );
  }
  if (totalCreditsRequired > all) {
    throw _err(
      'TOTAL_CREDITS_TOO_HIGH',
      'Tổng tín chỉ ($totalCreditsRequired) lớn hơn tổng tín chỉ '
          'của tất cả học phần ($all).',
    );
  }
}

/// Ly do bat buoc khi Admin doi phien ban cua sinh vien.
String requireReason(String raw) {
  final reason = raw.trim();
  if (reason.isEmpty || reason.runes.length > CurriculumLimits.maxReasonLength) {
    throw _err(
      'REASON_REQUIRED',
      'Cần ghi lý do (tối đa ${CurriculumLimits.maxReasonLength} ký tự).',
    );
  }
  return reason;
}

/// Thong tin toi thieu cua mot phien ban de chon theo nam hieu luc.
class VersionYearFact {
  const VersionYearFact({
    required this.id,
    required this.effectiveYear,
    required this.status,
  });

  final int id;
  final int effectiveYear;
  final String status;
}

/// Hoc che tin chi: sinh vien nhap hoc nam [admissionYear] dung phien ban
/// PUBLISHED co effectiveYear lon nhat <= [admissionYear] trong cung CTDT.
/// Tra ve null neu khong co phien ban phu hop.
int? pickVersionForAdmission(
  Iterable<VersionYearFact> versions,
  int admissionYear,
) {
  VersionYearFact? best;
  for (final v in versions) {
    if (v.status != CurriculumVersionStatus.published) continue;
    if (v.effectiveYear > admissionYear) continue;
    if (best == null || v.effectiveYear > best.effectiveYear) best = v;
  }
  return best?.id;
}

/// Mot CTDT khong duoc co hai phien ban PUBLISHED cung nam hieu luc,
/// neu khong quy tac chon theo nam se khong xac dinh.
void ensureEffectiveYearFree({
  required int effectiveYear,
  required Iterable<VersionYearFact> otherPublished,
}) {
  final clash = otherPublished.where(
    (v) =>
        v.status == CurriculumVersionStatus.published &&
        v.effectiveYear == effectiveYear,
  );
  if (clash.isNotEmpty) {
    throw _err(
      'EFFECTIVE_YEAR_TAKEN',
      'CTĐT đã có phiên bản công bố hiệu lực năm $effectiveYear. '
          'Hãy lưu trữ phiên bản đó trước hoặc đổi năm hiệu lực.',
    );
  }
}
