import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/calendar_date.dart';

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});

class CalendarState {
  final bool isLoading;
  final CalendarDate? gregorian;
  final CalendarDate? solarHijri;
  final CalendarDate? lunarHijri;
  final String? weekDay;
  final String? weekDayFa;
  final String? error;

  CalendarState({
    this.isLoading = false,
    this.gregorian,
    this.solarHijri,
    this.lunarHijri,
    this.weekDay,
    this.weekDayFa,
    this.error,
  });

  CalendarState copyWith({
    bool? isLoading,
    CalendarDate? gregorian,
    CalendarDate? solarHijri,
    CalendarDate? lunarHijri,
    String? weekDay,
    String? weekDayFa,
    String? error,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      gregorian: gregorian ?? this.gregorian,
      solarHijri: solarHijri ?? this.solarHijri,
      lunarHijri: lunarHijri ?? this.lunarHijri,
      weekDay: weekDay ?? this.weekDay,
      weekDayFa: weekDayFa ?? this.weekDayFa,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(CalendarState()) {
    loadToday();
  }

  void loadToday() {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();

      // Gregorian
      final gregorian = CalendarDate(
        day: now.day,
        month: now.month,
        year: now.year,
        calendarType: CalendarType.gregorian,
      );

      // Solar Hijri (Jalali)
      final jalali = Jalali.fromDateTime(now);
      final solarHijri = CalendarDate(
        day: jalali.day,
        month: jalali.month,
        year: jalali.year,
        calendarType: CalendarType.solarHijri,
      );

      // Lunar Hijri
      final hijri = HijriCalendar.now();
      final lunarHijri = CalendarDate(
        day: hijri.hDay,
        month: hijri.hMonth,
        year: hijri.hYear,
        calendarType: CalendarType.lunarHijri,
      );

      // Day of week
      final weekDayEn = AppConstants.gregorianWeekDaysFull[now.weekday % 7];
      // Jalali weekDay: 1=Sat, 2=Sun, ..., 7=Fri
      final weekDayFa = AppConstants.persianWeekDaysFull[now.weekday % 7];

      state = state.copyWith(
        isLoading: false,
        gregorian: gregorian,
        solarHijri: solarHijri,
        lunarHijri: lunarHijri,
        weekDay: weekDayEn,
        weekDayFa: weekDayFa,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
