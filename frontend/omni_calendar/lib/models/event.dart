import '../core/constants/app_constants.dart';

class Event {
  final int? id;
  final String title;
  final String? description;
  final CalendarType calendarType;
  final int originalDay;
  final int originalMonth;
  final int? originalYear;
  final bool isAnnualRecurring;
  final int notifyDaysBefore;
  final String notifyTime;
  final bool isPreloaded;
  final EventCategory category;
  final bool isHoliday;

  // Tri-calendar representations
  final int? gregorianDay;
  final int? gregorianMonth;
  final int? gregorianYear;
  final int? solarHijriDay;
  final int? solarHijriMonth;
  final int? solarHijriYear;
  final int? lunarHijriDay;
  final int? lunarHijriMonth;
  final int? lunarHijriYear;

  // Next occurrence dates (all stored as Gregorian DateTime)
  final DateTime? nextDateGregorian;
  final DateTime? nextDateSolarHijri;
  final DateTime? nextDateLunarHijri;
  final DateTime? earliestNextDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    this.id,
    required this.title,
    this.description,
    required this.calendarType,
    required this.originalDay,
    required this.originalMonth,
    this.originalYear,
    this.isAnnualRecurring = true,
    this.notifyDaysBefore = 0,
    this.notifyTime = '09:00:00',
    this.isPreloaded = false,
    this.category = EventCategory.personal,
    this.isHoliday = false,
    this.gregorianDay,
    this.gregorianMonth,
    this.gregorianYear,
    this.solarHijriDay,
    this.solarHijriMonth,
    this.solarHijriYear,
    this.lunarHijriDay,
    this.lunarHijriMonth,
    this.lunarHijriYear,
    this.nextDateGregorian,
    this.nextDateSolarHijri,
    this.nextDateLunarHijri,
    this.earliestNextDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      calendarType: CalendarType.fromValue(json['calendarType']),
      originalDay: json['originalDay'],
      originalMonth: json['originalMonth'],
      originalYear: json['originalYear'],
      isAnnualRecurring: json['isAnnualRecurring'] ?? true,
      notifyDaysBefore: json['notifyDaysBefore'] ?? 0,
      notifyTime: json['notifyTime'] ?? '09:00:00',
      isPreloaded: json['isPreloaded'] == true || json['isPreloaded'] == 1,
      category: json['category'] != null
          ? EventCategory.fromValue(json['category'])
          : EventCategory.personal,
      isHoliday: json['isHoliday'] == true || json['isHoliday'] == 1,
      gregorianDay: json['gregorianDay'],
      gregorianMonth: json['gregorianMonth'],
      gregorianYear: json['gregorianYear'],
      solarHijriDay: json['solarHijriDay'],
      solarHijriMonth: json['solarHijriMonth'],
      solarHijriYear: json['solarHijriYear'],
      lunarHijriDay: json['lunarHijriDay'],
      lunarHijriMonth: json['lunarHijriMonth'],
      lunarHijriYear: json['lunarHijriYear'],
      nextDateGregorian: json['nextDateGregorian'] != null
          ? DateTime.parse(json['nextDateGregorian'])
          : null,
      nextDateSolarHijri: json['nextDateSolarHijri'] != null
          ? DateTime.parse(json['nextDateSolarHijri'])
          : null,
      nextDateLunarHijri: json['nextDateLunarHijri'] != null
          ? DateTime.parse(json['nextDateLunarHijri'])
          : null,
      earliestNextDate: json['earliestNextDate'] != null
          ? DateTime.parse(json['earliestNextDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'calendarType': calendarType.value,
      'originalDay': originalDay,
      'originalMonth': originalMonth,
      'originalYear': originalYear,
      'isAnnualRecurring': isAnnualRecurring,
      'notifyDaysBefore': notifyDaysBefore,
      'notifyTime': notifyTime,
      'category': category.value,
      'isHoliday': isHoliday,
    };
  }

