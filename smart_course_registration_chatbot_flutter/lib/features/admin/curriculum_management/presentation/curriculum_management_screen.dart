import 'package:flutter/material.dart';
import '../../../../core/widgets/shared_app_header.dart';
import '../data/curriculum_management_repository.dart';
import '../domain/managed_curriculum.dart';
import 'curriculum_version_screen.dart';
import 'f07_ui.dart';

/// F07 catalogue screen. Deliberately NOT connected to any unconfirmed RPC.
class CurriculumManagementScreen extends StatefulWidget {
  const CurriculumManagementScreen({super.key, required this.repository, this.preview = false});

  final CurriculumManagementRepository repository;
  final bool preview;

  @override
  State<CurriculumManagementScreen> createState() => _CurriculumManagementScreenState();
}

class _CurriculumManagementScreenState extends State<CurriculumManagementScreen> {
  final _search = TextEditingController();
  bool _loading = true;
  String? _error;
  List<ManagedCurriculum> _curriculums = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await widget.repository.listCurriculums(query: _search.text.trim());
      if (!mounted) return;
      setState(() => _curriculums = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Không tải được chương trình đào tạo: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openVersion(ManagedCurriculumVersionSummary version) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CurriculumVersionScreen(
        repository: widget.repository,
        versionId: version.id,
        preview: widget.preview,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: F07Ui.background,
    body: SafeArea(child: Column(children: [
      SharedAppHeader.academic(
        sectionTitle: 'ADMIN · QUẢN LÝ CTĐT',
        identityLine: 'Quản trị hệ thống · Admin',
        detail: 'Danh mục chương trình đào tạo',
        leadingIcon: Icons.menu_rounded,
        onLeading: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop() : null,
      ),
      Expanded(child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          key: const ValueKey('f07-list-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
          children: [
            if (widget.preview) const _PreviewNotice(),
            const Text('Quản lý chương trình đào tạo',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: F07Ui.ink)),
            const SizedBox(height: 5),
            const Text('Danh sách, phiên bản và cấu trúc học phần theo khóa',
              style: TextStyle(color: F07Ui.muted, fontSize: 13)),
            const SizedBox(height: 17),
            TextField(
              key: const ValueKey('f07-search'),
              controller: _search,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Tìm tên hoặc mã CTĐT...',
                prefixIcon: const Icon(Icons.search, color: F07Ui.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Xóa tìm kiếm',
                  onPressed: () { _search.clear(); _load(); },
                ),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                contentPadding: const EdgeInsets.all(13),
              ),
            ),
            Align(alignment: Alignment.centerRight, child: TextButton.icon(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.search, size: 17),
              label: const Text('Tìm kiếm'),
            )),
            F07SectionTitle(title: 'Chương trình đào tạo',
              trailing: _loading ? null : '${_curriculums.length} CTĐT'),
            const SizedBox(height: 12),
            if (_loading) const Padding(
              padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()),
            ) else if (_error != null) F07Panel(child: Column(children: [
              Text(_error!, key: const ValueKey('f07-load-error')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: _load, child: const Text('Thử lại')),
            ])) else if (_curriculums.isEmpty)
              const F07Panel(child: Text('Chưa có chương trình đào tạo phù hợp.'))
            else
              ..._curriculums.map(_curriculumCard),
            const SizedBox(height: 18),
            const Text('Chức năng tạo/sửa CTĐT qua Backend sẽ được mở khi API F07 được bàn giao.',
              style: TextStyle(color: F07Ui.muted, fontSize: 12)),
          ],
        ),
      )),
    ])),
  );

  Widget _curriculumCard(ManagedCurriculum curriculum) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: F07Panel(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 4, height: 55, decoration: BoxDecoration(
              color: F07Ui.primary, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(curriculum.name, style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 17, color: F07Ui.ink,
              )),
              const SizedBox(height: 5),
              Text('${curriculum.code} · ${curriculum.majorCode}',
                style: const TextStyle(color: F07Ui.muted)),
            ])),
          ]),
          const SizedBox(height: 15),
          const Text('Các phiên bản', style: TextStyle(
            fontWeight: FontWeight.w700, color: F07Ui.ink)),
          const SizedBox(height: 5),
          if (curriculum.versions.isEmpty)
            const Text('Chưa có phiên bản', style: TextStyle(color: F07Ui.muted))
          else
            ...curriculum.versions.map((version) => ListTile(
              key: ValueKey('f07-version-${version.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text('Phiên bản ${version.versionCode}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Áp dụng ${version.effectiveYear} · '
                '${version.totalCreditsRequired} TC'),
              trailing: const Icon(Icons.chevron_right, color: F07Ui.primary),
              onTap: () => _openVersion(version),
            )),
        ],
      )),
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: F07Ui.paleBlue,
      borderRadius: BorderRadius.circular(10)),
    child: const Row(children: [
      Icon(Icons.science_outlined, size: 17, color: F07Ui.primary),
      SizedBox(width: 8),
      Expanded(child: Text('DỮ LIỆU MẪU · F07 chưa kết nối API thật',
        style: TextStyle(fontSize: 12, color: F07Ui.primary))),
    ]),
  );
}
