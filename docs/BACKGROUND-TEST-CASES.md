# Ora Alarm Application - Background & Lifecycle Test Specifications

This document defines QA test procedures for verifying alarm execution under real-world operating system constraints: backgrounding, device sleep/Doze mode, swipe-to-kill termination, and device reboot.

---

### BCK-001: Alarm Triggering While App Is in Foreground
- **ID**: `BCK-001`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 1 minute in future.
  2. Keep app open on World Clock or Alarms screen.
  3. Wait for scheduled trigger time.
- **Expected Result**: Ringing overlay transitions seamlessly into view with audio, vibration, and large hero clock.

---

### BCK-002: Alarm Triggering While App Is in Background
- **ID**: `BCK-002`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 2 minutes in future.
  2. Press Home / swipe up to return to home screen. Open another app (e.g. Browser or Messages).
  3. Wait for scheduled trigger time.
- **Expected Result**: Audible sound begins playing in background. Heads-up alarm notification appears with Stop and Snooze actions. Tapping notification opens Alarm Ringing screen.

---

### BCK-003: Alarm Triggering With Screen Locked
- **ID**: `BCK-003`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 2 minutes in future.
  2. Lock device screen immediately.
  3. Wait for scheduled trigger time.
- **Expected Result**:
  - Screen turns on automatically (`turnScreenOn="true"`).
  - Ringing interface is displayed on top of the lock screen (`showWhenLocked="true"`).
  - Audio loops continuously until Stop or Snooze is tapped.

---

### BCK-004: Alarm After Swiping App Away From Recent Apps (Terminated State)
- **ID**: `BCK-004`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 2 minutes in future.
  2. Open App Switcher / Multitasking tray.
  3. Swipe Ora up to kill/terminate the app process completely.
  4. Wait for scheduled trigger time.
- **Expected Result**: Native OS AlarmManager / UNUserNotificationCenter fires the scheduled event. Sound rings and high-priority notification launches app directly into the ringing interface.

---

### BCK-005: Alarm Recovery After Device Reboot
- **ID**: `BCK-005`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 10 minutes in future.
  2. Power off or restart the device.
  3. Turn device back on and do NOT open the app manually.
  4. Wait for scheduled trigger time.
- **Expected Result**:
  - Android: `RECEIVE_BOOT_COMPLETED` receiver runs and restores scheduled alarms.
  - Alarm rings on time.

---

### BCK-006: Android Doze Mode / Deep Sleep
- **ID**: `BCK-006`
- **Category**: Background & System
- **Steps**:
  1. Schedule alarm for 15 minutes in future.
  2. Disconnect device from power and leave untouched on a flat table for 15 minutes (or simulate Doze via ADB: `adb shell dumpsys deviceidle force-idle`).
- **Expected Result**: Exact alarm wakes up the CPU from Doze mode (`setAlarmClock` / exact alarm API) and sounds immediately.

---

### BCK-007: Daylight Saving Time (DST) Fall-Back and Spring-Forward
- **ID**: `BCK-007`
- **Category**: Background & System
- **Steps**:
  1. Set alarm across a DST boundary (e.g. 1:30 AM on transition Sunday).
- **Expected Result**: The alarm fires at the wall-clock time according to the local timezone rules without 1-hour shifts.

---

### BCK-008: Audio Focus Interruption & Resume
- **ID**: `BCK-008`
- **Category**: Background & System
- **Steps**:
  1. Start playing a podcast or video.
  2. Wait for alarm to ring.
- **Expected Result**: Media audio pauses or ducks. Alarm sound dominates. Upon tapping Stop, media resumes or remains paused according to standard OS audio policy.

