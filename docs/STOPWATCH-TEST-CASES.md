# Ora Alarm Application - Stopwatch Test Specifications

This document defines QA test cases for the precision Stopwatch module, wavy dial animation, background timing accuracy, and lap splits.

---

### STW-001: Initial Idle State
- **ID**: `STW-001`
- **Category**: Stopwatch
- **Steps**:
  1. Navigate to StopWatch tab.
- **Expected Result**: Displays `00:00`, dial completion at 0.0, empty lap list, and Play button visible.

---

### STW-002: Start Stopwatch
- **ID**: `STW-002`
- **Category**: Stopwatch
- **Steps**:
  1. Tap Play.
- **Expected Result**: Time begins incrementing with smooth 30ms ticker. Wavy dial progress bar animates.

---

### STW-003: Pause Stopwatch
- **ID**: `STW-003`
- **Category**: Stopwatch
- **Steps**:
  1. Tap Pause after 10 seconds.
- **Expected Result**: Time freezes. Dial pauses. Play button returns.

---

### STW-004: Resume Stopwatch
- **ID**: `STW-004`
- **Category**: Stopwatch
- **Steps**:
  1. Tap Play while paused.
- **Expected Result**: Continues accumulating time from the paused duration without jumping or resetting.

---

### STW-005: Reset Stopwatch
- **ID**: `STW-005`
- **Category**: Stopwatch
- **Steps**:
  1. Pause stopwatch and tap Reset.
- **Expected Result**: Elapsed time resets to `00:00`. Laps list cleared. Dial returns to origin.

---

### STW-006: Lap Recording & Delta Calculations
- **ID**: `STW-006`
- **Category**: Stopwatch
- **Steps**:
  1. Start stopwatch.
  2. Tap Lap at 5s, 12s, and 20s.
- **Expected Result**:
  - Lap 1: 5.00s (Delta: null).
  - Lap 2: 7.00s (Delta: +2.00s vs Lap 1).
  - Lap 3: 8.00s (Delta: +3.00s vs Lap 1).
  - Latest lap is prepended to the top of the list.

---

### STW-007: Background Timestamp Accuracy
- **ID**: `STW-007`
- **Category**: Stopwatch
- **Steps**:
  1. Start stopwatch.
  2. Background app for 60 seconds.
  3. Reopen app.
- **Expected Result**: Elapsed time uses `DateTime.now().difference(_startedAt)` and shows exactly 60s elapsed without timer drift.

---

### STW-008: App Termination Behavior
- **ID**: `STW-008`
- **Category**: Stopwatch
- **Steps**:
  1. Start stopwatch. Terminate application.
- **Expected Result**: App handles cold start cleanly without crash.

---

### STW-009: Dial Wave Gauge Ratio
- **ID**: `STW-009`
- **Category**: Stopwatch
- **Steps**:
  1. Let stopwatch run past 60 seconds.
- **Expected Result**: Dial progress wraps smoothly `(ms % 60000) / 60000.0` completing 1 full cycle per minute.

