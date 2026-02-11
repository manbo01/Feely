import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    _storage = StorageService();
    _notifications = NotificationService();
    _load();
  }

  late final StorageService _storage;
  late final NotificationService _notifications;

  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get loaded => _loaded;

  Future<void> _load() async {
    try {
      _settings = await _storage.getSettings();
    } catch (_) {
      _settings = const AppSettings();
    }
    _loaded = true;
    notifyListeners();
    try {
      await _applyNotificationSchedule();
    } catch (_) {}
  }

  Future<void> setTheme(AppTheme theme) async {
    _settings = _settings.copyWith(theme: theme);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationEnabled: enabled);
    await _storage.saveSettings(_settings);
    await _applyNotificationSchedule();
    notifyListeners();
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    _settings = _settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await _storage.saveSettings(_settings);
    await _applyNotificationSchedule();
    notifyListeners();
  }

  Future<void> _applyNotificationSchedule() async {
    try {
      await _notifications.init();
      await _notifications.requestPermissions();
      await _notifications.scheduleJournalReminder(_settings);
    } catch (_) {}
  }

  Future<void> initNotifications() async {
    await _applyNotificationSchedule();
  }
}
