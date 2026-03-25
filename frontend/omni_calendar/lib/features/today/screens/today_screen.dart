import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/tri_date_card.dart';
import '../../../shared/widgets/nowruz_countdown.dart';
import '../../../shared/widgets/event_card.dart';
import '../../events/providers/events_provider.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).loadUpcomingEvents(days: 14);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final eventsState = ref.watch(eventsProvider);
    final upcoming = eventsState.events.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('today')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(eventsProvider.notifier).loadUpcomingEvents(days: 14);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TriDateCard(),
            const SizedBox(height: 12),
            const NowruzCountdown(),
            const SizedBox(height: 20),
            // Upcoming events
            if (upcoming.isNotEmpty) ...[
              Text(
                l10n.get('upcomingEvents'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...upcoming.map((event) => EventCard(
                event: event,
                onTap: () => context.push('/edit-event/${event.id}'),
              )),
            ],
            const SizedBox(height: 20),
            // Quick actions
            Text(
              l10n.get('quickActions'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuickAction(
                  theme, l10n,
                  Icons.add,
                  l10n.get('addEvent'),
                  () => context.push('/add-event'),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  theme, l10n,
                  Icons.calendar_month,
                  l10n.get('openCalendar'),
                  () => context.go('/calendar'),
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  theme, l10n,
                  Icons.swap_horiz,
                  l10n.get('convertDate'),
                  () => context.go('/converter'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    ThemeData theme, AppLocalizations l10n,
    IconData icon, String label, VoidCallback onTap,
  ) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
