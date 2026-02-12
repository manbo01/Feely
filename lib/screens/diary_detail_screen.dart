import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';
import 'image_preview_io.dart' if (dart.library.html) 'image_preview_stub.dart' as image_preview;

class DiaryDetailScreen extends StatefulWidget {
  const DiaryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  DiaryEntry? _entry;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<DiaryProvider>();
    final entry = await provider.getEntry(widget.entryId);
    if (mounted) {
      setState(() {
        _entry = entry;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('일기')),
        body: const Center(child: Text('일기를 찾을 수 없습니다.')),
      );
    }

    final entry = _entry!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final captionColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '일기',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailCard(
                theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailLabel(theme, '날짜'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: captionColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDateWithWeekday(entry.date),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailLabel(theme, '시간'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 18, color: captionColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('a h:mm', 'ko').format(entry.date),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (entry.weatherText.isNotEmpty || entry.placeText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailLabel(theme, '날씨'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.wb_sunny_outlined, size: 18, color: captionColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        entry.weatherText.isEmpty ? '—' : entry.weatherText,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailLabel(theme, '장소'),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.place_outlined, size: 18, color: captionColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        entry.placeText.isEmpty ? '—' : entry.placeText,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _detailCard(
                theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailLabel(theme, '감정'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...entry.emotionTags.map(
                          (tag) {
                            final isDark = theme.brightness == Brightness.dark;
                            final tagBg = isDark
                                ? theme.colorScheme.surfaceContainerHighest
                                : primary;
                            final tagFg = isDark
                                ? theme.colorScheme.onSurface
                                : Colors.white;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: tagBg,
                                borderRadius: BorderRadius.circular(20),
                                border: isDark
                                    ? Border.all(
                                        color: theme.colorScheme.outline,
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: tagFg,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailLabel(theme, '강도'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _IntensityGradientBar(value: entry.intensity),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${entry.intensity}/10',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: captionColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: _detailCard(
                      theme,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _detailLabel(theme, '일기'),
                          const SizedBox(height: 8),
                          Text(
                            entry.content,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (entry.imagePaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                _detailCard(
                  theme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailLabel(theme, '사진'),
                      const SizedBox(height: 8),
                      ...image_preview.buildDetailImages(entry.imagePaths),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/edit',
                    arguments: entry.id,
                  ).then((_) => _load()),
                  icon: const Icon(Icons.edit_outlined, size: 22),
                  label: const Text('수정'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, entry),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    '삭제',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '작성: ${DateFormat('yyyy.MM.dd HH:mm').format(entry.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: captionColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, DiaryEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<DiaryProvider>().deleteEntry(entry.id);
    if (mounted) Navigator.pop(context);
  }

  String _formatDateWithWeekday(DateTime date) {
    const weekdays = '월화수목금토일';
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays.substring(date.weekday - 1, date.weekday)})';
  }

  Widget _detailCard(ThemeData theme, {required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _detailLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _IntensityGradientBar extends StatelessWidget {
  const _IntensityGradientBar({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fraction = (value.clamp(1, 10)) / 10;
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(
                  width: width * fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          intensityColor(1),
                          intensityColor(3),
                          intensityColor(5),
                          intensityColor(7),
                          intensityColor(10),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
