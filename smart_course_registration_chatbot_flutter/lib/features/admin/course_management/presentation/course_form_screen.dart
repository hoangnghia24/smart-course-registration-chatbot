import 'package:flutter/material.dart';

import '../../../../core/widgets/shared_app_header.dart';
import '../data/course_management_repository.dart';
import '../domain/admin_course.dart';
import 'course_error_message.dart';
import 'course_form_validator.dart';
import 'f06_figma_components.dart';

/// Biểu mẫu F06 theo SVG "Thêm môn học", đồng thời dùng cho chỉnh sửa.
/// Không tự phát sinh khoa phụ trách (CourseDto hiện không có thuộc tính này).
class CourseFormScreen extends StatefulWidget {
  const CourseFormScreen({super.key, required this.repository, this.course});

  final CourseManagementRepository repository;
  final AdminCourse? course;

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _credits;
  late final TextEditingController _description;
  bool _saving = false;
  bool _reactivate = false;
  bool _createActive = true;
  String? _error;

  bool get _editing => widget.course != null;

  @override
  void initState() {
    super.initState();
    final item = widget.course;
    _code = TextEditingController(text: item?.code ?? '');
    _name = TextEditingController(text: item?.name ?? '');
    _credits = TextEditingController(text: item?.credits.toString() ?? '');
    _description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _credits.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final item = AdminCourse(
      id: widget.course?.id,
      code: _code.text.trim(),
      name: _name.text.trim(),
      credits: int.parse(_credits.text.trim()),
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      isActive: _editing
          ? (widget.course!.isActive || _reactivate)
          : _createActive,
    );
    try {
      if (_editing) {
        await widget.repository.update(item);
      } else {
        await widget.repository.create(item);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = courseErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _editing ? 'Chỉnh sửa môn học' : 'Thêm môn học';
    return Scaffold(
      backgroundColor: F06Ui.background,
      body: SafeArea(
        child: Column(
          children: [
            SharedAppHeader.academic(
              sectionTitle: 'ADMIN · QUẢN LÝ MÔN HỌC',
              identityLine: 'Quản trị hệ thống · Admin',
              detail: title,
              onLeading: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  key: const ValueKey('f06-form-scroll'),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  children: [
                    F06SectionHeading(
                      title: title,
                      subtitle: _editing
                          ? 'Cập nhật thông tin danh mục môn học'
                          : 'Nhập thông tin danh mục môn học',
                    ),
                    const SizedBox(height: 16),
                    F06Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldTitle('Tên môn học *'),
                          TextFormField(
                            key: const ValueKey('f06-form-name'),
                            controller: _name,
                            enabled: !_saving,
                            decoration: _decoration(
                              'Ví dụ: Công nghệ phần mềm',
                            ),
                            validator: CourseFormValidator.name,
                          ),
                          const SizedBox(height: 14),
                          _fieldTitle('Mã môn *'),
                          TextFormField(
                            key: const ValueKey('f06-form-code'),
                            controller: _code,
                            enabled: !_saving,
                            textCapitalization: TextCapitalization.characters,
                            decoration: _decoration('Ví dụ: SE330101'),
                            validator: CourseFormValidator.code,
                          ),
                          const SizedBox(height: 14),
                          _fieldTitle('Số tín chỉ *'),
                          TextFormField(
                            key: const ValueKey('f06-form-credits'),
                            controller: _credits,
                            enabled: !_saving,
                            keyboardType: TextInputType.number,
                            decoration: _decoration('1–12'),
                            validator: CourseFormValidator.credits,
                          ),
                          const SizedBox(height: 14),
                          _fieldTitle('Khoa phụ trách'),
                          const F06ReadonlyNote(
                            title: 'Chưa có trong API F06',
                            description:
                                'CourseDto chưa có thông tin khoa. Không thể nhập hoặc lưu trường này ở phiên bản hiện tại.',
                          ),
                          const SizedBox(height: 14),
                          _fieldTitle('Trạng thái'),
                          if (!_editing)
                            DropdownButtonFormField<bool>(
                              key: const ValueKey('f06-form-status'),
                              initialValue: _createActive,
                              decoration: _decoration(null),
                              items: const [
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Đang hoạt động'),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Tạm ẩn'),
                                ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(
                                      () => _createActive = value ?? true,
                                    ),
                            )
                          else ...[
                            F06StatusPill(active: widget.course!.isActive),
                            if (!widget.course!.isActive)
                              CheckboxListTile(
                                key: const ValueKey('f06-reactivate'),
                                value: _reactivate,
                                onChanged: _saving
                                    ? null
                                    : (value) => setState(
                                        () => _reactivate = value ?? false,
                                      ),
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Kích hoạt lại môn học'),
                                subtitle: const Text(
                                  'Yêu cầu Backend cập nhật isActive = true',
                                ),
                              ),
                            if (widget.course!.isActive)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Để tạm ẩn môn học, dùng thao tác xác nhận ở danh sách hoặc trang chi tiết.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: F06Ui.secondary,
                                  ),
                                ),
                              ),
                          ],
                          const SizedBox(height: 14),
                          _fieldTitle('Mô tả môn học'),
                          TextFormField(
                            key: const ValueKey('f06-form-description'),
                            controller: _description,
                            enabled: !_saving,
                            minLines: 3,
                            maxLines: 5,
                            decoration: _decoration(
                              'Mô tả ngắn nội dung học phần',
                            ),
                          ),
                          const SizedBox(height: 18),
                          const F06ReadonlyNote(
                            title: 'Lưu ý',
                            description:
                                'Phân loại môn bắt buộc/tự chọn thuộc phiên bản CTĐT và được quản lý trong F07.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: F06Ui.outline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      key: const ValueKey('f06-form-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: F06Ui.navy,
                            backgroundColor: F06Ui.paleBlue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: F06Ui.outline),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('f06-form-save'),
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: F06Ui.navy,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Lưu môn học',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
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

  Widget _fieldTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 7, left: 3),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: F06Ui.navy,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: F06Ui.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _decoration(String? hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: F06Ui.outline),
      borderRadius: BorderRadius.circular(13),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: F06Ui.navy),
      borderRadius: BorderRadius.circular(13),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(13),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(13),
    ),
  );
}
