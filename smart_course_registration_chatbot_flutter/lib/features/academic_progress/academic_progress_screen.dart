import 'package:flutter/material.dart';

import '../../core/widgets/shared_app_header.dart';
import 'data/academic_progress_repository.dart';

class _ThemeColors {
  static const primary = Color(0xFF0D47A1);
  static const background = Color(0xFFF5F7FA);
  static const ink = Color(0xFF273447);
  static const muted = Color(0xFF68788D);
  static const border = Color(0xFFDDE5F0);
  static const lightBlue = Color(0xFFE8F1FF);
  static const green = Color(0xFF16865B);
  static const lightGreen = Color(0xFFE2F6EC);
  static const red = Color(0xFFD93448);
  static const lightRed = Color(0xFFFCE9EC);
  static const orange = Color(0xFF9C660D);
  static const lightOrange = Color(0xFFFFF2D8);
}

enum _CourseStatusFilter { all, passed, failed, inProgress, notStarted }

/// F23 theo màn hình KẾT QUẢ HỌC TẬP trong Figma gốc của nhóm.
/// Các trị số Figma là minh họa: UI chỉ hiển thị dữ liệu từ repository/API.
class AcademicProgressScreen extends StatefulWidget {
  const AcademicProgressScreen({
    super.key,
    required this.repository,
    this.studentDisplayName,
    this.studentIdentifier,
  });

  final AcademicProgressRepository repository;
  final String? studentDisplayName;
  final String? studentIdentifier;

  @override
  State<AcademicProgressScreen> createState() => _AcademicProgressScreenState();
}

