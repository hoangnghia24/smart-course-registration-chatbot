import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/core/widgets/shared_app_header.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/data/recommendation_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/recommendation_quick_access.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/recommendation_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/recommendation_screen.dart';

class _Repo implements RecommendationRepository {
  _Repo(this.loader);
  final Future<RecommendationOverview?> Function() loader;
  int calls = 0;
  @override
  Future<RecommendationOverview?> getOverview() {
    calls++;
    return loader();
  }
}

const _fallback = RecommendationOverview(
  hasCurriculum: true,
  hasProgress: true,
  curriculumName: 'Công nghệ phần mềm',
  earnedCredits: 86,
  totalCredits: 150,
  failedCourseCount: 1,
  courses: [
    RecommendationCourse(
      code: 'CS101',
      name: 'Kiến trúc máy tính',
      credits: 3,
      progressStatus: 'PASSED',
    ),
    RecommendationCourse(
      code: 'CS102',
      name: 'Toán rời rạc',
      credits: 3,
      progressStatus: 'FAILED',
    ),
  ],
);

const _official = RecommendationOverview(
  hasCurriculum: true,
  hasProgress: true,
  isOfficialRecommendation: true,
  curriculumName: 'Công nghệ phần mềm',
  earnedCredits: 86,
  totalCredits: 150,
  failedCourseCount: 1,
  courses: [
    RecommendationCourse(
      code: 'CS101',
      name: 'Kiến trúc máy tính',
      credits: 3,
      eligible: true,
      priorityRank: 1,
      explanations: ['Nền tảng phần cứng'],
    ),
    RecommendationCourse(
      code: 'CS202',
      name: 'Hệ điều hành',
      credits: 3,
      eligible: true,
      priorityRank: 2,
      reasonCodes: ['RECOMMENDED_SEMESTER'],
      explanations: ['Ưu tiên học theo thứ tự'],
    ),
    RecommendationCourse(
      code: 'CS303',
      name: 'Mạng máy tính',
      credits: 3,
      eligible: true,
      priorityRank: 3,
      explanations: ['Tiếp nối kiến thức'],
    ),
    RecommendationCourse(
      code: 'CS404',
      name: 'Toán rời rạc',
      credits: 3,
      eligible: true,
      priorityRank: 4,
      progressStatus: 'FAILED',
      lastAcademicScore: 3.5,
      reasonCodes: ['RETAKE_RECOMMENDED'],
    ),
    RecommendationCourse(
      code: 'CS999',
      name: 'Môn chưa đủ',
      credits: 3,
      eligible: false,
      priorityRank: null,
    ),
  ],
);

const _longDetailOverview = RecommendationOverview(
  hasCurriculum: true,
  hasProgress: true,
  isOfficialRecommendation: true,
  courses: [
    RecommendationCourse(
      code: 'LONG101',
      name:
          'Học phần có tên rất dài để kiểm tra khả năng xuống dòng trên mobile',
      credits: 3,
      eligible: false,
      priorityRank: 2,
      explanations: [
        'Lý do Backend rất dài và cần được giữ nguyên trong bảng chi tiết học phần.',
        'Chưa đáp ứng đầy đủ điều kiện tiên quyết theo kết quả đánh giá hiện tại.',
        'Có thể có thêm nhiều giải thích nghiệp vụ từ Rule Engine F24/F27.',
        'Nội dung này dùng để tái hiện trường hợp màn hình nhỏ và nội dung dài.',
        'Không được tự rút gọn thành kết luận khác với dữ liệu Backend.',
      ],
      reasonCodes: [
        'PREREQUISITE_NOT_MET',
        'REQUIRED_COURSE_PENDING',
        'LONG_REASON_CODE_FOR_MOBILE_LAYOUT',
        'ANOTHER_REASON_CODE',
      ],
      availableClassCount: 12,
    ),
  ],
);

