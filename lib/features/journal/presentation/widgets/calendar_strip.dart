import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Horizontal scrollable date strip showing days of the month.
/// Days with entries show an indicator dot.
class CalendarStrip extends StatefulWidget {
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
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  static const double _itemWidth = 44;
  static const double _itemMargin = 2;
  static const double _totalItemWidth = _itemWidth + _itemMargin * 2;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: _initialOffset(),
    );
  }

  @override
  void didUpdateWidget(covariant CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_initialOffset());
        }
      });
    }
  }

  double _initialOffset() {
    final today = DateTime.now();
    if (today.year == widget.year && today.month == widget.month) {
      // Scroll so that today is roughly centred.
      final targetDay = today.day - 1; // zero-based index
      return (targetDay * _totalItemWidth).clamp(0.0, double.infinity);
    }
    return 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(widget.year, widget.month);
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == widget.year && today.month == widget.month;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 64,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(widget.year, widget.month, day);
          final isToday = isCurrentMonth && today.day == day;
          final isSelected = widget.selectedDay == day;
          final hasEntry = widget.daysWithEntries.contains(day);

          final weekday = _weekdayLabel(date.weekday);

          return GestureDetector(
            onTap: () => widget.onDayTapped?.call(day),
            child: Container(
              width: _itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: _itemMargin),
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
