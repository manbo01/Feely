import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/diary_entry.dart';
import '../theme/app_theme.dart';

class DiaryCard extends StatelessWidget {
  const DiaryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final DiaryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final contentPreview = entry.content.length > 50
        ? '${entry.content.substring(0, 50)}...'
        : entry.content;
    final timeStr = DateFormat('a h:mm', 'ko').format(entry.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primary.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: entry.emotionTags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Intensity: ${entry.intensity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (entry.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        contentPreview,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2D2D2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (entry.weatherText.isNotEmpty ||
                        entry.placeText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (entry.weatherText.isNotEmpty) ...[
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                entry.weatherText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (entry.weatherText.isNotEmpty &&
                              entry.placeText.isNotEmpty)
                            const SizedBox(width: 8),
                          if (entry.placeText.isNotEmpty) ...[
                            Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                entry.placeText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (entry.imagePaths.isNotEmpty) ...[
                ClipOval(
                  child: _buildThumbnail(entry.imagePaths.first),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    return Image.file(
      File(path),
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 56,
        height: 56,
        color: const Color(0xFFE5E0F0),
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }
}
