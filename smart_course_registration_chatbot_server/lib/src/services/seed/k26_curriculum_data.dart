// Data reference for 2026 curriculum DEV import (three source PDFs).
// IMPORTANT: provisional subset, NOT a validated complete 150-credit curriculum.
// Source: approved-name rows from Danh_muc_mon_khong_trung.csv and
//         links from Lien_ket_mon_voi_CTDT.csv.
// Excluded: codes with conflicting names, cross-table code mismatches,
// non-degree-credit items, unverified
// normalized codes and elective placeholders without a concrete courseCode.
// The seeder always creates DRAFT versions; never auto-assigns existing students.

class K26CourseSeedData {
  const K26CourseSeedData(this.code, this.name, this.credits);
  final String code;
  final String name;
  final int credits;
}

class K26ProgramSeedData {
  const K26ProgramSeedData(this.code, this.name, this.majorCode);
  final String code;
  final String name;
  final String majorCode;
}

class K26ItemSeedData {
  const K26ItemSeedData({
    required this.programCode,
    required this.courseCode,
    required this.semester,
    required this.credits,
    required this.isRequired,
    required this.itemOrder,
    this.groupCode,
  });
  final String programCode;
  final String courseCode;
  final int semester;
  final int credits;
  final bool isRequired;
  final int itemOrder;
  final String? groupCode;
}

class K26CurriculumData {
  K26CurriculumData._();
  static const int publishedDegreeCredits = 150;
  static const String versionCode = '2026';
  static const int effectiveYear = 2026;
  // Draft because current source requires reviewing 8 ambiguous course codes,
  // 15 elective/other placeholders, and excluded non-degree-credit units.
  static const String seedVersionStatus = 'DRAFT';

  static const programs = <K26ProgramSeedData>[
    K26ProgramSeedData('CNTT', 'Công nghệ thông tin', '7480201'),
    K26ProgramSeedData('ATTT', 'An toàn thông tin', '7480202'),
    K26ProgramSeedData('KTDL', 'Kỹ thuật dữ liệu', '7480203'),
  ];

