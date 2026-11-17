import 'package:flutter/material.dart';

import 'data/recommendation_repository.dart';

/// Thẻ ở mục "Gợi ý học kỳ tiếp theo", theo bố cục Frame-9.svg.
/// Eligibility/priority/reason chỉ hiển thị khi BE thật sự cung cấp.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.course,
    required this.isOfficial,
    this.onOpenDetails,
  });

  final RecommendationCourse course;
  final bool isOfficial;
  final VoidCallback? onOpenDetails;

  static const _navy = Color(0xFF10499E);
  static const _muted = Color(0xFF718198);
  static const _red = Color(0xFFD63B4C);

  bool get _retakeFromBackend {
    final codes = {
      ...course.reasonCodes,
      if (course.reasonCode != null) course.reasonCode!,
    }.map((e) => e.toUpperCase());
    return codes.contains('RETAKE_RECOMMENDED') ||
        codes.contains('RETAKE_REQUIRED');
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = isOfficial && course.eligible == false;
    final isRetake = isOfficial && _retakeFromBackend;
    final isPriority =
        isOfficial && course.eligible == true && course.priorityRank != null;
    final isRed =
        isBlocked ||
        isRetake ||
        (!isOfficial && course.progressStatus == 'FAILED');
    final accent = isRed ? _red : const Color(0xFF2A6FC7);
    final badge = isBlocked
        ? 'Chưa đủ điều kiện'
        : isRetake
        ? 'Học lại'
        : isPriority
        ? 'Nên xem'
        : isOfficial
        ? (course.eligible == true ? 'Đủ điều kiện' : 'Chưa xác định')
        : (course.progressStatus == 'FAILED' ? 'Chưa đạt' : 'Trong CTĐT');
    final bg = isRed ? const Color(0xFFFFE9EB) : const Color(0xFFE7F0FF);
    // Nội dung nút theo Frame-9. Mở chi tiết cục bộ an toàn khi chưa có F05;
    // KHÔNG tuyên bố danh sách lớp là dữ liệu thật của backend.
    final actionText = isOfficial
        ? isRetake
              ? 'Xem các lớp học lại đang mở'
              : 'Xem thông tin và lớp học phần'
        : 'Xem thông tin môn học';

    final subtitleParts = <String>[];
    if (isRetake && course.lastAcademicScore != null) {
      subtitleParts.add('Điểm trước đó: ${course.lastAcademicScore}');
    } else if (isPriority) {
      // Nhãn thẻ theo Frame-9; giải thích BE đầy đủ vẫn ở bảng chi tiết.
      subtitleParts.add('Môn liên quan lộ trình');
    } else if (isOfficial && course.explanations.isNotEmpty) {
      subtitleParts.add(course.explanations.first);
    } else if (!isOfficial && course.progressStatus != null) {
      subtitleParts.add(_progressLabel(course.progressStatus));
    } else {
      subtitleParts.add(
        isOfficial
            ? 'Môn trong lộ trình học tập'
            : 'Môn thuộc chương trình đào tạo',
      );
    }
    if (course.credits != null) subtitleParts.add('${course.credits} tín chỉ');

    return Container(
      key: ValueKey('f24-course-${course.code}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isRed ? const Color(0xFFF6D3D7) : const Color(0xFFE7EDF5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF253145),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            key: ValueKey('f24-badge-${course.code}'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: isRed ? _red : _navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                    if (onOpenDetails != null) ...[
                      const SizedBox(height: 7),
                      TextButton(
                        onPressed: onOpenDetails,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          actionText,
                          key: ValueKey('f24-action-${course.code}'),
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _progressLabel(String? status) => switch (status) {
    'PASSED' => 'Đã đạt',
    'FAILED' => 'Chưa đạt',
    'IN_PROGRESS' => 'Đang học',
    'NOT_STARTED' => 'Chưa học',
    _ => 'Chưa rõ tiến độ',
  };
}
