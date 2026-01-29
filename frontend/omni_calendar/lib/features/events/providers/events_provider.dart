import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../models/event.dart';

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref.watch(apiServiceProvider));
});

class EventsState {
  final bool isLoading;
  final List<Event> events;
  final String? error;

  EventsState({
    this.isLoading = false,
    this.events = const [],
    this.error,
  });

  EventsState copyWith({
    bool? isLoading,
    List<Event>? events,
    String? error,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      error: error,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final ApiService _api;

  EventsNotifier(this._api) : super(EventsState());

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get(ApiConstants.events);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final events = data.map((e) => Event.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, events: events);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUpcomingEvents({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get(
        ApiConstants.upcomingEvents,
        queryParameters: {'days': days},
      );
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final events = data.map((e) => Event.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, events: events);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createEvent(Event event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(
        ApiConstants.events,
        data: event.toJson(),
      );
      if (response.data['success'] == true) {
        await loadEvents();
        return true;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateEvent(int id, Event event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.put(
        '${ApiConstants.events}/$id',
        data: event.toJson(),
      );
      if (response.data['success'] == true) {
        await loadEvents();
        return true;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEvent(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.delete('${ApiConstants.events}/$id');
      if (response.data['success'] == true) {
        await loadEvents();
        return true;
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
