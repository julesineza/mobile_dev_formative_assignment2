// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_dev_formative_assignment2/services/auth_service.dart';

void main() {
  test('accepts only ALU student email addresses', () {
    expect(AuthService.isAluEmail('name@alustudent.com'), isTrue);
    expect(AuthService.isAluEmail('NAME@ALUSTUDENT.COM'), isTrue);
    expect(AuthService.isAluEmail('name@gmail.com'), isFalse);
    expect(AuthService.isAluEmail('name@alustudent.com.example.org'), isFalse);
    expect(AuthService.isAluEmail('name@alustudent.com@other.com'), isFalse);
  });
}
