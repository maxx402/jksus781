import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/todo_provider.dart';

/// Bottom-pinned quick-add input. Press Enter to create, keeps focus.
class TodoQuickAdd extends ConsumerStatefulWidget {
  const TodoQuickAdd({super.key});

  @override
  ConsumerState<TodoQuickAdd> createState() => _TodoQuickAddState();
}

class _TodoQuickAddState extends ConsumerState<TodoQuickAdd> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    unawaited(ref.read(hapticServiceProvider).selection());
    await ref.read(todoProvider.notifier).add(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: '添加新待办...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.secondary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: _submit,
            icon: Icon(Icons.add_circle, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
