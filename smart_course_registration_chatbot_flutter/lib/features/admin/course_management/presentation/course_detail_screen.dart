import 'package:flutter/material.dart';

import '../../../../core/widgets/shared_app_header.dart';
import '../data/course_management_repository.dart';
import '../domain/admin_course.dart';
import 'course_error_message.dart';
import 'course_form_screen.dart';
import 'f06_figma_components.dart';

/// F06: trang chi tiết đối chiếu SVG "Chi tiết môn học".
/// Chỉ hiển thị dữ liệu thật có trong CourseDto, không bịa khoa/CTĐT/tiên quyết.
class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.repository,
    required this.course,
  });
  final CourseManagementRepository repository;
  final AdminCourse course;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  AdminCourse? _item;
  bool _loading = true;
  bool _mutating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.course;
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final id = widget.course.id;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final updated = await widget.repository.getById(id);
      if (!mounted) return;
      setState(() {
        _item = updated;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = courseErrorMessage(error);
        _loading = false;
      });
    }
  }

  Future<void> _edit() async {
    final course = _item;
    if (course == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CourseFormScreen(repository: widget.repository, course: course),
      ),
    );
    if (!mounted || changed != true) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deactivate() async {
    final course = _item;
    if (course == null || !course.isActive || course.id == null || _mutating) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tạm ẩn môn học?'),
        content: Text(
          '${course.code} sẽ ngừng hoạt động. Dữ liệu lịch sử được giữ nguyên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
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
      if (!mounted) {
        return;
      }
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể ngừng hoạt động môn học. Hãy tải lại.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(courseErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _mutating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _item;
    return Scaffold(
      backgroundColor: F06Ui.background,
      body: SafeArea(
        child: Column(
          children: [
            SharedAppHeader.academic(
              sectionTitle: 'ADMIN · QUẢN LÝ MÔN HỌC',
              identityLine: 'Quản trị hệ thống · Admin',
              detail: 'Chi tiết môn học',
              onLeading: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                key: const ValueKey('f06-detail-scroll'),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                children: [
                  if (_loading)
                    const SizedBox(
                      height: 240,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            key: const ValueKey('f06-detail-error'),
                          ),
                          FilledButton(
                            onPressed: _refresh,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  else if (course != null) ...[
                    F06Panel(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: F06Ui.navy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                      color: F06Ui.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    course.code,
                                    style: const TextStyle(
                                      color: F06Ui.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  Wrap(
                                    spacing: 9,
                                    runSpacing: 8,
                                    children: [
                                      _infoPill('${course.credits} TC'),
                                      const _InfoUnknown(),
                                      F06StatusPill(active: course.isActive),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    (course.description ?? '').trim().isEmpty
                                        ? 'Chưa có mô tả môn học.'
                                        : course.description!,
                                    style: const TextStyle(
                                      color: F06Ui.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: F06Ui.outline),
                                  _infoRow('Mã môn', course.code),
                                  _infoRow('Số tín chỉ', '${course.credits}'),
                                  _infoRow(
                                    'Khoa phụ trách',
                                    'Chưa có dữ liệu API',
                                  ),
                                  _infoRow(
                                    'Trạng thái',
                                    course.isActive
                                        ? 'Đang hoạt động'
                                        : 'Tạm ẩn',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const F06SectionHeading(
                      title: 'Liên kết chương trình đào tạo',
                    ),
                    const SizedBox(height: 10),
                    const F06ReadonlyNote(
                      title: 'Chờ API F07',
                      description:
                          'API F06 hiện chưa cung cấp các phiên bản CTĐT liên kết với môn này.',
                    ),
                    const SizedBox(height: 18),
                    const F06SectionHeading(title: 'Thao tác quản lý'),
                    const SizedBox(height: 12),
                    _actionRow(
                      Icons.edit_outlined,
                      'Chỉnh sửa thông tin môn',
                      _edit,
                    ),
                    const SizedBox(height: 9),
                    _actionRow(
                      Icons.account_tree_outlined,
                      'Quản lý điều kiện tiên quyết',
                      null,
                      note: 'Chờ giao diện và API F09',
                    ),
                    const SizedBox(height: 9),
                    _actionRow(
                      Icons.block_outlined,
                      'Tạm ẩn môn học',
                      course.isActive ? _deactivate : null,
                      note: course.isActive ? null : 'Môn đã tạm ẩn',
                    ),
                  ],
                ],
              ),
            ),
            if (!_loading && _error == null && course != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: F06Ui.outline)),
                ),
                child: FilledButton(
                  key: const ValueKey('f06-detail-edit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: F06Ui.navy,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _mutating ? null : _edit,
                  child: const Text(
                    'Chỉnh sửa môn học',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(color: F06Ui.secondary, fontSize: 13),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: F06Ui.ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _infoPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    decoration: BoxDecoration(
      color: F06Ui.paleBlue,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      label,
      style: const TextStyle(color: F06Ui.navy, fontWeight: FontWeight.w700),
    ),
  );

  Widget _actionRow(
    IconData icon,
    String text,
    VoidCallback? callback, {
    String? note,
  }) => F06Panel(
    padding: EdgeInsets.zero,
    child: ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: F06Ui.paleBlue,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: F06Ui.navy, size: 21),
      ),
      title: Text(
        text,
        style: const TextStyle(
          color: F06Ui.ink,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
      subtitle: note == null
          ? null
          : Text(note, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, color: F06Ui.navy),
      onTap: callback,
    ),
  );
}

class _InfoUnknown extends StatelessWidget {
  const _InfoUnknown();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    decoration: BoxDecoration(
      color: F06Ui.paleBlue,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Text(
      'Khoa: chờ API',
      style: TextStyle(fontWeight: FontWeight.w700, color: F06Ui.navy),
    ),
  );
}
