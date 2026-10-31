import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_course_registration_chatbot_flutter/app/smart_course_app.dart';
import 'package:smart_course_registration_chatbot_flutter/dev/week5_login_demo.dart';
import 'package:smart_course_registration_chatbot_flutter/features/auth/login_demo_screen.dart';

void main() {
  testWidgets('ứng dụng chính khởi động tại màn hình đăng nhập demo',
      (tester) async {
    await tester.pumpWidget(const SmartCourseApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(LoginDemoScreen), findsOneWidget);
  });

  testWidgets('entry point tuần 5 vẫn dùng cùng một ứng dụng',
      (tester) async {
    await tester.pumpWidget(const Week5LoginDemoApp());

    expect(find.byType(SmartCourseApp), findsOneWidget);
    expect(find.byType(LoginDemoScreen), findsOneWidget);
  });
}
