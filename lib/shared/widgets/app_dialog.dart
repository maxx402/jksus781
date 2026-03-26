import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// shadcn/ui-style dialog.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.description,
    required this.actions,
    this.child,
  });

  final String title;
  final String? description;
  final List<Widget> actions;
  final Widget? child;

  /// Convenience method to show this dialog.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required List<Widget> actions,
    Widget? child,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        description: description,
        actions: actions,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null) ...[
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (child != null) const SizedBox(height: AppSpacing.lg),
          ],
          ?child,
        ],
      ),
      actions: actions,
    );
  }
}
