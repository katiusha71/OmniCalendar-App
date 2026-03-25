import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool usePersianNumerals;
  final String locale;
  final ThemeMode themeMode;
  final bool isLoading;

  SettingsState({
    this.usePersianNumerals = false,
    this.locale = 'en',
    this.themeMode = ThemeMode.system,
    this.isLoading = true,
  });

  SettingsState copyWith({
    bool? usePersianNumerals,
    String? locale,
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      usePersianNumerals: usePersianNumerals ?? this.usePersianNumerals,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
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
    final themeModeStr = await _storage.get('themeMode');
    state = state.copyWith(
      usePersianNumerals: persianNumerals == 'true',
      locale: locale ?? 'en',
      themeMode: _parseThemeMode(themeModeStr),
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

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.save('themeMode', mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
