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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays
                  .map((d) => SizedBox(
                        width: 32,
                        child: Text(
                          d,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
              childAspectRatio: 1.1,
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
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.25)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        if (hasEntry)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
