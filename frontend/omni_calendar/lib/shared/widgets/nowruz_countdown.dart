import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/persian_numerals.dart';
import '../../features/settings/providers/settings_provider.dart';

class NowruzCountdown extends ConsumerStatefulWidget {
  const NowruzCountdown({super.key});

  @override
  ConsumerState<NowruzCountdown> createState() => _NowruzCountdownState();
}

class _NowruzCountdownState extends ConsumerState<NowruzCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isNowruz = false;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _computeRemaining());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _computeRemaining() {
    final now = DateTime.now();
    final todayJalali = Jalali.fromDateTime(now);

    // Next 1 Farvardin
    int targetYear = todayJalali.year;
    if (todayJalali.month > 1 || (todayJalali.month == 1 && todayJalali.day > 1)) {
      targetYear++;
    }

    final nextNowruz = Jalali(targetYear, 1, 1);
    final nextNowruzGreg = nextNowruz.toGregorian();
    final targetDate = DateTime(nextNowruzGreg.year, nextNowruzGreg.month, nextNowruzGreg.day);

    final diff = targetDate.difference(now);

    setState(() {
      if (todayJalali.month == 1 && todayJalali.day == 1) {
        _isNowruz = true;
        _remaining = Duration.zero;
      } else {
        _isNowruz = false;
        _remaining = diff;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(localizationProvider);
    final settings = ref.watch(settingsProvider);
    final usePersian = settings.usePersianNumerals;

    String fmtNum(dynamic n) => usePersian ? PersianNumerals.convert(n) : n.toString();

    if (_isNowruz) {
      return Card(
        color: const Color(0xFF34A853),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                l10n.get('nowruzMobarak'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wb_sunny,
                color: Color(0xFF34A853),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get('nowruzCountdown'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: fmtNum(days),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34A853),
                          ),
                        ),
                        TextSpan(text: ' ${l10n.get('daysUntilNowruz')}'),
                      ],
                    ),
                  ),
                  Text(
                    '${fmtNum(hours)}h',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
