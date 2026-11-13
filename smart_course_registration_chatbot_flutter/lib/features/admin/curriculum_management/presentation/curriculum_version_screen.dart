import 'package:flutter/material.dart';
import '../../../../core/widgets/shared_app_header.dart';
import '../data/curriculum_management_repository.dart';
import '../domain/managed_curriculum.dart';
import 'f07_ui.dart';

class CurriculumVersionScreen extends StatefulWidget {
  const CurriculumVersionScreen({
    super.key,
    required this.repository,
    required this.versionId,
    this.preview = false,
  });

  final CurriculumManagementRepository repository;
  final int versionId;
  final bool preview;

  @override
  State<CurriculumVersionScreen> createState() => _CurriculumVersionScreenState();
}

class _CurriculumVersionScreenState extends State<CurriculumVersionScreen> {
  ManagedCurriculumVersionDetail? _version;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  final Set<int> _expandedBlockIds = <int>{};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await widget.repository.getVersionById(widget.versionId);
      if (mounted) {
        setState(() {
          _version = data;
          _dirty = false;
          // Frame-24: hiển thị sẵn học phần của khối đầu tiên.
          _expandedBlockIds
            ..clear()
            ..addAll(data.blocks.isEmpty ? <int>[] : <int>[data.blocks.first.id]);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Không tải được phiên bản: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editBlock(ManagedKnowledgeBlock block) async {
    final version = _version;
    if (version == null || !version.isEditable) return;
    final input = TextEditingController(text: block.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên khối kiến thức'),
        content: TextField(
          key: const ValueKey('f07-block-name-input'),
          controller: input,
          decoration: const InputDecoration(labelText: 'Tên khối kiến thức'),
          maxLength: 150,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, input.text.trim()),
            child: const Text('Áp dụng')),
        ],
      ),
    );
    input.dispose();
    if (!mounted || result == null || result.isEmpty) return;
    final updated = version.blocks.map((item) => item.id == block.id
      ? item.copyWith(name: result) : item).toList();
    setState(() { _version = version.copyWith(blocks: updated); _dirty = true; });
  }

