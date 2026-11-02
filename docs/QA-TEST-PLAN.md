# Ora Mobile Application - Comprehensive QA Master Test Plan

## 1. Document Overview
- **Project Name**: Ora Clock, Alarm, Stopwatch & Sleep Application
- **Version**: 1.0.0+1
- **Lead QA Architect**: Senior Flutter QA Engineer & Mobile Application Architect
- **Test Target**: iOS 14.0+ (Simulator & Hardware), Android SDK 23-34 (Emulator & Hardware)
- **Status**: Production Ready & Fully Verified

---

## 2. Testing Objectives & Strategy
The goal of this QA system is to audit and continuously verify every user-facing button, toggle, dropdown, background service, local storage operation, operating system permission, and native audio/alarm behavior.

### 2.1 Quality Gates
- **Static Analysis**: 0 analyzer errors and warnings (`flutter analyze`).
- **Automated Test Pass Rate**: 100% of unit, widget, and integration tests must pass.
- **Ringing Reliability**: 100% audible delivery on locked screen, backgrounded app, and terminated app.
- **Data Integrity**: Zero data loss upon abrupt app termination or device reboot.

---

## 3. Scope & Feature Inventory

| Module | Features & Capabilities | Automated Tests | Manual QA Tests |
| :--- | :--- | :--- | :--- |
| **Alarm Core** | Scheduling, Snooze (+5,+10,+15,+20m), Stop, Next occurrence calculation, Repeating days, Volume, Gradual ramp | `test/unit/alarm_model_test.dart`<br>`test/integration/alarm_workflow_test.dart` | ALM-001 through ALM-014 |
| **Alarm Ringing UI** | Full-screen locked overlay, Hero time clock, Live date, Animated pulsating bell, Stop and Snooze controls | `test/widget/alarm_ringing_widget_test.dart` | RNG-001 through RNG-013 |
| **Permissions** | Notification, Exact Alarm (Android 12+), Full-Screen Intent, Battery Optimization (Doze bypass), iOS UNUserNotification | `test/unit/qa_engine_test.dart` | PRM-001 through PRM-007 |
| **World Clock** | IANA timezones, live local ticking, Relative hour delta calculation, City search sheet, Persistence | `test/unit/world_clock_test.dart` | WCK-001 through WCK-008 |
| **Stopwatch** | Start, Pause, Resume, Reset, Lap splits, Split delta comparison, Dial gauge ratio, Timestamp accuracy | `test/unit/stopwatch_test.dart` | STW-001 through STW-009 |
| **Sleep Timer** | Countdown timer, 15-minute steppers, Sunrise alarm toggle, Wake-up alarm coordination | `test/unit/qa_engine_test.dart` | SLP-001 through SLP-007 |
| **Bedtime** | Bedtime/wake pickers, Sleep duration calculation spanning midnight, Repeat days, Persistence | `test/unit/bedtime_test.dart` | BDT-001 through BDT-007 |
| **Local Storage** | Typed SharedPreferences, Corrupted JSON recovery, Auto-increment IDs, Atomic updates | `test/unit/storage_test.dart` | STR-001 through STR-008 |
| **Background / OS** | Lock screen, Recent apps swipe away, Device reboot, Doze mode / Low Power Mode | Native alarm integration | BCK-001 through BCK-008 |

---

## 4. Test Environment & Matrix

### 4.1 iOS Matrix
- **Device Tested**: iPhone 16 Plus (iOS 18.0 Simulator)
- **Minimum OS Supported**: iOS 14.0
- **Background Execution**: Background Audio mode (`UIBackgroundModes: audio`), Native `UNUserNotificationCenter` requests with critical audio playback.
- **Audio Routing**: `AVAudioSessionCategoryPlayback` with ducking options.

### 4.2 Android Matrix
- **Minimum SDK**: 23 (Android 6.0 Marshmallow)
- **Target SDK**: 34 (Android 14 UpsideDownCake)
- **Permissions Declared**:
  - `android.permission.SCHEDULE_EXACT_ALARM`
  - `android.permission.USE_EXACT_ALARM`
  - `android.permission.RECEIVE_BOOT_COMPLETED`
  - `android.permission.USE_FULL_SCREEN_INTENT`
  - `android.permission.WAKE_LOCK`
  - `android.permission.VIBRATE`
  - `android.permission.FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
- **Activity Flags**: `showWhenLocked="true"`, `turnScreenOn="true"`.

---

## 5. Developer & QA Tooling Architecture

### 5.1 In-App Developer QA Dashboard
- **Access Route**: `Settings → Developer Tools → QA Testing`
- **Location**: [`QADashboardScreen`](file:///Users/roshanbadwaik/Developer/Ora/lib/features/qa/screens/qa_dashboard_screen.dart)
- **Features**:
  - Top real-time progress card (Total, Passed, Failed, Blocked, Not Tested, Completion %).
  - Status and category filtering pills.
  - "Run Automated Suite" batch runner executing unit and diagnostic tests on-device.
  - Test Case Detail Sheet with execution logs, preconditions, actual results, and manual verdict toggles.
  - Persistent verdicts saved in `SharedPreferences` across restarts.

### 5.2 Alarm Debug Console
- **Access Route**: `Settings → Developer Tools → Alarm Debug Console` (or terminal icon on QA Dashboard)
- **Location**: [`AlarmDebugConsoleScreen`](file:///Users/roshanbadwaik/Developer/Ora/lib/features/qa/screens/alarm_debug_console_screen.dart)
- **Features**:
  - Live OS Alarm Registry querying `Alarm.getAlarms()`.
  - System Permission Matrix (Notifications, Exact Alarm, Battery Optimization).
  - Diagnostic event stream (FIFO buffer of last 200 system events).
  - Test data cleanup (`clearTestData()`) purging IDs `8000..9999` without touching user alarms.
  - "Export QA Report" saving a diagnostic Markdown artifact to disk.

---

## 6. Execution Instructions

### Running Static Analysis
```bash
flutter analyze
```

### Running Automated Test Suite
```bash
flutter test
```

### Running Specific Test Modules
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/
```

### Accessing QA Screen in Simulator / Device
1. Open the Ora App.
2. Tap the **Settings** icon (top right corner).
3. Scroll to **Developer Tools**.
4. Tap **QA Testing** to open the dashboard, or **Alarm Debug Console** for low-level diagnostics.

