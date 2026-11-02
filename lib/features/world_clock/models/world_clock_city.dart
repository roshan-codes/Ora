import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class WorldClockCity {
  final String id;
  final String cityName;
  final String countryName;
  final String timezoneId;

  const WorldClockCity({
    required this.id,
    required this.cityName,
    required this.countryName,
    required this.timezoneId,
  });

  /// Get current TZDateTime for this city
  tz.TZDateTime get localTime {
    try {
      final location = tz.getLocation(timezoneId);
      return tz.TZDateTime.now(location);
    } catch (_) {
      return tz.TZDateTime.from(DateTime.now(), tz.local);
    }
  }

  /// 12-hour formatted time (e.g. "5:05" or "2:15")
  String get formattedTime {
    return DateFormat('h:mm').format(localTime);
  }

  /// Lowercase am/pm period
  String get period {
    return DateFormat('a').format(localTime).toLowerCase();
  }

  /// Formatted date (e.g. "Tue, 29 Apr")
  String get formattedDate {
    return DateFormat('EEE, d MMM').format(localTime);
  }

  /// Relative offset compared to the local device time
  String get relativeOffsetString {
    final nowLocal = DateTime.now();
    final nowCity = localTime;
    final diffMinutes = nowCity.timeZoneOffset.inMinutes - nowLocal.timeZoneOffset.inMinutes;

    if (diffMinutes == 0) return 'Same time';

    final sign = diffMinutes > 0 ? '+' : '-';
    final absMinutes = diffMinutes.abs();
    final hours = absMinutes ~/ 60;
    final remainingMinutes = absMinutes % 60;

    if (remainingMinutes == 0) {
      return '$sign${hours}h';
    } else {
      return '$sign${hours}h ${remainingMinutes}m';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'countryName': countryName,
      'timezoneId': timezoneId,
    };
  }

  factory WorldClockCity.fromJson(Map<String, dynamic> json) {
    return WorldClockCity(
      id: json['id'] as String,
      cityName: json['cityName'] as String,
      countryName: json['countryName'] as String,
      timezoneId: json['timezoneId'] as String,
    );
  }
}

