# Ora Alarm Application - Alarm Test Specifications

This document defines the formal QA test cases for the core Alarm functionality, covering creation, scheduling, editing, deletion, recurring behavior, snooze durations, and ringing state transitions.

---

### ALM-001: Create Single Immediate Test Alarm (1 Minute)
- **ID**: `ALM-001`
- **Category**: Alarm Core
- **Preconditions**: Notifications permission granted. App is running.
- **Steps**:
  1. Open Developer QA Testing Dashboard (`Settings → Developer Tools → QA Testing`).
  2. Locate test case `ALM-001` or tap `Run Test`.
  3. Verify an alarm is scheduled for exactly current time + 1 minute.
- **Expected Result**: OS alarm scheduled successfully. Banner confirms trigger time in 60 seconds.
- **Automated/Manual**: Both. Automated test in QA Engine and Manual on device.

---

### ALM-002: Create Test Alarm (2 Minutes)
- **ID**: `ALM-002`
- **Category**: Alarm Core
- **Preconditions**: Exact alarm permissions enabled.
- **Steps**:
  1. Run `ALM-002` from QA Testing Dashboard.
  2. Background app or turn off screen.
  3. Wait 2 minutes.
- **Expected Result**: Alarm triggers on time (within ±1s precision) with audio and vibration.

---

### ALM-003: Create Test Alarm (5 Minutes)
- **ID**: `ALM-003`
- **Category**: Alarm Core
- **Steps**:
  1. Trigger 5-minute test alarm.
  2. Lock device screen.
  3. Verify wakeup at exact +5 minute mark.
- **Expected Result**: Device turns screen on / displays ringing full-screen interface.

---

### ALM-004: Recurring Alarm - Next Occurrence Calculation
- **ID**: `ALM-004`
- **Category**: Alarm Core
- **Steps**:
  1. Set alarm for 7:00 AM on weekdays (Mon-Fri).
  2. If today is Saturday, verify scheduled date is Monday 7:00 AM.
  3. If today is Wednesday 6:00 AM, verify scheduled date is today 7:00 AM.
- **Expected Result**: Trigger date strictly matches nearest future active day.

---

### ALM-005: Snooze Trigger Precision
- **ID**: `ALM-005`
- **Category**: Alarm Core
- **Steps**:
  1. When an alarm rings, tap `Snooze (10m)`.
  2. Inspect Debug Console `Alarm.getAlarms()`.
- **Expected Result**: Current audio stops immediately. New OS alarm scheduled for `now + 10 minutes`.

---

### ALM-006: Edit Alarm Time & Label
- **ID**: `ALM-006`
- **Category**: Alarm Core
- **Steps**:
  1. Open existing alarm card.
  2. Change time from 7:00 AM to 8:30 AM. Change label to "Standup Call".
  3. Tap `Save`.
- **Expected Result**: Previous alarm cancelled in OS. New alarm scheduled for 8:30 AM. Updated card reflects new time and label.

---

### ALM-007: Disable and Re-enable Alarm
- **ID**: `ALM-007`
- **Category**: Alarm Core
- **Steps**:
  1. Toggle switch to OFF.
  2. Check Debug Console: Alarm ID removed from OS active list.
  3. Toggle switch to ON.
  4. Check Debug Console: Alarm re-scheduled with updated future trigger.
- **Expected Result**: Seamless cancellation and restoration without data loss.

---

### ALM-008: Delete Alarm
- **ID**: `ALM-008`
- **Category**: Alarm Core
- **Steps**:
  1. Tap existing alarm to edit.
  2. Tap `Delete Alarm`.
  3. Confirm removal.
- **Expected Result**: Alarm deleted from UI and local storage. Cancelled from OS alarm queue.

---

### ALM-009: Sound & Ringtone Selection
- **ID**: `ALM-009`
- **Category**: Alarm Core
- **Steps**:
  1. In Add/Edit Alarm screen, preview available sounds (Classic Alarm, Gentle Chime, Digital Pulse, Sunrise Bell).
  2. Select "Gentle Chime" and save.
  3. Trigger test ring.
- **Expected Result**: Ringing screen plays "Gentle Chime" audio file in a loop.

---

### ALM-010: Volume Level & Gradual Ramp
- **ID**: `ALM-010`
- **Category**: Alarm Core
- **Steps**:
  1. Set volume slider to 40%. Enable "Gradual volume increase".
  2. Trigger alarm.
- **Expected Result**: Audio starts softly and ramps up over 15 seconds to 40% target volume.

---

### ALM-011: Stop Alarm Immediate Dismissal
- **ID**: `ALM-011`
- **Category**: Alarm Ringing
- **Steps**:
  1. Alarm rings.
  2. Tap `Stop Alarm`.
- **Expected Result**: Audio and vibration terminate instantly. Overlay closes. Next recurring alarm is scheduled.

---

### ALM-012: Multiple Snooze Attempts
- **ID**: `ALM-012`
- **Category**: Alarm Ringing
- **Steps**:
  1. Snooze alarm 3 consecutive times (+5m each).
- **Expected Result**: Every snooze cancels previous sound and queues next alarm cleanly without duplicate audio instances.

---

### ALM-013: Audio Focus & Interruption Handling
- **ID**: `ALM-013`
- **Category**: Alarm Ringing
- **Steps**:
  1. Play background music or trigger incoming phone call while alarm is ringing.
- **Expected Result**: Alarm audio session ducks or pauses other media. Phone call audio takes priority; alarm notification remains visible.

---

### ALM-014: High Density Alarms (Close Intervals)
- **ID**: `ALM-014`
- **Category**: Alarm Core
- **Steps**:
  1. Schedule Alarm A for 7:00 AM and Alarm B for 7:01 AM.
  2. Dismiss Alarm A at 7:00:30 AM.
- **Expected Result**: Alarm B fires on time at 7:01 AM without conflict or stale state.

