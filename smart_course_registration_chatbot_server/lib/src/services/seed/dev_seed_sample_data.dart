import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'k26_curriculum_data.dart';
import '../auth/school_account_provisioner.dart';
import '../auth/dev_seed_accounts.dart';

/// Development data seeder.
/// - Reconciles the owned DEV-CNTT demo rows one record at a time.
/// - Optionally adds three K26 2026 draft curricula with a separate transaction.
/// - Reuses existing Course codes and never deletes application data.
/// - Opt-in RAG student fixtures create login accounts, terms and sections.
///   Never reassign existing students or overwrite existing published versions.
/// - All RAG fixtures are partial and only for an isolated development DB.
/// IMPORTANT: run only in development mode (guarded by caller in server.dart).
/// K26 requires SEED_K26_CURRICULA=true to opt in.
class DevSeedSampleData {
  static Future<void> run(Session session) async {
    final summary = await _seedDemoCatalog(session);
    stdout.writeln(
      '[DEV DATA SEED] DEV-CNTT/DEV-2026 ready: '
      'courses created=${summary['createdCourses']}, '
      'courses updated=${summary['updatedCourses']}, '
      'items created=${summary['createdItems']}, '
      'items updated=${summary['updatedItems']}.',
    );

    // Important: K26 is independent of the OLD demo catalog guard above.
    // Therefore it can be added to a database that already has courses.
    // Always opt in explicitly because the current PDF-derived set is INCOMPLETE.
    final importK26 = Platform.environment['SEED_K26_CURRICULA']?.trim().toLowerCase() == 'true';
    if (importK26) {
      await _seedK26DraftCurriculums(session);
    } else {
      stdout.writeln(
        '[K26 SEED] Disabled. Set SEED_K26_CURRICULA=true in DEV '
        'to import draft 2026 curricula.',
      );
    }
  }

  /// Run after [DevSeedAccounts] so sections can reference real DEV profiles.
  static Future<void> runOperationalData(Session session) async {
    if (!_devAccountSeedEnabled) {
      stdout.writeln(
        '[DEV OPERATIONAL SEED] Disabled. Requires APP_ENV=development and '
        'ALLOW_DEV_SEED=true.',
      );
      return;
    }

    await _seedDemoTermsAndSections(session);

    if (!_ragFixturesEnabled) {
      stdout.writeln(
        '[RAG SEED] Disabled. Requires APP_ENV=development, '
        'ALLOW_DEV_SEED=true and SEED_RAG_STUDENTS=true.',
      );
      return;
    }
    stdout.writeln('[RAG SEED] Starting K23/K26 fixture import.');
    await seedRagStudents(session);
    await seedRagSections(session);
    stdout.writeln('[RAG SEED] Completed K23/K26 fixture import.');
  }

