import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preference keys and typed model.
class AppSettingsData {
  const AppSettingsData({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.reminderEnabled = false,
    this.reminderOffsetHours = 1,
    this.clipboardHintShown = false,
  });

  final ThemeMode themeMode;
  final double fontScale;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool reminderEnabled;
  final int reminderOffsetHours;
  final bool clipboardHintShown;

  AppSettingsData copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? reminderEnabled,
    int? reminderOffsetHours,
    bool? clipboardHintShown,
  }) {
    return AppSettingsData(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffsetHours: reminderOffsetHours ?? this.reminderOffsetHours,
      clipboardHintShown: clipboardHintShown ?? this.clipboardHintShown,
    );
  }
}

/// SharedPreferences wrapper for reading/writing settings.
class AppSettingsStorage {
  static const _keyThemeMode = 'theme_mode';
  static const _keyFontScale = 'font_scale';
  static const _keySoundEnabled = 'sound_enabled';
  static const _keyHapticEnabled = 'haptic_enabled';
  static const _keyReminderEnabled = 'reminder_enabled';
  static const _keyReminderOffset = 'reminder_offset';
  static const _keyClipboardHintShown = 'clipboard_hint_shown';

  static Future<AppSettingsData> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsData(
      themeMode: _parseThemeMode(prefs.getString(_keyThemeMode)),
      fontScale: prefs.getDouble(_keyFontScale) ?? 1.0,
      soundEnabled: prefs.getBool(_keySoundEnabled) ?? true,
      hapticEnabled: prefs.getBool(_keyHapticEnabled) ?? true,
      reminderEnabled: prefs.getBool(_keyReminderEnabled) ?? false,
      reminderOffsetHours: prefs.getInt(_keyReminderOffset) ?? 1,
      clipboardHintShown: prefs.getBool(_keyClipboardHintShown) ?? false,
    );
  }

  static Future<void> save(AppSettingsData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, _themeModeToString(data.themeMode));
    await prefs.setDouble(_keyFontScale, data.fontScale);
    await prefs.setBool(_keySoundEnabled, data.soundEnabled);
    await prefs.setBool(_keyHapticEnabled, data.hapticEnabled);
    await prefs.setBool(_keyReminderEnabled, data.reminderEnabled);
    await prefs.setInt(_keyReminderOffset, data.reminderOffsetHours);
    await prefs.setBool(_keyClipboardHintShown, data.clipboardHintShown);
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // ── Enable65 flag (read before Riverpod container) ──

  static const _keyEnable65 = 'enable_65';

  static Future<bool> isEnable65Enabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnable65) ?? false;
  }

  static Future<void> setEnable65(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnable65, value);
  }
}
