import 'package:flutter/material.dart';

import 'data/curriculum_lookup_repository.dart';

/// Màu lấy theo SVG Figma F04 do HAN cung cấp (390 x 844).
class _Palette {
  static const primary = Color(0xFF0D47A1);
  static const accent = Color(0xFF1D70C9);
  static const background = Color(0xFFF5F7FA);
  static const ink = Color(0xFF273447);
  static const muted = Color(0xFF68788D);
  static const border = Color(0xFFDDE5F0);
  static const blueSoft = Color(0xFFE4EFFF);
  static const greenSoft = Color(0xFFE3F4EC);
  static const green = Color(0xFF188A61);
}

enum _CourseFilter { all, mandatory, elective }

/// F04: bản Flutter tái tạo bố cục SVG của HAN, dùng dữ liệu Serverpod thật.
/// Không dùng con số tiến độ, điểm số hay trạng thái môn trong SVG làm dữ liệu.
class CurriculumLookupScreen extends StatefulWidget {
  const CurriculumLookupScreen({
    super.key,
    required this.repository,
    this.studentDisplayName,
    this.studentIdentifier,
  });

  final CurriculumLookupRepository repository;

  /// Chỉ truyền từ F01/account.me() khi đã xác minh; để null nếu không có.
  final String? studentDisplayName;
  final String? studentIdentifier;

  @override
  State<CurriculumLookupScreen> createState() => _CurriculumLookupScreenState();
}

