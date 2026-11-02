class BedtimeModel {
  final int bedtimeHour; // e.g. 23 (11 PM)
  final int bedtimeMinute;
  final int wakeHour; // e.g. 7 (7 AM)
  final int wakeMinute;
  final bool isEnabled;
  final List<int> repeatDays; // 1 = Mon .. 7 = Sun

  const BedtimeModel({
    this.bedtimeHour = 23,
    this.bedtimeMinute = 0,
    this.wakeHour = 7,
    this.wakeMinute = 0,
    this.isEnabled = true,
    this.repeatDays = const [1, 2, 3, 4, 5],
  });

  /// Total sleep duration between bedtime and wake time
  Duration get sleepDuration {
    var diffMinutes = (wakeHour * 60 + wakeMinute) - (bedtimeHour * 60 + bedtimeMinute);
    if (diffMinutes <= 0) {
      diffMinutes += 24 * 60;
    }
    return Duration(minutes: diffMinutes);
  }

  String get formattedSleepDuration {
    final d = sleepDuration;
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    if (mins == 0) {
      return '$hours hrs';
    }
    return '$hours hrs $mins mins';
  }

  /// Calculates duration remaining until next scheduled bedtime
  String get remainingUntilBedtime {
    final now = DateTime.now();
    final todayBedtime = DateTime(now.year, now.month, now.day, bedtimeHour, bedtimeMinute);
    var target = todayBedtime;
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final diff = target.difference(now);
    final hours = diff.inHours;
    final mins = diff.inMinutes.remainder(60);
    return 'in ${hours}h ${mins}m';
  }

  String formatTime(int h, int m) {
    final displayHour = h % 12 == 0 ? 12 : h % 12;
    final period = h >= 12 ? 'pm' : 'am';
    return '$displayHour:${m.toString().padLeft(2, '0')}$period';
  }

  String get formattedBedtime => formatTime(bedtimeHour, bedtimeMinute);
  String get formattedWakeTime => formatTime(wakeHour, wakeMinute);

  BedtimeModel copyWith({
    int? bedtimeHour,
    int? bedtimeMinute,
    int? wakeHour,
    int? wakeMinute,
    bool? isEnabled,
    List<int>? repeatDays,
  }) {
    return BedtimeModel(
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      wakeHour: wakeHour ?? this.wakeHour,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedtimeHour': bedtimeHour,
      'bedtimeMinute': bedtimeMinute,
      'wakeHour': wakeHour,
      'wakeMinute': wakeMinute,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays,
    };
  }

  factory BedtimeModel.fromJson(Map<String, dynamic> json) {
    return BedtimeModel(
      bedtimeHour: (json['bedtimeHour'] as num?)?.toInt() ?? 23,
      bedtimeMinute: (json['bedtimeMinute'] as num?)?.toInt() ?? 0,
      wakeHour: (json['wakeHour'] as num?)?.toInt() ?? 7,
      wakeMinute: (json['wakeMinute'] as num?)?.toInt() ?? 0,
      isEnabled: (json['isEnabled'] as bool?) ?? true,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5],
    );
  }
}

