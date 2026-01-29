import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/event.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../../../shared/widgets/event_card.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  CalendarType? _filterType;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    if (_showUpcoming) {
      await ref.read(eventsProvider.notifier).loadUpcomingEvents();
    } else {
      await ref.read(eventsProvider.notifier).loadEvents();
    }
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    if (_filterType == null) return events;
    return events.where((e) => e.calendarType == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final filteredEvents = _getFilteredEvents(eventsState.events);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniCalendar'),
        actions: [
          IconButton(
            icon: Icon(_showUpcoming ? Icons.upcoming : Icons.list),
            tooltip: _showUpcoming ? 'Show all events' : 'Show upcoming',
            onPressed: () {
              setState(() {
                _showUpcoming = !_showUpcoming;
              });
              _loadEvents();
            },
          ),
          PopupMenuButton<CalendarType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by calendar type',
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All calendars'),
              ),
              ...CalendarType.values.map(
                (type) => PopupMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  authState.user?.email ?? 'User',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: eventsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : eventsState.error != null
                ? _buildErrorState(eventsState.error!, theme)
                : filteredEvents.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildEventsList(filteredEvents, theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-event'),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _showUpcoming ? 'No upcoming events' : 'No events yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first event',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<Event> events, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 88,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          onTap: () => context.push('/edit-event/${event.id}'),
          onDelete: () => _showDeleteDialog(event),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && event.id != null) {
      await ref.read(eventsProvider.notifier).deleteEvent(event.id!);
    }
  }
}
