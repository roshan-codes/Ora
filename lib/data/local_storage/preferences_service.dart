import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._();
  PreferencesService._();

  static const String _keyAlarms = 'ora_alarms_list';
  static const String _keyCities = 'ora_world_clock_cities';
  static const String _keyBedtime = 'ora_bedtime_settings';
  static const String _keySleepTimer = 'ora_sleep_timer_settings';
  static const String _keyNextAlarmId = 'ora_next_alarm_id';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('PreferencesService must be initialized before access');
    }
    return _prefs!;
  }

  // --- Alarms ---
  Future<List<Map<String, dynamic>>> getAlarmsRaw() async {
    await init();
    final jsonStr = prefs.getString(_keyAlarms);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAlarmsRaw(List<Map<String, dynamic>> rawList) async {
    await init();
    final jsonStr = jsonEncode(rawList);
    await prefs.setString(_keyAlarms, jsonStr);
  }

  Future<int> getNextAlarmId() async {
    await init();
    final currentId = prefs.getInt(_keyNextAlarmId) ?? 100;
    final nextId = currentId + 1;
    await prefs.setInt(_keyNextAlarmId, nextId);
    return nextId;
  }

  // --- World Clock Cities ---
  Future<List<Map<String, dynamic>>> getCitiesRaw() async {
    await init();
    final jsonStr = prefs.getString(_keyCities);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCitiesRaw(List<Map<String, dynamic>> rawList) async {
    await init();
    final jsonStr = jsonEncode(rawList);
    await prefs.setString(_keyCities, jsonStr);
  }

  // --- Bedtime ---
  Future<Map<String, dynamic>?> getBedtimeRaw() async {
    await init();
    final jsonStr = prefs.getString(_keyBedtime);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBedtimeRaw(Map<String, dynamic> raw) async {
    await init();
    await prefs.setString(_keyBedtime, jsonEncode(raw));
  }

  // --- Sleep Timer ---
  Future<Map<String, dynamic>?> getSleepTimerRaw() async {
    await init();
    final jsonStr = prefs.getString(_keySleepTimer);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSleepTimerRaw(Map<String, dynamic> raw) async {
    await init();
    await prefs.setString(_keySleepTimer, jsonEncode(raw));
  }
}

