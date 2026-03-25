import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/ics_export_service.dart';
import '../../models/event.dart';

class EventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onDelete,
  });

  Color _getCalendarColor(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        return const Color(0xFF4285F4);
      case CalendarType.solarHijri:
        return const Color(0xFF34A853);
      case CalendarType.lunarHijri:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getCalendarIcon(CalendarType type) {
    switch (type) {
      case CalendarType.gregorian:
        return Icons.calendar_month;
      case CalendarType.solarHijri:
        return Icons.wb_sunny_outlined;
      case CalendarType.lunarHijri:
        return Icons.nightlight_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final categoryColor = event.category.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              color: categoryColor,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  event.category.icon,
                                  size: 18,
                                  color: categoryColor,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    event.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (event.isHoliday) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.event_busy,
                                          size: 12,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          l10n.get('holiday'),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else if (event.isPreloaded) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 12,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          l10n.get('holiday'),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: Colors.amber[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                event.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.ios_share, size: 20),
                            onPressed: () => IcsExportService.shareEvent(event),
                            tooltip: l10n.get('share'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          if (onDelete != null)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: onDelete,
                              tooltip: l10n.get('delete'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCalendarColor(event.calendarType).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCalendarIcon(event.calendarType),
                              size: 16,
                              color: _getCalendarColor(event.calendarType),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.calendarType.displayName.split(' ').first,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getCalendarColor(event.calendarType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.event,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (event.isAnnualRecurring) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.repeat,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.get('annual'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_hasTriCalendarData()) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.get('celebrations'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...CalendarType.values.map((type) =>
                            _buildCelebrationRow(context, type)),
                        ],
                      ),
                    ),
                  ],
                  if (event.notifyDaysBefore > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.notifyDaysBefore} ${event.notifyDaysBefore == 1 ? 'day' : 'days'} before at ${event.notifyTime.substring(0, 5)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasTriCalendarData() {
    return event.gregorianDay != null &&
        event.solarHijriDay != null &&
        event.lunarHijriDay != null;
  }

  Widget _buildCelebrationRow(BuildContext context, CalendarType type) {
    final theme = Theme.of(context);
    final color = _getCalendarColor(type);
    final icon = _getCalendarIcon(type);
    final dateStr = event.getFormattedDate(type);
    final nextDate = event.getNextDate(type);
    final isPrimary = type == event.calendarType;

    String calLabel;
    switch (type) {
      case CalendarType.gregorian:
        calLabel = 'Gregorian';
        break;
      case CalendarType.solarHijri:
        calLabel = 'Solar Hijri';
        break;
      case CalendarType.lunarHijri:
        calLabel = 'Lunar Hijri';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            calLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (nextDate != null) ...[
            Text(
              _formatShortDate(nextDate),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _getDaysUntil(nextDate),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    const months = AppConstants.gregorianMonths;
    return '${date.day} ${months[date.month - 1].substring(0, 3)}';
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return '(Today)';
    if (difference == 1) return '(Tomorrow)';
    if (difference < 0) return '(${-difference}d ago)';
    if (difference < 7) return '(in ${difference}d)';
    if (difference < 30) return '(in ${(difference / 7).floor()}w)';
    return '(in ${(difference / 30).floor()}mo)';
  }
}
