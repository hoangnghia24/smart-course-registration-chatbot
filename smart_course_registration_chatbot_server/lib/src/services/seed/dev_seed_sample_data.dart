import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'k26_curriculum_data.dart';

/// Development data seeder.
/// - Preserves the original DEV-CNTT demo seed, only when app_course is empty.
/// - Optionally adds three K26 2026 draft curricula with a separate transaction.
/// - Reuses existing Course codes; does NOT overwrite existing records.
/// - Does NOT create AuthUser/UserAccount or reassign students.
/// IMPORTANT: run only in development mode (guarded by caller in server.dart).
/// K26 requires SEED_K26_CURRICULA=true to opt in.
class DevSeedSampleData {
  static Future<void> run(Session session) async {
    final insertedCourses = await session.db.transaction((transaction) async {
      // An existing catalog belongs to the application/user, not this seeder.
      // Check INSIDE the transaction so unsuccessful seed runs roll back cleanly.
      final existingCourse = await Course.db.findFirstRow(
        session,
        transaction: transaction,
      );
      if (existingCourse != null) return 0;

      // Reuse the DEV IDs created by the existing DevSeedAccounts implementation.
      // Never update an existing curriculum or version.
      final existingCurriculum = await Curriculum.db.findFirstRow(
        session,
        where: (t) => t.code.equals('DEV-CNTT'),
        transaction: transaction,
      );
      final curriculum =
          existingCurriculum ??
          await Curriculum.db.insertRow(
            session,
            Curriculum(
              code: 'DEV-CNTT',
              name: 'Chương trình thử nghiệm - KHÔNG CHÍNH THỨC',
              majorCode: 'DEV',
              status: 'ACTIVE',
            ),
            transaction: transaction,
          );

      final existingVersion = await CurriculumVersion.db.findFirstRow(
        session,
        where: (t) =>
            t.curriculumId.equals(curriculum.id!) &
            t.versionCode.equals('DEV-2026'),
        transaction: transaction,
      );
      final version =
          existingVersion ??
          await CurriculumVersion.db.insertRow(
            session,
            CurriculumVersion(
              curriculumId: curriculum.id!,
              versionCode: 'DEV-2026',
              effectiveYear: 2026,
              // F07: phien ban mau da cong bo de co the gan sinh vien.
              status: 'PUBLISHED',
              // Tong tin chi = tong tin chi cac hoc phan trong CTDT mau.
              totalCreditsRequired: _sampleCourses
                  .where((s) => s.semester != null)
                  .fold<int>(0, (sum, s) => sum + s.credits),
              publishedAt: DateTime.now().toUtc(),
            ),
            transaction: transaction,
          );

      for (final spec in _sampleCourses) {
        final course = await Course.db.insertRow(
          session,
          Course(
            code: spec.code,
            name: spec.name,
            credits: spec.credits,
            description: spec.description,
            isActive: spec.isActive,
          ),
          transaction: transaction,
        );

        // Retired courses are intentionally NOT assigned to the curriculum.
        if (spec.semester != null) {
          await CurriculumItem.db.insertRow(
            session,
            CurriculumItem(
              curriculumVersionId: version.id!,
              courseId: course.id!,
              semester: spec.semester!,
              isRequired: spec.isRequired,
              credits: spec.credits,
            ),
            transaction: transaction,
          );
        }
      }
      return _sampleCourses.length;
    });

    if (insertedCourses == 0) {
      stdout.writeln(
        '[DEV DATA SEED] Demo catalog skipped (app_course is not empty). '
        'Existing rows remain unchanged.',
      );
    } else {
      stdout.writeln(
        '[DEV DATA SEED] Inserted $insertedCourses demo courses, '
        'using DEV-CNTT / DEV-2026.',
      );
    }

    // Important: K26 is independent of the OLD demo catalog guard above.
    // Therefore it can be added to a database that already has courses.
    // Always opt in explicitly because the current PDF-derived set is INCOMPLETE.
    final importK26 =
        Platform.environment['SEED_K26_CURRICULA']?.trim().toLowerCase() ==
        'true';
    if (importK26) {
      await _seedK26DraftCurriculums(session);
    } else {
      stdout.writeln(
        '[K26 SEED] Disabled. Set SEED_K26_CURRICULA=true in DEV '
        'to import draft 2026 curricula.',
      );
    }
  }

