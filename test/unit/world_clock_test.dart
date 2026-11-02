import 'package:flutter_test/flutter_test.dart';
import 'package:ora/features/world_clock/models/world_clock_city.dart';
import 'package:timezone/data/latest.dart' as tz_data;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('WorldClockCity Unit Tests', () {
    test('WCK-001: JSON serialization and deserialization', () {
      const city = WorldClockCity(
        id: 'tokyo-jp',
        cityName: 'Tokyo',
        countryName: 'Japan',
        timezoneId: 'Asia/Tokyo',
      );

      final json = city.toJson();
      final restored = WorldClockCity.fromJson(json);

      expect(restored.id, 'tokyo-jp');
      expect(restored.cityName, 'Tokyo');
      expect(restored.countryName, 'Japan');
      expect(restored.timezoneId, 'Asia/Tokyo');
    });

    test('WCK-002: Formatted time and period strings produce valid outputs', () {
      const city = WorldClockCity(
        id: 'london-gb',
        cityName: 'London',
        countryName: 'United Kingdom',
        timezoneId: 'Europe/London',
      );

      expect(city.formattedTime, isNotEmpty);
      expect(city.period, anyOf('am', 'pm'));
      expect(city.formattedDate, isNotEmpty);
    });

    test('WCK-003: Relative offset calculation returns formatted difference', () {
      const tokyo = WorldClockCity(
        id: 'tokyo',
        cityName: 'Tokyo',
        countryName: 'Japan',
        timezoneId: 'Asia/Tokyo',
      );

      final offset = tokyo.relativeOffsetString;
      expect(offset, isNotEmpty);
      // Offset should either be 'Same time' or start with '+' or '-'
      expect(offset, anyOf('Same time', startsWith('+'), startsWith('-')));
    });

    test('WCK-004: Fallback for unknown timezone does not crash', () {
      const invalidCity = WorldClockCity(
        id: 'mars-city',
        cityName: 'Mars Base',
        countryName: 'Space',
        timezoneId: 'Invalid/NonExistent_Zone',
      );

      // Should fall back gracefully to local time
      expect(() => invalidCity.localTime, returnsNormally);
      expect(invalidCity.formattedTime, isNotEmpty);
    });
  });
}