Future<void> _show(
  WidgetTester tester,
  RecommendationRepository repo, {
  bool preview = false,
  EdgeInsets? viewInsets,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      builder: viewInsets == null
          ? null
          : (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(viewInsets: viewInsets),
              child: child!,
            ),
      home: RecommendationScreen(
        repository: repo,
        isPreview: preview,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _see(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Đúng 3 khu vực Frame-9, dùng SharedAppHeader và menu', (
    tester,
  ) async {
    await _show(tester, _Repo(() async => _official), preview: true);
    expect(find.byType(SharedAppHeader), findsOneWidget);
    expect(find.text('Lộ trình học tập'), findsWidgets);
    expect(find.text('Kế hoạch học tập cá nhân'), findsOneWidget);
    expect(find.text('Thứ tự môn học đề xuất'), findsOneWidget);
    expect(find.text('Gợi ý học kỳ tiếp theo'), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-preview-notice')), findsOneWidget);
    expect(find.text('Học theo thứ tự phù hợp'), findsOneWidget);
    expect(find.text('1 môn cần học lại'), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-menu')), findsOneWidget);
    expect(find.textContaining('86/150 tín chỉ'), findsOneWidget);
  });

  testWidgets(
    'Chưa có Rule Engine: không tự tạo các bước hoặc nhãn Nên ưu tiên',
    (
      tester,
    ) async {
      await _show(tester, _Repo(() async => _fallback));
      expect(find.byKey(const ValueKey('f24-disclaimer')), findsOneWidget);
      expect(find.byKey(const ValueKey('f24-roadmap-empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('f24-step-CS101')), findsNothing);
      expect(find.text('Học phần trong CTĐT'), findsOneWidget);
      expect(find.text('Nên ưu tiên'), findsNothing);
      expect(find.text('2 môn chưa đạt'), findsNothing);
      expect(find.text('1 môn chưa đạt'), findsOneWidget);
    },
  );

  testWidgets('Thứ tự 1-2-3 đến từ priority; không dùng danh sách F23', (
    tester,
  ) async {
    await _show(tester, _Repo(() async => _official));
    expect(find.byKey(const ValueKey('f24-step-CS101')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-step-CS202')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-step-CS303')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-step-CS404')), findsNothing);
    expect(find.text('Bước 1'), findsOneWidget);
    expect(find.text('Bước 2'), findsOneWidget);
    expect(find.text('Bước 3'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('f24-selected-step-accent')),
      findsOneWidget,
    );
    expect(
      find.textContaining('không đồng nghĩa điều kiện tiên quyết'),
      findsOneWidget,
    );
  });

  testWidgets('Gợi ý học kỳ có nhãn Nên ưu tiên và Học lại đúng mã BE', (
    tester,
  ) async {
    await _show(tester, _Repo(() async => _official));
    await _see(tester, const ValueKey('f24-course-CS202'));
    expect(find.byKey(const ValueKey('f24-course-CS202')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-course-CS404')), findsOneWidget);
    expect(find.text('Nên ưu tiên'), findsNWidgets(4));
    expect(find.text('Học lại'), findsOneWidget);
    expect(find.text('Xem thông tin và lớp học phần'), findsNWidgets(4));
    expect(find.text('Xem các lớp học lại đang mở'), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-course-CS999')), findsOneWidget);
    expect(find.text('Chưa đủ điều kiện'), findsOneWidget);
  });

  testWidgets('Nhấn thông tin môn mở chi tiết, không bịa danh sách lớp', (
    tester,
  ) async {
    await _show(tester, _Repo(() async => _official));
    await _see(tester, const ValueKey('f24-course-CS202'));
    await tester.tap(find.byKey(const ValueKey('f24-action-CS202')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Điều kiện đăng ký: Đủ điều kiện'),
      findsOneWidget,
    );
    expect(find.textContaining('Số lớp được API trả về'), findsNothing);
    expect(
      find.textContaining('Danh sách lớp học phần chỉ được hiển thị'),
      findsOneWidget,
    );
  });

  testWidgets('Nút Học lại mở thông tin an toàn, không hiển thị lớp giả', (
    tester,
  ) async {
    await _show(tester, _Repo(() async => _official));
    await _see(tester, const ValueKey('f24-course-CS404'));
    await tester.tap(find.byKey(const ValueKey('f24-action-CS404')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Điểm học phần'), findsNothing);
    expect(
      find.textContaining('Danh sách lớp học phần chỉ được hiển thị'),
      findsOneWidget,
    );
    expect(find.textContaining('Tiến độ học: Chưa đạt'), findsOneWidget);
  });

  testWidgets('Loading rồi có dữ liệu, đúng số request', (tester) async {
    final completer = Completer<RecommendationOverview?>();
    final repo = _Repo(() => completer.future);
    await tester.pumpWidget(
      MaterialApp(home: RecommendationScreen(repository: repo)),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('f24-loading')), findsOneWidget);
    completer.complete(_fallback);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f24-plan')), findsOneWidget);
    expect(repo.calls, 1);
  });

  testWidgets('Response null hiển thị chưa có hồ sơ', (tester) async {
    await _show(tester, _Repo(() async => null));
    expect(find.byKey(const ValueKey('f24-unavailable')), findsOneWidget);
  });

  testWidgets('Rỗng không tạo môn giả', (tester) async {
    await _show(
      tester,
      _Repo(
        () async => const RecommendationOverview(
          hasCurriculum: true,
          hasProgress: true,
          courses: [],
        ),
      ),
    );
    expect(find.byKey(const ValueKey('f24-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-roadmap-empty')), findsOneWidget);
  });

  testWidgets('Lỗi mạng có nút thử lại', (tester) async {
    var fails = true;
    final repo = _Repo(() async {
      if (fails) throw Exception('NETWORK');
      return _fallback;
    });
    await _show(tester, repo);
    expect(find.byKey(const ValueKey('f24-error')), findsOneWidget);
    fails = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f24-plan')), findsOneWidget);
    expect(repo.calls, 2);
  });

  testWidgets('Lỗi Forbidden hiển thị đúng quyền', (tester) async {
    await _show(tester, _Repo(() async => throw Exception('FORBIDDEN')));
    expect(find.textContaining('chưa được cấp quyền'), findsOneWidget);
  });

  testWidgets('Quick Access mở đúng màn, dữ liệu định danh chuyển động', (
    tester,
  ) async {
    final repo = _Repo(() async => _fallback);
    await tester.pumpWidget(
      RecommendationRepositoryScope(
        repository: repo,
        child: const MaterialApp(
          home: Scaffold(
            body: RecommendationQuickAccess(
              studentName: 'Sinh viên A',
              studentCode: 'SV001',
              program: 'CNPM',
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Lộ trình học tập'));
    await tester.pumpAndSettle();
    expect(find.byType(RecommendationScreen), findsOneWidget);
    expect(find.textContaining('Sinh viên A - SV001'), findsOneWidget);
    expect(repo.calls, 1);
  });

  testWidgets('Không có Scope không mở màn', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RecommendationQuickAccess(),
        ),
      ),
    );
    await tester.tap(find.text('Lộ trình học tập'));
    await tester.pump();
    expect(find.byType(RecommendationScreen), findsNothing);
    expect(find.textContaining('chưa được kết nối repository'), findsOneWidget);
  });

  testWidgets('Kết quả cũ không ghi đè sau khi đổi repository', (tester) async {
    final older = Completer<RecommendationOverview?>();
    final oldRepo = _Repo(() => older.future);
    await tester.pumpWidget(
      MaterialApp(home: RecommendationScreen(repository: oldRepo)),
    );
    await tester.pump();
    final newer = _Repo(() async => _fallback);
    await tester.pumpWidget(
      MaterialApp(home: RecommendationScreen(repository: newer)),
    );
    await tester.pumpAndSettle();
    older.complete(_official);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f24-roadmap-empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('f24-step-CS101')), findsNothing);
  });

  testWidgets('Bố cục F24/F27 không overflow trên điện thoại', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _show(tester, _Repo(() async => _official));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('f24-course-CS999')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bottom sheet chi tiết cuộn được ở 390x800 với nội dung dài', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _show(tester, _Repo(() async => _longDetailOverview));
    await tester.drag(
      find.byKey(const ValueKey('f24-scroll')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f24-action-LONG101')));
    await tester.pumpAndSettle();

    expect(find.text('Đóng'), findsOneWidget);
    expect(find.textContaining('PREREQUISITE_NOT_MET'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bottom sheet chi tiết không overflow ở màn hình nhỏ hơn', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _show(tester, _Repo(() async => _longDetailOverview));
    await tester.drag(
      find.byKey(const ValueKey('f24-scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f24-action-LONG101')));
    await tester.pumpAndSettle();

    expect(find.text('Điều kiện đăng ký: Chưa đủ điều kiện'), findsOneWidget);
    expect(find.text('Đóng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bottom sheet vẫn cuộn được khi có keyboard inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _show(
      tester,
      _Repo(() async => _longDetailOverview),
      viewInsets: const EdgeInsets.only(bottom: 280),
    );
    await tester.drag(
      find.byKey(const ValueKey('f24-scroll')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f24-action-LONG101')));
    await tester.pumpAndSettle();

    expect(find.text('Đóng'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
