import 'dart:math' as math;

class DateParts {
  const DateParts({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;
}

DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime _utcDate(DateTime value) {
  return DateTime.utc(value.year, value.month, value.day);
}

int daysBetween(DateTime start, DateTime end) {
  return _utcDate(end).difference(_utcDate(start)).inDays;
}

int daysInMonth(int year, int month) {
  return DateTime.utc(year, month + 1, 0).day;
}

DateTime addMonthsClamped(DateTime date, int months) {
  final totalMonths = date.year * 12 + (date.month - 1) + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final day = math.min(date.day, daysInMonth(year, month));
  return DateTime(year, month, day);
}

DateTime addYearsClamped(DateTime date, int years) {
  return addMonthsClamped(date, years * 12);
}

DateTime addDays(DateTime date, int days) {
  final result = _utcDate(date).add(Duration(days: days));
  return DateTime(result.year, result.month, result.day);
}

DateParts calendarDifference(DateTime start, DateTime end) {
  var from = dateOnly(start);
  var to = dateOnly(end);
  if (to.isBefore(from)) {
    final temp = from;
    from = to;
    to = temp;
  }

  var years = 0;
  while (!addYearsClamped(from, years + 1).isAfter(to)) {
    years++;
  }

  final yearAnchor = addYearsClamped(from, years);
  var months = 0;
  while (!addMonthsClamped(yearAnchor, months + 1).isAfter(to)) {
    months++;
  }
  final anchor = addMonthsClamped(yearAnchor, months);
  return DateParts(years: years, months: months, days: daysBetween(anchor, to));
}

int workdaysBetween(DateTime start, DateTime end, {bool includeStart = false}) {
  var from = _utcDate(start);
  var to = _utcDate(end);
  if (to.isBefore(from)) {
    final temp = from;
    from = to;
    to = temp;
  }
  var current = includeStart ? from : from.add(const Duration(days: 1));
  var count = 0;
  while (!current.isAfter(to)) {
    if (current.weekday <= DateTime.friday) {
      count++;
    }
    current = current.add(const Duration(days: 1));
  }
  return count;
}

DateTime _birthdayInYear(DateTime birth, int year) {
  final day = math.min(birth.day, daysInMonth(year, birth.month));
  return DateTime(year, birth.month, day);
}

int ageInYears(DateTime birth, DateTime reference) {
  final start = dateOnly(birth);
  final ref = dateOnly(reference);
  if (ref.isBefore(start)) {
    return 0;
  }
  var age = ref.year - start.year;
  final birthday = _birthdayInYear(start, ref.year);
  if (ref.isBefore(birthday)) {
    age--;
  }
  return age;
}

int nominalAge(DateTime birth, DateTime reference) {
  return dateOnly(reference).year - dateOnly(birth).year + 1;
}

DateTime nextBirthday(DateTime birth, DateTime reference) {
  final start = dateOnly(birth);
  final ref = dateOnly(reference);
  var candidate = _birthdayInYear(start, ref.year);
  if (candidate.isBefore(ref)) {
    candidate = _birthdayInYear(start, ref.year + 1);
  }
  return candidate;
}

int daysUntilNextBirthday(DateTime birth, DateTime reference) {
  return daysBetween(reference, nextBirthday(birth, reference));
}
