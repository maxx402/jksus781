import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

enum AppBadgeVariant { primary, secondary, outline, destructive }

/// shadcn/ui-style badge / chip.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.secondary,
  });

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color bg;
    final Color fg;
    final BorderSide? border;

    switch (variant) {
      case AppBadgeVariant.primary:
        bg = colorScheme.primary;
        fg = colorScheme.onPrimary;
        border = null;
      case AppBadgeVariant.secondary:
        bg = colorScheme.secondary;
        fg = colorScheme.onSecondary;
        border = null;
      case AppBadgeVariant.outline:
        bg = Colors.transparent;
        fg = colorScheme.onSurface;
        border = BorderSide(color: colorScheme.outline);
      case AppBadgeVariant.destructive:
        bg = colorScheme.error;
        fg = colorScheme.onError;
        border = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: border != null ? Border.fromBorderSide(border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}
