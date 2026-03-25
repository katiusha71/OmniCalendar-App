import '../core/constants/app_constants.dart';

class CalendarDate {
  final int day;
  final int month;
  final int year;
  final CalendarType calendarType;

  CalendarDate({
    required this.day,
    required this.month,
    required this.year,
    required this.calendarType,
  });

  factory CalendarDate.fromJson(Map<String, dynamic> json, CalendarType type) {
    return CalendarDate(
      day: json['day'],
      month: json['month'],
      year: json['year'],
      calendarType: type,
    );
  }

  String get monthName {
    final months = calendarType == CalendarType.solarHijri
        ? AppConstants.persianMonths
        : calendarType == CalendarType.lunarHijri
            ? AppConstants.hijriMonths
            : AppConstants.gregorianMonths;
    return months[month - 1];
  }

  String get formatted => '$day $monthName $year';

  @override
  String toString() => formatted;
}
