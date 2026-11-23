import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'curriculum_rules.dart';
import 'curriculum_read_service.dart';

/// F07 - Quan ly CTDT, phien ban va lien ket Student <-> phien ban.
///
/// Endpoint chiu trach nhiem phan quyen (chi Admin) va truyen [actorId];
/// service chi chua nghiep vu de co the kiem thu tich hop truc tiep.
class CurriculumAdminService {
  CurriculumAdminService._();

  // ---------------------------------------------------------------------------
  // CTDT
  // ---------------------------------------------------------------------------

  static Future<List<AdminCurriculumDto>> listCurriculums(
    Session session, {
    String query = '',
  }) async {
    final keyword = query.trim();
    if (keyword.runes.length > 64) {
      throw AppException(
        code: 'INVALID_SEARCH_QUERY',
        message: 'Từ khóa tìm kiếm quá dài.',
      );
    }

    final List<Curriculum> curriculums;
    if (keyword.isEmpty) {
      curriculums = await Curriculum.db.find(
        session,
        orderBy: (t) => t.code,
        limit: 200,
      );
    } else {
      final pattern = '%${_escapeLike(keyword)}%';
      curriculums = await Curriculum.db.find(
        session,
        where: (t) =>
            t.code.ilike(pattern) |
            t.name.ilike(pattern) |
            t.majorCode.ilike(pattern),
        orderBy: (t) => t.code,
        limit: 200,
      );
    }

    final ids = curriculums.map((c) => c.id!).toSet();
    final versions = ids.isEmpty
        ? <CurriculumVersion>[]
        : await CurriculumVersion.db.find(
            session,
            where: (t) => t.curriculumId.inSet(ids),
            orderByList: (t) => [
              Order(column: t.effectiveYear, orderDescending: true),
              Order(column: t.versionCode),
            ],
          );
    final summaries = await _buildSummaries(session, versions);

    return [
      for (final c in curriculums)
        _toCurriculumDto(
          c,
          versions
              .where((v) => v.curriculumId == c.id)
              .map((v) => summaries[v.id!]!)
              .toList(),
        ),
    ];
  }