  Future<void> _addBlock() async {
    final version = _version;
    if (version == null || !version.isEditable) return;
    final input = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khối kiến thức'),
        content: TextField(
          controller: input,
          decoration: const InputDecoration(labelText: 'Tên khối mới'),
          maxLength: 150,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, input.text.trim()),
            child: const Text('Thêm')),
        ],
      ),
    );
    input.dispose();
    if (!mounted || result == null || result.isEmpty) return;
    final blocks = [...version.blocks];
    final nextId = blocks.fold<int>(0, (maxId, item) =>
      item.id > maxId ? item.id : maxId) + 1;
    blocks.add(ManagedKnowledgeBlock(
      id: nextId, code: 'DRAFT-$nextId', name: result,
      displayOrder: blocks.length + 1, requiredCredits: 0, items: const [],
    ));
    setState(() {
      _version = version.copyWith(blocks: blocks);
      _dirty = true;
      _expandedBlockIds.add(nextId);
    });
  }

  Future<void> _save() async {
    final version = _version;
    if (version == null || !version.isEditable || !_dirty || _saving) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.repository.saveDraftVersion(version,
        expectedRevision: version.revision);
      if (!mounted) return;
      setState(() { _version = saved; _dirty = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.preview
        ? 'Đã lưu vào dữ liệu mẫu (không phải Backend)' : 'Đã lưu bản nháp')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu không thành công: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = _version;
    return Scaffold(
      backgroundColor: F07Ui.background,
      body: SafeArea(child: Column(children: [
        SharedAppHeader.academic(
          sectionTitle: 'ADMIN · QUẢN LÝ CTĐT',
          identityLine: 'Quản trị hệ thống · Admin',
          detail: 'Phiên bản chương trình đào tạo',
          onLeading: () => Navigator.of(context).maybePop(),
        ),
        Expanded(child: ListView(
          key: const ValueKey('f07-version-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text('Quản lý phiên bản CTĐT', style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.w800, color: F07Ui.ink)),
            const SizedBox(height: 4),
            const Text('Phân nhóm học phần theo khối kiến thức',
              style: TextStyle(color: F07Ui.muted)),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              F07Panel(child: Column(children: [
                Text(_error!, key: const ValueKey('f07-version-error')),
                TextButton(onPressed: _load, child: const Text('Thử lại')),
              ]))
            else if (version == null)
              const F07Panel(child: Text('Không tìm thấy phiên bản'))
            else ...[
              _versionSummary(version),
              const SizedBox(height: 20),
              F07SectionTitle(title: 'Khối kiến thức',
                trailing: '${version.blocks.length} khối'),
              const SizedBox(height: 12),
              for (final block in version.blocks)
                _blockCard(block, version.isEditable),
              const SizedBox(height: 15),
              if (version.isEditable) Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: const ValueKey('f07-add-block'),
                  onPressed: _saving ? null : _addBlock,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm khối kiến thức'),
                ),
              ),
              const SizedBox(height: 14),
              Text(version.isEditable
                ? 'Chỉnh sửa trong bản nháp; chỉ lưu khi dữ liệu hợp lệ.'
                : 'Phiên bản đã công bố/lưu trữ chỉ được xem. Muốn thay đổi cần tạo bản nháp mới.',
                style: const TextStyle(fontSize: 12, color: F07Ui.muted)),
              if (widget.preview) const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('CHẾ ĐỘ XEM TRƯỚC · Không ghi dữ liệu lên máy chủ',
                  style: TextStyle(fontSize: 12, color: F07Ui.primary)),
              ),
            ],
          ],
        )),
        if (version != null && version.isEditable && !_loading)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            decoration: const BoxDecoration(color: Colors.white,
              border: Border(top: BorderSide(color: F07Ui.outline))),
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('f07-save-draft'),
              onPressed: _dirty && !_saving ? _save : null,
              style: FilledButton.styleFrom(backgroundColor: F07Ui.primary,
                padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text(_saving ? 'Đang lưu...' : 'Lưu cấu trúc CTĐT'),
            ),
          ),
      ])),
    );
  }

  Widget _versionSummary(ManagedCurriculumVersionDetail version) =>
    F07Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(version.curriculumName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            color: F07Ui.ink))),
      ]),
      const SizedBox(height: 7),
      Text('${version.curriculumCode} · Phiên bản ${version.summary.versionCode}',
        style: const TextStyle(color: F07Ui.muted)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: Text('Niên khóa áp dụng: ${version.summary.effectiveYear}',
          style: const TextStyle(color: F07Ui.muted))),
        F07VersionPill(status: version.summary.status),
      ]),
      const SizedBox(height: 10),
      Text('Tổng tín chỉ yêu cầu: ${version.summary.totalCreditsRequired} TC',
        style: const TextStyle(fontWeight: FontWeight.w600, color: F07Ui.ink)),
    ]));

  void _toggleBlock(int blockId) {
    setState(() {
      if (!_expandedBlockIds.add(blockId)) {
        _expandedBlockIds.remove(blockId);
      }
    });
  }

  /// Khối kiến thức mở rộng trực tiếp như Frame-24.svg.
  /// Không dùng bottom sheet; trạng thái hoàn thành của sinh viên không thuộc F07 Admin.
  Widget _blockCard(ManagedKnowledgeBlock block, bool editable) {
    final expanded = _expandedBlockIds.contains(block.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: F07Panel(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              button: true,
              label: '${block.name}, ${block.requiredCredits} tín chỉ, '
                  '${block.items.length} học phần. '
                  '${expanded ? 'Thu gọn' : 'Mở rộng'}',
              child: InkWell(
                key: ValueKey('f07-block-header-${block.id}'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => _toggleBlock(block.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 53,
                        decoration: BoxDecoration(
                          color: F07Ui.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: F07Ui.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${block.items.length} học phần',
                              style: const TextStyle(
                                fontSize: 12,
                                color: F07Ui.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: F07Ui.paleBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${block.requiredCredits} TC',
                              style: const TextStyle(
                                color: F07Ui.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: F07Ui.primary,
                            size: 23,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  key: ValueKey('f07-toggle-block-${block.id}'),
                  onPressed: () => _toggleBlock(block.id),
                  icon: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(expanded ? 'Thu gọn học phần' : 'Xem học phần'),
                ),
                if (editable)
                  TextButton(
                    key: ValueKey('f07-edit-block-${block.id}'),
                    onPressed: _saving ? null : () => _editBlock(block),
                    child: const Text('Chỉnh sửa ›'),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      key: ValueKey('f07-inline-courses-${block.id}'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 8, color: F07Ui.outline),
                        if (block.items.isEmpty && block.electiveGroups.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Chưa có học phần trong khối kiến thức này.',
                              style: TextStyle(color: F07Ui.muted, fontSize: 13),
                            ),
                          ),
                        for (var index = 0; index < block.items.length; index++) ...[
                          if (index > 0)
                            const Divider(height: 1, color: F07Ui.outline),
                          _courseRow(block.items[index]),
                        ],
                        if (block.electiveGroups.isNotEmpty) ...[
                          const Divider(height: 12, color: F07Ui.outline),
                          const Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 3),
                            child: Text(
                              'Nhóm học phần tự chọn',
                              style: TextStyle(
                                color: F07Ui.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          for (final group in block.electiveGroups)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.checklist_rounded,
                                    size: 19,
                                    color: F07Ui.primary,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      '${group.name} · Tối thiểu ${group.minCredits} TC',
                                      style: const TextStyle(
                                        color: F07Ui.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseRow(ManagedCourseItem item) => Padding(
    key: ValueKey('f07-course-${item.courseId}'),
    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: F07Ui.paleBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: F07Ui.primary,
            size: 15,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.courseName,
                style: const TextStyle(
                  color: F07Ui.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.credits} TC · '
                '${item.isRequired ? 'Bắt buộc' : 'Tự chọn'} · '
                '${item.courseCode} · HK ${item.semester}',
                style: const TextStyle(
                  color: F07Ui.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