class _CurriculumLookupScreenState extends State<CurriculumLookupScreen> {
  CurriculumDetails? _details;
  bool _loading = true;
  String? _error;
  _CourseFilter _filter = _CourseFilter.all;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final details = await widget.repository.getMyCurriculum();
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _details = details;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      final code = error.toString().toUpperCase();
      setState(() {
        _loading = false;
        _details = null;
        _error = code.contains('AUTH_REQUIRED') ||
                code.contains('UNAUTHENTICATED')
            ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
            : code.contains('FORBIDDEN') ||
                    code.contains('ACCOUNT_NOT_PROVISIONED') ||
                    code.contains('ACCOUNT_INACTIVE')
                ? 'Tài khoản không có quyền xem chương trình đào tạo này.'
                : 'Không tải được chương trình đào tạo. Hãy kiểm tra kết nối và thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.background,
      body: Column(
        children: [
          _buildBlueHeader(context),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildBlueHeader(BuildContext context) {
    final name = widget.studentDisplayName?.trim();
    final id = widget.studentIdentifier?.trim();
    return Container(
      width: double.infinity,
      color: _Palette.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CHƯƠNG TRÌNH ĐÀO TẠO',
                style: TextStyle(
                  color: Color(0xFFCFDFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  IconButton(
                    key: const ValueKey('f04-back'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.only(right: 12),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    tooltip: 'Quay lại',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HCM-UTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          name != null && name.isNotEmpty
                              ? name
                              : 'Sinh viên đang đăng nhập',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (id != null && id.isNotEmpty)
                          Text(
                            id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFCFDFFF),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFF3272C7),
                    child: Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: Column(
          key: ValueKey('f04-loading'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải chương trình đào tạo...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return _message(
        keyName: 'f04-error',
        icon: Icons.wifi_off_outlined,
        message: _error!,
        retry: true,
      );
    }
    final details = _details;
    if (details == null) {
      return _message(
        keyName: 'f04-unassigned',
        icon: Icons.assignment_late_outlined,
        message: 'Sinh viên chưa được gán chương trình đào tạo hoặc dữ liệu CTĐT chưa đầy đủ.',
        retry: true,
      );
    }

    final courses = details.items.where((course) {
      return switch (_filter) {
        _CourseFilter.all => true,
        _CourseFilter.mandatory => course.isRequired,
        _CourseFilter.elective => !course.isRequired,
      };
    }).toList()
      ..sort((a, b) {
        final semesterCompare = a.semester.compareTo(b.semester);
        return semesterCompare != 0
            ? semesterCompare
            : a.code.compareTo(b.code);
      });

    final groups = <int, List<CurriculumCourse>>{};
    for (final course in courses) {
      groups.putIfAbsent(course.semester, () => []).add(course);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: const ValueKey('f04-scroll-view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          _curriculumHeading(details),
          const SizedBox(height: 14),
          const _ProgressUnavailableCard(),
          const SizedBox(height: 16),
          _filterBar(),
          const SizedBox(height: 17),
          const Text(
            'Học phần theo học kỳ',
            style: TextStyle(
              fontSize: 20,
              color: _Palette.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Chọn một học kỳ để xem danh sách học phần',
            style: TextStyle(fontSize: 13, color: _Palette.muted),
          ),
          const SizedBox(height: 14),
          if (details.items.isEmpty)
            _emptyCard(
              keyName: 'f04-empty-items',
              message: 'Chương trình này chưa có danh sách học phần.',
            )
          else if (courses.isEmpty)
            _emptyCard(
              keyName: 'f04-filter-empty',
              message: 'Không có học phần phù hợp với bộ lọc.',
            )
          else
            for (final entry in groups.entries) ...[
              _SemesterCard(
                key: ValueKey('f04-semester-${entry.key}'),
                semester: entry.key,
                courses: entry.value,
                initiallyExpanded: entry.key == groups.keys.first,
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 6),
          const Text(
            'Các khối kiến thức và tín chỉ tích lũy sẽ được bổ sung theo dữ liệu backend đã duyệt; không dùng số liệu mẫu trong Figma.',
            style: TextStyle(
              color: _Palette.muted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _curriculumHeading(CurriculumDetails d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                d.name,
                key: const ValueKey('f04-curriculum-name'),
                style: const TextStyle(
                  fontSize: 21,
                  color: _Palette.ink,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: _Palette.blueSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                'Bản ${d.versionCode}',
                style: const TextStyle(
                  color: _Palette.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Mã CTĐT: ${d.code}  •  Mã ngành: ${d.majorCode}',
          style: const TextStyle(color: _Palette.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          'Năm hiệu lực: ${d.effectiveYear}  •  Trạng thái: ${d.versionStatus}',
          style: const TextStyle(color: _Palette.muted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _filterBar() {
    return Row(
      key: const ValueKey('f04-filter-bar'),
      children: [
        _filterButton(_CourseFilter.all, 'Tất cả'),
        const SizedBox(width: 8),
        _filterButton(_CourseFilter.mandatory, 'Bắt buộc'),
        const SizedBox(width: 8),
        _filterButton(_CourseFilter.elective, 'Tự chọn'),
      ],
    );
  }

  Widget _filterButton(_CourseFilter filter, String text) {
    final selected = _filter == filter;
    return Expanded(
      child: InkWell(
        key: ValueKey('f04-filter-${filter.name}'),
        onTap: () => setState(() => _filter = filter),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 42),
          decoration: BoxDecoration(
            color: selected ? _Palette.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? _Palette.primary : _Palette.border,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Colors.white : _Palette.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _message({
    required String keyName,
    required IconData icon,
    required String message,
    required bool retry,
  }) {
    return Center(
      child: Padding(
        key: ValueKey(keyName),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: _Palette.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (retry) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emptyCard({required String keyName, required String message}) {
    return Container(
      key: ValueKey(keyName),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Text(message, style: const TextStyle(color: _Palette.muted)),
    );
  }
}

class _ProgressUnavailableCard extends StatelessWidget {
  const _ProgressUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('f04-progress-placeholder'),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tiến độ tích lũy',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _Palette.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _Palette.greenSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Chờ F23',
                  style: TextStyle(
                    color: _Palette.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có dữ liệu tiến độ học tập',
            style: TextStyle(
              fontSize: 16,
              color: _Palette.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tín chỉ đã tích lũy, phần trăm hoàn thành và trạng thái môn sẽ được cập nhật từ API F23.',
            style: TextStyle(
              color: _Palette.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    super.key,
    required this.semester,
    required this.courses,
    required this.initiallyExpanded,
  });

  final int semester;
  final List<CurriculumCourse> courses;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('semester-$semester'),
        initiallyExpanded: initiallyExpanded,
        iconColor: _Palette.primary,
        collapsedIconColor: _Palette.muted,
        tilePadding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 11),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          semester > 0 ? 'Học kỳ $semester' : 'Chưa xác định học kỳ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _Palette.primary,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Danh sách học phần theo chương trình',
            style: TextStyle(color: _Palette.muted, fontSize: 11),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: _Palette.blueSoft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                '${courses.length} môn',
                style: const TextStyle(
                  color: _Palette.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.unfold_more_rounded, color: _Palette.primary),
          ],
        ),
        children: [
          for (final course in courses) _CourseLine(course: course),
        ],
      ),
    );
  }
}

class _CourseLine extends StatelessWidget {
  const _CourseLine({required this.course});

  final CurriculumCourse course;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('f04-course-${course.code}'),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _Palette.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _Palette.blueSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu_book_outlined,
                color: _Palette.accent, size: 15),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _Palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.code} · ${course.credits} TC · ${course.isRequired ? 'Bắt buộc' : 'Tự chọn'}',
                  style: const TextStyle(fontSize: 12, color: _Palette.muted),
                ),
                if (course.description != null &&
                    course.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    course.description!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _Palette.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              color: _Palette.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Chờ F23',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _Palette.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
