import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          _sectionTitle(theme, '테마 설정'),
          _themeCard(context, settings.theme),
          _sectionTitle(theme, '알림 설정'),
          _notificationCard(context, settings),
          _sectionTitle(theme, '데이터 관리'),
          _dataManagementCard(theme),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _themeCard(BuildContext context, AppTheme current) {
    final theme = Theme.of(context);
    final provider = context.read<SettingsProvider>();

    final options = [
      (AppTheme.light, Icons.light_mode, '밝은 테마'),
      (AppTheme.dark, Icons.dark_mode, '어두운 테마'),
      (AppTheme.blue, Icons.water_drop, '차분한 하늘색'),
      (AppTheme.green, Icons.eco, '자연스러운 초록색'),
      (AppTheme.purple, Icons.palette, '은은한 라벤더'),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: options
            .map(
              (o) => ListTile(
                leading: Icon(o.$2),
                title: Text(o.$3),
                trailing: current == o.$1
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () => provider.setTheme(o.$1),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, AppSettings settings) {
    final theme = Theme.of(context);
    final provider = context.read<SettingsProvider>();
    final enabled = settings.notificationEnabled;
    final hour = settings.notificationHour;
    final minute = settings.notificationMinute;
    final timeStr = _formatTime(hour, minute);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('일기 작성 알림'),
            subtitle: const Text('매일 지정한 시간에 알림을 받습니다'),
            trailing: Switch(
              value: enabled,
              onChanged: (v) => provider.setNotificationEnabled(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('알림 시간'),
            subtitle: Text(timeStr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickTime(context, provider, hour, minute),
          ),
        ],
      ),
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

  Widget _dataManagementCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: const ListTile(
        leading: Icon(Icons.storage),
        title: Text('데이터 관리'),
        subtitle: Text('데이터 내보내기 등 (준비 중)'),
      ),
    );
  }
}
