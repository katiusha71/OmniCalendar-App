import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../../core/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = ref.watch(localizationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings')),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader(theme, l10n.get('language')),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: settings.locale,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setLocale(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('فارسی'),
            value: 'fa',
            groupValue: settings.locale,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setLocale(value);
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(theme, l10n.get('display')),
          SwitchListTile(
            title: Text(l10n.get('persianNumerals')),
            subtitle: Text(l10n.get('persianNumeralsDesc')),
            value: settings.usePersianNumerals,
            onChanged: (_) {
              ref.read(settingsProvider.notifier).togglePersianNumerals();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
