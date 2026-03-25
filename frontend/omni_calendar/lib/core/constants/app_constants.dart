import 'package:flutter/material.dart';

enum CalendarType {
  gregorian('GREGORIAN', 'Gregorian'),
  solarHijri('SOLAR_HIJRI', 'Solar Hijri (Jalali)'),
  lunarHijri('LUNAR_HIJRI', 'Lunar Hijri');

  final String value;
  final String displayName;

  const CalendarType(this.value, this.displayName);

  static CalendarType fromValue(String value) {
    return CalendarType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CalendarType.gregorian,
    );
  }
}

enum EventCategory {
  national('national', 'National', Icons.flag, Color(0xFF4CAF50)),
  religious('religious', 'Religious', Icons.mosque, Color(0xFF9C27B0)),
  personal('personal', 'Personal', Icons.person, Color(0xFF2196F3)),
  birthday('birthday', 'Birthday', Icons.cake, Color(0xFFFF9800)),
  anniversary('anniversary', 'Anniversary', Icons.favorite, Color(0xFFE91E63));

  final String value;
  final String displayName;
  final IconData icon;
  final Color color;

  const EventCategory(this.value, this.displayName, this.icon, this.color);

  static EventCategory fromValue(String value) {
    return EventCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => EventCategory.personal,
    );
  }
}

class AppConstants {
  static const String appName = 'OmniCalendar';

  static const List<String> persianMonths = [
    'Farvardin', 'Ordibehesht', 'Khordad', 'Tir', 'Mordad', 'Shahrivar',
    'Mehr', 'Aban', 'Azar', 'Dey', 'Bahman', 'Esfand'
  ];

  static const List<String> persianMonthsFa = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'
  ];

  static const List<String> hijriMonths = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
  ];

  static const List<String> hijriMonthsAr = [
    'محرم', 'صفر', 'ربیع‌الاول', 'ربیع‌الثانی',
    'جمادی‌الاول', 'جمادی‌الثانی', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذیقعده', 'ذیحجه'
  ];

  static const List<String> gregorianMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> persianWeekDays = [
    'شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه'
  ];

  static const List<String> gregorianWeekDays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  static const List<String> gregorianWeekDaysFull = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  static const List<String> persianWeekDaysFull = [
    'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'
  ];

  /// Pre-loaded Persian holidays (Solar Hijri national + Lunar Hijri religious).
  static const List<Map<String, dynamic>> persianHolidays = [
    // Solar Hijri holidays
    {'title': 'Nowruz', 'titleFa': 'نوروز', 'calendarType': 'SOLAR_HIJRI', 'day': 1, 'month': 1, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': 'Sizdah Bedar', 'titleFa': 'سیزده بدر', 'calendarType': 'SOLAR_HIJRI', 'day': 13, 'month': 1, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': 'Islamic Republic Day', 'titleFa': 'روز جمهوری اسلامی', 'calendarType': 'SOLAR_HIJRI', 'day': 12, 'month': 1, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': 'Yalda Night', 'titleFa': 'شب یلدا', 'calendarType': 'SOLAR_HIJRI', 'day': 30, 'month': 9, 'year': 1403, 'category': 'national', 'isHoliday': false},
    {'title': 'Revolution Day', 'titleFa': 'پیروزی انقلاب اسلامی', 'calendarType': 'SOLAR_HIJRI', 'day': 22, 'month': 11, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': 'Oil Nationalization Day', 'titleFa': 'روز ملی شدن صنعت نفت', 'calendarType': 'SOLAR_HIJRI', 'day': 29, 'month': 12, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': 'Death of Khomeini', 'titleFa': 'رحلت امام خمینی', 'calendarType': 'SOLAR_HIJRI', 'day': 14, 'month': 3, 'year': 1403, 'category': 'national', 'isHoliday': true},
    {'title': '15 Khordad Uprising', 'titleFa': 'قیام ۱۵ خرداد', 'calendarType': 'SOLAR_HIJRI', 'day': 15, 'month': 3, 'year': 1403, 'category': 'national', 'isHoliday': true},
    // Lunar Hijri holidays
    {'title': 'Eid al-Fitr', 'titleFa': 'عید فطر', 'calendarType': 'LUNAR_HIJRI', 'day': 1, 'month': 10, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Eid al-Adha', 'titleFa': 'عید قربان', 'calendarType': 'LUNAR_HIJRI', 'day': 10, 'month': 12, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Tasua', 'titleFa': 'تاسوعا', 'calendarType': 'LUNAR_HIJRI', 'day': 9, 'month': 1, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Ashura', 'titleFa': 'عاشورا', 'calendarType': 'LUNAR_HIJRI', 'day': 10, 'month': 1, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Arbaeen', 'titleFa': 'اربعین', 'calendarType': 'LUNAR_HIJRI', 'day': 20, 'month': 2, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Birthday of Prophet', 'titleFa': 'میلاد پیامبر', 'calendarType': 'LUNAR_HIJRI', 'day': 17, 'month': 3, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Eid al-Ghadir', 'titleFa': 'عید غدیر', 'calendarType': 'LUNAR_HIJRI', 'day': 18, 'month': 12, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': "Mid-Sha'ban", 'titleFa': 'نیمه شعبان', 'calendarType': 'LUNAR_HIJRI', 'day': 15, 'month': 8, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Birthday of Imam Ali', 'titleFa': 'ولادت امام علی', 'calendarType': 'LUNAR_HIJRI', 'day': 13, 'month': 7, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': "Eid al-Mab'ath", 'titleFa': 'عید مبعث', 'calendarType': 'LUNAR_HIJRI', 'day': 27, 'month': 7, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Martyrdom of Imam Ali', 'titleFa': 'شهادت امام علی', 'calendarType': 'LUNAR_HIJRI', 'day': 21, 'month': 9, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Death of Prophet', 'titleFa': 'رحلت پیامبر', 'calendarType': 'LUNAR_HIJRI', 'day': 28, 'month': 2, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Martyrdom of Imam Reza', 'titleFa': 'شهادت امام رضا', 'calendarType': 'LUNAR_HIJRI', 'day': 29, 'month': 2, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Martyrdom of Imam Hassan Askari', 'titleFa': 'شهادت امام حسن عسکری', 'calendarType': 'LUNAR_HIJRI', 'day': 8, 'month': 3, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Birthday of Imam Mahdi', 'titleFa': 'ولادت امام مهدی', 'calendarType': 'LUNAR_HIJRI', 'day': 15, 'month': 8, 'year': 1446, 'category': 'religious', 'isHoliday': true},
    {'title': 'Birthday of Imam Sadiq', 'titleFa': 'ولادت امام صادق', 'calendarType': 'LUNAR_HIJRI', 'day': 17, 'month': 3, 'year': 1446, 'category': 'religious', 'isHoliday': false},
  ];
}
