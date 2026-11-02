# Ora Alarm Application - Bedtime Test Specifications

This document defines QA test cases for the Bedtime & Sleep Schedule module, overnight sleep duration calculations, and reminder persistence.

---

### BDT-001: Overnight Sleep Duration Spanning Midnight
- **ID**: `BDT-001`
- **Category**: Bedtime
- **Steps**:
  1. Set Bedtime to 11:00 PM (23:00) and Wake time to 7:00 AM (07:00).
- **Expected Result**: Calculated sleep duration equals exactly 8 hours (`8 hrs`).

---

### BDT-002: Same-Day Sleep Duration
- **ID**: `BDT-002`
- **Category**: Bedtime
- **Steps**:
  1. Set Bedtime to 1:00 AM (01:00) and Wake time to 9:30 AM (09:30).
- **Expected Result**: Calculated sleep duration equals 8 hours and 30 minutes (`8 hrs 30 mins`).

---

### BDT-003: Time remaining until Bedtime Countdown
- **ID**: `BDT-003`
- **Category**: Bedtime
- **Steps**:
  1. View Bedtime hero card.
- **Expected Result**: Displays human-readable countdown (e.g. `in 5h 20m`).

---

### BDT-004: Bedtime Schedule Toggle
- **ID**: `BDT-004`
- **Category**: Bedtime
- **Steps**:
  1. Toggle schedule enabled/disabled switch.
- **Expected Result**: Disabling silences bedtime reminders and cancels scheduled bedtime alarms.

---

### BDT-005: Repeat Day Selection
- **ID**: `BDT-005`
- **Category**: Bedtime
- **Steps**:
  1. Select Mon, Tue, Wed, Thu, Fri.
- **Expected Result**: Schedule applies only to selected days.

---

### BDT-006: Bedtime Time Picker
- **ID**: `BDT-006`
- **Category**: Bedtime
- **Steps**:
  1. Tap Bedtime card to open time picker.
  2. Select 10:30 PM. Tap Confirm.
- **Expected Result**: UI and sleep duration re-render immediately.

---

### BDT-007: Persistence Across Application Relaunch
- **ID**: `BDT-007`
- **Category**: Bedtime
- **Steps**:
  1. Set custom bedtime schedule.
  2. Force quit and restart app.
- **Expected Result**: All bedtime settings, days, and times are restored from `SharedPreferences`.

