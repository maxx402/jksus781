import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// shadcn/ui-style card component.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      );
    }

    return card;
  }
}
