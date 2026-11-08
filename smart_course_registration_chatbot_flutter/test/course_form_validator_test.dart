import 'package:flutter_test/flutter_test.dart';

import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_form_validator.dart';

void main() {
  group('F06 CourseFormValidator', () {
    test('Mã môn không được để trống', () {
      expect(CourseFormValidator.code(''), isNotNull);
      expect(CourseFormValidator.code('   '), isNotNull);
      expect(CourseFormValidator.code('CS101'), isNull);
    });

    test('Tên môn không được để trống', () {
      expect(CourseFormValidator.name(''), isNotNull);
      expect(CourseFormValidator.name('Lập trình'), isNull);
    });

    test('Tín chỉ phải là số nguyên từ 1 đến 12', () {
      expect(CourseFormValidator.credits('abc'), isNotNull);
      expect(CourseFormValidator.credits('0'), isNotNull);
      expect(CourseFormValidator.credits('13'), isNotNull);
      expect(CourseFormValidator.credits('3.5'), isNotNull);
      expect(CourseFormValidator.credits('3'), isNull);
      expect(CourseFormValidator.credits('12'), isNull);
    });
  });
}
