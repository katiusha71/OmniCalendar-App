import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool usePersianNumerals;
  final String locale;
  final bool isLoading;

  SettingsState({
    this.usePersianNumerals = false,
    this.locale = 'en',
    this.isLoading = true,
  });

  SettingsState copyWith({
    bool? usePersianNumerals,
    String? locale,
    bool? isLoading,
  }) {
    return SettingsState(
      usePersianNumerals: usePersianNumerals ?? this.usePersianNumerals,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final StorageService _storage = StorageService();

  SettingsNotifier() : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final persianNumerals = await _storage.get('usePersianNumerals');
    final locale = await _storage.get('locale');
    state = state.copyWith(
      usePersianNumerals: persianNumerals == 'true',
      locale: locale ?? 'en',
      isLoading: false,
    );
  }

  Future<void> togglePersianNumerals() async {
    final newValue = !state.usePersianNumerals;
    state = state.copyWith(usePersianNumerals: newValue);
    await _storage.save('usePersianNumerals', newValue.toString());
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _storage.save('locale', locale);
  }
}
