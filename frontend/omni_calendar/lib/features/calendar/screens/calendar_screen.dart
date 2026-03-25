import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/persian_numerals.dart';
import '../../../shared/widgets/event_card.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/month_view_provider.dart';
import '../widgets/month_grid.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthState = ref.watch(monthViewProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    final isFa = settings.locale == 'fa';
    final usePersian = settings.usePersianNumerals;

    String fmtNum(dynamic n) => usePersian ? PersianNumerals.convert(n) : n.toString();

    // Month name
    String monthName;
    switch (monthState.viewType) {
      case CalendarType.solarHijri:
        monthName = isFa
            ? AppConstants.persianMonthsFa[monthState.currentMonth - 1]
            : AppConstants.persianMonths[monthState.currentMonth - 1];
        break;
      case CalendarType.gregorian:
        monthName = AppConstants.gregorianMonths[monthState.currentMonth - 1];
        break;
      case CalendarType.lunarHijri:
        monthName = isFa
            ? AppConstants.hijriMonthsAr[monthState.currentMonth - 1]
            : AppConstants.hijriMonths[monthState.currentMonth - 1];
        break;
    }

    final selectedEvents = monthState.selectedDay != null
        ? (monthState.eventsByDay[monthState.selectedDay!] ?? [])
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('calendar')),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.get('today'),
            onPressed: () {
              ref.read(monthViewProvider.notifier).goToToday();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          // Calendar type switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<CalendarType>(
              segments: CalendarType.values
                  .map((type) => ButtonSegment(
                        value: type,
                        label: Text(
                          type.displayName.split(' ').first,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
              selected: {monthState.viewType},
              onSelectionChanged: (selected) {
                ref.read(monthViewProvider.notifier)
                    .switchCalendarType(selected.first);
              },
            ),
          ),
          // Month header with arrows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    ref.read(monthViewProvider.notifier).prevMonth();
                  },
                ),
                Text(
                  '$monthName ${fmtNum(monthState.currentYear)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    ref.read(monthViewProvider.notifier).nextMonth();
                  },
                ),
              ],
            ),
          ),
          // Month grid
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: MonthGrid(),
          ),
          const SizedBox(height: 8),
          // Selected day events
          if (monthState.selectedDay != null && selectedEvents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${fmtNum(monthState.selectedDay!)} $monthName',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...selectedEvents.map((event) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EventCard(
                event: event,
                onTap: () => context.push('/edit-event/${event.id}'),
              ),
            )),
          ] else if (monthState.selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  l10n.get('noEvents'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
