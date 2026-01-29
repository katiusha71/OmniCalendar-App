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
  final DateTime? nextGregorianDate;
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
    this.nextGregorianDate,
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
      nextGregorianDate: json['nextGregorianDate'] != null
          ? DateTime.parse(json['nextGregorianDate'])
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
    DateTime? nextGregorianDate,
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
      nextGregorianDate: nextGregorianDate ?? this.nextGregorianDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
