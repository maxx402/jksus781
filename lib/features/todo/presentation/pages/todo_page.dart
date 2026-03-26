import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_separator.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_filter_bar.dart';
import '../widgets/todo_item_tile.dart';
import '../widgets/todo_quick_add.dart';

/// Main todo list page — tab 0.
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoProvider);
    final items = state.filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('待办')),
      body: Column(
        children: [
          const TodoFilterBar(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : items.isEmpty
                    ? Center(
                        child: Text(
                          state.filter == TodoFilter.all
                              ? '暂无待办事项'
                              : state.filter == TodoFilter.active
                                  ? '所有任务已完成'
                                  : '暂无已完成任务',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const AppSeparator(),
                        itemBuilder: (context, index) {
                          return TodoItemTile(item: items[index]);
                        },
                      ),
          ),
          const TodoQuickAdd(),
        ],
      ),
    );
  }
}
