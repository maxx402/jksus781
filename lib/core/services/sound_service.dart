import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_provider.dart';

/// Centralized sound effects service.
class SoundService {
  SoundService(this._ref);

  final Ref _ref;
  final AudioPlayer _player = AudioPlayer();

  /// Play the todo-done chime. Respects user settings.
  Future<void> playTodoDone() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.soundEnabled) return;
    await _player.play(AssetSource('sounds/todo_done.mp3'));
  }

  void dispose() {
    _player.dispose();
  }
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
