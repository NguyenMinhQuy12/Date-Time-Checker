import 'package:flutter_test/flutter_test.dart';
import 'package:date_time_checker/date_time_logic.dart';

void main() {
  group('Leap Year Tests', () {
    test('TC-01: 2024 is a leap year', () {
      expect(isLeapYear(2024), true);
    });

    test('TC-02: 2023 is not a leap year', () {
      expect(isLeapYear(2023), false);
    });

    test('TC-03: 2000 is a leap year', () {
      expect(isLeapYear(2000), true);
    });

    test('TC-04: 2100 is not a leap year', () {
      expect(isLeapYear(2100), false);
    });

    test('TC-05: 2400 is a leap year', () {
      expect(isLeapYear(2400), true);
    });
  });

  group('Days In Month Tests', () {
    test('TC-06: January has 31 days', () {
      expect(daysInMonth(1, 2024), 31);
    });

    test('TC-07: April has 30 days', () {
      expect(daysInMonth(4, 2024), 30);
    });

    test('TC-08: February 2024 has 29 days', () {
      expect(daysInMonth(2, 2024), 29);
    });

    test('TC-09: February 2023 has 28 days', () {
      expect(daysInMonth(2, 2023), 28);
    });

    test('TC-10: Invalid month 13 has 0 days', () {
      expect(daysInMonth(13, 2024), 0);
    });
  });

  group('Date Validation Tests', () {
    test('TC-11: 29/02/2024 is valid', () {
      expect(checkDateLogic(29, 2, 2024), true);
    });

    test('TC-12: 29/02/2023 is invalid', () {
      expect(checkDateLogic(29, 2, 2023), false);
    });

    test('TC-13: 31/04/2024 is invalid', () {
      expect(checkDateLogic(31, 4, 2024), false);
    });

    test('TC-14: 01/01/1920 is valid', () {
      expect(checkDateLogic(1, 1, 1920), true);
    });

    test('TC-15: 31/12/3000 is valid', () {
      expect(checkDateLogic(31, 12, 3000), true);
    });

    test('TC-16: 10/12/1919 is invalid because year is below range', () {
      expect(checkDateLogic(10, 12, 1919), false);
    });

    test('TC-17: 10/12/3001 is invalid because year is above range', () {
      expect(checkDateLogic(10, 12, 3001), false);
    });

    test('TC-18: 32/01/2024 is invalid because day is out of range', () {
      expect(checkDateLogic(32, 1, 2024), false);
    });

    test('TC-19: 10/13/2024 is invalid because month is out of range', () {
      expect(checkDateLogic(10, 13, 2024), false);
    });

    test('TC-20: 30/11/2022 is valid', () {
      expect(checkDateLogic(30, 11, 2022), true);
    });
  });
}