class _AcademicProgressScreenState extends State<AcademicProgressScreen> {
  AcademicProgressDetails? _details;
  bool _loading = true;
  String? _error;
  int _requestId = 0;
  int? _selectedSemester;
  _CourseStatusFilter _statusFilter = _CourseStatusFilter.all;

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
      final data = await widget.repository.getMyProgress();
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _details = data;
        _loading = false;
      });
    } catch (exception) {
      if (!mounted || requestId != _requestId) return;
      final code = exception.toString().toUpperCase();
      setState(() {
        _details = null;
        _loading = false;
        _error =
            code.contains('AUTH_REQUIRED') || code.contains('UNAUTHENTICATED')
            ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
            : code.contains('FORBIDDEN') ||
                  code.contains('ACCOUNT_NOT_PROVISIONED') ||
                  code.contains('ACCOUNT_INACTIVE')
            ? 'Tài khoản không có quyền xem kết quả học tập.'
            : 'Không tải được kết quả học tập. Hãy kiểm tra kết nối và thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ThemeColors.background,
      body: Column(
        children: [
          SharedAppHeader.academic(
            sectionTitle: 'KẾT QUẢ HỌC TẬP',
            identityLine: widget.studentDisplayName?.trim().isNotEmpty == true
                ? widget.studentDisplayName!.trim()
                : 'Sinh viên đang đăng nhập',
            detail: widget.studentIdentifier?.trim().isNotEmpty == true
                ? widget.studentIdentifier!.trim()
                : null,
            leadingKey: const ValueKey('f23-back'),
            onLeading: () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(
        child: Column(
          key: ValueKey('f23-loading'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Đang tải kết quả học tập...'),
          ],
        ),
      );
    }
    if (_error case final message?) {
      return _stateMessage('f23-error', Icons.wifi_off_rounded, message);
    }
    final data = _details;
    if (data == null) {
      return _stateMessage(
        'f23-unavailable',
        Icons.assignment_late_outlined,
        'Chưa có dữ liệu kết quả học tập cho tài khoản này.',
      );
    }
    final semesters =
        data.courses
            .map((c) => c.semester)
            .whereType<int>()
            .where((s) => s > 0)
            .toSet()
            .toList()
          ..sort();
    // Chỉ dùng semester theo CTĐT, KHÔNG trình bày như học kỳ thực tế.
    final effectiveSemester = semesters.contains(_selectedSemester)
        ? _selectedSemester
        : null;
    final semesterCourses = data.courses
        .where(
          (c) => effectiveSemester == null || c.semester == effectiveSemester,
        )
        .toList();
    final selectedCourses = semesterCourses.where((c) {
      return switch (_statusFilter) {
        _CourseStatusFilter.all => true,
        _CourseStatusFilter.passed => c.status == 'PASSED',
        _CourseStatusFilter.failed => c.status == 'FAILED',
        _CourseStatusFilter.inProgress => c.status == 'IN_PROGRESS',
        _CourseStatusFilter.notStarted => c.status == 'NOT_STARTED',
      };
    }).toList()..sort(_compareCourses);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: const ValueKey('f23-scroll-view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 17, 20, 36),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bảng điểm học tập',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ThemeColors.ink,
                  ),
                ),
              ),
              _pill('F23', _ThemeColors.lightBlue, _ThemeColors.primary),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: _cardDecoration(),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                key: const ValueKey('f23-semester-filter'),
                value: effectiveSemester,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Tất cả học kỳ theo CTĐT'),
                  ),
                  for (final semester in semesters)
                    DropdownMenuItem<int?>(
                      value: semester,
                      child: Text('Học kỳ $semester (theo CTĐT)'),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _selectedSemester = value;
                  _statusFilter = _CourseStatusFilter.all;
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  keyName: 'f23-gpa',
                  title: 'GPA',
                  value: data.gpa != null ? _formatScore(data.gpa!) : '—',
                  subtext: data.gpa == null
                      ? _gpaExplanation(data.gpaStatus)
                      : 'Theo dữ liệu học vụ',
                  icon: Icons.show_chart_rounded,
                  accent: _ThemeColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  keyName: 'f23-credits',
                  title: 'Tín chỉ tích lũy',
                  value: data.earnedCredits != null
                      ? '${data.earnedCredits}'
                      : '—',
                  subtext: data.totalCredits != null
                      ? 'Trong ${data.totalCredits} tín chỉ CTĐT'
                      : 'Tổng tín chỉ chưa xác định',
                  icon: Icons.check_circle_outline_rounded,
                  accent: _ThemeColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (data.remainingCredits != null)
            Text(
              'Tín chỉ còn thiếu: ${data.remainingCredits}',
              key: const ValueKey('f23-remaining-credits'),
              style: const TextStyle(color: _ThemeColors.muted, fontSize: 12),
            ),
          if (data.totalCredits == null || data.earnedCredits == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Một số tín chỉ chưa thể tổng hợp vì quy tắc môn tự chọn hoặc dữ liệu học vụ chưa hoàn chỉnh.',
                style: TextStyle(
                  color: _ThemeColors.muted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Điểm các học phần',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: _ThemeColors.ink,
                  ),
                ),
              ),
              Text(
                '${semesterCourses.length} môn',
                style: const TextStyle(fontSize: 11, color: _ThemeColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _statusFilters(semesterCourses),
          const SizedBox(height: 15),
          if (data.courses.isEmpty)
            _empty('f23-empty', 'Chưa có học phần trong kết quả học tập.')
          else if (selectedCourses.isEmpty)
            _empty('f23-filter-empty', 'Không có học phần phù hợp với bộ lọc.')
          else
            for (final course in selectedCourses) ...[
              _courseCard(course),
              const SizedBox(height: 9),
            ],
          const SizedBox(height: 10),
          const Text(
            'Thông tin dựa trên kết quả học vụ được backend cung cấp. '
            'GPA, điểm và tín chỉ chưa đủ điều kiện sẽ không được tự tính hoặc giả lập.',
            style: TextStyle(
              color: _ThemeColors.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String keyName,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      key: ValueKey(keyName),
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    color: _ThemeColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtext,
            maxLines: 3,
            style: const TextStyle(
              color: _ThemeColors.muted,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilters(List<AcademicCourseProgress> courses) {
    final items = <(_CourseStatusFilter, String, String)>[
      (_CourseStatusFilter.all, 'Tất cả', ''),
      (_CourseStatusFilter.passed, 'Đã đạt', 'PASSED'),
      (_CourseStatusFilter.failed, 'Chưa đạt', 'FAILED'),
      (_CourseStatusFilter.inProgress, 'Đang học', 'IN_PROGRESS'),
      (_CourseStatusFilter.notStarted, 'Chưa học', 'NOT_STARTED'),
    ];
    // Giữ hàng đầu theo Figma; các trạng thái bổ sung tự xuống dòng
    // ở màn hình hẹp, không còn nút bị cắt hoặc yêu cầu cuộn ngang.
    return Wrap(
      key: const ValueKey('f23-status-filters'),
      spacing: 7,
      runSpacing: 6,
      children: [
        for (final (filter, label, statusCode) in items)
          ChoiceChip(
            key: ValueKey('f23-filter-${filter.name}'),
            selected: _statusFilter == filter,
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(
              '$label (${statusCode.isEmpty ? courses.length : courses.where((c) => c.status == statusCode).length})',
            ),
            onSelected: (_) => setState(() => _statusFilter = filter),
            selectedColor: _ThemeColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: _statusFilter == filter
                  ? _ThemeColors.primary
                  : _ThemeColors.border,
            ),
            labelStyle: TextStyle(
              color: _statusFilter == filter
                  ? Colors.white
                  : _ThemeColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _courseCard(AcademicCourseProgress course) {
    final (label, foreground, background, statusIcon) = _statusStyle(
      course.status,
    );
    final scoreVisible =
        course.scoreStatus == 'AVAILABLE' && course.score != null;
    final groupName = (course.groupName ?? course.groupCode ?? '').trim();
    return Container(
      key: ValueKey('f23-course-${course.code}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: course.status == 'FAILED'
            ? const Color(0xFFFFF7F8)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: course.status == 'FAILED'
              ? const Color(0xFFFFD7DF)
              : _ThemeColors.border,
        ),
      ),
      child: Stack(
        children: [
          // Vạch trạng thái sát cạnh trái, đúng ngôn ngữ hình ảnh Figma.
          // Màu chỉ phản ánh trạng thái do API trả về.
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 4,
            child: ColoredBox(
              key: ValueKey('f23-status-stripe-${course.code}'),
              color: foreground,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 11, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: foreground, size: 17),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          color: _ThemeColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${course.code} · ${course.credits} tín chỉ',
                        style: const TextStyle(
                          color: _ThemeColors.muted,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (groupName.isNotEmpty)
                        Text(
                          groupName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ThemeColors.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      if (course.semester != null && course.semester! > 0)
                        Text(
                          'HK ${course.semester} theo CTĐT',
                          style: const TextStyle(
                            color: _ThemeColors.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      if (course.statusDetail case final detail?)
                        if (detail.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              detail,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _ThemeColors.muted,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      scoreVisible ? _formatScore(course.score!) : '—',
                      key: ValueKey('f23-score-${course.code}'),
                      style: TextStyle(
                        fontSize: 15,
                        color: scoreVisible ? foreground : _ThemeColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _pill(label, background, foreground),
                    if (!scoreVisible) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 77,
                        child: Text(
                          _scoreExplanation(course.scoreStatus),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: _ThemeColors.muted,
                            fontSize: 9.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateMessage(String keyName, IconData icon, String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: ValueKey(keyName),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: _ThemeColors.primary),
          const SizedBox(height: 13),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );

  Widget _empty(String keyName, String message) => Container(
    key: ValueKey(keyName),
    padding: const EdgeInsets.all(18),
    decoration: _cardDecoration(),
    child: Text(message, style: const TextStyle(color: _ThemeColors.muted)),
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15),
  border: Border.all(color: _ThemeColors.border),
);

Widget _pill(String label, Color background, Color foreground) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
  decoration: BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: foreground,
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  ),
);

String _formatScore(double value) => value
    .toStringAsFixed(2)
    .replaceFirst(RegExp(r'0+$'), '')
    .replaceFirst(RegExp(r'\.$'), '');

String _gpaExplanation(String status) => switch (status) {
  'POLICY_PENDING' => 'Chờ quy chế tính GPA',
  'NO_DATA' => 'Chưa có dữ liệu GPA',
  _ => 'GPA chưa được cung cấp',
};

String _scoreExplanation(String status) => switch (status) {
  'NOT_PUBLISHED' => 'Chưa công bố',
  'NO_DATA' => 'Chưa có điểm',
  'POLICY_PENDING' => 'Chờ quy chế',
  _ => 'Chưa có điểm',
};

(String, Color, Color, IconData) _statusStyle(String status) =>
    switch (status) {
      'PASSED' => (
        'Đã đạt',
        _ThemeColors.green,
        _ThemeColors.lightGreen,
        Icons.check_circle_rounded,
      ),
      'FAILED' => (
        'Chưa đạt',
        _ThemeColors.red,
        _ThemeColors.lightRed,
        Icons.cancel_rounded,
      ),
      'IN_PROGRESS' => (
        'Đang học',
        _ThemeColors.primary,
        _ThemeColors.lightBlue,
        Icons.access_time_filled_rounded,
      ),
      'NOT_STARTED' => (
        'Chưa học',
        _ThemeColors.orange,
        _ThemeColors.lightOrange,
        Icons.remove_circle_outline_rounded,
      ),
      _ => (
        'Chưa xác định',
        _ThemeColors.muted,
        _ThemeColors.background,
        Icons.help_outline_rounded,
      ),
    };

int _compareCourses(AcademicCourseProgress a, AcademicCourseProgress b) {
  const last = 0x7fffffff;
  final aHasGroup = (a.groupCode ?? a.groupName ?? '').trim().isNotEmpty;
  final bHasGroup = (b.groupCode ?? b.groupName ?? '').trim().isNotEmpty;
  if (aHasGroup != bHasGroup) return aHasGroup ? -1 : 1;
  final order = (a.groupOrder ?? last).compareTo(b.groupOrder ?? last);
  if (order != 0) return order;
  final group = (a.groupCode ?? a.groupName ?? '').compareTo(
    b.groupCode ?? b.groupName ?? '',
  );
  if (group != 0) return group;
  final itemOrder = (a.itemOrder ?? last).compareTo(b.itemOrder ?? last);
  if (itemOrder != 0) return itemOrder;
  return a.code.compareTo(b.code);
}
