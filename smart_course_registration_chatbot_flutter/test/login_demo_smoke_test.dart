import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/dev/week5_login_demo.dart';

void _setPhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpLoginDemo(WidgetTester tester) async {
  _setPhoneSurface(tester);
  await tester.pumpWidget(const Week5LoginDemoApp());
  await tester.pumpAndSettle();
}

Future<void> _loginAs(
  WidgetTester tester, {
  required String username,
  required String password,
}) async {
  await tester.enterText(
    find.byKey(const ValueKey('login-username')),
    username,
  );
  await tester.enterText(
    find.byKey(const ValueKey('login-password')),
    password,
  );
  await tester.tap(find.byKey(const ValueKey('login-submit')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Student demo credentials open the Student Dashboard', (
    tester,
  ) async {
    await _pumpLoginDemo(tester);
    await _loginAs(tester, username: 'sv001', password: 'demo123');

    expect(find.text('Sinh viên'), findsOneWidget);
    expect(find.text('Nguyễn Minh Anh'), findsWidgets);
    expect(find.byKey(const ValueKey('dashboard-sign-out')), findsOneWidget);
  });

  testWidgets('Lecturer demo credentials open the Lecturer Dashboard', (
    tester,
  ) async {
    await _pumpLoginDemo(tester);
    await _loginAs(tester, username: 'gv001', password: 'demo123');

    expect(find.text('Giảng viên'), findsOneWidget);
    expect(find.text('Trần Minh Khôi'), findsWidgets);
  });

  testWidgets('Admin demo credentials open the Admin Dashboard', (
    tester,
  ) async {
    await _pumpLoginDemo(tester);
    await _loginAs(tester, username: 'admin001', password: 'demo123');

    expect(find.text('Quản trị viên'), findsOneWidget);
    expect(find.text('Lê Thanh Hùng'), findsWidgets);
  });

  testWidgets('Empty and invalid credentials are rejected', (tester) async {
    await _pumpLoginDemo(tester);

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tài khoản'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.text('Chào mừng trở lại!'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-username')),
      'sv999',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'wrong',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('Tài khoản hoặc mật khẩu demo không đúng.'),
      findsOneWidget,
    );
    expect(find.text('Chào mừng trở lại!'), findsOneWidget);
  });

  testWidgets(
    'Password visibility, remember UI state and forgot-password notice work',
    (tester) async {
      await _pumpLoginDemo(tester);

      final passwordField = find.byKey(const ValueKey('login-password'));
      final passwordEditor = find.descendant(
        of: passwordField,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(passwordEditor).obscureText, isTrue);
      await tester.tap(find.byKey(const ValueKey('login-toggle-password')));
      await tester.pump();
      expect(tester.widget<EditableText>(passwordEditor).obscureText, isFalse);

      await tester.tap(find.byKey(const ValueKey('login-remember')));
      await tester.pump();
      expect(
        tester
            .widget<Checkbox>(find.byKey(const ValueKey('login-remember')))
            .value,
        isTrue,
      );

      await tester.tap(find.text('Quên mật khẩu?'));
      await tester.pump();
      expect(find.textContaining('không gửi email thật'), findsOneWidget);
    },
  );

  testWidgets('Logout returns the demo to the login screen', (tester) async {
    await _pumpLoginDemo(tester);
    await _loginAs(tester, username: 'sv001', password: 'demo123');

    await tester.tap(find.byKey(const ValueKey('dashboard-sign-out')));
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại!'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit')), findsOneWidget);
  });

  testWidgets('Login demo renders at 390x844 without an exception', (
    tester,
  ) async {
    await _pumpLoginDemo(tester);
    expect(tester.takeException(), isNull);
  });
}
