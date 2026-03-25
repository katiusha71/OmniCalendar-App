import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/ics_export_service.dart';
import '../../../models/event.dart';
import '../providers/events_provider.dart';
import '../../../shared/widgets/event_card.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  CalendarType? _filterType;
  EventCategory? _filterCategory;
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    if (_showUpcoming) {
      await ref.read(eventsProvider.notifier).loadUpcomingEvents();
    } else {
      await ref.read(eventsProvider.notifier).loadEvents();
    }
  }

  List<Event> _getFilteredEvents(List<Event> events) {
    var filtered = events;
    if (_filterType != null) {
      filtered = filtered.where((e) => e.calendarType == _filterType).toList();
    }
    if (_filterCategory != null) {
      filtered = filtered.where((e) => e.category == _filterCategory).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    final filteredEvents = _getFilteredEvents(eventsState.events);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('events')),
        actions: [
          IconButton(
            icon: Icon(_showUpcoming ? Icons.upcoming : Icons.list),
            tooltip: _showUpcoming ? l10n.get('showAll') : l10n.get('showUpcoming'),
            onPressed: () {
              setState(() {
                _showUpcoming = !_showUpcoming;
              });
              _loadEvents();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: l10n.get('filterByCalendar'),
            onSelected: (value) {
              setState(() {
                if (value == 'all_cal') {
                  _filterType = null;
                } else if (value == 'all_cat') {
                  _filterCategory = null;
                } else if (value.startsWith('cal_')) {
                  _filterType = CalendarType.fromValue(value.substring(4));
                } else if (value.startsWith('cat_')) {
                  _filterCategory = EventCategory.fromValue(value.substring(4));
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all_cal',
                child: Text(l10n.get('allCalendars')),
              ),
              ...CalendarType.values.map(
                (type) => PopupMenuItem(
                  value: 'cal_${type.value}',
                  child: Text(type.displayName),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'all_cat',
                child: Text(l10n.get('allCategories')),
              ),
              ...EventCategory.values.map(
                (cat) => PopupMenuItem(
                  value: 'cat_${cat.value}',
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18, color: cat.color),
                      const SizedBox(width: 8),
                      Text(l10n.get(cat.value)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export_all') {
                _exportAll(eventsState.events);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    const Icon(Icons.file_download, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.get('exportAll')),
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
                ? _buildErrorState(eventsState.error!, theme, l10n)
                : filteredEvents.isEmpty
                    ? _buildEmptyState(theme, l10n)
                    : _buildEventsList(filteredEvents, theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-event'),
        icon: const Icon(Icons.add),
        label: Text(l10n.get('addEvent')),
      ),
    );
  }

  Future<void> _exportAll(List<Event> events) async {
    if (events.isEmpty) return;
    await IcsExportService.shareMultipleEvents(events);
  }

  Widget _buildErrorState(String error, ThemeData theme, AppLocalizations l10n) {
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
              l10n.get('somethingWrong'),
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
              label: Text(l10n.get('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _showUpcoming ? l10n.get('noUpcomingEvents') : l10n.get('noEvents'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('createFirstEvent'),
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
    final l10n = ref.read(localizationProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('deleteEvent')),
        content: Text('${l10n.get('deleteConfirm')} "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true && event.id != null) {
      await ref.read(eventsProvider.notifier).deleteEvent(event.id!);
    }
  }
}
