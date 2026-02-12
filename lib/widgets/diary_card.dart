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
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                            (tag) {
                              final isDark = theme.brightness == Brightness.dark;
                              final tagBg = isDark
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : primary;
                              final tagFg = isDark
                                  ? theme.colorScheme.onSurface
                                  : Colors.white;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
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
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: tagFg,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '강도: ${entry.intensity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (entry.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        contentPreview,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
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
                              entry.placeText.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '·',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
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
