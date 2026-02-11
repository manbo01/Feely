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
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '일기',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
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
                  _detailLabel(theme, '날짜'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: captionColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy년 M월 d일').format(entry.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _detailLabel(theme, '시간'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: captionColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('a h:mm', 'ko').format(entry.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (entry.weatherText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _detailLabel(theme, '날씨'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.wb_sunny_outlined, size: 18, color: captionColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.weatherText,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (entry.placeText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _detailLabel(theme, '장소'),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined, size: 18, color: captionColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.placeText,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _detailLabel(theme, '감정'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...entry.emotionTags.map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: intensityColor(entry.intensity).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '강도 ${entry.intensity}/10',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (entry.content.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _detailLabel(theme, '내용'),
                    const SizedBox(height: 8),
                    Text(
                      entry.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ],
                  if (entry.imagePaths.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _detailLabel(theme, '첨부된 사진'),
                    const SizedBox(height: 8),
                    ...image_preview.buildDetailImages(entry.imagePaths),
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
                      label: const Text('수정하기'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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

  Widget _detailLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
