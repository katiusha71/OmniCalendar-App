import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/database_service.dart';
import '../../../models/event.dart';

final monthViewProvider =
    StateNotifierProvider<MonthViewNotifier, MonthViewState>((ref) {
  return MonthViewNotifier();
});

class MonthViewState {
  final CalendarType viewType;
  final int currentYear;
  final int currentMonth;
  final Map<int, List<Event>> eventsByDay;
  final int? selectedDay;
  final bool isLoading;

  MonthViewState({
    this.viewType = CalendarType.solarHijri,
    required this.currentYear,
    required this.currentMonth,
    this.eventsByDay = const {},
    this.selectedDay,
    this.isLoading = false,
  });

  MonthViewState copyWith({
    CalendarType? viewType,
    int? currentYear,
    int? currentMonth,
    Map<int, List<Event>>? eventsByDay,
    int? selectedDay,
    bool? isLoading,
    bool clearSelection = false,
  }) {
    return MonthViewState(
      viewType: viewType ?? this.viewType,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      eventsByDay: eventsByDay ?? this.eventsByDay,
      selectedDay: clearSelection ? null : (selectedDay ?? this.selectedDay),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get daysInMonth {
    switch (viewType) {
      case CalendarType.solarHijri:
        return Jalali(currentYear, currentMonth).monthLength;
      case CalendarType.gregorian:
        return DateTime(currentYear, currentMonth + 1, 0).day;
      case CalendarType.lunarHijri:
        // Approximate
        if (currentMonth == 12) return 30;
        return currentMonth.isOdd ? 30 : 29;
    }
  }

  /// Returns weekday of the first day of the month.
  /// For Jalali: 1=Sat, 2=Sun, ..., 7=Fri
  /// For Gregorian: DateTime.weekday: 1=Mon, ..., 7=Sun
  int get firstWeekday {
    switch (viewType) {
      case CalendarType.solarHijri:
        return Jalali(currentYear, currentMonth, 1).weekDay; // 1=Sat
      case CalendarType.gregorian:
        return DateTime(currentYear, currentMonth, 1).weekday; // 1=Mon
      case CalendarType.lunarHijri:
        // Convert first day to Gregorian to get weekday
        final greg = HijriCalendar()
            .hijriToGregorian(currentYear, currentMonth, 1);
        return greg.weekday;
    }
  }
}

class MonthViewNotifier extends StateNotifier<MonthViewState> {
  final DatabaseService _db = DatabaseService();

  MonthViewNotifier()
      : super(MonthViewState(
          currentYear: Jalali.now().year,
          currentMonth: Jalali.now().month,
        )) {
    loadEventsForMonth();
  }

  void nextMonth() {
    int month = state.currentMonth + 1;
    int year = state.currentYear;
    if (month > 12) {
      month = 1;
      year++;
    }
    state = state.copyWith(
      currentMonth: month, currentYear: year, clearSelection: true,
    );
    loadEventsForMonth();
  }

  void prevMonth() {
    int month = state.currentMonth - 1;
    int year = state.currentYear;
    if (month < 1) {
      month = 12;
      year--;
    }
    state = state.copyWith(
      currentMonth: month, currentYear: year, clearSelection: true,
    );
    loadEventsForMonth();
  }

  void goToToday() {
    switch (state.viewType) {
      case CalendarType.solarHijri:
        final today = Jalali.now();
        state = state.copyWith(
          currentYear: today.year, currentMonth: today.month,
          selectedDay: today.day,
        );
        break;
      case CalendarType.gregorian:
        final now = DateTime.now();
        state = state.copyWith(
          currentYear: now.year, currentMonth: now.month,
          selectedDay: now.day,
        );
        break;
      case CalendarType.lunarHijri:
        final hijri = HijriCalendar.now();
        state = state.copyWith(
          currentYear: hijri.hYear, currentMonth: hijri.hMonth,
          selectedDay: hijri.hDay,
        );
        break;
    }
    loadEventsForMonth();
  }

  void switchCalendarType(CalendarType type) {
    if (type == state.viewType) return;

    // Switch to current date in the new calendar
    int year, month;
    switch (type) {
      case CalendarType.solarHijri:
        final j = Jalali.now();
        year = j.year; month = j.month;
        break;
      case CalendarType.gregorian:
        final now = DateTime.now();
        year = now.year; month = now.month;
        break;
      case CalendarType.lunarHijri:
        final h = HijriCalendar.now();
        year = h.hYear; month = h.hMonth;
        break;
    }

    state = state.copyWith(
      viewType: type, currentYear: year, currentMonth: month,
      clearSelection: true,
    );
    loadEventsForMonth();
  }

  void selectDay(int day) {
    state = state.copyWith(selectedDay: day);
  }

  Future<void> loadEventsForMonth() async {
    state = state.copyWith(isLoading: true);
    try {
      final events = await _db.getEventsForMonth(
        calendarType: state.viewType,
        month: state.currentMonth,
        year: state.currentYear,
      );

      final Map<int, List<Event>> byDay = {};
      for (final event in events) {
        int? day;
        switch (state.viewType) {
          case CalendarType.gregorian:
            day = event.gregorianDay;
            break;
          case CalendarType.solarHijri:
            day = event.solarHijriDay;
            break;
          case CalendarType.lunarHijri:
            day = event.lunarHijriDay;
            break;
        }
        if (day != null) {
          byDay.putIfAbsent(day, () => []).add(event);
        }
      }

      state = state.copyWith(isLoading: false, eventsByDay: byDay);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
