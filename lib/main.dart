import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/settings/app_settings.dart';
import 'core/settings/settings_provider.dart';
import 'features/enable65/presentation/pages/enable65_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final enable65 = await AppSettingsStorage.isEnable65Enabled();

  if (enable65) {
    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Enable65Page(),
    ));
    return;
  }

  // Pre-load settings before building the widget tree.
  final container = ProviderContainer();
  await container.read(settingsProvider.notifier).load();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ShuiheApp(),
    ),
  );
}
