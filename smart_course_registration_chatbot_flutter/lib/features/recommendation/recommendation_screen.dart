import 'package:flutter/material.dart';

import '../../core/widgets/shared_app_header.dart';
import 'data/recommendation_repository.dart';
import 'recommendation_card.dart';

/// F24/F27 - Lộ trình học tập: bố cục bám Frame-9.svg của nhóm.
/// Không dùng nhóm trạng thái học tập F23 để tự tạo thứ tự gợi ý.
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.repository,
    this.studentDisplayName,
    this.studentIdentifier,
    this.isPreview = false,
  });

  final RecommendationRepository repository;
  final String? studentDisplayName;
  final String? studentIdentifier;

  /// Chỉ true tại lib/dev/f24_contract_preview.dart; tuyệt đối không bật trong app thật.
  final bool isPreview;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  static const _navy = Color(0xFF10499E);
  static const _ink = Color(0xFF253145);
  static const _muted = Color(0xFF6E7E95);
  static const _bg = Color(0xFFF4F6FA);
  static const _purple = Color(0xFF7555D9);
  static const _red = Color(0xFFD6384B);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RecommendationOverview? _overview;
  String? _error;
  bool _loading = true;
  int _requestId = 0;
  int? _selectedStepIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void didUpdateWidget(covariant RecommendationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.repository, oldWidget.repository)) _load();
  }

  Future<void> _load() async {
    final current = ++_requestId;
    setState(() {
      _loading = true;
      _overview = null; // Không giữ nội dung của lần đăng nhập trước.
      _error = null;
      _selectedStepIndex = null;
    });
    try {
      final result = await widget.repository.getOverview();
      if (!mounted || current != _requestId) return;
      setState(() {
        _loading = false;
        _overview = result;
      });
    } catch (error) {
      if (!mounted || current != _requestId) return;
      final code = error.toString().toUpperCase();
      setState(() {
        _loading = false;
        _overview = null;
        _error =
            code.contains('AUTH_REQUIRED') || code.contains('UNAUTHENTICATED')
            ? 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.'
            : code.contains('FORBIDDEN') ||
                  code.contains('ACCOUNT_INACTIVE') ||
                  code.contains('ACCOUNT_NOT_PROVISIONED')
            ? 'Tài khoản chưa được cấp quyền xem dữ liệu học tập.'
            : 'Không tải được lộ trình học tập. Kiểm tra kết nối và thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _bg,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.route_outlined, color: _navy),
                title: Text('Lộ trình học tập'),
                selected: true,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.arrow_back_rounded),
                title: const Text('Về Dashboard Sinh viên'),
                onTap: () {
                  Navigator.of(context).pop(); // Đóng drawer.
                  Navigator.of(context).maybePop(); // Về màn trước.
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SharedAppHeader.academic(
            sectionTitle: 'LỘ TRÌNH HỌC TẬP',
            identityLine: widget.studentDisplayName?.trim().isNotEmpty == true
                ? widget.studentDisplayName!.trim()
                : 'Sinh viên đang đăng nhập',
            detail: widget.studentIdentifier?.trim().isNotEmpty == true
                ? widget.studentIdentifier!.trim()
                : null,
            leadingIcon: Icons.menu_rounded,
            leadingKey: const ValueKey('f24-menu'),
            leadingTooltip: 'Mở menu',
            onLeading: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: Column(
          key: ValueKey('f24-loading'),
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Đang tải lộ trình học tập...'),
          ],
        ),
      );
    }
    if (_error != null) {
      return _feedback(
        'f24-error',
        Icons.wifi_off_rounded,
        _error!,
        retry: true,
      );
    }
    if (_overview == null) {
      return _feedback(
        'f24-unavailable',
        Icons.school_outlined,
        'Chưa đủ thông tin chương trình đào tạo và tiến độ học tập.',
        retry: true,
      );
    }
    final overview = _overview!;
    final ordered = _orderedCourses(overview);
    final recommendations = _nextCourses(overview);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: const ValueKey('f24-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _pageTitle(overview),
                  const SizedBox(height: 16),
                  _personalPlan(overview),
                  if (overview.partialMessage?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _softNotice(overview.partialMessage!),
                  ],
                  // Preview đã có nhãn “Ví dụ minh họa” theo đúng Frame-9.
                  // Không đặt banner xanh vào giữa bố cục thiết kế gốc.
                  if (!overview.isOfficialRecommendation) ...[
                    const SizedBox(height: 10),
                    _softNotice(
                      'Đang dùng dữ liệu CTĐT (F04) và tiến độ (F23). '
                      'Chưa có kết quả đề xuất chính thức từ Rule Engine F24/F27.',
                      key: const ValueKey('f24-disclaimer'),
                    ),
                  ],
                  const SizedBox(height: 22),
                  _sectionTitle(
                    'Thứ tự môn học đề xuất',
                    widget.isPreview
                        ? 'Ví dụ minh họa'
                        : (overview.isOfficialRecommendation
                              ? 'Theo Rule Engine'
                              : 'Chưa có gợi ý'),
                  ),
                  const SizedBox(height: 10),
                  _roadmap(overview, ordered),
                  const SizedBox(height: 22),
                  _nextSectionHeading(overview, recommendations.length),
                  const SizedBox(height: 10),
                  if (overview.isOfficialRecommendation) ...[
                    if (recommendations.isEmpty)
                      _emptySection(
                        'Chưa có học phần đủ điều kiện trong kết quả gợi ý hiện tại.',
                      )
                    else
                      ...recommendations.map(
                        (course) => RecommendationCard(
                          course: course,
                          isOfficial: true,
                          onOpenDetails: () => _openDetails(course, true),
                        ),
                      ),
                  ] else ...[
                    if (overview.courses.isEmpty)
                      _emptySection('Chưa có học phần từ chương trình đào tạo.')
                    else
                      ...overview.courses
                          .take(5)
                          .map(
                            (course) => RecommendationCard(
                              course: course,
                              isOfficial: false,
                              onOpenDetails: () => _openDetails(course, false),
                            ),
                          ),
                    if (overview.courses.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Đang hiển thị 5/${overview.courses.length} học phần tham khảo.',
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<RecommendationCourse> _orderedCourses(RecommendationOverview overview) {
    if (!overview.isOfficialRecommendation) return const [];
    final values = overview.courses
        .where(
          (c) =>
              c.priorityRank != null &&
              c.priorityRank! > 0 &&
              c.eligible == true,
        )
        .toList();
    values.sort((a, b) {
      final byRank = a.priorityRank!.compareTo(b.priorityRank!);
      return byRank != 0 ? byRank : a.code.compareTo(b.code);
    });
    return values.take(3).toList(growable: false);
  }

  List<RecommendationCourse> _nextCourses(RecommendationOverview overview) {
    if (!overview.isOfficialRecommendation) return const [];
    final eligible = overview.courses.where((c) => c.eligible == true).toList();
    // Nếu BE trả mã lý do chọn học kỳ, ưu tiên chính xác nhóm đó.
    // Không suy ra điều kiện đăng ký từ trạng thái F23 hay thứ tự CTĐT.
    final specific = eligible.where((c) {
      final codes = <String>{
        ...c.reasonCodes,
        if (c.reasonCode != null) c.reasonCode!,
      };
      return codes.contains('RECOMMENDED_SEMESTER') ||
          codes.contains('RETAKE_RECOMMENDED') ||
          codes.contains('RETAKE_REQUIRED');
    }).toList();
    final values = specific.isNotEmpty ? specific : eligible;
    values.sort((a, b) {
      if (a.priorityRank == null && b.priorityRank == null) {
        return a.code.compareTo(b.code);
      }
      if (a.priorityRank == null) return 1;
      if (b.priorityRank == null) return -1;
      final byRank = a.priorityRank!.compareTo(b.priorityRank!);
      return byRank != 0 ? byRank : a.code.compareTo(b.code);
    });
    return values.take(2).toList(growable: false);
  }

  Widget _pageTitle(RecommendationOverview overview) => Row(
    children: [
      const Expanded(
        child: Text(
          'Lộ trình học tập',
          style: TextStyle(
            color: _ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EFFD),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          overview.isOfficialRecommendation ? 'Cá nhân hóa' : 'Chờ đề xuất',
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    ],
  );

  Widget _personalPlan(RecommendationOverview overview) {
    final creditText =
        overview.earnedCredits == null || overview.totalCredits == null
        ? 'Chưa đủ số liệu tín chỉ'
        : '${overview.earnedCredits}/${overview.totalCredits} tín chỉ';
    final failed = overview.failedCourseCount;
    return Container(
      key: const ValueKey('f24-plan'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  size: 25,
                  color: _purple,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kế hoạch học tập cá nhân',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '${overview.curriculumName ?? 'Chưa rõ ngành học'} · $creditText',
            style: const TextStyle(color: _muted, fontSize: 14),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE6EBF3)),
          ),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _dotLabel(
                widget.isPreview
                    ? 'Học theo thứ tự phù hợp'
                    : overview.isOfficialRecommendation
                    ? 'Thứ tự học được đề xuất'
                    : 'Chưa có thứ tự gợi ý',
                const Color(0xFF2D6EC7),
              ),
              _dotLabel(
                failed == null
                    ? 'Chưa có dữ liệu môn chưa đạt'
                    : widget.isPreview
                    ? '$failed môn cần học lại'
                    : '$failed môn chưa đạt',
                _red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dotLabel(String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _sectionTitle(String title, String detail) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(detail, style: const TextStyle(color: _muted, fontSize: 12)),
    ],
  );

  Widget _roadmap(
    RecommendationOverview overview,
    List<RecommendationCourse> ordered,
  ) {
    return Container(
      key: const ValueKey('f24-roadmap'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ordered.isEmpty
          ? _emptyInCard(
              overview.isOfficialRecommendation
                  ? 'Rule Engine chưa cung cấp thứ tự ưu tiên và điều kiện đủ để lập lộ trình.'
                  : 'Chưa có thứ tự đề xuất từ Rule Engine. Không dùng thứ tự CTĐT để suy ra môn nên học trước.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < ordered.length; i++) ...[
                  _roadmapStep(ordered[i], i, ordered.length),
                  if (i < ordered.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 21, top: 0, bottom: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.south_rounded,
                          size: 30,
                          color: Color(0xFF9CB4D7),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 13),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 17, color: _navy),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Thứ tự gợi ý không đồng nghĩa điều kiện tiên quyết.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _roadmapStep(RecommendationCourse course, int index, int total) {
    final selected = (_selectedStepIndex ?? (total > 1 ? 1 : 0)) == index;
    final highlight = selected ? const Color(0xFFEDF4FF) : _bg;
    return Material(
      color: highlight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey('f24-step-${course.code}'),
        onTap: () => setState(() => _selectedStepIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? const Color(0xFFB8D3FE)
                  : const Color(0xFFE0E7F1),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: selected ? _navy : const Color(0xFFE3ECF7),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF57718F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                          style: TextStyle(
                            color: selected ? _navy : _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          course.explanations.isEmpty
                              ? 'Được xếp theo dữ liệu gợi ý của hệ thống'
                              : course.explanations.first,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: selected
                          ? const Color(0xFFD9E8FF)
                          : const Color(0xFFE6EDF5),
                    ),
                    child: Text(
                      'Bước ${index + 1}',
                      style: TextStyle(
                        color: selected ? _navy : const Color(0xFF62758C),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              // Vạch xanh nhấn Bước 2 theo đúng Frame-9; chỉ hiện ở bước đang chọn.
              if (selected)
                Positioned(
                  left: -14,
                  top: -8,
                  bottom: -8,
                  child: Container(
                    key: const ValueKey('f24-selected-step-accent'),
                    width: 4,
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextSectionHeading(RecommendationOverview overview, int count) => Row(
    children: [
      Expanded(
        child: Text(
          overview.isOfficialRecommendation
              ? 'Gợi ý học kỳ tiếp theo'
              : 'Học phần trong CTĐT',
          style: const TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0EAFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          overview.isOfficialRecommendation
              ? '$count gợi ý'
              : '${overview.courses.length} học phần',
          style: const TextStyle(
            color: _purple,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );

  Widget _emptyInCard(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
    child: Column(
      key: const ValueKey('f24-roadmap-empty'),
      children: [
        const Icon(Icons.route_outlined, size: 32, color: _muted),
        const SizedBox(height: 9),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.5),
        ),
      ],
    ),
  );

  Widget _emptySection(String message) => Container(
    key: const ValueKey('f24-empty'),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _muted),
    ),
  );

  Widget _softNotice(String text, {Key? key}) => Container(
    key: key,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE9F1FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 18, color: _navy),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF355A89),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _feedback(
    String keyName,
    IconData icon,
    String message, {
    bool retry = false,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: ValueKey(keyName),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: _muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _ink),
          ),
          if (retry) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ],
      ),
    ),
  );

  void _openDetails(RecommendationCourse course, bool official) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${course.code} · ${course.credits == null ? 'Chưa rõ tín chỉ' : '${course.credits} tín chỉ'}',
                  style: const TextStyle(color: _muted),
                ),
                const SizedBox(height: 16),
                _detailRow('Tiến độ học', _progressText(course.progressStatus)),
                _detailRow(
                  'Điều kiện đăng ký',
                  !official
                      ? 'Chưa có dữ liệu từ F24/F27'
                      : course.eligible == true
                      ? 'Đủ điều kiện'
                      : course.eligible == false
                      ? 'Chưa đủ điều kiện'
                      : 'Chưa xác định',
                ),
                _detailRow(
                  'Thứ tự ưu tiên',
                  course.priorityRank?.toString() ?? 'Chưa xác định',
                ),
                if (official && course.explanations.isNotEmpty)
                  _detailRow('Lý do gợi ý', course.explanations.join('; ')),
                if (official && course.reasonCodes.isNotEmpty)
                  _detailRow('Mã lý do', course.reasonCodes.join(', ')),
                if (official && course.availableClassCount != null)
                  _detailRow(
                    'Số lớp được API trả về',
                    '${course.availableClassCount}',
                  ),
                const SizedBox(height: 10),
                const Text(
                  'Danh sách lớp học phần chỉ được hiển thị khi API F05 '
                  'được tích hợp. Hiện chưa thể tra cứu lớp đang mở từ màn hình này.',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      '$label: $value',
      style: const TextStyle(fontSize: 14, color: _ink),
    ),
  );

  String _progressText(String? status) => switch (status) {
    'PASSED' => 'Đã đạt',
    'FAILED' => 'Chưa đạt',
    'IN_PROGRESS' => 'Đang học',
    'NOT_STARTED' => 'Chưa học',
    _ => 'Chưa có dữ liệu',
  };
}
