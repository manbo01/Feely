import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarSection extends StatelessWidget {
  const CalendarSection({
    super.key,
    required this.selectedDate,
    required this.currentMonth,
    required this.datesWithEntries,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime selectedDate;
  final DateTime currentMonth;
  final Set<DateTime> datesWithEntries;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthFormat = DateFormat('MMMM yyyy', 'ko');
    final days = _buildDaysInMonth(currentMonth);
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final primary = theme.colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF8F7FC),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth - 0;
            const crossSpacing = 4.0;
            const mainSpacing = 6.0;
            final cellWidth = (contentWidth - 6 * crossSpacing) / 7;
            const aspectRatio = 1.2;
            final cellHeight = cellWidth / aspectRatio;
            final gridHeight = 6 * cellHeight + 5 * mainSpacing;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: primary),
                      onPressed: () {
                        final prev = DateTime(
                          currentMonth.year,
                          currentMonth.month - 1,
                        );
                        onMonthChanged(prev);
                      },
                    ),
                    Text(
                      monthFormat.format(currentMonth),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, color: primary),
                      onPressed: () {
                        final next = DateTime(
                          currentMonth.year,
                          currentMonth.month + 1,
                        );
                        onMonthChanged(next);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: weekdays
                      .map((d) => SizedBox(
                            width: cellWidth.clamp(0.0, 40.0),
                            child: Text(
                              d,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: primary.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: gridHeight,
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    mainAxisSpacing: mainSpacing,
                    crossAxisSpacing: crossSpacing,
                    childAspectRatio: aspectRatio,
                    children: days.map((day) {
                      if (day == null) return const SizedBox.shrink();
                      final dayOnly = DateTime(day.year, day.month, day.day);
                      final isSelected = dayOnly ==
                          DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                          );
                      final hasEntry = datesWithEntries.any((d) =>
                          d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day);

                      return GestureDetector(
                        onTap: () => onDateSelected(day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? primary : null,
                            shape: hasEntry && !isSelected
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                            borderRadius: isSelected
                                ? BorderRadius.circular(8)
                                : null,
                            border: hasEntry && !isSelected
                                ? Border.all(color: primary, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${day.day}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF2D2D2D),
                                ),
                              ),
                              if (hasEntry && !isSelected)
                                Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<DateTime?> _buildDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startWeekday = first.weekday % 7;
    final days = <DateTime?>[];
    for (var i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (var d = 1; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    while (days.length < 42) {
      days.add(null);
    }
    return days;
  }
}
