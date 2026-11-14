import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/data/recommendation_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/recommendation_card.dart';

void main() {
  testWidgets(
    'Figma card: Nhãn Nên xem chỉ có khi BE trả ưu tiên và đủ điều kiện',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationCard(
                isOfficial: true,
                course: RecommendationCourse(
                  code: 'SE202',
                  name: 'Hệ điều hành',
                  credits: 3,
                  eligible: true,
                  priorityRank: 2,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Hệ điều hành'), findsOneWidget);
      expect(find.text('Nên xem'), findsOneWidget);
      // Nếu không có nút action thì không tự tạo một điều hướng.
      expect(find.text('Xem thông tin và lớp học phần'), findsNothing);
      expect(find.textContaining('3 tín chỉ'), findsOneWidget);
    },
  );

  testWidgets('Frame-9: 2 nhãn hành động khác nhau, có callback thực', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              RecommendationCard(
                isOfficial: true,
                onOpenDetails: () => pressed++,
                course: const RecommendationCourse(
                  code: 'OS',
                  name: 'Hệ điều hành',
                  credits: 3,
                  eligible: true,
                  priorityRank: 2,
                ),
              ),
              RecommendationCard(
                isOfficial: true,
                onOpenDetails: () => pressed++,
                course: const RecommendationCourse(
                  code: 'MATH',
                  name: 'Toán rời rạc',
                  credits: 3,
                  eligible: true,
                  priorityRank: 3,
                  reasonCodes: ['RETAKE_RECOMMENDED'],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Xem thông tin và lớp học phần'), findsOneWidget);
    expect(find.text('Xem các lớp học lại đang mở'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('f24-action-OS')));
    await tester.tap(find.byKey(const ValueKey('f24-action-MATH')));
    expect(pressed, 2);
  });

  testWidgets('Không đủ điều kiện thì không được gắn nhãn Nên xem', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: true,
            course: RecommendationCourse(
              code: 'SE203',
              name: 'Cơ sở dữ liệu',
              eligible: false,
              priorityRank: 1,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Chưa đủ điều kiện'), findsOneWidget);
    expect(find.text('Nên xem'), findsNothing);
  });

  testWidgets('Chế độ F04/F23 chỉ hiện trạng thái học tập, không gợi ý', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: false,
            course: RecommendationCourse(
              code: 'CS102',
              name: 'Toán rời rạc',
              progressStatus: 'FAILED',
            ),
          ),
        ),
      ),
    );
    final badge = tester.widget<Text>(
      find.byKey(const ValueKey('f24-badge-CS102')),
    );
    expect(badge.data, 'Chưa đạt');
    expect(find.text('Nên xem'), findsNothing);
    expect(find.text('Học lại'), findsNothing);
  });
}
