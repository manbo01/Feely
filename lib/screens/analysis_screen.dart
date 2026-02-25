import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/weather.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late DateTime _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diaryProvider = context.watch<DiaryProvider>();
    final entries = diaryProvider.allEntries;

    final hasEntries = entries.isNotEmpty;

    final monthlyEntries = entries.where((e) =>
        e.date.year == _selectedMonth.year &&
        e.date.month == _selectedMonth.month);
    final yearlyEntries =
        entries.where((e) => e.date.year == _selectedYear);

    final overallTopEmotion = _topEmotion(entries);
    final monthlyEmotionStats = _countByEmotion(monthlyEntries);
    final yearlyEmotionStats = _countByEmotion(yearlyEntries);
    final weatherEmotionStats = _weatherEmotionPattern(entries);

    final monthLabel = DateFormat('yyyy년 M월', 'ko').format(_selectedMonth);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '분석',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: hasEntries
          ? ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _sectionHeader(
                  theme,
                  Icons.insights_outlined,
                  '요약',
                ),
                const SizedBox(height: 12),
                _buildSummaryCard(theme, entries, overallTopEmotion),
                const SizedBox(height: 28),
                _sectionHeader(
                  theme,
                  Icons.calendar_month_outlined,
                  '월간 감정 통계',
                ),
                const SizedBox(height: 12),
                _buildMonthSelector(theme, monthLabel),
                const SizedBox(height: 12),
                _buildEmotionStatsCard(
                  theme: theme,
                  stats: monthlyEmotionStats,
                  emptyLabel: '이 달에는 아직 기록된 감정이 없어요.',
                ),
                const SizedBox(height: 28),
                _sectionHeader(
                  theme,
                  Icons.timeline_outlined,
                  '연간 감정 통계',
                ),
                const SizedBox(height: 12),
                _buildYearSelector(theme),
                const SizedBox(height: 12),
                _buildEmotionStatsCard(
                  theme: theme,
                  stats: yearlyEmotionStats,
                  emptyLabel: '이 해에는 아직 기록된 감정이 없어요.',
                ),
                const SizedBox(height: 28),
                _sectionHeader(
                  theme,
                  Icons.cloud_outlined,
                  '날씨와 감정 패턴',
                ),
                const SizedBox(height: 12),
                _buildWeatherPatternCard(
                  theme: theme,
                  stats: weatherEmotionStats,
                ),
                const SizedBox(height: 24),
              ],
            )
          : _buildEmptyPlaceholder(theme),
    );
  }

  Widget _sectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    List<DiaryEntry> entries,
    String? overallTopEmotion,
  ) {
    final totalCount = entries.length;
    final sorted = List<DiaryEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final firstDate = sorted.first.date;
    final lastDate = sorted.last.date;
    final dateRange =
        '${DateFormat('yyyy.MM.dd', 'ko').format(firstDate)} - ${DateFormat('yyyy.MM.dd', 'ko').format(lastDate)}';

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지금까지의 기록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalCount개의 감정 일기가 쌓였어요.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (overallTopEmotion != null)
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '가장 자주 느낀 감정은 "$overallTopEmotion" 이에요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme, String monthLabel) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                  1,
                );
              });
            },
          ),
          Text(
            monthLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                  1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _selectedYear -= 1;
              });
            },
          ),
          Text(
            '$_selectedYear년',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _selectedYear += 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionStatsCard({
    required ThemeData theme,
    required Map<String, int> stats,
    required String emptyLabel,
  }) {
    if (stats.isEmpty) {
      return Material(
        color:
            theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emptyLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = sorted.first.value;

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.map((entry) {
            final ratio = maxCount == 0 ? 0.0 : entry.value / maxCount;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _EmotionBarRow(
                label: entry.key,
                count: entry.value,
                ratio: ratio,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWeatherPatternCard({
    required ThemeData theme,
    required Map<String, List<String>> stats,
  }) {
    if (stats.isEmpty) {
      return Material(
        color:
            theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '날씨와 함께 기록된 일기가 아직 많지 않아요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.entries.map((entry) {
            final weather = entry.key;
            final emotions = entry.value;
            final emotionText =
                emotions.isNotEmpty ? '"${emotions.join('", "')}"' : null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_cloudy_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emotionText != null
                          ? '$weather 날에는 $emotionText 감정을 자주 느꼈어요.'
                          : '$weather 날과 함께 기록된 감정이 아직 없어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 분석할 일기가 없어요',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '감정 일기를 조금 더 쌓으면,\n여기에서 다양한 통계와 패턴을 볼 수 있어요.',
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

  Map<String, int> _countByEmotion(Iterable<DiaryEntry> entries) {
    final Map<String, int> result = {};
    for (final e in entries) {
      for (final tag in e.emotionTags) {
        if (tag.trim().isEmpty) continue;
        result[tag] = (result[tag] ?? 0) + 1;
      }
    }
    return result;
  }

  String? _topEmotion(Iterable<DiaryEntry> entries) {
    final stats = _countByEmotion(entries);
    if (stats.isEmpty) return null;
    return stats.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  Map<String, List<String>> _weatherEmotionPattern(
      Iterable<DiaryEntry> entries) {
    final Map<String, Map<String, int>> byWeather = {};

    for (final e in entries) {
      final weatherRaw = e.weatherText.trim();
      if (weatherRaw.isEmpty) continue;
      if (e.emotionTags.isEmpty) continue;

      final weatherKey = _normalizeWeatherKeyword(weatherRaw);
      if (weatherKey == null) continue;

      byWeather.putIfAbsent(weatherKey, () => {});
      final emotionMap = byWeather[weatherKey]!;

      for (final tag in e.emotionTags) {
        if (tag.trim().isEmpty) continue;
        emotionMap[tag] = (emotionMap[tag] ?? 0) + 1;
      }
    }

    final Map<String, List<String>> result = {};
    byWeather.forEach((weather, emotionCounts) {
      if (emotionCounts.isEmpty) {
        result[weather] = <String>[];
        return;
      }

      final maxCount =
          emotionCounts.values.reduce((a, b) => a >= b ? a : b);
      final tops = emotionCounts.entries
          .where((e) => e.value == maxCount)
          .map((e) => e.key)
          .toList();
      result[weather] = tops;
    });

    return result;
  }

  /// 날씨 텍스트에서 '맑음', '흐림', '비', '눈' 등 최전방 키워드만 추출해
  /// 드롭다운에서 선택한 값과 자동 인식 값을 통일합니다.
  String? _normalizeWeatherKeyword(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    // 드롭다운에서 사용 중인 기본 키워드만 고려
    const candidates = [
      weatherOptionClear,
      weatherOptionCloudy,
      weatherOptionRain,
      weatherOptionSnow,
    ];

    for (final c in candidates) {
      if (text.startsWith(c)) return c;
      if (text.contains(c)) return c;
    }

    // 어떤 기본 키워드도 포함하지 않으면 분석 대상에서 제외
    return null;
  }
}

class _EmotionBarRow extends StatelessWidget {
  const _EmotionBarRow({
    required this.label,
    required this.count,
    required this.ratio,
  });

  final String label;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count회',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

