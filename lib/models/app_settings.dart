/// 앱 설정 (테마, 알림).
enum AppTheme {
  light,
  dark,
  blue,
  green,
  purple,
}

class AppSettings {
  final AppTheme theme;
  final bool notificationEnabled;
  final int notificationHour;
  final int notificationMinute;

  const AppSettings({
    this.theme = AppTheme.light,
    this.notificationEnabled = true,
    this.notificationHour = 21,
    this.notificationMinute = 0,
  });

  AppSettings copyWith({
    AppTheme? theme,
    bool? notificationEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme.name,
      'notificationEnabled': notificationEnabled,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      theme: AppTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => AppTheme.light,
      ),
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      notificationHour: (json['notificationHour'] as num?)?.toInt() ?? 21,
      notificationMinute: (json['notificationMinute'] as num?)?.toInt() ?? 0,
    );
  }
}
