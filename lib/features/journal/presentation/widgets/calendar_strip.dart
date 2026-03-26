import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Horizontal scrollable date strip showing days of the month.
/// Days with entries show an indicator dot.
class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    required this.year,
    required this.month,
    required this.daysWithEntries,
    this.selectedDay,
    this.onDayTapped,
  });

  final int year;
  final int month;
  final Set<int> daysWithEntries;
  final int? selectedDay;
  final ValueChanged<int>? onDayTapped;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(year, month, day);
          final isToday = isCurrentMonth && today.day == day;
          final isSelected = selectedDay == day;
          final hasEntry = daysWithEntries.contains(day);

          final weekday = _weekdayLabel(date.weekday);

          return GestureDetector(
            onTap: () => onDayTapped?.call(day),
            child: Container(
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : isToday
                        ? colorScheme.secondary
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasEntry
                          ? (isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['一', '二', '三', '四', '五', '六', '日'];
    return labels[weekday - 1];
  }
}
