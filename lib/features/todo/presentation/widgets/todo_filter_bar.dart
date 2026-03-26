import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/todo_provider.dart';

/// Three-segment filter: 全部 / 进行中 / 已完成.
class TodoFilterBar extends ConsumerWidget {
  const TodoFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(todoProvider).filter;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: SegmentedButton<TodoFilter>(
        segments: const [
          ButtonSegment(value: TodoFilter.all, label: Text('全部')),
          ButtonSegment(value: TodoFilter.active, label: Text('进行中')),
          ButtonSegment(value: TodoFilter.done, label: Text('已完成')),
        ],
        selected: {current},
        onSelectionChanged: (selection) {
          ref.read(todoProvider.notifier).setFilter(selection.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 13),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onSurface;
          }),
        ),
      ),
    );
  }
}
