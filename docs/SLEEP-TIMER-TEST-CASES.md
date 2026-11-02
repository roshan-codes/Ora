# Ora Alarm Application - Sleep Timer Test Specifications

This document defines QA test cases for the Sleep Timer module, wake-up schedule coordination, countdown steppers, and sunrise alarm controls.

---

### SLP-001: Countdown Stepper Adjustment
- **ID**: `SLP-001`
- **Category**: Sleep Timer
- **Steps**:
  1. Open Sleep Timer screen.
  2. Tap `+` and `-` steppers.
- **Expected Result**: Target time shifts in 15-minute increments (e.g. 7:00 AM → 7:15 AM → 7:30 AM).

---

### SLP-002: Weekday Multi-Selection Chips
- **ID**: `SLP-002`
- **Category**: Sleep Timer
- **Steps**:
  1. Toggle weekday chips (S, M, T, W, T, F, S).
- **Expected Result**: Selected days highlight in active coral background. Deselected days return to white.

---

### SLP-003: Sunrise Alarm Toggle
- **ID**: `SLP-003`
- **Category**: Sleep Timer
- **Steps**:
  1. Toggle "Sunrise alarm: Slowly brighten screen before alarm".
- **Expected Result**: Setting is persisted in alarm configuration.

---

### SLP-004: Vibration Mode Toggle
- **ID**: `SLP-004`
- **Category**: Sleep Timer
- **Steps**:
  1. Toggle "Vibrate".
- **Expected Result**: Toggles vibration pattern in OS alarm settings.

---

### SLP-005: Save and Sync with Alarm Engine
- **ID**: `SLP-005`
- **Category**: Sleep Timer
- **Steps**:
  1. Configure 7:00 AM wake-up schedule.
  2. Tap `Next`.
- **Expected Result**: Schedules or updates the wake-up alarm in the central Alarm system with all selected flags.

---

### SLP-006: Sleep Timer Background Countdown
- **ID**: `SLP-006`
- **Category**: Sleep Timer
- **Steps**:
  1. Start a 15-minute timer countdown.
  2. Switch to another app.
- **Expected Result**: Target completion timestamp is preserved.

---

### SLP-007: Skip Flow
- **ID**: `SLP-007`
- **Category**: Sleep Timer
- **Steps**:
  1. Tap `Skip` button on Sleep Timer screen.
- **Expected Result**: Navigates forward without scheduling or modifying active alarms.

