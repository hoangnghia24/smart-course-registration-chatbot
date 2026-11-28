import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/data/recommendation_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/recommendation_card.dart';

void main() {
  testWidgets(
    'Card: Nhãn Nên ưu tiên chỉ có khi BE trả priorityRank',
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
      expect(find.text('Nên ưu tiên'), findsOneWidget);
      // Nếu không có nút action thì không tự tạo một điều hướng.
      expect(find.text('Xem thông tin và lớp học phần'), findsNothing);
      expect(find.textContaining('3 tín chỉ'), findsOneWidget);
    },
  );

  testWidgets('Card: nhãn Nên ưu tiên và Học lại độc lập, có callback thực', (
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
    expect(find.text('Nên ưu tiên'), findsNWidgets(2));
    await tester.tap(find.byKey(const ValueKey('f24-action-OS')));
    await tester.tap(find.byKey(const ValueKey('f24-action-MATH')));
    expect(pressed, 2);
  });

  testWidgets('Chưa đủ điều kiện vẫn giữ Nên ưu tiên khi BE trả priorityRank', (
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
    expect(find.text('Nên ưu tiên'), findsOneWidget);
  });

  testWidgets('Có thể hiển thị đồng thời Đủ điều kiện và Nên ưu tiên', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: true,
            course: RecommendationCourse(
              code: 'CS201',
              name: 'Mạng máy tính',
              eligible: true,
              priorityRank: 1,
              explanations: ['Được Rule Engine trả về'],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Đủ điều kiện'), findsOneWidget);
    expect(find.text('Nên ưu tiên'), findsOneWidget);
    expect(find.text('Được Rule Engine trả về'), findsOneWidget);
  });

  testWidgets('Chưa đủ điều kiện hiển thị lý do Backend và vẫn giữ ưu tiên', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: true,
            course: RecommendationCourse(
              code: 'CS204',
              name: 'Cơ sở dữ liệu',
              eligible: false,
              priorityRank: 3,
              explanations: ['Thiếu học phần tiên quyết'],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Chưa đủ điều kiện'), findsOneWidget);
    expect(find.text('Nên ưu tiên'), findsOneWidget);
    expect(find.text('Thiếu học phần tiên quyết'), findsOneWidget);
  });

  testWidgets('Thiếu dữ liệu hiển thị Chưa xác định, không suy đoán', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: true,
            course: RecommendationCourse(
              code: 'CS205',
              name: 'Môn chưa rõ',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Chưa xác định'), findsOneWidget);
    expect(find.text('Nên ưu tiên'), findsNothing);
  });

  testWidgets('Chưa đạt từ tiến độ vẫn tách khỏi eligibility/priority', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationCard(
            isOfficial: true,
            course: RecommendationCourse(
              code: 'CS206',
              name: 'Môn đã học nhưng chưa đạt',
              progressStatus: 'FAILED',
              eligible: true,
              priorityRank: 2,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Đủ điều kiện'), findsOneWidget);
    expect(find.text('Nên ưu tiên'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('f24-progress-CS206')),
      findsOneWidget,
    );
    expect(find.text('Học lại'), findsNothing);
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
    expect(find.text('Nên ưu tiên'), findsNothing);
    expect(find.text('Học lại'), findsNothing);
  });
}
