import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// Creates demo courses and curriculum items once in an EMPTY course catalog.
///
/// Guardrails:
/// - Called only in Serverpod's development run mode (see server.dart).
/// - Does not touch existing course catalogs, even partially populated ones.
/// - Inserts the curriculum, version, courses and mapping rows atomically.
/// - Does not create AuthUser/UserAccount records; DevSeedAccounts handles those.
///
/// Automatically called on each development server startup.
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
              status: 'DEMO',
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
              status: 'DEMO',
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
            ),
            transaction: transaction,
          );
        }
      }
      return _sampleCourses.length;
    });

    if (insertedCourses == 0) {
      stdout.writeln(
        '[DEV DATA SEED] Skipped: app_course already contains data. '
        'Existing rows remain unchanged.',
      );
    } else {
      stdout.writeln(
        '[DEV DATA SEED] Inserted $insertedCourses courses, '
        '37 curriculum items, using DEV-CNTT / DEV-2026.',
      );
    }
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
