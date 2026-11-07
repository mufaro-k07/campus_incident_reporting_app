import 'package:campus_incident_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateEmail', () {
    test('rejects an empty email', () {
      expect(validateEmail('', allowAnyDomain: false), isNotNull);
    });

    test('rejects a badly formatted email', () {
      expect(validateEmail('mufaro@', allowAnyDomain: false), isNotNull);
      expect(validateEmail('no-at-sign.com', allowAnyDomain: false), isNotNull);
    });

    test('rejects an email outside the ALU domains', () {
      expect(
        validateEmail('someone@gmail.com', allowAnyDomain: false),
        isNotNull,
      );
      expect(
        validateEmail('someone@notalustudent.com', allowAnyDomain: false),
        isNotNull,
      );
      expect(
        validateEmail('someone@alustudent.com.fake.org', allowAnyDomain: false),
        isNotNull,
      );
    });

    test('accepts student and staff ALU emails', () {
      expect(
        validateEmail('m.kunze@alustudent.com', allowAnyDomain: false),
        isNull,
      );
      expect(
        validateEmail('lecturer@alueducation.com', allowAnyDomain: false),
        isNull,
      );
      expect(
        validateEmail('  M.Kunze@ALUSTUDENT.com ', allowAnyDomain: false),
        isNull,
      );
    });

    test('accepts any domain when the dev flag allows it', () {
      expect(validateEmail('someone@gmail.com', allowAnyDomain: true), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects empty and short passwords', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword('1234567'), isNotNull);
    });

    test('accepts a password with at least 8 characters', () {
      expect(validatePassword('12345678'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects a different password', () {
      expect(validateConfirmPassword('password1', 'password2'), isNotNull);
    });

    test('accepts a matching password', () {
      expect(validateConfirmPassword('password1', 'password1'), isNull);
    });
  });

  group('validateName', () {
    test('rejects an empty or one-letter name', () {
      expect(validateName('   '), isNotNull);
      expect(validateName('M'), isNotNull);
    });

    test('accepts a normal name', () {
      expect(validateName('Mufaro Kunze'), isNull);
    });
  });
}
