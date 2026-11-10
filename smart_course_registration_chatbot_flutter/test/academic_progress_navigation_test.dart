import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/academic_progress_quick_access.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/academic_progress_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/academic_progress_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/data/academic_progress_repository.dart';

class _FakeProgressRepository implements AcademicProgressRepository {
  int callCount = 0;

  @override
  Future<AcademicProgressDetails?> getMyProgress() async {
    callCount++;
    return null; // Trạng thái thiếu dữ liệu thật, không tạo GPA/tín chỉ giả.
  }
}

void main() {
  testWidgets('F23 quick access mở màn hình và gọi repository một lần', (
    tester,
  ) async {
    final fake = _FakeProgressRepository();
    await tester.pumpWidget(
      AcademicProgressRepositoryScope(
        repository: fake,
        child: const MaterialApp(
          home: Scaffold(body: AcademicProgressQuickAccess()),
        ),
      ),
    );

    await tester.tap(find.text('Kết quả học tập'));
    await tester.pumpAndSettle();

    expect(find.byType(AcademicProgressScreen), findsOneWidget);
    expect(fake.callCount, 1);
  });

  testWidgets('F23 quick access thiếu scope hiển thị thông báo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AcademicProgressQuickAccess()),
      ),
    );

    await tester.tap(find.text('Kết quả học tập'));
    await tester.pump();

    expect(find.byType(AcademicProgressScreen), findsNothing);
    expect(
      find.text('Chức năng F23 chưa được kết nối Serverpod.'),
      findsOneWidget,
    );
  });
}
