import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_checkbox.dart';
import '../../domain/entities/todo_item.dart';
import '../providers/todo_provider.dart';
import 'todo_detail_sheet.dart';

/// A single todo row with checkbox, animations, swipe-to-delete.
class TodoItemTile extends ConsumerStatefulWidget {
  const TodoItemTile({super.key, required this.item});

  final TodoEntity item;

  @override
  ConsumerState<TodoItemTile> createState() => _TodoItemTileState();
}

class _TodoItemTileState extends ConsumerState<TodoItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onToggleDone() async {
    if (widget.item.isDone) return;

    // Fire-and-forget: sound + haptic
    unawaited(ref.read(soundServiceProvider).playTodoDone());
    unawaited(ref.read(hapticServiceProvider).todoComplete());

    // Visual: fade
    _fadeController.forward();

    // Delay then update data
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await ref.read(todoProvider.notifier).markDone(widget.item.id!);
  }

  Future<void> _onDelete() async {
    unawaited(ref.read(hapticServiceProvider).danger());
    await ref.read(todoProvider.notifier).deleteTodo(widget.item.id!);
  }

  void _onTap() {
    TodoDetailSheet.show(context: context, ref: ref, item: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: colorScheme.error,
        child: Icon(Icons.delete_outline, color: colorScheme.onError),
      ),
      child: FadeTransition(
        opacity: item.isDone ? const AlwaysStoppedAnimation(0.5) : _fadeAnimation,
        child: InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                AppCheckbox(
                  value: item.isDone,
                  onChanged: item.isDone ? null : (_) => _onToggleDone(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isDone
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: AppBadge(
                            label: DateFormat('M/d').format(item.dueDate!),
                            variant: _isDueOverdue(item.dueDate!)
                                ? AppBadgeVariant.destructive
                                : AppBadgeVariant.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.isPinned)
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isDueOverdue(DateTime due) {
    return due.isBefore(DateTime.now());
  }
}
