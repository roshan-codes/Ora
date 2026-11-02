import 'package:flutter_test/flutter_test.dart';
import 'package:ora/data/local_storage/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService Storage Tests', () {
    test('STR-001: Save and retrieve raw alarms list', () async {
      final storage = PreferencesService.instance;
      await storage.init();

      final initial = await storage.getAlarmsRaw();
      expect(initial, isEmpty);

      final dummyAlarms = [
        {'id': 101, 'hour': 7, 'minute': 30, 'label': 'Morning'},
        {'id': 102, 'hour': 22, 'minute': 0, 'label': 'Bedtime'},
      ];

      await storage.saveAlarmsRaw(dummyAlarms);
      final retrieved = await storage.getAlarmsRaw();

      expect(retrieved.length, 2);
      expect(retrieved[0]['id'], 101);
      expect(retrieved[1]['label'], 'Bedtime');
    });

    test('STR-002: Auto-incrementing alarm IDs prevent collisions', () async {
      final storage = PreferencesService.instance;
      await storage.init();

      final id1 = await storage.getNextAlarmId();
      final id2 = await storage.getNextAlarmId();
      final id3 = await storage.getNextAlarmId();

      expect(id2, id1 + 1);
      expect(id3, id2 + 1);
    });

    test('STR-003: Graceful fallback when local JSON is corrupted', () async {
      final storage = PreferencesService.instance;
      await storage.init();

      // Corrupt the raw string directly in SharedPreferences
      await storage.prefs.setString('ora_alarms_list', '{invalid_json_corrupted: true]');

      // Should handle parse failure and return an empty list without crashing
      final alarms = await storage.getAlarmsRaw();
      expect(alarms, isEmpty);
    });

    test('STR-004: City persistence and retrieval', () async {
      final storage = PreferencesService.instance;
      await storage.init();

      final cities = [
        {'id': 'tokyo', 'cityName': 'Tokyo', 'countryName': 'Japan', 'timezoneId': 'Asia/Tokyo'},
      ];

      await storage.saveCitiesRaw(cities);
      final retrieved = await storage.getCitiesRaw();

      expect(retrieved.length, 1);
      expect(retrieved.first['cityName'], 'Tokyo');
    });

    test('STR-005: Bedtime configuration persistence', () async {
      final storage = PreferencesService.instance;
      await storage.init();

      final bedtimeMap = {
        'bedtimeHour': 23,
        'bedtimeMinute': 15,
        'wakeHour': 7,
        'wakeMinute': 45,
        'isEnabled': true,
        'repeatDays': [1, 2, 3, 4, 5],
      };

      await storage.saveBedtimeRaw(bedtimeMap);
      final retrieved = await storage.getBedtimeRaw();

      expect(retrieved, isNotNull);
      expect(retrieved!['bedtimeHour'], 23);
      expect(retrieved['wakeMinute'], 45);
    });
  });
}