  /// Seed only the reviewed subset of the three PDF-derived 2026 curricula.
  /// Never updates existing Course/Curriculum/Version/Student rows.
  /// - One Course row per code, reused by multiple CurriculumItems.
  /// - New CurriculumVersions are DRAFT because electives/credits/aliases need review.
  /// - A pre-existing version is not touched (even if empty).
  /// - A single transaction prevents partially imported K26 data on failure.
  static Future<void> _seedK26DraftCurriculums(Session session) async {
    final summary = await session.db.transaction((transaction) async {
      final requestedCodes = K26CurriculumData.courses
          .map((spec) => spec.code)
          .toSet();
      final currentCourses = await Course.db.find(
        session,
        where: (t) => t.code.inSet(requestedCodes),
        transaction: transaction,
      );
      final coursesByCode = <String, Course>{
        for (final course in currentCourses) course.code: course,
      };

      final newCourses = <Course>[];
      var differentExistingName = 0;
      var existingInactive = 0;

      for (final spec in K26CurriculumData.courses) {
        final existing = coursesByCode[spec.code];
        if (existing != null) {
          if (existing.credits != spec.credits) {
            throw AppException(
              code: 'K26_COURSE_CREDITS_CONFLICT',
              message: 'Mon ${spec.code}: ${existing.credits} TC in DB, '
                  '${spec.credits} TC in approved source. '
                  'Review manually; seed rolled back.',
            );
          }
          if (existing.name.trim().toLowerCase() !=
              spec.name.trim().toLowerCase()) {
            differentExistingName++;
          }
          if (!existing.isActive) existingInactive++;
          continue;
        }

        newCourses.add(
          Course(
            code: spec.code,
            name: spec.name,
            credits: spec.credits,
            description: null,
            isActive: true,
          ),
        );
      }

      if (newCourses.isNotEmpty) {
        final inserted = await Course.db.insert(
          session,
          newCourses,
          transaction: transaction,
        );
        for (final course in inserted) {
          coursesByCode[course.code] = course;
        }
      }

      var createdPrograms = 0;
      var createdVersions = 0;
      var createdItems = 0;
      var skippedVersions = 0;
      var createdGroups = 0;

      for (final program in K26CurriculumData.programs) {
        var curriculum = await Curriculum.db.findFirstRow(
          session,
          where: (t) => t.code.equals(program.code),
          transaction: transaction,
        );
        if (curriculum != null) {
          if (curriculum.majorCode != program.majorCode) {
            throw AppException(
              code: 'K26_CURRICULUM_CODE_CONFLICT',
              message: 'CTDT ${program.code} has another majorCode. '
                  'Do not overwrite existing data.',
            );
          }
        } else {
          curriculum = await Curriculum.db.insertRow(
            session,
            Curriculum(
              code: program.code,
              name: program.name,
              majorCode: program.majorCode,
              status: 'ACTIVE',
            ),
            transaction: transaction,
          );
          createdPrograms++;
        }

        // findFirstRow returns Curriculum?; after find/create it must exist.
        final curriculumId = curriculum!.id!;

        final oldVersion = await CurriculumVersion.db.findFirstRow(
          session,
          where: (t) =>
              t.curriculumId.equals(curriculumId) &
              t.versionCode.equals(K26CurriculumData.versionCode),
          transaction: transaction,
        );
        if (oldVersion != null) {
          // Don't mutate an existing draft/published/archived version.
          skippedVersions++;
          continue;
        }

        final version = await CurriculumVersion.db.insertRow(
          session,
          CurriculumVersion(
            curriculumId: curriculumId,
            versionCode: K26CurriculumData.versionCode,
            effectiveYear: K26CurriculumData.effectiveYear,
            status: K26CurriculumData.seedVersionStatus,
            totalCreditsRequired: K26CurriculumData.publishedDegreeCredits,
            revision: 1,
          ),
          transaction: transaction,
        );
        createdVersions++;

        // Optional specialization tracks are grouping hints, NOT mandatory.
        // Other rows have no group because knowledge blocks have not been
        // independently verified against the full PDF curriculum tables.
        final groupNames = <String, String>{
          'CN-PM': 'Chuyên ngành Công nghệ phần mềm (lựa chọn)',
          'CN-HTTT': 'Chuyên ngành Hệ thống thông tin (lựa chọn)',
          'CN-AI': 'Chuyên ngành Trí tuệ nhân tạo (lựa chọn)',
        };
        final programItems = K26CurriculumData.items
            .where((spec) => spec.programCode == program.code)
            .toList();
        final usedGroupCodes = programItems
            .where((spec) => spec.groupCode != null)
            .map((spec) => spec.groupCode!)
            .toSet();
        final groupIds = <String, int>{};
        var groupOrder = 10;
        for (final groupCode in (usedGroupCodes.toList()..sort())) {
          final group = await CurriculumGroup.db.insertRow(
            session,
            CurriculumGroup(
              curriculumVersionId: version.id!,
              groupCode: groupCode,
              groupName: groupNames[groupCode] ?? groupCode,
              groupOrder: groupOrder,
            ),
            transaction: transaction,
          );
          groupIds[groupCode] = group.id!;
          groupOrder += 10;
          createdGroups++;
        }

        final toInsert = <CurriculumItem>[];
        for (final spec in programItems) {
          final course = coursesByCode[spec.courseCode];
          if (course == null || course.id == null) {
            throw AppException(
              code: 'K26_COURSE_MISSING',
              message: 'Missing Course ${spec.courseCode} for ${program.code}.',
            );
          }
          if (course.credits != spec.credits) {
            throw AppException(
              code: 'K26_ITEM_CREDITS_CONFLICT',
              message: 'Credits mismatch for ${spec.courseCode}.',
            );
          }
          toInsert.add(
            CurriculumItem(
              curriculumVersionId: version.id!,
              courseId: course.id!,
              semester: spec.semester,
              isRequired: spec.isRequired,
              groupId: spec.groupCode == null
                  ? null
                  : groupIds[spec.groupCode],
              itemOrder: spec.itemOrder,
              credits: spec.credits,
            ),
          );
        }
        if (toInsert.isNotEmpty) {
          await CurriculumItem.db.insert(
            session,
            toInsert,
            transaction: transaction,
          );
          createdItems += toInsert.length;
        }
      }

      return <String, int>{
        'createdCourses': newCourses.length,
        'nameDifferences': differentExistingName,
        'inactiveExisting': existingInactive,
        'createdPrograms': createdPrograms,
        'createdVersions': createdVersions,
        'createdGroups': createdGroups,
        'createdItems': createdItems,
        'skippedVersions': skippedVersions,
      };
    });

    stdout.writeln(
      '[K26 SEED] Draft import complete: '
      'new courses=${summary['createdCourses']}, '
      'new programs=${summary['createdPrograms']}, '
      'new versions=${summary['createdVersions']}, '
      'new groups=${summary['createdGroups']}, '
      'new items=${summary['createdItems']}, '
      'existing versions untouched=${summary['skippedVersions']}.',
    );
    if (summary['nameDifferences']! > 0 || summary['inactiveExisting']! > 0) {
      stdout.writeln(
        '[K26 SEED] Review existing catalog: '
        'different names=${summary['nameDifferences']}, '
        'inactive courses=${summary['inactiveExisting']}. '
        'No pre-existing records were changed.',
      );
    }
    stdout.writeln(
      '[K26 SEED] These versions are DRAFT and incomplete: '
      'not suitable for Rule Engine graduation checks or automatic assignment.',
    );
  }
}

