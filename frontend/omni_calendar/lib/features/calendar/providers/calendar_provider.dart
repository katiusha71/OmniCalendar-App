import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/calendar_date.dart';

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref.watch(apiServiceProvider));
});

class CalendarState {
  final bool isLoading;
  final CalendarDate? gregorian;
  final CalendarDate? solarHijri;
  final CalendarDate? lunarHijri;
  final String? error;

  CalendarState({
    this.isLoading = false,
    this.gregorian,
    this.solarHijri,
    this.lunarHijri,
    this.error,
  });

  CalendarState copyWith({
    bool? isLoading,
    CalendarDate? gregorian,
    CalendarDate? solarHijri,
    CalendarDate? lunarHijri,
    String? error,
  }) {
    return CalendarState(
      isLoading: isLoading ?? this.isLoading,
      gregorian: gregorian ?? this.gregorian,
      solarHijri: solarHijri ?? this.solarHijri,
      lunarHijri: lunarHijri ?? this.lunarHijri,
      error: error,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final ApiService _api;

  CalendarNotifier(this._api) : super(CalendarState()) {
    loadToday();
  }

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get(ApiConstants.today);
      if (response.data['success'] == true) {
        final data = response.data['data'];

        final gregorian = CalendarDate.fromJson(
          data['gregorian'],
          CalendarType.gregorian,
        );
        final solarHijri = CalendarDate.fromJson(
          data['solarHijri'],
          CalendarType.solarHijri,
        );
        final lunarHijri = CalendarDate.fromJson(
          data['lunarHijri'],
          CalendarType.lunarHijri,
        );

        state = state.copyWith(
          isLoading: false,
          gregorian: gregorian,
          solarHijri: solarHijri,
          lunarHijri: lunarHijri,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> convertDate({
    required int day,
    required int month,
    int? year,
    required CalendarType sourceType,
    required CalendarType targetType,
  }) async {
    try {
      final response = await _api.post(ApiConstants.convert, data: {
        'day': day,
        'month': month,
        'year': year,
        'calendarType': sourceType.value,
        'targetType': targetType.value,
      });

      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
    return null;
  }
}
