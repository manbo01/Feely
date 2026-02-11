import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../models/app_settings.dart';
import 'notification_schedule_impl_io.dart'
    if (dart.library.html) 'notification_schedule_impl_stub.dart'
    as schedule_impl;

class NotificationService {
  NotificationService() {
    _plugin = FlutterLocalNotificationsPlugin();
  }

  late final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const int journalReminderId = 1;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const android = AndroidInitializationSettings('ic_notification');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelect,
    );
    _initialized = true;
  }

  void _onSelect(NotificationResponse? response) {
    // 알림 탭 시 앱으로 이동 등은 플atform channel 등으로 처리 가능
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true);
  }

  Future<void> scheduleJournalReminder(AppSettings settings) async {
    await _plugin.cancel(journalReminderId);
    if (!settings.notificationEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.notificationHour,
      settings.notificationMinute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await schedule_impl.scheduleJournalReminderImpl(
      _plugin,
      journalReminderId,
      'Feely',
      '오늘의 감정을 기록해 보세요.',
      scheduled,
    );
  }

  Future<void> cancelJournalReminder() async {
    await _plugin.cancel(journalReminderId);
  }
}
