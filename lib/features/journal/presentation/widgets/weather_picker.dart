import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/journal_enums.dart';

/// Horizontal weather selector.
class WeatherPicker extends StatelessWidget {
  const WeatherPicker({super.key, this.selected, required this.onSelected});

  final JournalWeather? selected;
  final ValueChanged<JournalWeather?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      children: JournalWeather.values.map((weather) {
        final isActive = selected == weather;
        return GestureDetector(
          onTap: () => onSelected(isActive ? null : weather),
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
              '${weather.emoji} ${weather.label}',
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