  // 70 reviewed name+code+credits rows. 1 Course per code across programs.
  static const courses = <K26CourseSeedData>[
    K26CourseSeedData('ADNT330580', 'Mạng máy tính nâng cao', 3),
    K26CourseSeedData('ARIN330585', 'Trí tuệ nhân tạo', 3),
    K26CourseSeedData('BCAP433280', 'Blockchain và ứng dụng', 3),
    K26CourseSeedData('BDAN333977', 'Phân tích dữ liệu lớn (Big Data Analysis)', 3),
    K26CourseSeedData('BDAS436177', 'Ứng dụng dữ liệu lớn: Truyền dữ liệu theo thời gian thực (Big Data Applications: Real-Time Streaming)', 3),
    K26CourseSeedData('BDPR431385', 'Xử lý dữ liệu lớn', 3),
    K26CourseSeedData('CAAL230180', 'Kiến trúc máy tính và hợp ngữ', 3),
    K26CourseSeedData('CLCO332779', 'Điện toán đám mây', 3),
    K26CourseSeedData('CNDE430780', 'Thiết kế mạng', 3),
    K26CourseSeedData('CRYP331980', 'Mật mã ứng dụng', 3),
    K26CourseSeedData('DAAN436277', 'Phân tích dữ liệu (Data analytics)', 3),
    K26CourseSeedData('DAMI330484', 'Khai phá dữ liệu', 3),
    K26CourseSeedData('DASA230179', 'Cấu trúc dữ liệu và giải thuật', 3),
    K26CourseSeedData('DAWH430784', 'Kho dữ liệu', 3),
    K26CourseSeedData('DBMS330284', 'Hệ quản trị cơ sở dữ liệu', 3),
    K26CourseSeedData('DBSE431284', 'Bảo mật CSDL', 3),
    K26CourseSeedData('DBSY230184', 'Cơ sở dữ liệu', 3),
    K26CourseSeedData('DICO132585', 'Chuyên đề nâng cao năng lực số', 3),
    K26CourseSeedData('DIGR230485', 'Toán rời rạc và lý thuyết đồ thị', 3),
    K26CourseSeedData('DIPR430685', 'Xử lý ảnh số', 3),
    K26CourseSeedData('EEEN234162', 'Điện tử căn bản', 3),
    K26CourseSeedData('ENCO140126', 'Kỹ năng giao tiếp tiếng Anh sơ cấp', 4),
    K26CourseSeedData('ESYS431080', 'Hệ thống nhúng', 3),
    K26CourseSeedData('ETHA332080', 'Tấn công mạng và phòng thủ', 3),
    K26CourseSeedData('GRPR473880', 'Khóa luận tốt nghiệp', 7),
    K26CourseSeedData('GRPR474377', 'Khóa luận tốt nghiệp', 7),
    K26CourseSeedData('IDVI333677', 'Tương tác dữ liệu trực quan', 3),
    K26CourseSeedData('INDE131777', 'Nhập môn ngành KTDL', 3),
    K26CourseSeedData('INDS331085', 'Nhập môn Khoa học dữ liệu', 3),
    K26CourseSeedData('INOT231780', 'Vạn Vật Kết Nối', 3),
    K26CourseSeedData('INPR130285', 'Nhập môn lập trình', 3),
    K26CourseSeedData('INSE330380', 'An toàn thông tin', 3),
    K26CourseSeedData('IPPA233277', 'Lập trình Python', 3),
    K26CourseSeedData('ISAD330384', 'Phân tích và thiết kế hệ thống thông tin', 3),
    K26CourseSeedData('LLCT120205', 'Kinh tế chính trị Mác - Lênin', 2),
    K26CourseSeedData('LLCT120314', 'Tư tưởng Hồ Chí Minh', 2),
    K26CourseSeedData('LLCT120405', 'Chủ nghĩa xã hội khoa học', 2),
    K26CourseSeedData('LLCT130105', 'Triết học Mác – Lênin', 3),
    K26CourseSeedData('LLCT220514', 'Lịch sử Đảng CSVN', 2),
    K26CourseSeedData('MAAI330985', 'Toán cho trí tuệ nhân tạo', 3),
    K26CourseSeedData('MALE431984', 'Học máy', 3),
    K26CourseSeedData('MALE431985', 'Học máy', 3),
    K26CourseSeedData('MATH132901', 'Xác suất thống kê ứng dụng', 3),
    K26CourseSeedData('MOPR331279', 'Lập trình di động', 3),
    K26CourseSeedData('MTSE431179', 'Các công nghệ phần mềm mới', 3),
    K26CourseSeedData('NEES330380', 'Mạng máy tính căn bản', 3),
    K26CourseSeedData('NPRO430980', 'Lập trình mạng', 3),
    K26CourseSeedData('NSEC430880', 'An ninh mạng', 3),
    K26CourseSeedData('OOPR230279', 'Lập trình hướng đối tượng', 3),
    K26CourseSeedData('OOSD330879', 'Thiết kế phần mềm hướng đối tượng', 3),
    K26CourseSeedData('OPSY330280', 'Hệ điều hành', 3),
    K26CourseSeedData('PHED110130', 'Giáo dục thể chất 1', 1),
    K26CourseSeedData('PHED110513', 'Giáo dục thể chất 1', 1),
    K26CourseSeedData('PHYS111202', 'Thí nghiệm vật lý 1', 1),
    K26CourseSeedData('PHYS130902', 'Vật lý 1', 3),
    K26CourseSeedData('POAI451485', 'Tiểu luận chuyên ngành TTNT', 5),
    K26CourseSeedData('PODE454277', 'Tiểu luận chuyên ngành KTDL', 5),
    K26CourseSeedData('POIS451184', 'Tiểu luận chuyên ngành HTTT', 5),
    K26CourseSeedData('POIS453780', 'Tiểu luận chuyên ngành ATTT', 5),
    K26CourseSeedData('POSE451479', 'Tiểu luận chuyên ngành CNPM', 5),
    K26CourseSeedData('PRBE214262', 'Thực tập điện tử căn bản', 1),
    K26CourseSeedData('PRTE230385', 'Kỹ thuật lập trình', 3),
    K26CourseSeedData('RPAN233577', 'Lập trình R cho phân tích', 3),
    K26CourseSeedData('SOEN330679', 'Công nghệ phần mềm', 3),
    K26CourseSeedData('SOTE431079', 'Kiểm thử phần mềm', 3),
    K26CourseSeedData('WASE432680', 'An toàn ứng dụng web', 3),
    K26CourseSeedData('WEPR330479', 'Lập trình Web', 3),
    K26CourseSeedData('WESE331479', 'Bảo mật web', 3),
    K26CourseSeedData('WIPR230579', 'Lập trình trên Windows', 3),
    K26CourseSeedData('WISE432380', 'An toàn mạng không dây & di động', 3),
  ];

