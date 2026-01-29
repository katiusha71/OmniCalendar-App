import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/event.dart';

class EventCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calendarColor = _getCalendarColor(event.calendarType);

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
              color: calendarColor,
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
                            Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
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
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: onDelete,
                          tooltip: 'Delete event',
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
                          color: calendarColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCalendarIcon(event.calendarType),
                              size: 16,
                              color: calendarColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.calendarType.displayName.split(' ').first,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: calendarColor,
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
                          'Annual',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (event.nextGregorianDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Next: ${_formatGregorianDate(event.nextGregorianDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDaysUntil(event.nextGregorianDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
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

  String _formatGregorianDate(DateTime date) {
    final months = AppConstants.gregorianMonths;
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return '(Today)';
    if (difference == 1) return '(Tomorrow)';
    if (difference < 0) return '(${-difference} days ago)';
    if (difference < 7) return '(in $difference days)';
    if (difference < 30) return '(in ${(difference / 7).floor()} weeks)';
    return '(in ${(difference / 30).floor()} months)';
  }
}
