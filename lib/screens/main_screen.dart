import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/diary_provider.dart';
import '../models/diary_entry.dart';
import '../widgets/calendar_section.dart';
import '../widgets/diary_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  Set<DateTime> _datesWithEntries = {};
  List<DiaryEntry> _entriesForDate = [];
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  Future<void> _refresh(DiaryProvider provider) async {
    final dates = await provider.getDatesWithEntries();
    final entries = await provider.getEntriesForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _datesWithEntries = dates;
        _entriesForDate = entries;
        _initialFetchDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diaryProvider = context.watch<DiaryProvider>();
    if (diaryProvider.loaded && !_initialFetchDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refresh(diaryProvider);
      });
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: primaryColor.withOpacity(0.2),
            child: Icon(Icons.person_outline, size: 22, color: primaryColor),
          ),
          onPressed: () {},
        ),
        title: Text(
          'Feely',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: !diaryProvider.loaded
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refresh(diaryProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarSection(
                      selectedDate: _selectedDate,
                      currentMonth: _currentMonth,
                      datesWithEntries: _datesWithEntries,
                      onDateSelected: (date) async {
                        setState(() {
                          _selectedDate = date;
                          _currentMonth = DateTime(date.year, date.month, 1);
                        });
                        _entriesForDate =
                            await diaryProvider.getEntriesForDate(date);
                        setState(() {});
                      },
                      onMonthChanged: (month) async {
                        setState(() => _currentMonth = month);
                        _datesWithEntries =
                            await diaryProvider.getDatesWithEntries();
                        setState(() {});
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '오늘의 일기',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              '전체보기',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        DateFormat('yyyy년 M월 d일').format(_selectedDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_entriesForDate.isEmpty)
                      _EmptyDayPlaceholder(
                        onWrite: () => _openWriteForSelected(),
                      )
                    else
                      ..._entriesForDate
                          .map(
                            (e) => DiaryCard(
                              entry: e,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: e.id,
                              ),
                            ),
                          )
                          .toList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWriteForSelected,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.bar_chart_outlined,
                label: '통계',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 56),
            Expanded(
              child: _NavItem(
                icon: Icons.settings_outlined,
                label: '설정',
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWriteForSelected() {
    Navigator.pushNamed(
      context,
      '/write',
      arguments: _selectedDate,
    ).then((_) async {
      final provider = context.read<DiaryProvider>();
      _datesWithEntries = await provider.getDatesWithEntries();
      _entriesForDate = await provider.getEntriesForDate(_selectedDate);
      if (mounted) setState(() {});
    });
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayPlaceholder extends StatelessWidget {
  const _EmptyDayPlaceholder({required this.onWrite});

  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '이 날의 일기가 없습니다',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 일기를 작성해보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
