// iOS/Android/macOS: 실제 스케줄
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleJournalReminderImpl(
  FlutterLocalNotificationsPlugin plugin,
  int id,
  String title,
  String body,
  tz.TZDateTime scheduled,
) async {
  const android = AndroidNotificationDetails(
    'feely_journal',
    '일기 작성 알림',
    channelDescription: '매일 지정한 시간에 일기 작성 알림을 보냅니다.',
  );
  const ios = DarwinNotificationDetails();
  const details = NotificationDetails(android: android, iOS: ios);

  await plugin.zonedSchedule(
    id,
    title,
    body,
    scheduled,
    details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
