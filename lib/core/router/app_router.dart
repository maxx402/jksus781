import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/memo/presentation/pages/memo_edit_page.dart';
import '../../features/memo/presentation/pages/memo_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/todo',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todo',
              builder: (context, state) => const TodoPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/memo',
              builder: (context, state) => const MemoPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journal',
              builder: (context, state) => const JournalPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/memo/edit',
      builder: (context, state) =>
          MemoEditPage(id: state.extra as int?),
    ),
  ],
);
