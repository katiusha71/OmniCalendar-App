import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../core/utils/persian_numerals.dart';

class DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final List<Event> events;
  final bool usePersianNumerals;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.day,
    this.isToday = false,
    this.isSelected = false,
    this.events = const [],
    this.usePersianNumerals = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasEvents = events.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
                  ? theme.colorScheme.primaryContainer
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              usePersianNumerals ? PersianNumerals.convert(day) : '$day',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : isToday
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
              ),
            ),
            if (hasEvents)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events
                      .take(3)
                      .map((e) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : e.category.color,
                              shape: BoxShape.circle,
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
