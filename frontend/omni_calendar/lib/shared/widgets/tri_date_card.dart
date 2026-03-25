import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/persian_numerals.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/calendar/providers/calendar_provider.dart';

class TriDateCard extends ConsumerWidget {
  const TriDateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);
    final usePersian = settings.usePersianNumerals;
    final isFa = settings.locale == 'fa';

    if (calState.gregorian == null) return const SizedBox.shrink();

    final greg = calState.gregorian!;
    final solar = calState.solarHijri!;
    final lunar = calState.lunarHijri!;
    final weekDay = calState.weekDay;

    String fmtNum(dynamic n) => usePersian ? PersianNumerals.convert(n) : n.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              weekDay ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDateColumn(
                  theme,
                  const Color(0xFF34A853),
                  Icons.wb_sunny_outlined,
                  isFa ? l10n.get('solarHijri') : 'Solar Hijri',
                  fmtNum(solar.day),
                  isFa ? AppConstants.persianMonthsFa[solar.month - 1] : AppConstants.persianMonths[solar.month - 1],
                  fmtNum(solar.year),
                ),
                _buildDivider(theme),
                _buildDateColumn(
                  theme,
                  const Color(0xFF4285F4),
                  Icons.calendar_month,
                  isFa ? l10n.get('gregorian') : 'Gregorian',
                  fmtNum(greg.day),
                  AppConstants.gregorianMonths[greg.month - 1],
                  fmtNum(greg.year),
                ),
                _buildDivider(theme),
                _buildDateColumn(
                  theme,
                  const Color(0xFF9C27B0),
                  Icons.nightlight_outlined,
                  isFa ? l10n.get('lunarHijri') : 'Lunar Hijri',
                  fmtNum(lunar.day),
                  isFa ? AppConstants.hijriMonthsAr[lunar.month - 1] : AppConstants.hijriMonths[lunar.month - 1],
                  fmtNum(lunar.year),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateColumn(
    ThemeData theme, Color color, IconData icon,
    String label, String day, String month, String year,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(month, style: theme.textTheme.bodyMedium),
          Text(year, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 80,
      color: theme.colorScheme.outlineVariant,
    );
  }
}
