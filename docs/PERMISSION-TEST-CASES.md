# Ora Alarm Application - System Permissions Test Specifications

This document defines QA test cases for Android and iOS system permissions, exact alarm policies, full-screen intents, notifications, and battery optimization overrides.

---

### PRM-001: Notification Permission Verification
- **ID**: `PRM-001`
- **Category**: Permissions
- **Platforms**: iOS & Android 13+
- **Steps**:
  1. Open Developer QA Testing Dashboard → Permission Tests.
  2. Inspect "Notification Permission" status.
  3. Tap "Request Permission" if not granted.
- **Expected Result**: System prompt appears. Upon user decision, QA dashboard reflects `Granted` or `Denied` truthfully (never spoofed).

---

### PRM-002: Android Exact Alarm Permission (`SCHEDULE_EXACT_ALARM`)
- **ID**: `PRM-002`
- **Category**: Permissions
- **Platforms**: Android 12+ (API 31+)
- **Steps**:
  1. On Android 12+, inspect exact alarm permission status in QA Console.
  2. If revoked, tap "Open Settings".
  3. Toggle "Allow setting alarms and reminders" in Android system settings.
  4. Return to app.
- **Expected Result**: QA dashboard updates status to `Granted`. Alarms fire with sub-second precision.

---

### PRM-003: Android Full-Screen Intent Permission
- **ID**: `PRM-003`
- **Category**: Permissions
- **Platforms**: Android 14+ (API 34+)
- **Steps**:
  1. Verify `USE_FULL_SCREEN_INTENT` manifest declaration.
  2. Trigger alarm with screen off.
- **Expected Result**: Ringing activity appears over lock screen immediately.

---

### PRM-004: Android Battery Optimization (Doze Mode Bypass)
- **ID**: `PRM-004`
- **Category**: Permissions
- **Platforms**: Android
- **Steps**:
  1. Check battery optimization status in QA Console.
  2. Tap "Request Unrestricted Battery".
- **Expected Result**: System prompt asks to whitelist app from Doze mode, ensuring alarms trigger when device is asleep.

---

### PRM-005: iOS Critical Notifications & Audio Session
- **ID**: `PRM-005`
- **Category**: Permissions
- **Platforms**: iOS
- **Steps**:
  1. Verify `UIBackgroundModes: audio` in `Info.plist`.
  2. Schedule alarm. Set iPhone to Mute (hardware silent switch) or Do Not Disturb.
- **Expected Result**: Alarm audio plays via `AVAudioSessionCategoryPlayback` even when the hardware mute switch is on.

---

### PRM-006: Revoked Permission Graceful Handling
- **ID**: `PRM-006`
- **Category**: Permissions
- **Steps**:
  1. Revoke notifications in device OS settings while app is in background.
  2. Open app.
- **Expected Result**: App detects revoked state, presents warning card in QA console and Settings, and does not crash.

---

### PRM-007: Deep Link to System App Settings
- **ID**: `PRM-007`
- **Category**: Permissions
- **Steps**:
  1. In QA Console, tap "Open App Settings".
- **Expected Result**: Native OS settings page for Ora opens directly.

