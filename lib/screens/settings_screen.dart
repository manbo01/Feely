import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'emotion_tags_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>().settings;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '설정',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: [
          _sectionHeader(theme, Icons.palette_outlined, '테마 설정'),
          const SizedBox(height: 12),
          _themeSwatches(context, settings.theme),
          const SizedBox(height: 28),
          _sectionHeader(theme, Icons.label_outline, '감정 태그 관리'),
          const SizedBox(height: 12),
          _emotionTagsManagementTile(context, theme),
          const SizedBox(height: 28),
          _sectionHeader(theme, Icons.notifications_outlined, '일기 작성 알림'),
          const SizedBox(height: 12),
          _notificationCard(context, settings),
          const SizedBox(height: 28),
          _sectionHeader(theme, Icons.storage_outlined, '데이터 관리 (준비 중)'),
          const SizedBox(height: 8),
          Text(
            '당신의 데이터를 안전하게 관리하세요 :)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, size: 22),
                  label: const Text('가져오기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_outlined, size: 22),
                  label: const Text('내보내기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withOpacity(0.6)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  'Feely v$appVersion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with love for your peace of mind',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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

  Widget _emotionTagsManagementTile(BuildContext context, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmotionTagsManagementScreen(),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '감정 태그 추가 및 삭제',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeSwatches(BuildContext context, AppTheme current) {
    final theme = Theme.of(context);
    final provider = context.read<SettingsProvider>();

    final options = [
      (AppTheme.light, '라이트', const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)),
      (AppTheme.dark, '다크', const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)),
      (AppTheme.blue, '파랑', const Color(0xFF90CAF9), const Color(0xFF64B5F6)),
      (AppTheme.green, '초록', const Color(0xFFA5D6A7), const Color(0xFF81C784)),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: options.map((o) {
        final isSelected = current == o.$1;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => provider.setTheme(o.$1),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: o.$3,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : o.$4,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              o.$2,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _notificationCard(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final provider = context.read<SettingsProvider>();
    final enabled = settings.notificationEnabled;
    final hour = settings.notificationHour;
    final minute = settings.notificationMinute;
    final timeStr = _formatTime(hour, minute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '알림 설정',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '지정된 시간에 알림을 발송할까요?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (v) => provider.setNotificationEnabled(v),
              activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '알림 시간',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '매일 몇 시에 알림을 발송할까요?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _pickTime(context, provider, hour, minute),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    timeStr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    if (hour >= 12) {
      return '오후 ${hour == 12 ? 12 : hour - 12}:${minute.toString().padLeft(2, '0')}';
    }
    return '오전 ${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(
    BuildContext context,
    SettingsProvider provider,
    int initialHour,
    int initialMinute,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (time != null) {
      await provider.setNotificationTime(time.hour, time.minute);
    }
  }
}
