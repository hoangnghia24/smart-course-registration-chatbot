import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Kho truy van CTDT dung chung cho Student, Admin va (sau nay) chatbot.
///
/// Service khong xu ly authentication/authorization. Endpoint phai kiem tra
/// quyen va quyet dinh versionId duoc phep doc truoc khi goi ham nay.
///
/// Chi doc; khong can thay doi schema, DTO hay migration.
class CurriculumReadService {
  CurriculumReadService._();

  /// null khi versionId khong ton tai; loi neu du lieu tham chieu bi hong.
  static Future<CurriculumReadSnapshot?> getByVersion(
    Session session,
    int versionId, {
    Transaction? transaction,
  }) async {
    if (versionId <= 0) {
      throw AppException(
        code: 'INVALID_VERSION_ID',
        message: 'ID phien ban CTDT khong hop le.',
      );
    }

    final version = await CurriculumVersion.db.findById(
      session,
      versionId,
      transaction: transaction,
    );
    if (version == null) return null;

    final curriculum = await Curriculum.db.findById(
      session,
      version.curriculumId,
      transaction: transaction,
    );
    if (curriculum == null) {
      throw AppException(
        code: 'CURRICULUM_NOT_FOUND',
        message: 'Phien ban CTDT khong co chuong trinh dao tao tuong ung.',
      );
    }

    final groups = await CurriculumGroup.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(versionId),
      orderByList: (t) => [
        Order(column: t.groupOrder),
        Order(column: t.groupCode),
      ],
      transaction: transaction,
    );

    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(versionId),
      transaction: transaction,
    );

    // Tra cuu Course theo mot truy van de tranh N+1 query.
    final courseIds = items.map((item) => item.courseId).toSet();
    final courses = courseIds.isEmpty
        ? <Course>[]
        : await Course.db.find(
            session,
            where: (t) => t.id.inSet(courseIds),
            transaction: transaction,
          );
    final coursesById = <int, Course>{
      for (final course in courses) course.id!: course,
    };

    // Khong am tham bo mon khoi CTDT khi du lieu bi thieu.
    final missingCourseIds = courseIds
        .where((id) => !coursesById.containsKey(id))
        .toList()
      ..sort();
    if (missingCourseIds.isNotEmpty) {
      throw AppException(
        code: 'CURRICULUM_DATA_INCOMPLETE',
        message: 'CTDT thieu mon hoc tham chieu: '
            '${missingCourseIds.join(', ')}.',
      );
    }

    return CurriculumReadSnapshot._(
      curriculum: curriculum,
      version: version,
      groups: groups,
      items: items,
      coursesById: coursesById,
    );
  }
}

/// Du lieu doc mot lan, co the chuyen sang DTO Student hoac DTO Admin.
/// Khong la model Serverpod va khong tra truc tiep qua Endpoint.
class CurriculumReadSnapshot {
  const CurriculumReadSnapshot._({
    required this.curriculum,
    required this.version,
    required this.groups,
    required this.items,
    required this.coursesById,
  });

  final Curriculum curriculum;
  final CurriculumVersion version;
  final List<CurriculumGroup> groups;
  final List<CurriculumItem> items;
  final Map<int, Course> coursesById;

  Map<int, CurriculumGroup> get _groupsById => {
        for (final group in groups) group.id!: group,
      };

  /// DTO F04 hien co, khong thay doi wire format/API.
  CurriculumDetailsDto toStudentDto() {
    final groupsById = _groupsById;
    final details = <CurriculumItemDetailDto>[];

    for (final item in items) {
      final course = coursesById[item.courseId]!;
      final group = item.groupId == null ? null : groupsById[item.groupId];

      details.add(
        CurriculumItemDetailDto(
          course: CourseItemDto(
            code: course.code,
            name: course.name,
            credits: item.credits ?? course.credits,
            description: course.description,
          ),
          semester: item.semester,
          isRequired: item.isRequired,
          groupCode: group?.groupCode,
          groupName: group?.groupName,
          groupOrder: group?.groupOrder,
          itemOrder: item.itemOrder,
        ),
      );
    }

    // Hoc ky -> nhom kien thuc -> thu tu mon -> ma mon.
    details.sort((a, b) {
      final semester = a.semester.compareTo(b.semester);
      if (semester != 0) return semester;

      final groupOrder = (a.groupOrder ?? 999999)
          .compareTo(b.groupOrder ?? 999999);
      if (groupOrder != 0) return groupOrder;

      final groupCode = (a.groupCode ?? '\uffff')
          .compareTo(b.groupCode ?? '\uffff');
      if (groupCode != 0) return groupCode;

      final itemOrder = (a.itemOrder ?? 999999)
          .compareTo(b.itemOrder ?? 999999);
      if (itemOrder != 0) return itemOrder;

      return a.course.code.compareTo(b.course.code);
    });

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
      items: details,
    );
  }

  /// Cac khoi kien thuc cua Admin, theo thu tu tu DB.
  List<AdminCurriculumGroupDto> toAdminGroups() => [
        for (final group in groups)
          AdminCurriculumGroupDto(
            groupCode: group.groupCode,
            groupName: group.groupName,
            groupOrder: group.groupOrder,
          ),
      ];

  /// Phan item DTO cho API Admin cu, giu thu tu sap xep truoc refactor.
  List<AdminCurriculumItemDto> toAdminItems() {
    final groupsById = _groupsById;
    final details = <AdminCurriculumItemDto>[];

    for (final item in items) {
      final course = coursesById[item.courseId]!;
      final group = item.groupId == null ? null : groupsById[item.groupId];
      details.add(
        AdminCurriculumItemDto(
          courseId: item.courseId,
          courseCode: course.code,
          courseName: course.name,
          credits: item.credits ?? course.credits,
          semester: item.semester,
          isRequired: item.isRequired,
          groupCode: group?.groupCode,
          itemOrder: item.itemOrder,
        ),
      );
    }

    details.sort((a, b) {
      final semester = a.semester.compareTo(b.semester);
      if (semester != 0) return semester;
      final itemOrder = (a.itemOrder ?? 999999)
          .compareTo(b.itemOrder ?? 999999);
      if (itemOrder != 0) return itemOrder;
      return (a.courseCode ?? '').compareTo(b.courseCode ?? '');
    });
    return details;
  }
}
