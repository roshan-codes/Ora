import 'package:intl/intl.dart';
import '../../../core/constants/audio_constants.dart';

class AlarmModel {
  final int id;
  final int hour; // 0-23
  final int minute; // 0-59
  final String label;
  final bool isEnabled;
  final List<int> repeatDays; // 1 = Mon, ..., 7 = Sun
  final String audioPath;
  final String audioTitle;
  final double volume; // 0.0 to 1.0
  final bool gradualVolume;
  final bool vibrate;
  final int snoozeDurationMinutes; // 5, 10, 15, 20
  final bool sunriseAlarm;

  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = 'Alarm',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.audioPath = 'assets/audio/classic_alarm.wav',
    this.audioTitle = 'Classic Alarm',
    this.volume = 0.8,
    this.gradualVolume = false,
    this.vibrate = true,
    this.snoozeDurationMinutes = 10,
    this.sunriseAlarm = false,
  });

  /// Computes the next scheduled DateTime for this alarm
  DateTime getNextTriggerDateTime({DateTime? now}) {
    final current = now ?? DateTime.now();
    final todayTrigger = DateTime(
      current.year,
      current.month,
      current.day,
      hour,
      minute,
      0,
    );

    // One-time alarm
    if (repeatDays.isEmpty) {
      if (todayTrigger.isAfter(current)) {
        return todayTrigger;
      } else {
        // Trigger tomorrow
        return todayTrigger.add(const Duration(days: 1));
      }
    }

    // Repeating alarm: find the closest scheduled day in the future
    for (int daysAhead = 0; daysAhead <= 7; daysAhead++) {
      final candidate = todayTrigger.add(Duration(days: daysAhead));
      final candidateWeekday = candidate.weekday; // 1 = Monday, 7 = Sunday
      if (repeatDays.contains(candidateWeekday)) {
        if (candidate.isAfter(current)) {
          return candidate;
        }
      }
    }

    // Fallback: 7 days later
    return todayTrigger.add(const Duration(days: 7));
  }

  /// Calculates DateTime for snooze trigger
  DateTime calculateSnoozeDateTime({DateTime? from}) {
    final base = from ?? DateTime.now();
    return base.add(Duration(minutes: snoozeDurationMinutes));
  }

  /// 12-hour formatted time digits (e.g. "5:15" or "7:00")
  String get formattedTime {
    final dt = DateTime(2026, 1, 1, hour, minute);
    return DateFormat('h:mm').format(dt);
  }

  /// AM or PM in lowercase (e.g. "am", "pm") matching the design
  String get period {
    return hour >= 12 ? 'pm' : 'am';
  }

  /// Summary of repeat days
  String get repeatDaysSummary {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.length == 5 &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4) &&
        repeatDays.contains(5)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(6) &&
        repeatDays.contains(7)) {
      return 'Weekends';
    }

    const dayNames = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final sorted = List<int>.from(repeatDays)..sort();
    return sorted.map((d) => dayNames[d]!).join(', ');
  }

  AlarmModel copyWith({
    int? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    String? audioPath,
    String? audioTitle,
    double? volume,
    bool? gradualVolume,
    bool? vibrate,
    int? snoozeDurationMinutes,
    bool? sunriseAlarm,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      audioPath: audioPath ?? this.audioPath,
      audioTitle: audioTitle ?? this.audioTitle,
      volume: volume ?? this.volume,
      gradualVolume: gradualVolume ?? this.gradualVolume,
      vibrate: vibrate ?? this.vibrate,
      snoozeDurationMinutes:
          snoozeDurationMinutes ?? this.snoozeDurationMinutes,
      sunriseAlarm: sunriseAlarm ?? this.sunriseAlarm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
      'audioPath': audioPath,
      'audioTitle': audioTitle,
      'volume': volume,
      'gradualVolume': gradualVolume,
      'vibrate': vibrate,
      'snoozeDurationMinutes': snoozeDurationMinutes,
      'sunriseAlarm': sunriseAlarm,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: (json['label'] as String?) ?? 'Alarm',
      isEnabled: (json['isEnabled'] as bool?) ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      audioPath: (json['audioPath'] as String?) ??
          AudioConstants.defaultSound.assetPath,
      audioTitle: (json['audioTitle'] as String?) ??
          AudioConstants.defaultSound.title,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      gradualVolume: (json['gradualVolume'] as bool?) ?? false,
      vibrate: (json['vibrate'] as bool?) ?? true,
      snoozeDurationMinutes:
          (json['snoozeDurationMinutes'] as num?)?.toInt() ?? 10,
      sunriseAlarm: (json['sunriseAlarm'] as bool?) ?? false,
    );
  }
}

