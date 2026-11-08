import 'package:flutter/material.dart';

import '../../../../core/widgets/shared_app_header.dart';
import '../data/course_management_repository.dart';
import '../domain/admin_course.dart';
import 'course_detail_screen.dart';
import 'course_error_message.dart';
import 'course_form_screen.dart';
import 'f06_figma_components.dart';

enum _CourseFilter { all, active, hidden }

/// F06: danh mục môn học theo SVG Admin - Danh sách.
/// Lọc trạng thái chỉ áp dụng lên trang đang tải do RPC chưa có status filter.
class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key, required this.repository});
  final CourseManagementRepository repository;

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  static const _pageSize = 20;
  final _search = TextEditingController();
  List<AdminCourse> _items = const [];
  _CourseFilter _filter = _CourseFilter.all;
  int _page = 1;
  int _requestNumber = 0;
  String _query = '';
  bool _loading = true;
  bool _mutating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _requestNumber++;
    _search.dispose();
    super.dispose();
  }

  List<AdminCourse> get _visibleItems => switch (_filter) {
    _CourseFilter.all => _items,
    _CourseFilter.active => _items.where((course) => course.isActive).toList(),
    _CourseFilter.hidden => _items.where((course) => !course.isActive).toList(),
  };

  Future<void> _load({int? page}) async {
    if (!mounted) return;
    final request = ++_requestNumber;
    final targetPage = page ?? _page;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = _query.isEmpty
          ? await widget.repository.getPage(
              page: targetPage,
              pageSize: _pageSize,
            )
          : await widget.repository.search(
              query: _query,
              page: targetPage,
              pageSize: _pageSize,
            );
      if (!mounted || request != _requestNumber) return;
      setState(() {
        _items = rows;
        _page = targetPage;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _requestNumber) return;
      setState(() {
        _error = courseErrorMessage(error);
        _loading = false;
      });
    }
  }

  Future<void> _submitSearch() async {
    if (_loading || _mutating) return;
    setState(() {
      _query = _search.text.trim();
      _filter = _CourseFilter.all;
    });
    await _load(page: 1);
  }

  Future<void> _clearSearch() async {
    if (_loading || _mutating) return;
    _search.clear();
    setState(() {
      _query = '';
      _filter = _CourseFilter.all;
    });
    await _load(page: 1);
  }

  Future<void> _openForm([AdminCourse? course]) async {
    if (_mutating) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CourseFormScreen(repository: widget.repository, course: course),
      ),
    );
    if (!mounted || changed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          course == null ? 'Đã thêm môn học' : 'Đã cập nhật môn học',
        ),
      ),
    );
    await _load(page: 1);
  }

  Future<void> _openDetail(AdminCourse course) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CourseDetailScreen(repository: widget.repository, course: course),
      ),
    );
    if (mounted && changed == true) await _load();
  }

  Future<void> _deactivate(AdminCourse course) async {
    if (_mutating || _loading || !course.isActive || course.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tạm ẩn môn học?'),
        content: Text(
          'Môn ${course.code} sẽ ngừng hoạt động. Dữ liệu lịch sử không bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            key: const ValueKey('f06-confirm-deactivate'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _mutating = true);
    try {
      final success = await widget.repository.deactivate(course.id!);
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể ngừng hoạt động môn học. Hãy tải lại.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã ngừng hoạt động môn học')),
        );
        await _load();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(courseErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: F06Ui.background,
      body: SafeArea(
        child: Column(
          children: [
            SharedAppHeader.academic(
              sectionTitle: 'ADMIN · QUẢN LÝ MÔN HỌC',
              identityLine: 'Quản trị hệ thống · Admin',
              detail: 'Danh mục môn học',
              leadingIcon: Icons.menu_rounded,
              onLeading: Navigator.of(context).canPop()
                  ? () => Navigator.of(context).maybePop()
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(),
                child: ListView(
                  key: const ValueKey('f06-list-scroll'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: F06SectionHeading(
                            title: 'Quản lý môn học',
                            subtitle:
                                'Theo dõi danh mục môn học của nhà trường',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: F06Ui.paleBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
                          child: Text(
                            '${_items.length} môn/trang',
                            style: const TextStyle(
                              color: F06Ui.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey('f06-search-field'),
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Tìm tên môn, mã môn...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: F06Ui.secondary,
                        ),
                        suffixIcon: IconButton(
                          key: const ValueKey('f06-clear-search'),
                          tooltip: 'Xóa tìm kiếm',
                          onPressed: (_loading || _mutating)
                              ? null
                              : _clearSearch,
                          icon: const Icon(Icons.close),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(color: F06Ui.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(color: F06Ui.outline),
                        ),
                      ),
                      onSubmitted: (_) => _submitSearch(),
                    ),
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: const ValueKey('f06-search-button'),
                        onPressed: (_loading || _mutating)
                            ? null
                            : _submitSearch,
                        icon: const Icon(Icons.search, size: 17),
                        label: const Text('Tìm kiếm'),
                      ),
                    ),
                    Wrap(
                      spacing: 7,
                      runSpacing: 8,
                      children: [
                        _filterChip('Tất cả', _CourseFilter.all),
                        _filterChip('Đang hoạt động', _CourseFilter.active),
                        _filterChip('Tạm ẩn', _CourseFilter.hidden),
                      ],
                    ),
                    if (_filter != _CourseFilter.all) ...[
                      const SizedBox(height: 5),
                      const Text(
                        'Bộ lọc trạng thái áp dụng cho trang đang xem (API chưa hỗ trợ lọc toàn bộ).',
                        style: TextStyle(color: F06Ui.secondary, fontSize: 11),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: F06SectionHeading(title: 'Danh sách môn học'),
                        ),
                        Text(
                          'Trang $_page',
                          style: const TextStyle(
                            color: F06Ui.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_loading)
                      const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            key: ValueKey('f06-loading'),
                          ),
                        ),
                      )
                    else if (_error != null)
                      SizedBox(
                        height: 220,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                key: const ValueKey('f06-error'),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              FilledButton(
                                key: const ValueKey('f06-retry'),
                                onPressed: _load,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_visibleItems.isEmpty)
                      SizedBox(
                        height: 180,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.menu_book_outlined,
                                size: 40,
                                color: F06Ui.secondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _filter != _CourseFilter.all
                                    ? 'Không có môn phù hợp trên trang này'
                                    : _query.isEmpty
                                    ? 'Chưa có môn học'
                                    : 'Không tìm thấy môn học',
                                key: const ValueKey('f06-empty'),
                              ),
                              if (_page > 1)
                                TextButton(
                                  onPressed: () => _load(page: _page - 1),
                                  child: const Text('Trang trước'),
                                ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      for (final course in _visibleItems) ...[
                        _courseCard(course),
                        const SizedBox(height: 10),
                      ],
                    ],
                    if (!_loading && _error == null && _items.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton(
                            key: const ValueKey('f06-prev-page'),
                            onPressed: (_page <= 1 || _mutating)
                                ? null
                                : () => _load(page: _page - 1),
                            child: const Text('Trước'),
                          ),
                          Expanded(
                            child: Text(
                              'Trang $_page',
                              key: const ValueKey('f06-page'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          OutlinedButton(
                            key: const ValueKey('f06-next-page'),
                            onPressed: (_items.length < _pageSize || _mutating)
                                ? null
                                : () => _load(page: _page + 1),
                            child: const Text('Tiếp'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: F06Ui.outline)),
              ),
              child: FilledButton.icon(
                key: const ValueKey('f06-add-course'),
                onPressed: (_loading || _mutating) ? null : () => _openForm(),
                style: FilledButton.styleFrom(
                  backgroundColor: F06Ui.navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Thêm môn học',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _CourseFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      key: ValueKey('f06-filter-${value.name}'),
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      backgroundColor: F06Ui.paleBlue,
      selectedColor: F06Ui.navy,
      side: BorderSide.none,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : F06Ui.navy,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }

  Widget _courseCard(AdminCourse course) {
    final itemId = course.id ?? course.code;
    return F06Panel(
      padding: const EdgeInsets.all(13),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: course.isActive ? F06Ui.navy : F06Ui.amber,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          key: ValueKey('f06-course-$itemId'),
                          style: const TextStyle(
                            color: F06Ui.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (course.isActive && course.id != null)
                        IconButton(
                          key: ValueKey('f06-deactivate-${course.id}'),
                          onPressed: _mutating
                              ? null
                              : () => _deactivate(course),
                          tooltip: 'Ngừng hoạt động',
                          icon: const Icon(
                            Icons.block_outlined,
                            size: 20,
                            color: F06Ui.amber,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${course.code} · ${course.credits} tín chỉ',
                    style: const TextStyle(
                      color: F06Ui.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Khoa phụ trách: chờ dữ liệu API',
                    style: TextStyle(color: F06Ui.secondary, fontSize: 11),
                  ),
                  const SizedBox(height: 9),
                  Align(
                    alignment: Alignment.centerRight,
                    child: F06StatusPill(active: course.isActive),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        key: ValueKey('f06-detail-$itemId'),
                        onPressed: _mutating ? null : () => _openDetail(course),
                        child: const Text('Xem chi tiết'),
                      ),
                      TextButton.icon(
                        key: ValueKey('f06-edit-$itemId'),
                        onPressed: _mutating ? null : () => _openForm(course),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Chỉnh sửa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
