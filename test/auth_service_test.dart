import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_dev_formative_assignment2/services/auth_service.dart';

void main() {
  group('AuthService.isAluEmail', () {
    test('accepts a valid ALU student email case-insensitively', () {
      expect(AuthService.isAluEmail('  NAME@ALUSTUDENT.COM '), isTrue);
    });

    test('rejects malformed or non-ALU addresses', () {
      expect(AuthService.isAluEmail('name@gmail.com'), isFalse);
      expect(AuthService.isAluEmail('@alustudent.com'), isFalse);
      expect(AuthService.isAluEmail('name@alustudent.com.example.org'), isFalse);
      expect(AuthService.isAluEmail('name@alustudent.com@other.com'), isFalse);
    });
  });
}
