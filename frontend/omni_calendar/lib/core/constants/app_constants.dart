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

class AppConstants {
  static const String appName = 'OmniCalendar';
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  static const List<String> persianMonths = [
    'Farvardin', 'Ordibehesht', 'Khordad', 'Tir', 'Mordad', 'Shahrivar',
    'Mehr', 'Aban', 'Azar', 'Dey', 'Bahman', 'Esfand'
  ];

  static const List<String> hijriMonths = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
  ];

  static const List<String> gregorianMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
}
