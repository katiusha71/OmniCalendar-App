import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/calendar_conversion_service.dart';
import '../../../core/utils/persian_numerals.dart';
import '../../settings/providers/settings_provider.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  // Gregorian
  int _gregDay = 1, _gregMonth = 1, _gregYear = 2025;
  // Solar Hijri
  int _solarDay = 1, _solarMonth = 1, _solarYear = 1404;
  // Lunar Hijri
  int _lunarDay = 1, _lunarMonth = 1, _lunarYear = 1446;

  @override
  void initState() {
    super.initState();
    // Initialize with today
    final now = DateTime.now();
    _gregDay = now.day;
    _gregMonth = now.month;
    _gregYear = now.year;
    _convert(CalendarType.gregorian);
  }

  void _convert(CalendarType source) {
    try {
      int day, month, year;
      switch (source) {
        case CalendarType.gregorian:
          day = _gregDay; month = _gregMonth; year = _gregYear;
          break;
        case CalendarType.solarHijri:
          day = _solarDay; month = _solarMonth; year = _solarYear;
          break;
        case CalendarType.lunarHijri:
          day = _lunarDay; month = _lunarMonth; year = _lunarYear;
          break;
      }

      final tri = CalendarConversionService.convertToAll(
        sourceType: source, day: day, month: month, year: year,
      );

      setState(() {
        if (source != CalendarType.gregorian) {
          _gregDay = tri.gregorianDay;
          _gregMonth = tri.gregorianMonth;
          _gregYear = tri.gregorianYear;
        }
        if (source != CalendarType.solarHijri) {
          _solarDay = tri.solarHijriDay;
          _solarMonth = tri.solarHijriMonth;
          _solarYear = tri.solarHijriYear;
        }
        if (source != CalendarType.lunarHijri) {
          _lunarDay = tri.lunarHijriDay;
          _lunarMonth = tri.lunarHijriMonth;
          _lunarYear = tri.lunarHijriYear;
        }
      });
    } catch (_) {
      // Invalid date combination, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final settings = ref.watch(settingsProvider);
    final usePersian = settings.usePersianNumerals;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('converter')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCalendarSection(
            theme, l10n,
            CalendarType.gregorian,
            l10n.get('gregorian'),
            const Color(0xFF4285F4),
            Icons.calendar_month,
            AppConstants.gregorianMonths,
            _gregDay, _gregMonth, _gregYear,
            31, // simplified max days
            usePersian,
            (d) { _gregDay = d; _convert(CalendarType.gregorian); },
            (m) { _gregMonth = m; _convert(CalendarType.gregorian); },
            (y) { _gregYear = y; _convert(CalendarType.gregorian); },
          ),
          const SizedBox(height: 16),
          _buildCalendarSection(
            theme, l10n,
            CalendarType.solarHijri,
            l10n.get('solarHijri'),
            const Color(0xFF34A853),
            Icons.wb_sunny_outlined,
            settings.locale == 'fa' ? AppConstants.persianMonthsFa : AppConstants.persianMonths,
            _solarDay, _solarMonth, _solarYear,
            31,
            usePersian,
            (d) { _solarDay = d; _convert(CalendarType.solarHijri); },
            (m) { _solarMonth = m; _convert(CalendarType.solarHijri); },
            (y) { _solarYear = y; _convert(CalendarType.solarHijri); },
          ),
          const SizedBox(height: 16),
          _buildCalendarSection(
            theme, l10n,
            CalendarType.lunarHijri,
            l10n.get('lunarHijri'),
            const Color(0xFF9C27B0),
            Icons.nightlight_outlined,
            settings.locale == 'fa' ? AppConstants.hijriMonthsAr : AppConstants.hijriMonths,
            _lunarDay, _lunarMonth, _lunarYear,
            30,
            usePersian,
            (d) { _lunarDay = d; _convert(CalendarType.lunarHijri); },
            (m) { _lunarMonth = m; _convert(CalendarType.lunarHijri); },
            (y) { _lunarYear = y; _convert(CalendarType.lunarHijri); },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection(
    ThemeData theme, AppLocalizations l10n,
    CalendarType type, String label, Color color, IconData icon,
    List<String> months,
    int day, int month, int year, int maxDays,
    bool usePersian,
    void Function(int) onDayChanged,
    void Function(int) onMonthChanged,
    void Function(int) onYearChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    value: day.clamp(1, maxDays),
                    decoration: InputDecoration(
                      labelText: l10n.get('day'),
                      isDense: true,
                    ),
                    items: List.generate(maxDays, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(usePersian ? PersianNumerals.convert(i + 1) : '${i + 1}'),
                    )),
                    onChanged: (v) { if (v != null) onDayChanged(v); },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<int>(
                    value: month.clamp(1, 12),
                    decoration: InputDecoration(
                      labelText: l10n.get('month'),
                      isDense: true,
                    ),
                    items: List.generate(12, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(months[i]),
                    )),
                    onChanged: (v) { if (v != null) onMonthChanged(v); },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: ValueKey('${type.value}_year_$year'),
                    initialValue: usePersian ? PersianNumerals.convert(year) : year.toString(),
                    decoration: InputDecoration(
                      labelText: l10n.get('year'),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (v) {
                      final normalized = v.replaceAllMapped(RegExp(r'[۰-۹]'), (m) {
                        const digits = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
                        return '${digits.indexOf(m.group(0)!)}';
                      });
                      final parsed = int.tryParse(normalized);
                      if (parsed != null) onYearChanged(parsed);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
