import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';

/// Notifier for app-wide settings.
class SettingsNotifier extends StateNotifier<AppSettingsData> {
  SettingsNotifier() : super(const AppSettingsData());

  /// Load persisted settings — call once at app startup.
  Future<void> load() async {
    state = await AppSettingsStorage.load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await AppSettingsStorage.save(state);
  }

  Future<void> setFontScale(double scale) async {
    state = state.copyWith(fontScale: scale);
    await AppSettingsStorage.save(state);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await AppSettingsStorage.save(state);
  }

  Future<void> setHapticEnabled(bool enabled) async {
    state = state.copyWith(hapticEnabled: enabled);
    await AppSettingsStorage.save(state);
  }

  Future<void> setReminderEnabled(bool enabled) async {
    state = state.copyWith(reminderEnabled: enabled);
    await AppSettingsStorage.save(state);
  }

  Future<void> setReminderOffsetHours(int hours) async {
    state = state.copyWith(reminderOffsetHours: hours);
    await AppSettingsStorage.save(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsData>((ref) {
  return SettingsNotifier();
});
