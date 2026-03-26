import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/memo_provider.dart';
import '../widgets/memo_card.dart';
import '../widgets/memo_search_bar.dart';

/// Memo list page — tab 1. Supports grid/list toggle.
class MemoPage extends ConsumerWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoProvider);
    final items = state.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('备忘'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(memoProvider.notifier).toggleViewMode(),
            icon: Icon(
              state.viewMode == MemoViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const MemoSearchBar(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : items.isEmpty
                    ? Center(
                        child: Text(
                          state.searchQuery.isNotEmpty
                              ? '未找到匹配备忘'
                              : '暂无备忘',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      )
                    : state.viewMode == MemoViewMode.grid
                        ? GridView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return MemoCard(
                                item: item,
                                onTap: () =>
                                    context.push('/memo/edit', extra: item.id),
                                onLongPress: () => _showActions(
                                    context, ref, item.id!, item.isPinned),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return MemoCard(
                                item: item,
                                onTap: () =>
                                    context.push('/memo/edit', extra: item.id),
                                onLongPress: () => _showActions(
                                    context, ref, item.id!, item.isPinned),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/memo/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActions(
      BuildContext context, WidgetRef ref, int id, bool isPinned) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(isPinned ? '取消置顶' : '置顶'),
              onTap: () {
                Navigator.pop(context);
                ref.read(memoProvider.notifier).togglePin(id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title:
                  const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(memoProvider.notifier).deleteMemo(id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
