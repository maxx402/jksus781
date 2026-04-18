import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/clipboard_service.dart';
import '../../core/settings/settings_provider.dart';

/// Bottom navigation shell wrapping the 4 tabs.
/// Also handles clipboard checking on launch and resume.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final AppLifecycleListener _lifecycleListener;
  bool _initialCheckDone = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialLaunch();
    });
  }

  Future<void> _handleInitialLaunch() async {
    if (_initialCheckDone) return;
    _initialCheckDone = true;

    final settings = ref.read(settingsProvider);
    if (!mounted) return;

    if (!settings.clipboardHintShown) {
      await ClipboardService.showFirstLaunchHint(context, ref);
    }

    if (!mounted) return;
    await _doClipboardCheck();
  }

  Future<void> _onResume() async {
    if (!mounted || !_initialCheckDone) return;
    await _doClipboardCheck();
  }

  Future<void> _doClipboardCheck() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      await ClipboardService.checkAndPrompt(context, ref);
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: '待办',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: '备忘',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '手记',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
