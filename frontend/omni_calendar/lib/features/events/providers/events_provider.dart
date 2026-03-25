import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_service.dart';
import '../../../models/event.dart';

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier();
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
  final DatabaseService _db = DatabaseService();

  EventsNotifier() : super(EventsState());

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _db.getAllEvents();
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUpcomingEvents({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _db.getUpcomingEvents(days: days);
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createEvent(Event event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _db.insertEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateEvent(int id, Event event) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _db.updateEvent(id, event);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEvent(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _db.deleteEvent(id);
      await loadEvents();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