  String get formattedDate {
    final months = calendarType == CalendarType.solarHijri
        ? AppConstants.persianMonths
        : calendarType == CalendarType.lunarHijri
            ? AppConstants.hijriMonths
            : AppConstants.gregorianMonths;

    final monthName = months[originalMonth - 1];
    if (originalYear != null) {
      return '$originalDay $monthName $originalYear';
    }
    return '$originalDay $monthName';
  }

  /// Get formatted date string for any calendar type using converted fields.
  String getFormattedDate(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        if (gregorianDay != null && gregorianMonth != null) {
          return '$gregorianDay ${AppConstants.gregorianMonths[gregorianMonth! - 1]}';
        }
        break;
      case CalendarType.solarHijri:
        if (solarHijriDay != null && solarHijriMonth != null) {
          return '$solarHijriDay ${AppConstants.persianMonths[solarHijriMonth! - 1]}';
        }
        break;
      case CalendarType.lunarHijri:
        if (lunarHijriDay != null && lunarHijriMonth != null) {
          return '$lunarHijriDay ${AppConstants.hijriMonths[lunarHijriMonth! - 1]}';
        }
        break;
    }
    return formattedDate;
  }

  /// Get the next occurrence DateTime for a specific calendar type.
  DateTime? getNextDate(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        return nextDateGregorian;
      case CalendarType.solarHijri:
        return nextDateSolarHijri;
      case CalendarType.lunarHijri:
        return nextDateLunarHijri;
    }
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    CalendarType? calendarType,
    int? originalDay,
    int? originalMonth,
    int? originalYear,
    bool? isAnnualRecurring,
    int? notifyDaysBefore,
    String? notifyTime,
    bool? isPreloaded,
    EventCategory? category,
    bool? isHoliday,
    int? gregorianDay,
    int? gregorianMonth,
    int? gregorianYear,
    int? solarHijriDay,
    int? solarHijriMonth,
    int? solarHijriYear,
    int? lunarHijriDay,
    int? lunarHijriMonth,
    int? lunarHijriYear,
    DateTime? nextDateGregorian,
    DateTime? nextDateSolarHijri,
    DateTime? nextDateLunarHijri,
    DateTime? earliestNextDate,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      calendarType: calendarType ?? this.calendarType,
      originalDay: originalDay ?? this.originalDay,
      originalMonth: originalMonth ?? this.originalMonth,
      originalYear: originalYear ?? this.originalYear,
      isAnnualRecurring: isAnnualRecurring ?? this.isAnnualRecurring,
      notifyDaysBefore: notifyDaysBefore ?? this.notifyDaysBefore,
      notifyTime: notifyTime ?? this.notifyTime,
      isPreloaded: isPreloaded ?? this.isPreloaded,
      category: category ?? this.category,
      isHoliday: isHoliday ?? this.isHoliday,
      gregorianDay: gregorianDay ?? this.gregorianDay,
      gregorianMonth: gregorianMonth ?? this.gregorianMonth,
      gregorianYear: gregorianYear ?? this.gregorianYear,
      solarHijriDay: solarHijriDay ?? this.solarHijriDay,
      solarHijriMonth: solarHijriMonth ?? this.solarHijriMonth,
      solarHijriYear: solarHijriYear ?? this.solarHijriYear,
      lunarHijriDay: lunarHijriDay ?? this.lunarHijriDay,
      lunarHijriMonth: lunarHijriMonth ?? this.lunarHijriMonth,
      lunarHijriYear: lunarHijriYear ?? this.lunarHijriYear,
      nextDateGregorian: nextDateGregorian ?? this.nextDateGregorian,
      nextDateSolarHijri: nextDateSolarHijri ?? this.nextDateSolarHijri,
      nextDateLunarHijri: nextDateLunarHijri ?? this.nextDateLunarHijri,
      earliestNextDate: earliestNextDate ?? this.earliestNextDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