  static Future<Map<String, int>> _seedDemoCatalog(Session session) async {
    return session.db.transaction((transaction) async {
      const curriculumName = 'Chương trình thử nghiệm - KHÔNG CHÍNH THỨC';
      final now = DateTime.now().toUtc();
      final totalCredits = _sampleCourses.where((spec) => spec.semester != null).fold<int>(0, (sum, spec) => sum + spec.credits);

      var curriculum = await Curriculum.db.findFirstRow(
        session,
        where: (t) => t.code.equals('DEV-CNTT'),
        transaction: transaction,
      );
      if (curriculum == null) {
        curriculum = await Curriculum.db.insertRow(
          session,
          Curriculum(
            code: 'DEV-CNTT',
            name: curriculumName,
            majorCode: 'DEV',
            status: 'ACTIVE',
          ),
          transaction: transaction,
        );
      } else if (curriculum.name != curriculumName || curriculum.majorCode != 'DEV' || curriculum.status != 'ACTIVE') {
        curriculum = await Curriculum.db.updateRow(
          session,
          curriculum.copyWith(
            name: curriculumName,
            majorCode: 'DEV',
            status: 'ACTIVE',
          ),
          transaction: transaction,
        );
      }

      var version = await CurriculumVersion.db.findFirstRow(
        session,
        where: (t) => t.curriculumId.equals(curriculum!.id!) & t.versionCode.equals('DEV-2026'),
        transaction: transaction,
      );
      if (version == null) {
        version = await CurriculumVersion.db.insertRow(
          session,
          CurriculumVersion(
            curriculumId: curriculum.id!,
            versionCode: 'DEV-2026',
            effectiveYear: 2026,
            status: 'PUBLISHED',
            totalCreditsRequired: totalCredits,
            publishedAt: now,
          ),
          transaction: transaction,
        );
      } else if (version.effectiveYear != 2026 || version.status != 'PUBLISHED' || version.totalCreditsRequired != totalCredits || version.publishedAt == null) {
        version = await CurriculumVersion.db.updateRow(
          session,
          version.copyWith(
            effectiveYear: 2026,
            status: 'PUBLISHED',
            totalCreditsRequired: totalCredits,
            publishedAt: version.publishedAt ?? now,
          ),
          transaction: transaction,
        );
      }
      final versionId = version.id!;

      final requestedCodes = _sampleCourses.map((spec) => spec.code).toSet();
      final existingCourses = await Course.db.find(
        session,
        where: (t) => t.code.inSet(requestedCodes),
        transaction: transaction,
      );
      final coursesByCode = <String, Course>{
        for (final course in existingCourses) course.code: course,
      };
      var createdCourses = 0;
      var updatedCourses = 0;
      for (final spec in _sampleCourses) {
        var course = coursesByCode[spec.code];
        if (course == null) {
          course = await Course.db.insertRow(
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
          createdCourses++;
        } else if (course.name != spec.name || course.credits != spec.credits || course.description != spec.description || course.isActive != spec.isActive) {
          course = await Course.db.updateRow(
            session,
            course.copyWith(
              name: spec.name,
              credits: spec.credits,
              description: spec.description,
              isActive: spec.isActive,
            ),
            transaction: transaction,
          );
          updatedCourses++;
        }
        coursesByCode[spec.code] = course;
      }

      final existingItems = await CurriculumItem.db.find(
        session,
        where: (t) => t.curriculumVersionId.equals(versionId),
        transaction: transaction,
      );
      final itemsByCourseId = <int, CurriculumItem>{
        for (final item in existingItems) item.courseId: item,
      };
      final orderBySemester = <int, int>{};
      var createdItems = 0;
      var updatedItems = 0;
      for (final spec in _sampleCourses.where(
        (spec) => spec.semester != null,
      )) {
        final semester = spec.semester!;
        final itemOrder = (orderBySemester[semester] ?? 0) + 1;
        orderBySemester[semester] = itemOrder;
        final course = coursesByCode[spec.code]!;
        final existing = itemsByCourseId[course.id!];
        if (existing == null) {
          await CurriculumItem.db.insertRow(
            session,
            CurriculumItem(
              curriculumVersionId: versionId,
              courseId: course.id!,
              semester: semester,
              isRequired: spec.isRequired,
              itemOrder: itemOrder,
              credits: spec.credits,
            ),
            transaction: transaction,
          );
          createdItems++;
        } else if (existing.semester != semester || existing.isRequired != spec.isRequired || existing.itemOrder != itemOrder || existing.credits != spec.credits) {
          await CurriculumItem.db.updateRow(
            session,
            existing.copyWith(
              semester: semester,
              isRequired: spec.isRequired,
              itemOrder: itemOrder,
              credits: spec.credits,
            ),
            transaction: transaction,
          );
          updatedItems++;
        }
      }

      return <String, int>{
        'createdCourses': createdCourses,
        'updatedCourses': updatedCourses,
        'createdItems': createdItems,
        'updatedItems': updatedItems,
      };
    });
  }

  /// Seed only the reviewed subset of the three PDF-derived 2026 curricula.
  /// Never updates existing Course/Curriculum/Version/Student rows.
  /// - One Course row per code, reused by multiple CurriculumItems.
  /// - New CurriculumVersions are DRAFT because electives/credits/aliases need review.
  /// - A pre-existing version is not touched (even if empty).
  /// - A single transaction prevents partially imported K26 data on failure.
  static Future<void> _seedK26DraftCurriculums(Session session) async {
    final summary = await session.db.transaction((transaction) async {
      final requestedCodes = K26CurriculumData.courses.map((spec) => spec.code).toSet();
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
              message:
                  'Mon ${spec.code}: ${existing.credits} TC in DB, '
                  '${spec.credits} TC in approved source. '
                  'Review manually; seed rolled back.',
            );
          }
          if (existing.name.trim().toLowerCase() != spec.name.trim().toLowerCase()) {
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
              message:
                  'CTDT ${program.code} has another majorCode. '
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
        final curriculumId = curriculum.id!;

        final oldVersion = await CurriculumVersion.db.findFirstRow(
          session,
          where: (t) => t.curriculumId.equals(curriculumId) & t.versionCode.equals(K26CurriculumData.versionCode),
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
        final programItems = K26CurriculumData.items.where((spec) => spec.programCode == program.code).toList();
        final usedGroupCodes = programItems.where((spec) => spec.groupCode != null).map((spec) => spec.groupCode!).toSet();
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
              groupId: spec.groupCode == null ? null : groupIds[spec.groupCode],
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

  static bool _flag(String key) => Platform.environment[key]?.trim().toLowerCase() == 'true';

  static bool get _devAccountSeedEnabled => Platform.environment['APP_ENV']?.trim().toLowerCase() == 'development' && _flag('ALLOW_DEV_SEED');

  static bool get _ragFixturesEnabled => _devAccountSeedEnabled && _flag('SEED_RAG_STUDENTS');

  /// Seeds two deterministic academic terms and the matching sections for the
  /// owned DEV curriculum. Existing non-DEV rows are never changed.
  static Future<void> _seedDemoTermsAndSections(Session session) async {
    final lecturer = await Lecturer.db.findFirstRow(
      session,
      where: (t) => t.lecturerCode.equals('DEV-GV001'),
    );
    if (lecturer == null) {
      stdout.writeln(
        '[DEV OPERATIONAL SEED] Lecturer DEV-GV001 is missing; terms and '
        'sections were skipped. Configure SEED_LECTURER_EMAIL/PASSWORD.',
      );
      return;
    }
    if (lecturer.teachingStatus != LecturerStatus.active) {
      stdout.writeln(
        '[DEV OPERATIONAL SEED] Lecturer DEV-GV001 is not active; terms and '
        'sections were skipped.',
      );
      return;
    }

    final lecturerAccount = await UserAccount.db.findById(
      session,
      lecturer.userAccountId,
    );
    if (lecturerAccount?.role != AccountRole.lecturer || lecturerAccount?.status != AccountStatus.active) {
      stdout.writeln(
        '[DEV OPERATIONAL SEED] DEV-GV001 does not have an active lecturer '
        'account; terms and sections were skipped.',
      );
      return;
    }

    final now = DateTime.now().toUtc();
    final summary = await session.db.transaction((transaction) async {
      final curriculum = await Curriculum.db.findFirstRow(
        session,
        where: (t) => t.code.equals('DEV-CNTT'),
        transaction: transaction,
      );
      final version = curriculum == null
          ? null
          : await CurriculumVersion.db.findFirstRow(
              session,
              where: (t) => t.curriculumId.equals(curriculum.id!) & t.versionCode.equals('DEV-2026'),
              transaction: transaction,
            );
      if (version == null || version.status != 'PUBLISHED') {
        throw StateError(
          'DEV-CNTT/DEV-2026 must be published before operational seeding.',
        );
      }

      var backfilledStudents = 0;
      final student = await Student.db.findFirstRow(
        session,
        where: (t) => t.studentCode.equals('DEV-SV001'),
        transaction: transaction,
      );
      if (student != null && student.curriculumVersionId == version.id && student.admissionYear == null) {
        await Student.db.updateRow(
          session,
          student.copyWith(admissionYear: 2026),
          transaction: transaction,
        );
        backfilledStudents++;
      }

      final termSpecs =
          <
            ({
              int semester,
              String academicYear,
              String termName,
              DateTime startAt,
              DateTime endAt,
            })
          >[
            (
              semester: 1,
              academicYear: '2026-2027',
              termName: 'DEV-HK1',
              startAt: DateTime.utc(2026, 9, 1),
              endAt: DateTime.utc(2027, 1, 31, 23, 59, 59),
            ),
            (
              semester: 2,
              academicYear: '2026-2027',
              termName: 'DEV-HK2',
              startAt: DateTime.utc(2027, 2, 1),
              endAt: DateTime.utc(2027, 6, 30, 23, 59, 59),
            ),
          ];

      var createdTerms = 0;
      var updatedTerms = 0;
      var createdSections = 0;
      var updatedSections = 0;
      for (final spec in termSpecs) {
        var term = await AcademicTerm.db.findFirstRow(
          session,
          where: (t) => t.academicYear.equals(spec.academicYear) & t.termName.equals(spec.termName),
          transaction: transaction,
        );
        final activeTerm = await AcademicTerm.db.findFirstRow(
          session,
          where: (t) => t.status.equals('ACTIVE'),
          transaction: transaction,
        );
        final status = now.isAfter(spec.endAt)
            ? 'COMPLETED'
            : now.isBefore(spec.startAt)
            ? 'PLANNED'
            : activeTerm == null || activeTerm.id == term?.id
            ? 'ACTIVE'
            : 'PLANNED';
        if (term == null) {
          term = await AcademicTerm.db.insertRow(
            session,
            AcademicTerm(
              academicYear: spec.academicYear,
              termName: spec.termName,
              status: status,
              maxCreditsPerTerm: 25,
              startAt: spec.startAt,
              endAt: spec.endAt,
            ),
            transaction: transaction,
          );
          createdTerms++;
        } else if (term.status != status || term.maxCreditsPerTerm != 25 || term.startAt != spec.startAt || term.endAt != spec.endAt) {
          term = await AcademicTerm.db.updateRow(
            session,
            term.copyWith(
              status: status,
              maxCreditsPerTerm: 25,
              startAt: spec.startAt,
              endAt: spec.endAt,
            ),
            transaction: transaction,
          );
          updatedTerms++;
        }
        final termId = term.id!;

        final semesterCodes = _sampleCourses
            .where(
              (course) => course.semester == spec.semester && course.isActive,
            )
            .map((course) => course.code)
            .toSet();
        final courses = await Course.db.find(
          session,
          where: (t) => t.code.inSet(semesterCodes),
          transaction: transaction,
        );
        for (final course in courses) {
          final sectionCode = 'DEV-${course.code}-01';
          var section = await CourseSection.db.findFirstRow(
            session,
            where: (t) => t.termId.equals(termId) & t.sectionCode.equals(sectionCode),
            transaction: transaction,
          );
          final sectionStatus = status == 'ACTIVE'
              ? 'OPEN'
              : status == 'COMPLETED'
              ? 'COMPLETED'
              : 'DRAFT';
          if (section == null) {
            await CourseSection.db.insertRow(
              session,
              CourseSection(
                courseId: course.id!,
                termId: termId,
                teachingPhase: 1,
                lecturerId: lecturer.id!,
                sectionCode: sectionCode,
                capacity: 40,
                minimumEnrollment: 1,
                status: sectionStatus,
                createdAt: spec.startAt.subtract(const Duration(days: 30)),
              ),
              transaction: transaction,
            );
            createdSections++;
          } else if (section.courseId != course.id ||
              section.lecturerId != lecturer.id ||
              section.teachingPhase != 1 ||
              section.capacity != 40 ||
              section.minimumEnrollment != 1 ||
              section.status != sectionStatus) {
            section = await CourseSection.db.updateRow(
              session,
              section.copyWith(
                courseId: course.id!,
                lecturerId: lecturer.id!,
                teachingPhase: 1,
                capacity: 40,
                minimumEnrollment: 1,
                status: sectionStatus,
              ),
              transaction: transaction,
            );
            updatedSections++;
          }
        }
      }

      return <String, int>{
        'students': backfilledStudents,
        'createdTerms': createdTerms,
        'updatedTerms': updatedTerms,
        'createdSections': createdSections,
        'updatedSections': updatedSections,
      };
    });

    stdout.writeln(
      '[DEV OPERATIONAL SEED] Ready: student profiles backfilled='
      '${summary['students']}, terms created=${summary['createdTerms']}, '
      'terms updated=${summary['updatedTerms']}, sections created='
      '${summary['createdSections']}, sections updated='
      '${summary['updatedSections']}.',
    );
  }

  /// Create DEV academic terms/sections for the actual curriculum of each
  /// fixture student. No separate JSON file is needed. The dates, lecturer,
  /// capacity and section statuses are synthetic; phases come from the
  /// reviewed RAG plan (phase 1 where the source does not specify a phase).
  /// Never modify existing sections, terms, or student assignments.
  static Future<void> seedRagSections(Session session) async {
    if (!_ragFixturesEnabled) return;
    if (!_flag('SEED_RAG_ALLOW_INCOMPLETE_DEMO')) {
      stdout.writeln(
        '[RAG SECTIONS] Skipped. For isolated DEV fixtures, set '
        'SEED_RAG_ALLOW_INCOMPLETE_DEMO=true.',
      );
      return;
    }

    // Original server.dart runs DevSeedSampleData before DevSeedAccounts.
    // Bootstrap the existing DEV accounts if the required lecturer is absent.
    // The original later call is idempotent and will reuse those accounts.
    var lecturer = await Lecturer.db.findFirstRow(
      session,
      where: (t) => t.lecturerCode.equals('DEV-GV001'),
    );
    if (lecturer == null) {
      stdout.writeln(
        '[RAG SECTIONS] DEV-GV001 missing; running DevSeedAccounts.',
      );
      await DevSeedAccounts.run(session);
      lecturer = await Lecturer.db.findFirstRow(
        session,
        where: (t) => t.lecturerCode.equals('DEV-GV001'),
      );
    }
    if (lecturer == null || lecturer.teachingStatus != LecturerStatus.active) {
      throw StateError(
        'RAG sections require an active DEV-GV001 lecturer. '
        'Check SEED_LECTURER_EMAIL/PASSWORD and the lecturer profile.',
      );
    }
    final lecturerId = lecturer.id!;
    final lecturerAccount = await UserAccount.db.findById(
      session,
      lecturer.userAccountId,
    );
    if (lecturerAccount?.role != AccountRole.lecturer || lecturerAccount?.status != AccountStatus.active) {
      throw StateError('DEV-GV001 needs an active Lecturer account.');
    }
    final now = DateTime.now().toUtc();
    final summary = await session.db.transaction((transaction) async {
      final terms = <String, AcademicTerm>{};
      final seenSections = <String>{};
      var newTerms = 0;
      var newSections = 0;
      var existingSections = 0;
      var skippedItems = 0;
      for (final spec in _ragStudentPrograms) {
        final studentCode = 'DEV-K${spec.year % 100}-${spec.code}-001';
        final student = await Student.db.findFirstRow(
          session,
          where: (t) => t.studentCode.equals(studentCode),
          transaction: transaction,
        );
        if (student == null) {
          throw StateError('Missing RAG student $studentCode.');
        }
        final version = await CurriculumVersion.db.findById(
          session,
          student.curriculumVersionId,
          transaction: transaction,
        );
        final curriculum = version == null
            ? null
            : await Curriculum.db.findById(
                session,
                version.curriculumId,
                transaction: transaction,
              );
        if (version == null || version.status != 'PUBLISHED' || version.effectiveYear != spec.year || curriculum?.code != spec.code || student.admissionYear != spec.year) {
          throw StateError('Invalid CTDT fixture assignment for $studentCode.');
        }
        final items = await CurriculumItem.db.find(
          session,
          where: (t) => t.curriculumVersionId.equals(version.id!),
          transaction: transaction,
        );
        final courseIds = items.map((i) => i.courseId).toSet();
        if (courseIds.isEmpty) throw StateError('Empty CTDT for $studentCode.');
        final courses = await Course.db.find(
          session,
          where: (t) => t.id.inSet(courseIds),
          transaction: transaction,
        );
        final byCode = {for (final c in courses) c.code: c};
        final byCourseId = {for (final item in items) item.courseId: item};
        final planned = _ragStudentItems.where(
          (r) => r.program == spec.code && r.year == spec.year,
        );
        for (final row in planned) {
          final course = byCode[row.code];
          final item = course == null ? null : byCourseId[course.id!];
          if (course == null ||
              !course.isActive ||
              course.credits != row.credits ||
              item == null ||
              item.semester != row.semester ||
              item.credits != row.credits ||
              item.isRequired != row.isRequired) {
            skippedItems++;
            continue;
          }
          final year = spec.year + (row.semester - 1) ~/ 2;
          final half = (row.semester - 1) % 2 + 1;
          final termKey = '$year-$half';
          var term = terms[termKey];
          if (term == null) {
            final academicYear = '$year-${year + 1}';
            final termName = 'DEV-RAG-HK$half';
            final start = half == 1 ? DateTime.utc(year, 9, 1) : DateTime.utc(year + 1, 2, 1);
            final end = half == 1 ? DateTime.utc(year + 1, 1, 31, 23, 59, 59) : DateTime.utc(year + 1, 6, 30, 23, 59, 59);
            term = await AcademicTerm.db.findFirstRow(
              session,
              where: (t) => t.academicYear.equals(academicYear) & t.termName.equals(termName),
              transaction: transaction,
            );
            if (term == null) {
              final active = await AcademicTerm.db.findFirstRow(
                session,
                where: (t) => t.status.equals('ACTIVE'),
                transaction: transaction,
              );
              final status = now.isAfter(end)
                  ? 'COMPLETED'
                  : now.isBefore(start) || active != null
                  ? 'PLANNED'
                  : 'ACTIVE';
              if (!now.isBefore(start) && !now.isAfter(end) && active != null) {
                stdout.writeln(
                  '[RAG SECTIONS] Existing ACTIVE term ${active.id}; '
                  '$termName $academicYear will remain PLANNED.',
                );
              }
              term = await AcademicTerm.db.insertRow(
                session,
                AcademicTerm(
                  academicYear: academicYear,
                  termName: termName,
                  status: status,
                  maxCreditsPerTerm: 25.0,
                  startAt: start,
                  endAt: end,
                ),
                transaction: transaction,
              );
              newTerms++;
            }
            terms[termKey] = term;
          }
          final termId = term.id!;
          final code = 'DEV-RAG-${course.code}-D${row.phase}-01';
          if (!seenSections.add('$termId/$code')) continue;
          final existing = await CourseSection.db.findFirstRow(
            session,
            where: (t) => t.termId.equals(termId) & t.sectionCode.equals(code),
            transaction: transaction,
          );
          if (existing != null) {
            if (existing.courseId != course.id || existing.teachingPhase != row.phase) {
              throw StateError(
                'Conflicting section $code in term $termId. No overwrite.',
              );
            }
            existingSections++;
            continue;
          }
          final status = term.status == 'COMPLETED'
              ? 'COMPLETED'
              : term.status == 'ACTIVE'
              ? 'OPEN'
              : term.status == 'CLOSED'
              ? 'CLOSED'
              : 'DRAFT';
          await CourseSection.db.insertRow(
            session,
            CourseSection(
              courseId: course.id!,
              termId: termId,
              lecturerId: lecturerId,
              teachingPhase: row.phase,
              sectionCode: code,
              capacity: 40,
              minimumEnrollment: 1,
              status: status,
              createdAt: term.startAt.subtract(const Duration(days: 30)),
            ),
            transaction: transaction,
          );
          newSections++;
        }
      }
      return <String, int>{
        'terms': newTerms,
        'sections': newSections,
        'existing': existingSections,
        'skipped': skippedItems,
      };
    });
    stdout.writeln(
      '[RAG SECTIONS] New terms=${summary['terms']}, '
      'new sections=${summary['sections']}, existing=${summary['existing']}, '
      'skipped curriculum rows=${summary['skipped']}. DEV ONLY.',
    );
  }

  /// Creates seven login-capable DEV students, one per RAG program/version.
  /// Safe to rerun sequentially. Call only on an isolated DEV/test database.
  /// AuthServices must already be initialized (as in the normal server startup).
  static Future<void> seedRagStudents(Session session) async {
    if (!_ragFixturesEnabled) return;

    final configuredPassword = Platform.environment['SEED_RAG_STUDENT_PASSWORD'];
    final password = configuredPassword == null || configuredPassword.isEmpty ? Platform.environment['SEED_STUDENT_PASSWORD'] ?? '' : configuredPassword;
    if (password.length < 16) {
      throw StateError(
        'Configure SEED_RAG_STUDENT_PASSWORD (at least 16 characters), '
        'or SEED_STUDENT_PASSWORD if the former is not set.',
      );
    }
    final configuredDomain = Platform.environment['SCHOOL_EMAIL_DOMAIN']?.trim().toLowerCase();
    final domain = configuredDomain == null || configuredDomain.isEmpty ? 'example.test' : configuredDomain;
    if (!RegExp(r'^[^@\s]+\.[^@\s]+$').hasMatch(domain)) {
      throw StateError('Invalid SCHOOL_EMAIL_DOMAIN.');
    }
    final allowFixture = _flag('SEED_RAG_ALLOW_INCOMPLETE_DEMO');
    var created = 0;
    var reused = 0;
    for (final spec in _ragStudentPrograms) {
      final studentCode = 'DEV-K${spec.year % 100}-${spec.code}-001';
      final email = '${studentCode.toLowerCase()}@$domain';
      final existing = await Student.db.findFirstRow(
        session,
        where: (t) => t.studentCode.equals(studentCode),
      );
      if (existing != null) {
        final account = await UserAccount.db.findById(
          session,
          existing.userAccountId,
        );
        final version = await CurriculumVersion.db.findById(
          session,
          existing.curriculumVersionId,
        );
        final curriculum = version == null ? null : await Curriculum.db.findById(session, version.curriculumId);
        if (account?.schoolEmail != email ||
            account?.role != AccountRole.student ||
            account?.status != AccountStatus.active ||
            curriculum?.code != spec.code ||
            curriculum?.majorCode != spec.majorCode ||
            version?.effectiveYear != spec.year ||
            existing.admissionYear != spec.year) {
          throw StateError(
            'Existing fixture $studentCode differs from expected profile. '
            'No existing data changed. Review the DEV database or domain.',
          );
        }
        reused++;
        stdout.writeln('[RAG STUDENTS] Existing $studentCode preserved.');
        continue;
      }
      final existingAccount = await UserAccount.db.findFirstRow(
        session,
        where: (t) => t.schoolEmail.equals(email),
      );
      if (existingAccount != null) {
        throw StateError(
          'Email $email already exists without the expected Student. No overwrite.',
        );
      }
      final versionId = await _resolveRagStudentVersion(
        session,
        spec,
        allowFixture: allowFixture,
      );
      // Provisioner handles auth identity, password hashing, UserAccount and
      // Student in its own atomic transaction. Do not manually insert AuthUser.
      await SchoolAccountProvisioner.create(
        session,
        email: email,
        password: password,
        role: AccountRole.student,
        studentCode: studentCode,
        curriculumVersionId: versionId,
        curriculumCode: spec.code,
        admissionYear: spec.year,
      );
      created++;
      stdout.writeln(
        '[RAG STUDENTS] Created $studentCode -> ${spec.code}/${spec.year} ($email).',
      );
    }
    stdout.writeln('[RAG STUDENTS] Created=$created, existing=$reused.');
  }

  static Future<int> _resolveRagStudentVersion(
    Session session,
    _RagStudentProgram spec, {
    required bool allowFixture,
  }) async {
    return session.db.transaction((transaction) async {
      var curriculum = await Curriculum.db.findFirstRow(
        session,
        where: (t) => t.code.equals(spec.code),
        transaction: transaction,
      );
      if (curriculum == null) {
        if (!allowFixture) {
          throw StateError(
            'Missing curriculum ${spec.code}. Enable the isolated DEV fixture '
            'or import the official program first.',
          );
        }
        curriculum = await Curriculum.db.insertRow(
          session,
          Curriculum(
            code: spec.code,
            name: spec.name,
            majorCode: spec.majorCode,
            status: 'ACTIVE',
          ),
          transaction: transaction,
        );
      }
      if (curriculum.majorCode != spec.majorCode || curriculum.status != 'ACTIVE') {
        throw StateError(
          'Existing curriculum ${spec.code} is incompatible; no overwrite.',
        );
      }
      final curriculumId = curriculum.id!;
      final versions = await CurriculumVersion.db.find(
        session,
        where: (t) => t.curriculumId.equals(curriculumId) & t.effectiveYear.equals(spec.year) & t.status.equals('PUBLISHED'),
        transaction: transaction,
      );
      final official = versions
          .where(
            (v) => !v.versionCode.startsWith('RAG-') && !v.versionCode.startsWith('DEV-'),
          )
          .toList();
      if (official.length > 1) {
        throw StateError(
          'Multiple published versions for ${spec.code}/${spec.year}; '
          'resolve the ambiguity before creating test students.',
        );
      }
      if (official.length == 1) {
        final version = official.single;
        if (version.totalCreditsRequired != spec.totalCredits) {
          throw StateError(
            'Published curriculum credits differ from RAG: ${spec.code}/${spec.year}.',
          );
        }
        final item = await CurriculumItem.db.findFirstRow(
          session,
          where: (t) => t.curriculumVersionId.equals(version.id!),
          transaction: transaction,
        );
        if (item == null) {
          throw StateError(
            'Published curriculum is empty: ${spec.code}/${spec.year}.',
          );
        }
        return version.id!;
      }
      if (!allowFixture) {
        throw StateError(
          'No published version for ${spec.code}/${spec.year}. '
          'Only for isolated DEV, set SEED_RAG_ALLOW_INCOMPLETE_DEMO=true.',
        );
      }
      // Reuse previously seeded scenario/fixture versions if compatible.
      for (final code in [
        'RAG-SCENARIO-${spec.year}',
        'RAG-STUDENT-${spec.year}',
      ]) {
        final existing = await CurriculumVersion.db.findFirstRow(
          session,
          where: (t) => t.curriculumId.equals(curriculumId) & t.versionCode.equals(code),
          transaction: transaction,
        );
        if (existing == null) continue;
        if (existing.status != 'PUBLISHED' || existing.effectiveYear != spec.year || existing.totalCreditsRequired != spec.totalCredits) {
          throw StateError(
            'Existing DEV version $code differs for ${spec.code}; no overwrite.',
          );
        }
        final item = await CurriculumItem.db.findFirstRow(
          session,
          where: (t) => t.curriculumVersionId.equals(existing.id!),
          transaction: transaction,
        );
        if (item == null) {
          throw StateError(
            'Existing DEV version $code is empty; no overwrite.',
          );
        }
        return existing.id!;
      }
      // A separate, explicitly opted-in partial fixture, NOT an official curriculum.
      // PUBLISHED is required by SchoolAccountProvisioner. No existing draft is promoted.
      final selected = _ragStudentItems.where((r) => r.program == spec.code && r.year == spec.year).toList();
      final courses = <String, Course>{};
      for (final row in selected) {
        final previous = await Course.db.findFirstRow(
          session,
          where: (t) => t.code.equals(row.code),
          transaction: transaction,
        );
        if (previous != null && (previous.credits != row.credits || !previous.isActive)) {
          stdout.writeln(
            '[RAG STUDENTS] Skip incompatible course ${row.code}; no overwrite.',
          );
          continue;
        }
        if (previous != null && previous.name != row.name) {
          stdout.writeln(
            '[RAG STUDENTS] Preserve existing course name ${row.code}.',
          );
        }
        courses[row.code] =
            previous ??
            await Course.db.insertRow(
              session,
              Course(
                code: row.code,
                name: row.name,
                credits: row.credits,
                isActive: true,
              ),
              transaction: transaction,
            );
      }
      if (courses.isEmpty) {
        throw StateError('No usable RAG items for ${spec.code}/${spec.year}.');
      }
      final version = await CurriculumVersion.db.insertRow(
        session,
        CurriculumVersion(
          curriculumId: curriculumId,
          versionCode: 'RAG-STUDENT-${spec.year}',
          effectiveYear: spec.year,
          status: 'PUBLISHED',
          totalCreditsRequired: spec.totalCredits,
          publishedAt: DateTime.now().toUtc(),
          revision: 1,
        ),
        transaction: transaction,
      );
      final versionId = version.id!;
      final groups = <String, int>{};
      var groupOrder = 0;
      var itemOrder = 0;
      for (final row in selected) {
        final course = courses[row.code];
        if (course == null) continue;
        var groupId = groups[row.group];
        if (groupId == null) {
          groupOrder++;
          final group = await CurriculumGroup.db.insertRow(
            session,
            CurriculumGroup(
              curriculumVersionId: versionId,
              groupCode: 'RAG-$groupOrder',
              groupName: row.group,
              groupOrder: groupOrder,
            ),
            transaction: transaction,
          );
          groupId = group.id!;
          groups[row.group] = groupId;
        }
        await CurriculumItem.db.insertRow(
          session,
          CurriculumItem(
            curriculumVersionId: versionId,
            courseId: course.id!,
            semester: row.semester,
            isRequired: row.isRequired,
            credits: row.credits,
            groupId: groupId,
            itemOrder: ++itemOrder,
          ),
          transaction: transaction,
        );
      }
      stdout.writeln(
        '[RAG STUDENTS] Partial DEV fixture ${spec.code}/${spec.year}: '
        '$itemOrder items. Not for official graduation/registration decisions.',
      );
      return versionId;
    });
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

// Snapshot of the supported RAG metadata and reviewed teaching-plan rows.
// Source: seven academic_rag_*.jsonl files, normalized plan from prior RAG seed.
// Some elective slots, ambiguous credits and prerequisites are intentionally absent.
class _RagStudentProgram {
  const _RagStudentProgram(
    this.code,
    this.name,
    this.majorCode,
    this.year,
    this.totalCredits,
  );
  final String code;
  final String name;
  final String majorCode;
  final int year;
  final int totalCredits;
}

const _ragStudentPrograms = <_RagStudentProgram>[
  _RagStudentProgram('CNTT', 'Công nghệ thông tin', '7480201', 2023, 150),
  _RagStudentProgram('ATTT', 'An toàn thông tin', '7480202', 2023, 150),
  _RagStudentProgram('KTDL', 'Kỹ thuật dữ liệu', '7480203', 2023, 150),
  _RagStudentProgram('CNTT', 'Công nghệ thông tin', '7480201', 2026, 150),
  _RagStudentProgram('ATTT', 'An toàn thông tin', '7480202', 2026, 150),
  _RagStudentProgram('KTDL', 'Kỹ thuật dữ liệu', '7480203', 2026, 150),
  _RagStudentProgram('CNTT-JP', 'Công nghệ thông tin hệ Việt – Nhật', '7480201', 2026, 160, ),
];

class _RagStudentItem {
  const _RagStudentItem(
    this.program,
    this.year,
    this.semester,
    this.code,
    this.name,
    this.credits,
    this.isRequired,
    this.group, {
    required this.phase,
  });
  final int phase;
  final String program;
  final int year;
  final int semester;
  final String code;
  final String name;
  final int credits;
  final bool isRequired;
  final String group;
}

const _ragStudentItems = <_RagStudentItem>[
  _RagStudentItem("ATTT", 2023, 1, "MATH132401", "Toán 1", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_1_p11
  _RagStudentItem("ATTT", 2023, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_1_p11
  _RagStudentItem("ATTT", 2023, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_1_p11
  _RagStudentItem("ATTT", 2023, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_1_p11
  _RagStudentItem("ATTT", 2023, 1, "LCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_1_p11
  _RagStudentItem("ATTT", 2023, 2, "MATH132501", "Toán 2", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_2_p12
  _RagStudentItem("ATTT", 2023, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_3_p12
  _RagStudentItem("ATTT", 2023, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_4_p13
  _RagStudentItem("ATTT", 2023, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_4_p13
  _RagStudentItem("ATTT", 2023, 4, "CRYP331980", "Mật mã ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_4_p13
  _RagStudentItem("ATTT", 2023, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_4_p13
  _RagStudentItem("ATTT", 2023, 4, "ADNT330580", "Mạng máy tính nâng cao", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_4_p13
  _RagStudentItem("ATTT", 2023, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "SYPR432780", "Lập trình hệ thống", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "MALE431984", "Học máy", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "ETHA332080", "Tấn công mạng và phòng thủ", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "WISE432380", "An toàn mạng không dây & di động", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "MOPR331279", "Lập trình di động", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 5, "ENCS330537", "Tiếng Anh Chuyên ngành Khoa học Máy tính", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_5_p13
  _RagStudentItem("ATTT", 2023, 6, "CNDE430780", "Thiết kế mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_6_p13
  _RagStudentItem("ATTT", 2023, 6, "NSEC430880", "An ninh mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_6_p13
  _RagStudentItem("ATTT", 2023, 6, "NPRO430980", "Lập trình mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_6_p13
  _RagStudentItem("ATTT", 2023, 6, "BCAP433280", "Blockchain và ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_6_p13
  _RagStudentItem("ATTT", 2023, 6, "WASE432680", "An toàn ứng dụng web", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_6_p13
  _RagStudentItem("ATTT", 2023, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_7_p14
  _RagStudentItem("ATTT", 2023, 7, "ITEN423580", "Chuyên đề doanh nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_7_p14
  _RagStudentItem("ATTT", 2023, 7, "POIS453780", "Tiểu luận chuyên ngành ATTT", 5, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_7_p14
  _RagStudentItem("ATTT", 2023, 8, "DIFO432180", "Pháp lý kỹ thuật số", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_8_p14_part_1
  _RagStudentItem("ATTT", 2023, 8, "GRPR403880", "Khóa luận tốt nghiệp", 10, true, "Kế hoạch chung", phase: 1, ), // attt_2023_semester_8_p14_part_1
  _RagStudentItem("CNTT", 2023, 1, "MATH132401", "Toán 1", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_1_p12
  _RagStudentItem("CNTT", 2023, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_1_p12
  _RagStudentItem("CNTT", 2023, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_1_p12
  _RagStudentItem("CNTT", 2023, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_1_p12
  _RagStudentItem("CNTT", 2023, 1, "LCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_1_p12
  _RagStudentItem("CNTT", 2023, 2, "MATH132501", "Toán 2", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_2_p12
  _RagStudentItem("CNTT", 2023, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_3_p12
  _RagStudentItem("CNTT", 2023, 4, "WIPR230579", "Lập trình trên Windows", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 4, "ARIN330585", "Trí tuệ nhân tạo", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 4, "SOEN330679", "Công nghệ phần mềm", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_4_p13
  _RagStudentItem("CNTT", 2023, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_5_p13
  _RagStudentItem("CNTT", 2023, 5, "DBMS330284", "Hệ quản trị cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_5_p13
  _RagStudentItem("CNTT", 2023, 5, "ENCS330537", "Tiếng Anh Chuyên ngành Khoa học Máy tính", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_5_p13
  _RagStudentItem("CNTT", 2023, 6, "MOPR331279", "Lập trình di động", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "SOTE431079", "Kiểm thử phần mềm", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "MTSE431179", "Các công nghệ phần mềm mới", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "NPRO430980", "Lập trình mạng", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "ADNT330580", "Mạng máy tính nâng cao", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "ETHA332080", "Tấn công mạng và phòng thủ", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "CNDE430780", "Thiết kế mạng", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "ISAD330384", "Phân tích và thiết kế hệ thống thông tin", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "DAMI330484", "Khai phá dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "BDES333877", "Nhập môn dữ liệu lớn (Big data essential)", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "DBSE431284", "Bảo mật CSDL", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "MAAI330985", "Toán cho trí tuệ nhân tạo", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "INDS331085", "Nhập môn Khoa học dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 6, "BDPR431385", "Xử lý dữ liệu lớn", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_6_p14
  _RagStudentItem("CNTT", 2023, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 7, "ITEN420885", "Chuyên đề doanh nghiệp (CNTT)", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 7, "POSE451479", "Tiểu luận chuyên ngành CNPM", 5, false, "Công nghệ Phần mềm", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 7, "POCN451280", "Tiểu luận chuyên ngành MMT", 5, false, "Mạng và an ninh mạng", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 7, "POIS451184", "Tiểu luận chuyên ngành HTTT", 5, false, "Hệ thống Thông tin", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 7, "POAI451485", "Tiểu luận chuyên ngành TTNT", 5, false, "Trí tuệ nhân tạo", phase: 1, ), // cntt_2023_semester_7_p14
  _RagStudentItem("CNTT", 2023, 8, "WESE331479", "Bảo mật web", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_8_p15_part_1
  _RagStudentItem("CNTT", 2023, 8, "NSEC430880", "An ninh mạng", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_8_p15_part_1
  _RagStudentItem("CNTT", 2023, 8, "BDAN333977", "Phân tích dữ liệu lớn (Big data analysis)", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_8_p15_part_1
  _RagStudentItem("CNTT", 2023, 8, "DLEA432085", "Học sâu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2023_semester_8_p15_part_1
  _RagStudentItem("CNTT", 2023, 8, "GRPR401979", "Khóa luận tốt nghiệp", 10, true, "Kế hoạch chung", phase: 1, ), // cntt_2023_semester_8_p15_part_1
  _RagStudentItem("KTDL", 2023, 1, "MATH132401", "Toán 1", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_1_p10
  _RagStudentItem("KTDL", 2023, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_1_p10
  _RagStudentItem("KTDL", 2023, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_1_p10
  _RagStudentItem("KTDL", 2023, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_1_p10
  _RagStudentItem("KTDL", 2023, 1, "LCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_1_p10
  _RagStudentItem("KTDL", 2023, 2, "MATH132501", "Toán 2", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_2_p10
  _RagStudentItem("KTDL", 2023, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_3_p11
  _RagStudentItem("KTDL", 2023, 4, "WIPR230579", "Lập trình trên Windows", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 4, "ARIN330585", "Trí tuệ nhân tạo", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 4, "RPAN233577", "Lập trình R cho phân tích", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_4_p11
  _RagStudentItem("KTDL", 2023, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "SOEN330679", "Công nghệ phần mềm", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "DBMS330284", "Hệ quản trị cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "BDES333877", "Nhập môn dữ liệu lớn (Big data essential)", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "DAMI330484", "Khai phá dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "CLCO432779", "Điện toán đám mây", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 5, "ENCS330537", "Tiếng Anh Chuyên ngành Khoa học Máy tính", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_5_p11
  _RagStudentItem("KTDL", 2023, 6, "IDVI333677", "Tương tác dữ liệu trực quan", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 6, "DAWH430784", "Kho dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 6, "BDAN333977", "Phân tích dữ liệu lớn (Big data analysis)", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 6, "DSYS335977", "Hệ phân bố", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 6, "DIPR430685", "Xử lý ảnh", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 6, "BDML434077", "Big Data Applications: Machine Learning at Scale", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_6_p12
  _RagStudentItem("KTDL", 2023, 7, "PODE454277", "Tiểu luận chuyên ngành KTDL", 5, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_7_p12
  _RagStudentItem("KTDL", 2023, 7, "INTE202879", "Chuyên đề doanh nghiệp", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_7_p12
  _RagStudentItem("KTDL", 2023, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_7_p12
  _RagStudentItem("KTDL", 2023, 8, "BDAS436177", "Big Data Applications: Real-Time Streaming", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_8_p12_part_1
  _RagStudentItem("KTDL", 2023, 8, "GRPR404377", "Khóa luận tốt nghiệp", 10, true, "Kế hoạch chung", phase: 1, ), // ktdl_2023_semester_8_p12_part_1
  _RagStudentItem("ATTT", 2026, 1, "MATH132101", "Giải tích một biến số", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "INPR130285", "Nhập môn lập trình", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "LCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 1, "ENCO140126", "Kỹ năng giao tiếp tiếng Anh sơ cấp", 4, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_1_p14
  _RagStudentItem("ATTT", 2026, 2, "MATH133601", "Giải tích nhiều biến số", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "DIGR230485", "Toán rời rạc và lý thuyết đồ thị", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_2_p15
  _RagStudentItem("ATTT", 2026, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 3, "ENCO240126", "Kỹ năng giao tiếp tiếng Anh trung cấp", 4, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_3_p15
  _RagStudentItem("ATTT", 2026, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_4_p15
  _RagStudentItem("ATTT", 2026, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_4_p15
  _RagStudentItem("ATTT", 2026, 4, "DBSY230184", "Cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_4_p15
  _RagStudentItem("ATTT", 2026, 4, "CRYP331980", "Mật mã ứng dụng", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_4_p15
  _RagStudentItem("ATTT", 2026, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_4_p15
  _RagStudentItem("ATTT", 2026, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "ESYS431080", "Hệ thống nhúng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "MALE431984", "Học máy", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "ETHA332080", "Tấn công mạng và phòng thủ", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "WISE432380", "An toàn mạng không dây & di động", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "MOPR331279", "Lập trình di động", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 5, "ADNT330580", "Mạng máy tính nâng cao", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_5_p16
  _RagStudentItem("ATTT", 2026, 6, "CNDE430780", "Thiết kế mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_6_p16
  _RagStudentItem("ATTT", 2026, 6, "NSEC430880", "An ninh mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_6_p16
  _RagStudentItem("ATTT", 2026, 6, "NPRO430980", "Lập trình mạng", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_6_p16
  _RagStudentItem("ATTT", 2026, 6, "WASE432680", "An toàn ứng dụng web", 3, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_6_p16
  _RagStudentItem("ATTT", 2026, 6, "BCAP433280", "Blockchain và ứng dụng", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_6_p16
  _RagStudentItem("ATTT", 2026, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_7_p16
  _RagStudentItem("ATTT", 2026, 7, "POIS453780", "Tiểu luận chuyên ngành ATTT", 5, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_7_p16
  _RagStudentItem("ATTT", 2026, 7, "DIFO432180", "Pháp lý kỹ thuật số", 3, true, "Kế hoạch chung", phase: 2, ), // attt_2026_semester_7_p16
  _RagStudentItem("ATTT", 2026, 8, "GRPR473880", "Khóa luận tốt nghiệp", 7, true, "Kế hoạch chung", phase: 1, ), // attt_2026_semester_8_p17
  _RagStudentItem("CNTT", 2026, 1, "MATH132101", "Giải tích một biến số", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "INPR130285", "Nhập môn lập trình", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "LLCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 1, "ENCO140126", "Kỹ năng giao tiếp tiếng Anh sơ cấp", 4, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_1_p15
  _RagStudentItem("CNTT", 2026, 2, "MATH133601", "Giải tích nhiều biến số", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "DIGR230485", "Toán rời rạc và lý thuyết đồ thị", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "GELA236939", "Pháp luật đại cương", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_2_p15
  _RagStudentItem("CNTT", 2026, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "ENCO240126", "Kỹ năng giao tiếp tiếng Anh trung cấp", 4, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_3_p16
  _RagStudentItem("CNTT", 2026, 4, "WIPR230579", "Lập trình trên Windows", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 4, "DBSY230184", "Cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 4, "ARIN330585", "Trí tuệ nhân tạo", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_4_p16
  _RagStudentItem("CNTT", 2026, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_5_p16
  _RagStudentItem("CNTT", 2026, 5, "DBMS330284", "Hệ quản trị cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_5_p16
  _RagStudentItem("CNTT", 2026, 5, "SOEN330679", "Công nghệ phần mềm", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_5_p16
  _RagStudentItem("CNTT", 2026, 5, "MALE431985", "Học máy", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_5_p16
  _RagStudentItem("CNTT", 2026, 5, "MOPR331279", "Lập trình di động", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_5_p16
  _RagStudentItem("CNTT", 2026, 6, "WESE331479", "Bảo mật web", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "OOSD330879", "Thiết kế phần mềm hướng đối tượng", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "SOTE431079", "Kiểm thử phần mềm", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "MTSE431179", "Các công nghệ phần mềm mới", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "ISAD330384", "Phân tích và thiết kế hệ thống thông tin", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "DAMI330484", "Khai phá dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "BDES333877", "Nhập môn dữ liệu lớn (Big data essential)", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "DBSE431284", "Bảo mật CSDL", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "MAAI330985", "Toán cho trí tuệ nhân tạo", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "INDS331085", "Nhập môn Khoa học dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "BDPR431385", "Xử lý dữ liệu lớn", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 6, "DLEA432085", "Học sâu", 3, false, "Chuyên ngành lựa chọn", phase: 2, ), // cntt_2026_semester_6_p17
  _RagStudentItem("CNTT", 2026, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 2, ), // cntt_2026_semester_7_p17
  _RagStudentItem("CNTT", 2026, 7, "POSE451479", "Tiểu luận chuyên ngành CNPM", 5, false, "Công nghệ Phần mềm", phase: 1, ), // cntt_2026_semester_7_p17
  _RagStudentItem("CNTT", 2026, 7, "POIS451184", "Tiểu luận chuyên ngành HTTT", 5, false, "Hệ thống Thông tin", phase: 1, ), // cntt_2026_semester_7_p17
  _RagStudentItem("CNTT", 2026, 7, "POAI451485", "Tiểu luận chuyên ngành TTNT", 5, false, "Trí tuệ nhân tạo", phase: 1, ), // cntt_2026_semester_7_p17
  _RagStudentItem("CNTT", 2026, 8, "GRPR473880", "Khóa luận tốt nghiệp", 7, true, "Kế hoạch chung", phase: 1, ), // cntt_2026_semester_8_p18
  _RagStudentItem("CNTT-JP", 2026, 1, "MATH132101", "Giải tích một biến số", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 1, "LLCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 1, "VJEC131847", "Tiếng Nhật JPA1", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_1_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "MATH133601", "Giải tích nhiều biến số", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "GELA236939", "Pháp luật đại cương", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 2, "VJEC131947", "Tiếng Nhật JPA2", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_2_p15
  _RagStudentItem("CNTT-JP", 2026, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 3, "VJEC232047", "Tiếng Nhật JPA3", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_3_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "WIPR230579", "Lập trình trên Windows", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "ARIN330585", "Trí tuệ nhân tạo", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "INOT231780", "IoT", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 4, "VJEC332247", "Tiếng Nhật JPA4.1", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_4_p16
  _RagStudentItem("CNTT-JP", 2026, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_5_p16
  _RagStudentItem("CNTT-JP", 2026, 5, "DBMS330284", "Hệ quản trị cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_5_p16
  _RagStudentItem("CNTT-JP", 2026, 5, "SOEN330679", "Công nghệ phần mềm", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_5_p16
  _RagStudentItem("CNTT-JP", 2026, 5, "MALE431985", "Học máy", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_5_p16
  _RagStudentItem("CNTT-JP", 2026, 5, "MOPR331279", "Lập trình di động", 3, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_5_p16
  _RagStudentItem("CNTT-JP", 2026, 6, "VJEC332447", "Tiếng Nhật JPA5", 3, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "WESE331479", "Bảo mật web", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "OOSD330879", "Thiết kế phần mềm hướng đối tượng", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "SOTE431079", "Kiểm thử phần mềm", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "MTSE431179", "Các công nghệ phần mềm mới", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "ISAD330384", "Phân tích và thiết kế hệ thống thông tin", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "DAMI330484", "Khai phá dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "BDES333877", "Nhập môn dữ liệu lớn (Big data essential)", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "DBSE431284", "Bảo mật CSDL", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "MAAI330985", "Toán cho trí tuệ nhân tạo", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "INDS331085", "Nhập môn Khoa học dữ liệu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "BDPR431385", "Xử lý dữ liệu lớn", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 6, "DLEA432085", "Học sâu", 3, false, "Chuyên ngành lựa chọn", phase: 1, ), // cntt_jp_2026_semester_6_p17
  _RagStudentItem("CNTT-JP", 2026, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 2, ), // cntt_jp_2026_semester_7_p17
  _RagStudentItem("CNTT-JP", 2026, 7, "POSE451479", "Tiểu luận chuyên ngành CNPM", 5, false, "Công nghệ Phần mềm", phase: 1, ), // cntt_jp_2026_semester_7_p17
  _RagStudentItem("CNTT-JP", 2026, 7, "POIS451184", "Tiểu luận chuyên ngành HTTT", 5, false, "Hệ thống Thông tin", phase: 1, ), // cntt_jp_2026_semester_7_p17
  _RagStudentItem("CNTT-JP", 2026, 7, "POAI451485", "Tiểu luận chuyên ngành TTNT", 5, false, "Trí tuệ nhân tạo", phase: 1, ), // cntt_jp_2026_semester_7_p17
  _RagStudentItem("CNTT-JP", 2026, 8, "GRPR473880", "Khóa luận tốt nghiệp", 7, true, "Kế hoạch chung", phase: 1, ), // cntt_jp_2026_semester_8_p18
  _RagStudentItem("KTDL", 2026, 1, "MATH132101", "Giải tích một biến số", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "MATH143001", "Đại số và cấu trúc đại số", 4, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "INDE131777", "Nhập môn ngành KTDL", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "INPR130285", "Nhập môn lập trình", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "PHYS130902", "Vật lý 1", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "LLCT130105", "Triết học Mác – Lênin", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "LCT120205", "Kinh tế chính trị Mác - Lênin", 2, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 1, "ENCO140126", "Kỹ năng giao tiếp tiếng Anh sơ cấp", 4, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_1_p15
  _RagStudentItem("KTDL", 2026, 2, "MATH133601", "Giải tích nhiều biến số", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "MATH132901", "Xác suất thống kê ứng dụng", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "PRTE230385", "Kỹ thuật lập trình", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "PHYS111202", "Thí nghiệm vật lý 1", 1, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "EEEN234162", "Điện tử căn bản", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "DIGR230485", "Toán rời rạc và lý thuyết đồ thị", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "GELA236939", "Pháp luật đại cương", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "LLCT120405", "Chủ nghĩa xã hội khoa học", 2, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 2, "LLCT120314", "Tư tưởng Hồ Chí Minh", 2, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_2_p15
  _RagStudentItem("KTDL", 2026, 3, "PRBE214262", "Thực tập điện tử căn bản", 1, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "DASA230179", "Cấu trúc dữ liệu và giải thuật", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "OOPR230279", "Lập trình hướng đối tượng", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "CAAL230180", "Kiến trúc máy tính và hợp ngữ", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "LLCT220514", "Lịch sử Đảng CSVN", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "NEES330380", "Mạng máy tính căn bản", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 3, "ENCO240126", "Kỹ năng giao tiếp tiếng Anh trung cấp", 4, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_3_p15
  _RagStudentItem("KTDL", 2026, 4, "IPPA233277", "Lập trình Python", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 4, "OPSY330280", "Hệ điều hành", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 4, "DBSY230184", "Cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 4, "ARIN330585", "Trí tuệ nhân tạo", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 4, "INSE330380", "An toàn thông tin", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 4, "RPAN233577", "Lập trình R cho phân tích", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_4_p16
  _RagStudentItem("KTDL", 2026, 5, "DIPR430685", "Xử lý ảnh", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "WEPR330479", "Lập trình Web", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "SOEN330679", "Công nghệ phần mềm", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "DBMS330284", "Hệ quản trị cơ sở dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "BDES333877", "Nhập môn dữ liệu lớn (Big data essential)", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "MALE431985", "Học máy", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 5, "IDVI333677", "Tương tác dữ liệu trực quan", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_5_p16
  _RagStudentItem("KTDL", 2026, 6, "CLCO332779", "Điện toán đám mây", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "DAMI330484", "Khai phá dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "DAWH430784", "Kho dữ liệu", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "BDAN333977", "Phân tích dữ liệu lớn (Big data analysis)", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "DAAN436277", "Phân tích dữ liệu (Data analytics)", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "DBSE431284", "Bảo mật CSDL", 3, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 6, "DLEA432085", "Học sâu", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_6_p17
  _RagStudentItem("KTDL", 2026, 7, "PODE454277", "Tiểu luận chuyên ngành KTDL", 5, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_7_p17
  _RagStudentItem("KTDL", 2026, 7, "ITIN421085", "Thực tập tốt nghiệp (ATTT)", 2, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_7_p17
  _RagStudentItem("KTDL", 2026, 7, "BDAS436177", "Big Data Applications: Real-Time Streaming", 3, true, "Kế hoạch chung", phase: 2, ), // ktdl_2026_semester_7_p17
  _RagStudentItem("KTDL", 2026, 8, "GRPR474377", "Khóa luận tốt nghiệp", 7, true, "Kế hoạch chung", phase: 1, ), // ktdl_2026_semester_8_p17
];