  static Future<AdminCurriculumDto> createCurriculum(
    Session session, {
    required int actorId,
    required String code,
    required String name,
    required String majorCode,
  }) async {
    final normalizedCode = requireCode(code, field: 'CURRICULUM');
    final normalizedName = requireName(name, field: 'CURRICULUM');
    final normalizedMajor = requireCode(majorCode, field: 'MAJOR');

    return session.db.transaction((tx) async {
      final existing = await Curriculum.db.findFirstRow(
        session,
        where: (t) => t.code.equals(normalizedCode),
        transaction: tx,
      );
      if (existing != null) {
        throw AppException(
          code: 'CURRICULUM_CODE_EXISTS',
          message: 'Mã CTĐT đã tồn tại.',
        );
      }

      final Curriculum saved;
      try {
        saved = await Curriculum.db.insertRow(
          session,
          Curriculum(
            code: normalizedCode,
            name: normalizedName,
            majorCode: normalizedMajor,
            status: CurriculumProgramStatus.active,
          ),
          transaction: tx,
        );
      } on DatabaseQueryException catch (e) {
        if (e.code == '23505') {
          throw AppException(
            code: 'CURRICULUM_CODE_EXISTS',
            message: 'Mã CTĐT đã tồn tại.',
          );
        }
        rethrow;
      }

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.curriculumCreated,
        details: 'curriculumId=${saved.id};code=$normalizedCode',
      );
      return _toCurriculumDto(saved, const []);
    });
  }

  // ---------------------------------------------------------------------------
  // Phien ban
  // ---------------------------------------------------------------------------

  /// Tao phien ban DRAFT moi; co the sao chep tu mot phien ban cung CTDT.
  static Future<AdminCurriculumVersionDetailDto> createDraftVersion(
    Session session, {
    required int actorId,
    required int curriculumId,
    required String versionCode,
    required int effectiveYear,
    int? copyFromVersionId,
  }) async {
    requirePositiveId(curriculumId, code: 'INVALID_CURRICULUM_ID');
    final code = requireCode(versionCode, field: 'VERSION');
    final year = requireYear(effectiveYear, code: 'INVALID_EFFECTIVE_YEAR');

    final newId = await session.db.transaction((tx) async {
      final curriculum = await Curriculum.db.findById(
        session,
        curriculumId,
        transaction: tx,
      );
      if (curriculum == null) throw _curriculumNotFound();
      if (curriculum.status != CurriculumProgramStatus.active) {
        throw AppException(
          code: 'CURRICULUM_INACTIVE',
          message: 'CTĐT đã ngừng hoạt động.',
        );
      }

      await _ensureVersionCodeFree(session, tx, curriculumId, code);

      CurriculumVersion? source;
      if (copyFromVersionId != null) {
        source = await CurriculumVersion.db.findById(
          session,
          copyFromVersionId,
          transaction: tx,
        );
        if (source == null || source.curriculumId != curriculumId) {
          throw AppException(
            code: 'SOURCE_VERSION_NOT_FOUND',
            message: 'Không tìm thấy phiên bản nguồn thuộc CTĐT này.',
          );
        }
      }

      final CurriculumVersion version;
      try {
        version = await CurriculumVersion.db.insertRow(
          session,
          CurriculumVersion(
            curriculumId: curriculumId,
            versionCode: code,
            effectiveYear: year,
            status: CurriculumVersionStatus.draft,
            totalCreditsRequired: source?.totalCreditsRequired,
            revision: 1,
          ),
          transaction: tx,
        );
      } on DatabaseQueryException catch (e) {
        if (e.code == '23505') throw _versionCodeExists();
        rethrow;
      }

      if (source != null) {
        await _copyContent(session, tx, from: source.id!, to: version.id!);
      }

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.versionCreated,
        details:
            'versionId=${version.id};curriculumId=$curriculumId;'
            'code=$code;copyFrom=${copyFromVersionId ?? '-'}',
      );
      return version.id!;
    });

    return getVersionDetail(session, newId);
  }

  /// Chi tiet CTDT dung chung kho truy van voi Student.
  /// Giu nguyen DTO cho cac man hinh Admin da su dung.
  static Future<AdminCurriculumVersionDetailDto> getVersionDetail(
    Session session,
    int versionId, {
    Transaction? transaction,
  }) async {
    requirePositiveId(versionId, code: 'INVALID_VERSION_ID');

    final snapshot = await CurriculumReadService.getByVersion(
      session,
      versionId,
      transaction: transaction,
    );
    if (snapshot == null) throw _versionNotFound();

    final itemDtos = snapshot.toAdminItems();
    var totalCredits = 0;
    var requiredCredits = 0;
    for (final item in itemDtos) {
      final credits = item.credits ?? 0;
      totalCredits += credits;
      if (item.isRequired) requiredCredits += credits;
    }

    final summaries = await _buildSummaries(
      session,
      [snapshot.version],
      transaction: transaction,
    );

    return AdminCurriculumVersionDetailDto(
      summary: summaries[versionId]!,
      curriculumCode: snapshot.curriculum.code,
      curriculumName: snapshot.curriculum.name,
      majorCode: snapshot.curriculum.majorCode,
      groups: snapshot.toAdminGroups(),
      items: itemDtos,
      totalItemCredits: totalCredits,
      requiredItemCredits: requiredCredits,
    );
  }

  /// Luu ban nhap: thay toan bo khoi kien thuc va hoc phan.
  /// Tin chi duoc chup lai tu Course tai thoi diem luu.
  static Future<AdminCurriculumVersionDetailDto> saveDraft(
    Session session, {
    required int actorId,
    required CurriculumDraftInput input,
  }) async {
    requirePositiveId(input.versionId, code: 'INVALID_VERSION_ID');
    final draft = validateDraftInput(input);

    await session.db.transaction((tx) async {
      final version = await CurriculumVersion.db.findById(
        session,
        input.versionId,
        transaction: tx,
      );
      if (version == null) throw _versionNotFound();
      ensureEditable(version.status);
      if (version.revision != input.expectedRevision) throw _conflict();

      if (draft.versionCode != version.versionCode) {
        await _ensureVersionCodeFree(
          session,
          tx,
          version.curriculumId,
          draft.versionCode,
        );
      }

      final courseIds = draft.items.map((i) => i.courseId).toSet();
      final courses = courseIds.isEmpty
          ? <Course>[]
          : await Course.db.find(
              session,
              where: (t) => t.id.inSet(courseIds),
              transaction: tx,
            );
      final courseById = {for (final c in courses) c.id!: c};
      final missing = courseIds.where((id) => !courseById.containsKey(id));
      if (missing.isNotEmpty) {
        throw AppException(
          code: 'COURSE_NOT_FOUND',
          message: 'Không tìm thấy môn học: ${missing.join(', ')}.',
        );
      }

      // Cap nhat co dieu kien: chong ghi de khi hai Admin luu dong thoi.
      final updated = await CurriculumVersion.db.updateWhere(
        session,
        columnValues: (t) => [
          t.versionCode(draft.versionCode),
          t.effectiveYear(draft.effectiveYear),
          t.totalCreditsRequired(draft.totalCreditsRequired),
          t.revision(version.revision + 1),
        ],
        where: (t) =>
            t.id.equals(version.id!) &
            t.revision.equals(input.expectedRevision) &
            t.status.equals(CurriculumVersionStatus.draft),
        transaction: tx,
      );
      if (updated.isEmpty) throw _conflict();

      await CurriculumItem.db.deleteWhere(
        session,
        where: (t) => t.curriculumVersionId.equals(version.id!),
        transaction: tx,
      );
      await CurriculumGroup.db.deleteWhere(
        session,
        where: (t) => t.curriculumVersionId.equals(version.id!),
        transaction: tx,
      );

      final groupIdByCode = <String, int>{};
      if (draft.groups.isNotEmpty) {
        final inserted = await CurriculumGroup.db.insert(
          session,
          [
            for (final g in draft.groups)
              CurriculumGroup(
                curriculumVersionId: version.id!,
                groupCode: g.groupCode,
                groupName: g.groupName,
                groupOrder: g.groupOrder,
              ),
          ],
          transaction: tx,
        );
        for (final g in inserted) {
          groupIdByCode[g.groupCode] = g.id!;
        }
      }

      if (draft.items.isNotEmpty) {
        await CurriculumItem.db.insert(
          session,
          [
            for (final i in draft.items)
              CurriculumItem(
                curriculumVersionId: version.id!,
                courseId: i.courseId,
                semester: i.semester,
                isRequired: i.isRequired,
                groupId: i.groupCode == null ? null : groupIdByCode[i.groupCode],
                itemOrder: i.itemOrder,
                credits: courseById[i.courseId]!.credits,
              ),
          ],
          transaction: tx,
        );
      }

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.versionDraftSaved,
        details:
            'versionId=${version.id};revision=${version.revision + 1};'
            'items=${draft.items.length};groups=${draft.groups.length}',
      );
    });

    return getVersionDetail(session, input.versionId);
  }

  /// Cong bo chinh thuc: DRAFT -> PUBLISHED, sau do noi dung bi khoa.
  static Future<AdminCurriculumVersionDetailDto> publishVersion(
    Session session, {
    required int actorId,
    required int versionId,
    required int expectedRevision,
  }) async {
    requirePositiveId(versionId, code: 'INVALID_VERSION_ID');

    await session.db.transaction((tx) async {
      final version = await CurriculumVersion.db.findById(
        session,
        versionId,
        transaction: tx,
      );
      if (version == null) throw _versionNotFound();
      ensureEditable(version.status);
      if (version.revision != expectedRevision) throw _conflict();

      final curriculum = await Curriculum.db.findById(
        session,
        version.curriculumId,
        transaction: tx,
      );
      if (curriculum == null) throw _curriculumNotFound();
      if (curriculum.status != CurriculumProgramStatus.active) {
        throw AppException(
          code: 'CURRICULUM_INACTIVE',
          message: 'CTĐT đã ngừng hoạt động.',
        );
      }

      final items = await CurriculumItem.db.find(
        session,
        where: (t) => t.curriculumVersionId.equals(versionId),
        transaction: tx,
      );
      final courseIds = items.map((i) => i.courseId).toSet();
      final courses = courseIds.isEmpty
          ? <Course>[]
          : await Course.db.find(
              session,
              where: (t) => t.id.inSet(courseIds),
              transaction: tx,
            );
      final courseById = {for (final c in courses) c.id!: c};

      // Mot CTDT khong co hai phien ban PUBLISHED cung nam hieu luc.
      final otherPublished = await CurriculumVersion.db.find(
        session,
        where: (t) =>
            t.curriculumId.equals(version.curriculumId) &
            t.status.equals(CurriculumVersionStatus.published) &
            t.id.notEquals(versionId),
        transaction: tx,
      );
      ensureEffectiveYearFree(
        effectiveYear: version.effectiveYear,
        otherPublished: otherPublished.map(
          (v) => VersionYearFact(
            id: v.id!,
            effectiveYear: v.effectiveYear,
            status: v.status,
          ),
        ),
      );

      validatePublishable(
        totalCreditsRequired: version.totalCreditsRequired,
        items: [
          for (final i in items)
            PublishItemFact(
              courseCode: courseById[i.courseId]?.code ?? '#${i.courseId}',
              credits: i.credits,
              isRequired: i.isRequired,
              courseActive: courseById[i.courseId]?.isActive ?? false,
            ),
        ],
      );

      final updated = await CurriculumVersion.db.updateWhere(
        session,
        columnValues: (t) => [
          t.status(CurriculumVersionStatus.published),
          t.publishedAt(DateTime.now().toUtc()),
          t.revision(version.revision + 1),
        ],
        where: (t) =>
            t.id.equals(versionId) &
            t.revision.equals(expectedRevision) &
            t.status.equals(CurriculumVersionStatus.draft),
        transaction: tx,
      );
      if (updated.isEmpty) throw _conflict();

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.versionPublished,
        details: 'versionId=$versionId;code=${version.versionCode}',
      );
    });

    return getVersionDetail(session, versionId);
  }

  /// PUBLISHED -> ARCHIVED. Sinh vien dang dung van giu phien ban;
  /// phien ban khong con duoc chon cho sinh vien moi.
  static Future<AdminCurriculumVersionDetailDto> archiveVersion(
    Session session, {
    required int actorId,
    required int versionId,
  }) async {
    requirePositiveId(versionId, code: 'INVALID_VERSION_ID');

    await session.db.transaction((tx) async {
      final version = await CurriculumVersion.db.findById(
        session,
        versionId,
        transaction: tx,
      );
      if (version == null) throw _versionNotFound();
      if (version.status != CurriculumVersionStatus.published) {
        throw AppException(
          code: 'INVALID_STATUS_TRANSITION',
          message: 'Chỉ lưu trữ được phiên bản đã công bố.',
        );
      }

      final updated = await CurriculumVersion.db.updateWhere(
        session,
        columnValues: (t) => [
          t.status(CurriculumVersionStatus.archived),
          t.revision(version.revision + 1),
        ],
        where: (t) =>
            t.id.equals(versionId) &
            t.status.equals(CurriculumVersionStatus.published),
        transaction: tx,
      );
      if (updated.isEmpty) throw _conflict();

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.versionArchived,
        details: 'versionId=$versionId;code=${version.versionCode}',
      );
    });

    return getVersionDetail(session, versionId);
  }

  /// Xoa phien ban DRAFT chua duoc su dung.
  static Future<bool> deleteDraftVersion(
    Session session, {
    required int actorId,
    required int versionId,
  }) async {
    requirePositiveId(versionId, code: 'INVALID_VERSION_ID');

    return session.db.transaction((tx) async {
      final version = await CurriculumVersion.db.findById(
        session,
        versionId,
        transaction: tx,
      );
      if (version == null) throw _versionNotFound();
      ensureEditable(version.status);

      final students = await Student.db.count(
        session,
        where: (t) => t.curriculumVersionId.equals(versionId),
        transaction: tx,
      );
      if (students > 0) {
        throw AppException(
          code: 'VERSION_IN_USE',
          message: 'Phiên bản đang được sử dụng, không thể xóa.',
        );
      }

      await CurriculumItem.db.deleteWhere(
        session,
        where: (t) => t.curriculumVersionId.equals(versionId),
        transaction: tx,
      );
      await CurriculumGroup.db.deleteWhere(
        session,
        where: (t) => t.curriculumVersionId.equals(versionId),
        transaction: tx,
      );
      await CurriculumVersion.db.deleteRow(session, version, transaction: tx);

      await _audit(
        session,
        tx,
        actorId: actorId,
        action: CurriculumAuditAction.versionDeleted,
        details: 'versionId=$versionId;code=${version.versionCode}',
      );
      return true;
    });
  }

  // ---------------------------------------------------------------------------
  // Chon phien ban theo nam hieu luc (hoc che tin chi)
  // ---------------------------------------------------------------------------

  /// Phien ban PUBLISHED co effectiveYear lon nhat <= [admissionYear]
  /// trong CTDT [curriculumId]; null neu khong co.
  static Future<int?> resolveVersionForAdmission(
    Session session, {
    required int curriculumId,
    required int admissionYear,
    Transaction? transaction,
  }) async {
    final versions = await CurriculumVersion.db.find(
      session,
      where: (t) =>
          t.curriculumId.equals(curriculumId) &
          t.status.equals(CurriculumVersionStatus.published),
      transaction: transaction,
    );
    return pickVersionForAdmission(
      versions.map(
        (v) => VersionYearFact(
          id: v.id!,
          effectiveYear: v.effectiveYear,
          status: v.status,
        ),
      ),
      admissionYear,
    );
  }

  /// Xem truoc phien ban se duoc gan cho sinh vien CTDT [curriculumCode]
  /// nhap hoc nam [admissionYear]. Dung cho man hinh cap tai khoan.
  static Future<AdminCurriculumVersionSummaryDto?> previewVersionForAdmission(
    Session session, {
    required String curriculumCode,
    required int admissionYear,
  }) async {
    final code = requireCode(curriculumCode, field: 'CURRICULUM');
    final year = requireYear(admissionYear, code: 'INVALID_ADMISSION_YEAR');
    final curriculum = await Curriculum.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );
    if (curriculum == null) throw _curriculumNotFound();

    final versionId = await resolveVersionForAdmission(
      session,
      curriculumId: curriculum.id!,
      admissionYear: year,
    );
    if (versionId == null) return null;
    final version = await CurriculumVersion.db.findById(session, versionId);
    if (version == null) return null;
    return (await _buildSummaries(session, [version]))[versionId];
  }

  // ---------------------------------------------------------------------------
  // Sinh vien <-> phien ban
  // ---------------------------------------------------------------------------

  static Future<StudentCurriculumAssignmentDto> getStudentAssignment(
    Session session,
    String studentCode, {
    Transaction? transaction,
  }) async {
    final student = await _findStudent(session, studentCode, transaction);
    return _toAssignmentDto(session, student, transaction);
  }

  /// Admin chu dich doi phien ban CTDT cua sinh vien (bat buoc ghi ly do).
  static Future<StudentCurriculumAssignmentDto> changeStudentVersion(
    Session session, {
    required int actorId,
    required String studentCode,
    required int versionId,
    required String reason,
  }) async {
    requirePositiveId(versionId, code: 'INVALID_VERSION_ID');
    final normalizedReason = requireReason(reason);

    return session.db.transaction((tx) async {
      final student = await _findStudent(session, studentCode, tx);
      if (student.curriculumVersionId == versionId) {
        return _toAssignmentDto(session, student, tx);
      }

      final version = await CurriculumVersion.db.findById(
        session,
        versionId,
        transaction: tx,
      );
      if (version == null) throw _versionNotFound();
      ensureAssignable(version.status);

      final curriculum = await Curriculum.db.findById(
        session,
        version.curriculumId,
        transaction: tx,
      );
      if (curriculum == null) throw _curriculumNotFound();

      // Nganh cua sinh vien = nganh cua CTDT dang theo hoc.
      // Cho phep doi sang CTDT khac CUNG nganh (vd dai tra -> CLC);
      // doi nganh la nghiep vu khac, khong xu ly o day.
      final currentMajor = await _majorOfVersion(
        session,
        student.curriculumVersionId,
        tx,
      );
      if (currentMajor != null && currentMajor != curriculum.majorCode) {
        throw AppException(
          code: 'MAJOR_MISMATCH',
          message:
              'Sinh viên thuộc ngành $currentMajor, phiên bản thuộc '
              'ngành ${curriculum.majorCode}.',
        );
      }

      final updated = await Student.db.updateRow(
        session,
        student.copyWith(curriculumVersionId: versionId),
        transaction: tx,
      );

      await _audit(
        session,
        tx,
        actorId: actorId,
        targetUserAccountId: student.userAccountId,
        action: CurriculumAuditAction.studentVersionChanged,
        details:
            'studentId=${student.id};from=${student.curriculumVersionId};'
            'to=$versionId;reason=$normalizedReason',
      );
      return _toAssignmentDto(session, updated, tx);
    });
  }

  /// Cap nhat nam nhap hoc cho sinh vien (vd: du lieu truoc F07).
  /// KHONG tu doi phien ban; Admin goi [changeStudentVersion] neu can.
  static Future<StudentCurriculumAssignmentDto> setStudentAdmissionYear(
    Session session, {
    required int actorId,
    required String studentCode,
    required int admissionYear,
  }) async {
    final year = requireYear(admissionYear, code: 'INVALID_ADMISSION_YEAR');

    return session.db.transaction((tx) async {
      final student = await _findStudent(session, studentCode, tx);
      final updated = await Student.db.updateRow(
        session,
        student.copyWith(admissionYear: year),
        transaction: tx,
      );
      await _audit(
        session,
        tx,
        actorId: actorId,
        targetUserAccountId: student.userAccountId,
        action: CurriculumAuditAction.studentAdmissionYearUpdated,
        details:
            'studentId=${student.id};year=${student.admissionYear}->$year',
      );
      return _toAssignmentDto(session, updated, tx);
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _escapeLike(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  static AppException _versionNotFound() => AppException(
    code: 'VERSION_NOT_FOUND',
    message: 'Không tìm thấy phiên bản CTĐT.',
  );

  static AppException _curriculumNotFound() => AppException(
    code: 'CURRICULUM_NOT_FOUND',
    message: 'Không tìm thấy CTĐT.',
  );

  static AppException _versionCodeExists() => AppException(
    code: 'VERSION_CODE_EXISTS',
    message: 'Mã phiên bản đã tồn tại trong CTĐT này.',
  );

  static AppException _conflict() => AppException(
    code: 'VERSION_CONFLICT',
    message: 'Dữ liệu đã bị thay đổi bởi người khác. Vui lòng tải lại.',
  );

  static Future<void> _ensureVersionCodeFree(
    Session session,
    Transaction tx,
    int curriculumId,
    String code,
  ) async {
    final dup = await CurriculumVersion.db.findFirstRow(
      session,
      where: (t) =>
          t.curriculumId.equals(curriculumId) & t.versionCode.equals(code),
      transaction: tx,
    );
    if (dup != null) throw _versionCodeExists();
  }

  static Future<void> _copyContent(
    Session session,
    Transaction tx, {
    required int from,
    required int to,
  }) async {
    final groups = await CurriculumGroup.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(from),
      transaction: tx,
    );
    final newGroupId = <int, int>{};
    for (final g in groups) {
      final copy = await CurriculumGroup.db.insertRow(
        session,
        CurriculumGroup(
          curriculumVersionId: to,
          groupCode: g.groupCode,
          groupName: g.groupName,
          groupOrder: g.groupOrder,
        ),
        transaction: tx,
      );
      newGroupId[g.id!] = copy.id!;
    }

    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(from),
      transaction: tx,
    );
    if (items.isEmpty) return;

    // Phien ban moi lay tin chi hien hanh cua Course (chup lai tai thoi diem tao).
    final courseIds = items.map((i) => i.courseId).toSet();
    final courses = await Course.db.find(
      session,
      where: (t) => t.id.inSet(courseIds),
      transaction: tx,
    );
    final creditsById = {for (final c in courses) c.id!: c.credits};

    await CurriculumItem.db.insert(
      session,
      [
        for (final i in items)
          CurriculumItem(
            curriculumVersionId: to,
            courseId: i.courseId,
            semester: i.semester,
            isRequired: i.isRequired,
            groupId: i.groupId == null ? null : newGroupId[i.groupId],
            itemOrder: i.itemOrder,
            credits: creditsById[i.courseId] ?? i.credits,
          ),
      ],
      transaction: tx,
    );
  }

  static Future<Map<int, AdminCurriculumVersionSummaryDto>> _buildSummaries(
    Session session,
    List<CurriculumVersion> versions, {
    Transaction? transaction,
  }) async {
    if (versions.isEmpty) return {};
    final result = <int, AdminCurriculumVersionSummaryDto>{};
    for (final v in versions) {
      final studentCount = await Student.db.count(
        session,
        where: (t) => t.curriculumVersionId.equals(v.id!),
        transaction: transaction,
      );
      result[v.id!] = AdminCurriculumVersionSummaryDto(
        id: v.id!,
        curriculumId: v.curriculumId,
        versionCode: v.versionCode,
        effectiveYear: v.effectiveYear,
        status: v.status,
        totalCreditsRequired: v.totalCreditsRequired,
        revision: v.revision,
        publishedAt: v.publishedAt,
        studentCount: studentCount,
      );
    }
    return result;
  }

  static AdminCurriculumDto _toCurriculumDto(
    Curriculum c,
    List<AdminCurriculumVersionSummaryDto> versions,
  ) => AdminCurriculumDto(
    id: c.id!,
    code: c.code,
    name: c.name,
    majorCode: c.majorCode,
    status: c.status,
    versions: versions,
  );

  static Future<String?> _majorOfVersion(
    Session session,
    int versionId,
    Transaction? tx,
  ) async {
    final version = await CurriculumVersion.db.findById(
      session,
      versionId,
      transaction: tx,
    );
    if (version == null) return null;
    final curriculum = await Curriculum.db.findById(
      session,
      version.curriculumId,
      transaction: tx,
    );
    return curriculum?.majorCode;
  }

  static Future<Student> _findStudent(
    Session session,
    String studentCode,
    Transaction? tx,
  ) async {
    final code = studentCode.trim();
    if (code.isEmpty) {
      throw AppException(
        code: 'INVALID_STUDENT_CODE',
        message: 'Mã sinh viên không hợp lệ.',
      );
    }
    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.studentCode.equals(code),
      transaction: tx,
    );
    if (student == null) {
      throw AppException(
        code: 'STUDENT_NOT_FOUND',
        message: 'Không tìm thấy sinh viên.',
      );
    }
    return student;
  }

  static Future<StudentCurriculumAssignmentDto> _toAssignmentDto(
    Session session,
    Student student,
    Transaction? tx,
  ) async {
    final version = await CurriculumVersion.db.findById(
      session,
      student.curriculumVersionId,
      transaction: tx,
    );
    final curriculum = version == null
        ? null
        : await Curriculum.db.findById(
            session,
            version.curriculumId,
            transaction: tx,
          );

    int? suggestedVersionId;
    if (curriculum != null && student.admissionYear != null) {
      suggestedVersionId = await resolveVersionForAdmission(
        session,
        curriculumId: curriculum.id!,
        admissionYear: student.admissionYear!,
        transaction: tx,
      );
    }

    return StudentCurriculumAssignmentDto(
      studentId: student.id!,
      studentCode: student.studentCode,
      admissionYear: student.admissionYear,
      curriculumVersionId: student.curriculumVersionId,
      curriculumCode: curriculum?.code ?? '',
      majorCode: curriculum?.majorCode ?? '',
      versionCode: version?.versionCode ?? '',
      versionStatus: version?.status ?? '',
      suggestedVersionId: suggestedVersionId,
    );
  }

  static Future<void> _audit(
    Session session,
    Transaction tx, {
    required int actorId,
    required String action,
    String? details,
    int? targetUserAccountId,
  }) async {
    await AuditLog.db.insertRow(
      session,
      AuditLog(
        actorUserAccountId: actorId,
        targetUserAccountId: targetUserAccountId,
        action: action,
        createdAt: DateTime.now().toUtc(),
        details: details,
      ),
      transaction: tx,
    );
  }
}
