import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri/hijri_calendar.dart';
import '../constants/app_constants.dart';

class TriCalendarDate {
  final int gregorianDay, gregorianMonth, gregorianYear;
  final int solarHijriDay, solarHijriMonth, solarHijriYear;
  final int lunarHijriDay, lunarHijriMonth, lunarHijriYear;

  TriCalendarDate({
    required this.gregorianDay,
    required this.gregorianMonth,
    required this.gregorianYear,
    required this.solarHijriDay,
    required this.solarHijriMonth,
    required this.solarHijriYear,
    required this.lunarHijriDay,
    required this.lunarHijriMonth,
    required this.lunarHijriYear,
  });

  String formattedGregorian() =>
      '$gregorianDay ${AppConstants.gregorianMonths[gregorianMonth - 1]}';

  String formattedSolarHijri() =>
      '$solarHijriDay ${AppConstants.persianMonths[solarHijriMonth - 1]}';

  String formattedLunarHijri() =>
      '$lunarHijriDay ${AppConstants.hijriMonths[lunarHijriMonth - 1]}';

  String formatted(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        return formattedGregorian();
      case CalendarType.solarHijri:
        return formattedSolarHijri();
      case CalendarType.lunarHijri:
        return formattedLunarHijri();
    }
  }
}

class CalendarConversionService {
  /// Convert a date from any calendar system to all 3 calendar representations.
  static TriCalendarDate convertToAll({
    required CalendarType sourceType,
    required int day,
    required int month,
    int? year,
  }) {
    // First, get the Gregorian date as our pivot
    final greg = _toGregorian(sourceType, day, month, year);

    // Then convert Gregorian to the other two
    final jalali = Jalali.fromDateTime(DateTime(greg.year, greg.month, greg.day));
    final hijri = HijriCalendar.fromDate(DateTime(greg.year, greg.month, greg.day));

    return TriCalendarDate(
      gregorianDay: greg.day,
      gregorianMonth: greg.month,
      gregorianYear: greg.year,
      solarHijriDay: jalali.day,
      solarHijriMonth: jalali.month,
      solarHijriYear: jalali.year,
      lunarHijriDay: hijri.hDay,
      lunarHijriMonth: hijri.hMonth,
      lunarHijriYear: hijri.hYear,
    );
  }

  /// Convert source calendar date to a Gregorian ({year, month, day}).
  static DateTime _toGregorian(CalendarType type, int day, int month, int? year) {
    switch (type) {
      case CalendarType.gregorian:
        final y = year ?? DateTime.now().year;
        return DateTime(y, month, day);

      case CalendarType.solarHijri:
        final y = year ?? Jalali.now().year;
        final jalali = Jalali(y, month, day);
        final g = jalali.toGregorian();
        return DateTime(g.year, g.month, g.day);

      case CalendarType.lunarHijri:
        final y = year ?? HijriCalendar.now().hYear;
        final hijri = HijriCalendar()
          ..hYear = y
          ..hMonth = month
          ..hDay = day;
        return hijri.hijriToGregorian(y, month, day);
    }
  }
}
