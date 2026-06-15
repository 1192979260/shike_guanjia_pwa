class ReminderSettings {
  static const defaultAdvanceMinutes = 60;

  final bool enabled;
  final int advanceMinutes;
  final bool includeTodayLessons;
  final bool includeMakeupLessons;
  final DateTime updatedAt;

  ReminderSettings({
    required this.enabled,
    required this.advanceMinutes,
    required this.includeTodayLessons,
    required this.includeMakeupLessons,
    required this.updatedAt,
  });

  factory ReminderSettings.defaults({DateTime? updatedAt}) {
    return ReminderSettings(
      enabled: true,
      advanceMinutes: defaultAdvanceMinutes,
      includeTodayLessons: true,
      includeMakeupLessons: true,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      enabled: json['enabled'] as bool? ?? true,
      advanceMinutes:
          (json['advanceMinutes'] as num?)?.toInt() ?? defaultAdvanceMinutes,
      includeTodayLessons: json['includeTodayLessons'] as bool? ?? true,
      includeMakeupLessons: json['includeMakeupLessons'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'advanceMinutes': advanceMinutes,
      'includeTodayLessons': includeTodayLessons,
      'includeMakeupLessons': includeMakeupLessons,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ReminderSettings copyWith({
    bool? enabled,
    int? advanceMinutes,
    bool? includeTodayLessons,
    bool? includeMakeupLessons,
    DateTime? updatedAt,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      advanceMinutes: advanceMinutes ?? this.advanceMinutes,
      includeTodayLessons: includeTodayLessons ?? this.includeTodayLessons,
      includeMakeupLessons: includeMakeupLessons ?? this.includeMakeupLessons,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ThemeSkin {
  warm,
  fresh,
  classic;

  static ThemeSkin fromJson(Object? value) {
    final name = value?.toString();
    return ThemeSkin.values.firstWhere(
      (skin) => skin.name == name,
      orElse: () => ThemeSkin.warm,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case ThemeSkin.warm:
        return '暖色贴纸';
      case ThemeSkin.fresh:
        return '清新浅色';
      case ThemeSkin.classic:
        return '经典稳重';
    }
  }
}
