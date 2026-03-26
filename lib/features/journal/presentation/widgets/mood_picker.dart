import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/journal_enums.dart';

/// Horizontal mood selector.
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, this.selected, required this.onSelected});

  final JournalMood? selected;
  final ValueChanged<JournalMood?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      children: JournalMood.values.map((mood) {
        final isActive = selected == mood;
        return GestureDetector(
          onTap: () => onSelected(isActive ? null : mood),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.secondary,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${mood.emoji} ${mood.label}',
              style: TextStyle(
                fontSize: 13,
                color: isActive
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
