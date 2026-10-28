import 'package:flutter_test/flutter_test.dart';
import 'package:fnthink_calculator/core/utils/date_calc.dart';

void main() {
  test('天数差与月份天数', () {
    expect(daysBetween(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
    expect(daysBetween(DateTime(2024, 1, 1), DateTime(2024, 1, 1)), 0);
    expect(daysBetween(DateTime(2024, 12, 31), DateTime(2025, 1, 1)), 1);
    expect(daysInMonth(2024, 2), 29);
    expect(daysInMonth(2023, 2), 28);
  });

  test('月末夹取', () {
    expect(addMonthsClamped(DateTime(2023, 1, 31), 1), DateTime(2023, 2, 28));
    expect(addMonthsClamped(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
    expect(addMonthsClamped(DateTime(2024, 3, 31), -1), DateTime(2024, 2, 29));
    expect(addYearsClamped(DateTime(2024, 2, 29), 1), DateTime(2025, 2, 28));
    expect(addDays(DateTime(2024, 2, 28), 2), DateTime(2024, 3, 1));
  });

  test('日历差值', () {
    expect(
      calendarDifference(DateTime(2024, 1, 31), DateTime(2024, 2, 29)).months,
      1,
    );
    final janToMar = calendarDifference(
      DateTime(2024, 1, 31),
      DateTime(2024, 3, 1),
    );
    expect(janToMar.months, 1);
    expect(janToMar.days, 1);

    final year = calendarDifference(
      DateTime(2024, 1, 1),
      DateTime(2024, 12, 31),
    );
    expect(year.months, 11);
    expect(year.days, 30);

    final leapYear = calendarDifference(
      DateTime(2024, 2, 29),
      DateTime(2025, 2, 28),
    );
    expect(leapYear.years, 1);
    expect(leapYear.months, 0);
    expect(leapYear.days, 0);

    final reversed = calendarDifference(
      DateTime(2024, 3, 1),
      DateTime(2024, 1, 31),
    );
    expect(reversed.months, 1);
    expect(reversed.days, 1);
  });

  test('工作日仅排除周末', () {
    final monday = DateTime(2024, 1, 1);
    final sunday = DateTime(2024, 1, 7);
    expect(workdaysBetween(monday, sunday), 4);
    expect(workdaysBetween(monday, sunday, includeStart: true), 5);
    expect(workdaysBetween(monday, monday), 0);
    expect(workdaysBetween(monday, monday, includeStart: true), 1);
  });

  test('年龄与虚岁', () {
    expect(ageInYears(DateTime(2000, 1, 1), DateTime(2026, 10, 28)), 26);
    expect(ageInYears(DateTime(2000, 12, 31), DateTime(2026, 10, 28)), 25);
    expect(ageInYears(DateTime(2000, 2, 29), DateTime(2025, 2, 28)), 25);
    expect(ageInYears(DateTime(2000, 2, 29), DateTime(2025, 2, 27)), 24);
    expect(nominalAge(DateTime(2000, 1, 1), DateTime(2026, 10, 28)), 27);
  });

  test('下次生日', () {
    expect(
      nextBirthday(DateTime(2000, 1, 1), DateTime(2026, 1, 1)),
      DateTime(2026, 1, 1),
    );
    expect(
      daysUntilNextBirthday(DateTime(2000, 1, 1), DateTime(2026, 1, 1)),
      0,
    );
    expect(
      daysUntilNextBirthday(DateTime(2000, 1, 1), DateTime(2026, 1, 2)),
      364,
    );
    expect(
      nextBirthday(DateTime(2000, 2, 29), DateTime(2025, 2, 27)),
      DateTime(2025, 2, 28),
    );
    expect(
      nextBirthday(DateTime(2000, 2, 29), DateTime(2025, 3, 1)),
      DateTime(2026, 2, 28),
    );
  });
}
