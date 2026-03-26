import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_provider.dart';

/// Centralized haptic feedback service. Checks user settings before firing.
class HapticService {
  HapticService(this._ref);

  final Ref _ref;

  bool get _enabled => _ref.read(settingsProvider).hapticEnabled;

  /// Light tap — used for todo completion.
  Future<void> todoComplete() async {
    if (!_enabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Heavy impact — used for destructive actions (delete).
  Future<void> danger() async {
    if (!_enabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection click — used for creation, selection changes.
  Future<void> selection() async {
    if (!_enabled) return;
    await HapticFeedback.selectionClick();
  }
}

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService(ref);
});
