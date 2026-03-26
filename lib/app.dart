import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/settings/settings_provider.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Sets up theme, router and locale.
class ShuiheApp extends ConsumerWidget {
  const ShuiheApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: '水赫手记',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      // Global iOS-style scroll behavior
      scrollBehavior: const _IOSScrollBehavior(),
    );
  }
}

class _IOSScrollBehavior extends ScrollBehavior {
  const _IOSScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
