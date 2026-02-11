import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/app_theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('일기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              '/edit',
              arguments: entry.id,
            ).then((_) => _load()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.emotionTags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: intensityColor(entry.intensity).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.intensity}/10',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (entry.content.isNotEmpty)
              Text(
                entry.content,
                style: theme.textTheme.bodyLarge,
              ),
            if (entry.weatherText.isNotEmpty || entry.placeText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (entry.weatherText.isNotEmpty) ...[
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.weatherText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (entry.weatherText.isNotEmpty &&
                      entry.placeText.isNotEmpty)
                    const SizedBox(width: 16),
                  if (entry.placeText.isNotEmpty) ...[
                    Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.placeText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (entry.imagePath != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entry.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ListTile(
                    leading: Icon(Icons.broken_image),
                    title: Text('이미지를 불러올 수 없습니다'),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              '작성: ${DateFormat('yyyy.MM.dd HH:mm').format(entry.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (entry.updatedAt != entry.createdAt)
              Text(
                '수정: ${DateFormat('yyyy.MM.dd HH:mm').format(entry.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