/// `semester == null` means the course is outside this demo curriculum.
class _SampleCourse {
  const _SampleCourse(
    this.code,
    this.name,
    this.credits,
    this.semester, {
    this.isRequired = true,
    this.isActive = true,
    this.description,
  });

  final String code;
  final String name;
  final int credits;
  final int? semester;
  final bool isRequired;
  final bool isActive;
  final String? description;
}

const _sampleCourses = <_SampleCourse>[
  // Semester 1
  _SampleCourse(
    'IT101',
    'Nhập môn Công nghệ thông tin',
    3,
    1,
    description: 'Tổng quan ngành CNTT, nghề nghiệp và kỹ năng số.',
  ),
  _SampleCourse(
    'IT102',
    'Tin học cơ sở',
    3,
    1,
    description: 'Sử dụng máy tính, ứng dụng văn phòng và dữ liệu.',
  ),
  _SampleCourse(
    'MTH101',
    'Toán cao cấp A1',
    3,
    1,
    description: 'Giới hạn, đạo hàm, tích phân và ứng dụng.',
  ),
  _SampleCourse(
    'SKL101',
    'Kỹ năng học đại học',
    2,
    1,
    description: 'Học tập tự chủ, cộng tác và thuyết trình.',
  ),
  _SampleCourse(
    'ENG101',
    'Tiếng Anh 1',
    3,
    1,
    description: 'Tiếng Anh giao tiếp và học thuật căn bản.',
  ),

  // Semester 2
  _SampleCourse(
    'IT105',
    'Lập trình căn bản',
    4,
    2,
    description: 'Biến, rẽ nhánh, vòng lặp, hàm và kiểm thử.',
  ),
  _SampleCourse(
    'MTH102',
    'Toán rời rạc',
    3,
    2,
    description: 'Logic, tập hợp, quan hệ, đồ thị và tổ hợp.',
  ),
  _SampleCourse(
    'IT106',
    'Kiến trúc máy tính',
    3,
    2,
    description: 'CPU, bộ nhớ, hệ thống số và tập lệnh.',
  ),
  _SampleCourse(
    'ENG102',
    'Tiếng Anh 2',
    3,
    2,
    description: 'Tiếng Anh cho môi trường học tập chuyên ngành.',
  ),
  _SampleCourse(
    'PHY101',
    'Vật lý đại cương',
    3,
    2,
    description: 'Kiến thức vật lý nền tảng cho công nghệ.',
  ),

  // Semester 3
  _SampleCourse(
    'IT201',
    'Lập trình hướng đối tượng',
    4,
    3,
    description: 'Lớp, đối tượng, kế thừa và đa hình.',
  ),
  _SampleCourse(
    'IT202',
    'Cấu trúc dữ liệu và giải thuật',
    4,
    3,
    description: 'Danh sách, cây, đồ thị và thuật toán phổ biến.',
  ),
  _SampleCourse(
    'IT203',
    'Cơ sở dữ liệu',
    4,
    3,
    description: 'Mô hình quan hệ, SQL và chuẩn hóa dữ liệu.',
  ),
  _SampleCourse(
    'IT204',
    'Mạng máy tính',
    3,
    3,
    description: 'Mô hình TCP/IP, địa chỉ mạng và giao thức.',
  ),
  _SampleCourse(
    'IT205',
    'Hệ điều hành',
    3,
    3,
    description: 'Tiến trình, bộ nhớ, luồng và hệ thống tệp.',
  ),

  // Semester 4
  _SampleCourse(
    'IT206',
    'Phát triển ứng dụng Web',
    4,
    4,
    description: 'HTML, CSS, JavaScript và dịch vụ web.',
  ),
  _SampleCourse(
    'IT207',
    'Công nghệ phần mềm',
    3,
    4,
    description: 'Phân tích yêu cầu, thiết kế và quy trình phát triển.',
  ),
  _SampleCourse(
    'IT208',
    'Thiết kế và phân tích thuật toán',
    3,
    4,
    description: 'Độ phức tạp và các chiến lược thuật toán.',
  ),
  _SampleCourse(
    'MTH201',
    'Xác suất thống kê',
    3,
    4,
    description: 'Xác suất, ước lượng và kiểm định thống kê.',
  ),
  _SampleCourse(
    'IT210',
    'Nhập môn trí tuệ nhân tạo',
    3,
    4,
    isRequired: false,
    description: 'Tìm kiếm trạng thái, biểu diễn tri thức và AI cơ bản.',
  ),

  // Semester 5
  _SampleCourse(
    'IT301',
    'Phát triển ứng dụng di động',
    4,
    5,
    description: 'Thiết kế ứng dụng đa nền tảng và trải nghiệm di động.',
  ),
  _SampleCourse(
    'IT302',
    'An toàn và bảo mật thông tin',
    3,
    5,
    description: 'Mã hóa, xác thực, phân quyền và bảo vệ dữ liệu.',
  ),
  _SampleCourse(
    'IT303',
    'Cơ sở dữ liệu nâng cao',
    3,
    5,
    description: 'Tối ưu truy vấn, giao dịch và chỉ mục.',
  ),
  _SampleCourse(
    'IT304',
    'Điện toán đám mây',
    3,
    5,
    isRequired: false,
    description: 'Dịch vụ cloud, triển khai và giám sát ứng dụng.',
  ),
  _SampleCourse(
    'IT305',
    'Thiết kế giao diện UI/UX',
    3,
    5,
    description: 'Nghiên cứu người dùng, nguyên mẫu và kiểm thử UX.',
  ),

  // Semester 6
  _SampleCourse(
    'IT306',
    'Học máy',
    4,
    6,
    description: 'Học có giám sát, không giám sát và đánh giá mô hình.',
  ),
  _SampleCourse(
    'IT307',
    'Phát triển API và Backend',
    4,
    6,
    description: 'REST API, xác thực, kiểm thử và cơ sở dữ liệu.',
  ),
  _SampleCourse(
    'IT308',
    'DevOps và triển khai phần mềm',
    3,
    6,
    description: 'CI/CD, container và tự động hóa triển khai.',
  ),
  _SampleCourse(
    'IT309',
    'Khai phá dữ liệu',
    3,
    6,
    isRequired: false,
    description: 'Tiền xử lý, phân cụm và khai thác mẫu dữ liệu.',
  ),
  _SampleCourse(
    'IT310',
    'Quản lý dự án phần mềm',
    3,
    6,
    description: 'Lập kế hoạch, quản trị rủi ro và Agile.',
  ),

  // Semester 7
  _SampleCourse(
    'IT401',
    'Thực tập doanh nghiệp',
    4,
    7,
    description: 'Thực hành công việc thực tế dưới sự hướng dẫn.',
  ),
  _SampleCourse(
    'IT402',
    'Đồ án chuyên ngành',
    4,
    7,
    description: 'Xây dựng sản phẩm phần mềm theo nhóm.',
  ),
  _SampleCourse(
    'IT403',
    'Ứng dụng trí tuệ nhân tạo',
    3,
    7,
    isRequired: false,
    description: 'Triển khai mô hình AI trong các bài toán thực tế.',
  ),
  _SampleCourse(
    'IT404',
    'Công nghệ Blockchain căn bản',
    3,
    7,
    isRequired: false,
    description: 'Sổ cái phân tán và hợp đồng thông minh.',
  ),

  // Semester 8
  _SampleCourse(
    'IT405',
    'Khóa luận tốt nghiệp',
    8,
    8,
    description: 'Nghiên cứu và xây dựng sản phẩm tốt nghiệp.',
  ),
  _SampleCourse(
    'IT406',
    'Kiểm thử phần mềm',
    3,
    8,
    description: 'Unit test, integration test và kiểm thử tự động.',
  ),
  _SampleCourse(
    'IT407',
    'Khởi nghiệp và đổi mới sáng tạo số',
    2,
    8,
    isRequired: false,
    description: 'Mô hình kinh doanh, thử nghiệm ý tưởng sản phẩm.',
  ),

  // Inactive records intentionally outside the demo curriculum.
  _SampleCourse(
    'OLD101',
    'Lập trình Pascal (ngừng mở)',
    3,
    null,
    isActive: false,
    description: 'Dùng để kiểm thử phân quyền tìm kiếm và xóa mềm.',
  ),
  _SampleCourse(
    'OLD102',
    'Công nghệ Flash (ngừng mở)',
    2,
    null,
    isActive: false,
    description: 'Dùng để kiểm thử danh sách môn không hoạt động.',
  ),
];
