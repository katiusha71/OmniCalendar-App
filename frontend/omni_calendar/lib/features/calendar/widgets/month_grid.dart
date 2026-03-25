import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/month_view_provider.dart';
import 'day_cell.dart';

class MonthGrid extends ConsumerWidget {
  const MonthGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthState = ref.watch(monthViewProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isFa = settings.locale == 'fa';
    final usePersian = settings.usePersianNumerals;

    final isJalali = monthState.viewType == CalendarType.solarHijri;

    // Weekday headers
    final weekDays = isJalali
        ? AppConstants.persianWeekDays
        : AppConstants.gregorianWeekDays;

    // Compute first day offset
    final firstWd = monthState.firstWeekday;
    int offset;
    if (isJalali) {
      // Jalali weekDay: 1=Sat, 2=Sun, ..., 7=Fri. Grid starts Sat.
      offset = firstWd - 1;
    } else {
      // Gregorian DateTime.weekday: 1=Mon, ..., 7=Sun. Grid starts Sun.
      offset = firstWd % 7; // Sun=0, Mon=1, ..., Sat=6
    }

    final daysInMonth = monthState.daysInMonth;
    final totalCells = offset + daysInMonth;

    // Determine today
    int? todayDay;
    switch (monthState.viewType) {
      case CalendarType.solarHijri:
        final j = Jalali.now();
        if (j.year == monthState.currentYear && j.month == monthState.currentMonth) {
          todayDay = j.day;
        }
        break;
      case CalendarType.gregorian:
        final now = DateTime.now();
        if (now.year == monthState.currentYear && now.month == monthState.currentMonth) {
          todayDay = now.day;
        }
        break;
      case CalendarType.lunarHijri:
        final h = HijriCalendar.now();
        if (h.hYear == monthState.currentYear && h.hMonth == monthState.currentMonth) {
          todayDay = h.hDay;
        }
        break;
    }

    return Column(
      children: [
        // Weekday header row
        Row(
          children: weekDays.map((wd) => Expanded(
            child: Center(
              child: Text(
                isFa ? wd : wd,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 4),
        // Day grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox.shrink();
            final day = index - offset + 1;
            if (day > daysInMonth) return const SizedBox.shrink();

            final events = monthState.eventsByDay[day] ?? [];

            return DayCell(
              day: day,
              isToday: day == todayDay,
              isSelected: day == monthState.selectedDay,
              events: events,
              usePersianNumerals: usePersian,
              onTap: () {
                ref.read(monthViewProvider.notifier).selectDay(day);
              },
            );
          },
        ),
      ],
    );
  }
}
