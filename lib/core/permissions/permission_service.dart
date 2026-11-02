import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._();
  PermissionService._();

  /// Request essential permissions for reliable alarm triggering
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    if (kIsWeb) return results;

    // 1. Notification Permission (Android 13+ and iOS)
    final notifStatus = await Permission.notification.request();
    results['notification'] = notifStatus.isGranted;

    // 2. Android-specific permissions
    if (Platform.isAndroid) {
      // Schedule Exact Alarm (Android 12+)
      try {
        final exactStatus = await Permission.scheduleExactAlarm.status;
        if (!exactStatus.isGranted) {
          final reqResult = await Permission.scheduleExactAlarm.request();
          results['schedule_exact_alarm'] = reqResult.isGranted;
        } else {
          results['schedule_exact_alarm'] = true;
        }
      } catch (e) {
        debugPrint('Schedule exact alarm check error: $e');
      }

      // Ignore Battery Optimizations (helps prevent OEM background kills)
      try {
        final batteryOptStatus = await Permission.ignoreBatteryOptimizations.status;
        if (!batteryOptStatus.isGranted) {
          // Do not forcefully prompt on startup, but record status
          results['ignore_battery_optimizations'] = false;
        } else {
          results['ignore_battery_optimizations'] = true;
        }
      } catch (e) {
        debugPrint('Battery optimization check error: $e');
      }
    }

    return results;
  }

  /// Check whether exact alarm permission is granted on Android
  Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (_) {
      return true;
    }
  }

  /// Request exact alarm permission (opens system settings on Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final res = await Permission.scheduleExactAlarm.request();
      return res.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Request battery optimization disable to safeguard alarms from Doze kills
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final res = await Permission.ignoreBatteryOptimizations.request();
      return res.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> hasNotificationPermission() async {
    if (kIsWeb) return false;
    return await Permission.notification.isGranted;
  }
}