  // 119 read-only items; speciality choices are optional, not required.
  static const items = <K26ItemSeedData>[
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'INPR130285', semester: 1, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'PHYS130902', semester: 1, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'LLCT130105', semester: 1, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'LLCT120205', semester: 1, credits: 2, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'ENCO140126', semester: 1, credits: 4, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'MATH132901', semester: 2, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'PRTE230385', semester: 2, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'PHYS111202', semester: 2, credits: 1, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'EEEN234162', semester: 2, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DIGR230485', semester: 2, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'LLCT120405', semester: 2, credits: 2, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'LLCT120314', semester: 2, credits: 2, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'PRBE214262', semester: 3, credits: 1, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DASA230179', semester: 3, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'OOPR230279', semester: 3, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'CAAL230180', semester: 3, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'LLCT220514', semester: 3, credits: 2, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'NEES330380', semester: 3, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'IPPA233277', semester: 3, credits: 3, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'WIPR230579', semester: 4, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DBSY230184', semester: 4, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'OPSY330280', semester: 4, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'ARIN330585', semester: 4, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'INSE330380', semester: 4, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'INOT231780', semester: 4, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'WEPR330479', semester: 5, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DBMS330284', semester: 5, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'SOEN330679', semester: 5, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'MALE431985', semester: 5, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'MOPR331279', semester: 5, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'WESE331479', semester: 6, credits: 3, isRequired: false, itemOrder: 1, groupCode: 'CN-PM'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'OOSD330879', semester: 6, credits: 3, isRequired: false, itemOrder: 2, groupCode: 'CN-PM'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'SOTE431079', semester: 6, credits: 3, isRequired: false, itemOrder: 3, groupCode: 'CN-PM'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'MTSE431179', semester: 6, credits: 3, isRequired: false, itemOrder: 4, groupCode: 'CN-PM'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'ISAD330384', semester: 6, credits: 3, isRequired: false, itemOrder: 5, groupCode: 'CN-HTTT'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DAMI330484', semester: 6, credits: 3, isRequired: false, itemOrder: 6, groupCode: 'CN-HTTT'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'DBSE431284', semester: 6, credits: 3, isRequired: false, itemOrder: 7, groupCode: 'CN-HTTT'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'MAAI330985', semester: 6, credits: 3, isRequired: false, itemOrder: 8, groupCode: 'CN-AI'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'INDS331085', semester: 6, credits: 3, isRequired: false, itemOrder: 9, groupCode: 'CN-AI'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'BDPR431385', semester: 6, credits: 3, isRequired: false, itemOrder: 10, groupCode: 'CN-AI'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'POSE451479', semester: 7, credits: 5, isRequired: false, itemOrder: 1, groupCode: 'CN-PM'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'POIS451184', semester: 7, credits: 5, isRequired: false, itemOrder: 2, groupCode: 'CN-HTTT'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'POAI451485', semester: 7, credits: 5, isRequired: false, itemOrder: 3, groupCode: 'CN-AI'),
    K26ItemSeedData(programCode: 'CNTT', courseCode: 'GRPR473880', semester: 8, credits: 7, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'INPR130285', semester: 1, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'PHYS130902', semester: 1, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'LLCT130105', semester: 1, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'ENCO140126', semester: 1, credits: 4, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'MATH132901', semester: 2, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'PRTE230385', semester: 2, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'PHYS111202', semester: 2, credits: 1, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'EEEN234162', semester: 2, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'DIGR230485', semester: 2, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'LLCT120405', semester: 2, credits: 2, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'LLCT120314', semester: 2, credits: 2, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'PRBE214262', semester: 3, credits: 1, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'DASA230179', semester: 3, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'OOPR230279', semester: 3, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'CAAL230180', semester: 3, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'NEES330380', semester: 3, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'IPPA233277', semester: 3, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'LLCT220514', semester: 3, credits: 2, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'INOT231780', semester: 4, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'OPSY330280', semester: 4, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'DBSY230184', semester: 4, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'CRYP331980', semester: 4, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'INSE330380', semester: 4, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'WEPR330479', semester: 5, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'ESYS431080', semester: 5, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'MALE431984', semester: 5, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'ETHA332080', semester: 5, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'WISE432380', semester: 5, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'MOPR331279', semester: 5, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'ADNT330580', semester: 5, credits: 3, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'CNDE430780', semester: 6, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'NSEC430880', semester: 6, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'NPRO430980', semester: 6, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'WASE432680', semester: 6, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'BCAP433280', semester: 6, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'POIS453780', semester: 7, credits: 5, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'ATTT', courseCode: 'GRPR473880', semester: 8, credits: 7, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'INDE131777', semester: 1, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'INPR130285', semester: 1, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'PHYS130902', semester: 1, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'LLCT130105', semester: 1, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'ENCO140126', semester: 1, credits: 4, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'MATH132901', semester: 2, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'PRTE230385', semester: 2, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'PHYS111202', semester: 2, credits: 1, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'EEEN234162', semester: 2, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DIGR230485', semester: 2, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'LLCT120405', semester: 2, credits: 2, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'LLCT120314', semester: 2, credits: 2, isRequired: true, itemOrder: 7),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'PRBE214262', semester: 3, credits: 1, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DASA230179', semester: 3, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'OOPR230279', semester: 3, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'CAAL230180', semester: 3, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'LLCT220514', semester: 3, credits: 2, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'NEES330380', semester: 3, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'IPPA233277', semester: 4, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'OPSY330280', semester: 4, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DBSY230184', semester: 4, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'ARIN330585', semester: 4, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'INSE330380', semester: 4, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'RPAN233577', semester: 4, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DIPR430685', semester: 5, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'WEPR330479', semester: 5, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'SOEN330679', semester: 5, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DBMS330284', semester: 5, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'MALE431985', semester: 5, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'IDVI333677', semester: 5, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'CLCO332779', semester: 6, credits: 3, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DAMI330484', semester: 6, credits: 3, isRequired: true, itemOrder: 2),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DAWH430784', semester: 6, credits: 3, isRequired: true, itemOrder: 3),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'BDAN333977', semester: 6, credits: 3, isRequired: true, itemOrder: 4),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DAAN436277', semester: 6, credits: 3, isRequired: true, itemOrder: 5),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'DBSE431284', semester: 6, credits: 3, isRequired: true, itemOrder: 6),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'PODE454277', semester: 7, credits: 5, isRequired: true, itemOrder: 1),
    K26ItemSeedData(programCode: 'KTDL', courseCode: 'GRPR474377', semester: 8, credits: 7, isRequired: true, itemOrder: 1),
  ];
}
