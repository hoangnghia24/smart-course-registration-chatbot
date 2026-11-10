import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/shared_app_header.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'data/course_lookup_repository.dart';

/// F03 — Tra cứu học phần. Bám bố cục SVG 390x844, tối ưu màn hình điện thoại.
/// Mọi dữ liệu học vụ trong bản mẫu chưa được xác minh và không phải dữ liệu API.
class CourseLookupScreen extends StatefulWidget {
  const CourseLookupScreen({
    super.key,
    this.studentName = 'Sinh viên demo',
    this.studentCode = 'SV001',
    this.program = 'Công nghệ phần mềm',
    this.repository,
    this.isLiveData = false,
  });

  final String studentName;
  final String studentCode;
  final String program;
  final CourseLookupRepository? repository;
  /// True khi repository lấy dữ liệu từ Serverpod, không hiển thị mock như thật.
  final bool isLiveData;

  @override
  State<CourseLookupScreen> createState() => _CourseLookupScreenState();
}

class _CourseLookupScreenState extends State<CourseLookupScreen> {
  late final TextEditingController _searchController;
  late final CourseLookupRepository _repository;
  Timer? _debounce;
  CourseLookupFilter _filter = CourseLookupFilter.all;
  List<CourseInfo> _courses = const [];
  String? _expandedCode;
  String? _error;
  bool _loading = true;
  int _requestId = 0;
  Future<CourseInfo>? _detailFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Lập trình');
    _repository = widget.repository ?? const DemoCourseLookupRepository();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCourses();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final currentRequest = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository.lookup(
        query: _searchController.text,
        filter: _filter,
      );
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _courses = result;
        _loading = false;
        _expandedCode = result.any((c) => c.code == _expandedCode)
            ? _expandedCode
            : (result.isEmpty ? null : result.first.code);
        if (widget.isLiveData && _expandedCode != null) {
          final course = result.firstWhere((c) => c.code == _expandedCode);
          _detailFuture = course.id == null
              ? Future<CourseInfo>.error(StateError('Thiếu ID học phần.'))
              : (_repository as CourseDetailsRepository).getCourseById(course.id!);
        } else {
          _detailFuture = null;
        }
      });
    } catch (_) {
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _loading = false;
        _error = 'Chưa thể tải danh sách học phần. Vui lòng thử lại.';
        _courses = const [];
      });
    }
  }

  void _onQueryChanged(String _) {
    setState(() {}); // Cập nhật biểu tượng xóa trong ô tìm kiếm.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _loadCourses);
  }

  void _onClearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _loadCourses();
  }

  void _setFilter(CourseLookupFilter filter) {
    if (_filter == filter) return;
    _debounce?.cancel();
    if (widget.isLiveData && filter == CourseLookupFilter.majorOnly) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('API F03 chưa hỗ trợ lọc học phần theo ngành/CTĐT.'),
        ));
      return;
    }
    _filter = filter;
    _loadCourses();
  }

  void _showSampleWarning() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Đây là dữ liệu minh họa. Chưa có API lớp học phần/đăng ký thật.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showPrerequisiteInformation() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tiên quyết và tương đương',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chưa có dữ liệu hoặc quy định học vụ được xác minh từ hệ thống. '
                'Khi API và nguồn chính thức sẵn sàng, thông tin sẽ được cập nhật tại đây.',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đã hiểu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SharedAppHeader.academic(
            sectionTitle: 'TRA CỨU HỌC PHẦN',
            identityLine: widget.studentCode.isEmpty
                ? widget.studentName
                : '${widget.studentName} - ${widget.studentCode}',
            detail: widget.program,
            leadingIcon: Icons.menu_rounded,
            leadingKey: const ValueKey('course-back'),
            leadingTooltip: 'Quay về Dashboard',
            onLeading: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                showPreviewMessage(context, 'Đây là màn hình tra cứu học phần.');
              }
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                key: const ValueKey('course-scroll'),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tìm kiếm học phần',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    _buildFilters(),
                    const SizedBox(height: 12),
                    if (widget.isLiveData)
                      const Text(
                        'DỮ LIỆU F03 TỪ SERVERPOD • TỐI ĐA 50 KẾT QUẢ',
                        key: ValueKey('course-live-label'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      )
                    else
                      const Text(
                        'BẢN MẪU • DỮ LIỆU MINH HỌA • CHƯA KẾT NỐI F03',
                        key: ValueKey('course-demo-label'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Kết quả tra cứu',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!_loading && _error == null)
                          Text(
                            '${_courses.length} học phần',
                            key: const ValueKey('course-result-count'),
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildResults(),
                    const SizedBox(height: 14),
                    _buildPrerequisiteShortcut(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E2F0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: Color(0xFF8394AB), size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey('course-search'),
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              onSubmitted: (_) {
                _debounce?.cancel();
                _loadCourses();
              },
              decoration: const InputDecoration(
                hintText: 'Nhập tên hoặc mã học phần',
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('course-clear'),
            tooltip: 'Xóa từ khóa',
            onPressed: _searchController.text.isEmpty ? null : _onClearSearch,
            icon: const Icon(Icons.close_rounded, color: Color(0xFF98A7BA)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterChip(CourseLookupFilter.all, 'Tất cả'),
        const SizedBox(width: 8),
        _filterChip(CourseLookupFilter.majorOnly, 'Đúng ngành'),
        const SizedBox(width: 8),
        _filterChip(CourseLookupFilter.threeCredits, '3 tín chỉ'),
      ],
    );
  }

  Widget _filterChip(CourseLookupFilter value, String label) {
    final selected = _filter == value;
    return Expanded(
      child: SizedBox(
        height: 35,
        child: OutlinedButton(
          key: ValueKey('course-filter-${value.name}'),
          onPressed: () => _setFilter(value),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            backgroundColor: selected ? AppColors.primary : Colors.white,
            foregroundColor: selected ? Colors.white : AppColors.mutedText,
            side: BorderSide(
              color: selected ? AppColors.primary : const Color(0xFFD8E2F0),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(key: ValueKey('course-loading')),
              SizedBox(height: 12),
              Text('Đang tải danh sách học phần...'),
            ],
          ),
        ),
      );
    }
    if (_error != null) {
      return _StatusCard(
        key: const ValueKey('course-error'),
        icon: Icons.wifi_off_rounded,
        message: _error!,
        actionLabel: 'Thử lại',
        onAction: _loadCourses,
      );
    }
    if (_courses.isEmpty) {
      return _StatusCard(
        key: const ValueKey('course-empty'),
        icon: Icons.search_off_rounded,
        message: widget.isLiveData && _searchController.text.trim().isEmpty
            ? 'Nhập tên hoặc mã học phần để tra cứu.'
            : 'Không có học phần phù hợp với từ khóa hoặc bộ lọc.',
        actionLabel: 'Xóa tìm kiếm',
        onAction: _onClearSearch,
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _courses.length; i++) ...[
          if (widget.isLiveData)
            _LiveCourseCard(
              key: ValueKey('course-card-${_courses[i].code}'),
              course: _courses[i],
              expanded: _expandedCode == _courses[i].code,
              detailFuture: _expandedCode == _courses[i].code
                  ? _detailFuture
                  : null,
              onToggle: () => _toggleLiveCourse(_courses[i]),
              onRetry: () => _fetchLiveDetails(_courses[i]),
            )
          else
            _CourseCard(
              key: ValueKey('course-card-${_courses[i].code}'),
              course: _courses[i],
              expanded: _expandedCode == _courses[i].code,
              onToggle: () {
                setState(() {
                  _expandedCode = _expandedCode == _courses[i].code
                      ? null
                      : _courses[i].code;
                });
              },
              onShowRules: _showPrerequisiteInformation,
              onRegister: _showSampleWarning,
            ),
          if (i != _courses.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _toggleLiveCourse(CourseInfo course) {
    if (_expandedCode == course.code) {
      setState(() {
        _expandedCode = null;
        _detailFuture = null;
      });
    } else {
      setState(() {
        _expandedCode = course.code;
        _detailFuture = course.id == null
            ? Future<CourseInfo>.error(StateError('Thiếu ID học phần.'))
            : (_repository as CourseDetailsRepository).getCourseById(course.id!);
      });
    }
  }

  void _fetchLiveDetails(CourseInfo course) {
    setState(() {
      _detailFuture = course.id == null
          ? Future<CourseInfo>.error(StateError('Thiếu ID học phần.'))
          : (_repository as CourseDetailsRepository).getCourseById(course.id!);
    });
  }

  Widget _buildPrerequisiteShortcut() {
    return Material(
      color: const Color(0xFFECF3FF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('course-prerequisite-shortcut'),
        borderRadius: BorderRadius.circular(14),
        onTap: _showPrerequisiteInformation,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFD8E8FF),
                child: Icon(Icons.check_rounded, color: AppColors.primary),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tra cứu tiên quyết và tương đương',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Kiểm tra quan hệ giữa các môn học',
                      style: TextStyle(color: AppColors.mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}


/// Thẻ dữ liệu F03 thật: chỉ hiển thị các trường CourseDto được backend cung cấp.
/// Không bịa trạng thái đã đạt, lớp đang mở, tiên quyết hoặc lịch học.
class _LiveCourseCard extends StatelessWidget {
  const _LiveCourseCard({
    super.key,
    required this.course,
    required this.expanded,
    required this.detailFuture,
    required this.onToggle,
    required this.onRetry,
  });

  final CourseInfo course;
  final bool expanded;
  final Future<CourseInfo>? detailFuture;
  final VoidCallback onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: const Color(0xFFF6F9FF),
            child: InkWell(
              key: ValueKey('course-live-toggle-${course.code}'),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              )),
                          const SizedBox(height: 5),
                          Text('Mã môn: ${course.code}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText,
                              )),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _Tag('${course.credits} TC',
                            color: AppColors.primary,
                            background: const Color(0xFFE2EEFF)),
                        Icon(expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
              child: detailFuture == null
                  ? const Text('Chưa có thông tin chi tiết học phần.')
                  : FutureBuilder<CourseInfo>(
                      future: detailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: CircularProgressIndicator(
                                key: ValueKey('course-detail-loading')),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Không tải được chi tiết học phần.'),
                              TextButton(onPressed: onRetry,
                                  child: const Text('Thử lại chi tiết')),
                            ],
                          );
                        }
                        final details = snapshot.data!;
                        return Column(
                          key: const ValueKey('course-live-details'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Tag(details.isActive == true
                                  ? 'Môn đang hoạt động' : 'Môn ngừng hoạt động',
                                color: AppColors.primary,
                                background: const Color(0xFFE9F1FF)),
                            const SizedBox(height: 12),
                            const Text('Mô tả học phần',
                              style: TextStyle(fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                            const SizedBox(height: 6),
                            Text(details.description?.trim().isNotEmpty == true
                                  ? details.description!
                                  : 'Chưa có mô tả trong cơ sở dữ liệu.',
                              style: const TextStyle(color: AppColors.mutedText)),
                            const SizedBox(height: 12),
                            const Text(
                              'API F03 chưa cung cấp lớp đang mở, điểm đã đạt '
                              'và điều kiện tiên quyết.',
                              style: TextStyle(fontSize: 11,
                                  color: AppColors.mutedText),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: null,
                                child: Text('Xem lớp và đăng ký (chưa hỗ trợ)'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    super.key,
    required this.course,
    required this.expanded,
    required this.onToggle,
    required this.onShowRules,
    required this.onRegister,
  });

  final CourseInfo course;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onShowRules;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    if (course.isCompleted) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 15,
              backgroundColor: Color(0xFFDCF7E9),
              child: Icon(Icons.check_rounded, color: Color(0xFF119B70), size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${course.code} · ${course.credits} tín chỉ',
                    style: const TextStyle(color: AppColors.mutedText, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.sampleGrade == null
                        ? 'Trạng thái mẫu: Đã đạt'
                        : 'Điểm đã đạt (mẫu): ${course.sampleGrade!.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFF138F66),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
            _Tag('Đã đạt', color: const Color(0xFF138F66), background: const Color(0xFFE3F8EC)),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: const Color(0xFFF6F9FF),
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 12, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Mã môn: ${course.code}',
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _Tag('${course.credits} TC', color: AppColors.primary, background: const Color(0xFFE2EEFF)),
                        Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    children: [
                      _Tag(
                        course.inMajor ? 'Chuyên ngành' : 'Ngoài ngành',
                        color: const Color(0xFF2862AF),
                        background: const Color(0xFFE9F1FF),
                      ),
                      const _Tag(
                        'Chưa học',
                        color: Color(0xFF68788D),
                        background: Color(0xFFF0F2F6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    key: const ValueKey('course-rules-link'),
                    onTap: onShowRules,
                    child: const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Điều kiện học phần',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
                              SizedBox(height: 5),
                              Text('Xem tiên quyết và môn tương đương',
                                  style: TextStyle(fontSize: 11, color: AppColors.mutedText)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const Divider(height: 20, color: Color(0xFFE6EBF3)),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Lớp học phần đang mở',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text)),
                      ),
                      _Tag('${course.classes.length} lớp',
                          color: AppColors.primary, background: const Color(0xFFE8F1FF)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final section in course.classes) ...[
                    _ClassSampleTile(section: section),
                    const SizedBox(height: 9),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: FilledButton(
                      key: const ValueKey('course-register-preview'),
                      onPressed: onRegister,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      child: const Text(
                        'Xem lớp và đăng ký',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClassSampleTile extends StatelessWidget {
  const _ClassSampleTile({required this.section});
  final CourseClassInfo section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE4EBF5)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.classCode,
              style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(section.schedule,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 11)),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${section.registered}/${section.capacity} sinh viên đã đăng ký',
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 10),
                ),
              ),
              _Tag('Còn ${section.remaining}',
                  color: const Color(0xFF138F66), background: const Color(0xFFE3F8EC)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.color, required this.background});
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(9)),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    super.key,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.mutedText),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text)),
          const SizedBox(height: 9),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
