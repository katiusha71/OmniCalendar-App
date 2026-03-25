import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'translations/en.dart';
import 'translations/fa.dart';

class AppLocalizations {
  final Map<String, String> _strings;

  AppLocalizations(this._strings);

  String get(String key) => _strings[key] ?? key;

  static AppLocalizations of(String locale) {
    switch (locale) {
      case 'fa':
        return AppLocalizations(faTranslations);
      default:
        return AppLocalizations(enTranslations);
    }
  }
}

final localizationProvider = Provider<AppLocalizations>((ref) {
  final settings = ref.watch(settingsProvider);
  return AppLocalizations.of(settings.locale);
});
