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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feely'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('yyyy년 M월 d일').format(_selectedDate),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_entriesForDate.length}개의 일기',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
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
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWriteForSelected,
        icon: const Icon(Icons.edit),
        label: const Text(
          '일기 쓰기',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
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
