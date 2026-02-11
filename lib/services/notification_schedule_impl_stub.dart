// Web: 알림 스케줄 없음 (로컬 알림은 모바일/데스크톱만 지원)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleJournalReminderImpl(
  FlutterLocalNotificationsPlugin plugin,
  int id,
  String title,
  String body,
  tz.TZDateTime scheduled,
) async {
  // Web에서는 로컬 알림 미지원
}
