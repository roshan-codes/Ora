# Ora Alarm Application - World Clock Test Specifications

This document defines the formal QA test cases for the World Clock module, including timezone math, location search, relative delta calculations, and persistence.

---

### WCK-001: Default City Population
- **ID**: `WCK-001`
- **Category**: World Clock
- **Steps**:
  1. Clear app storage and launch app fresh.
  2. Navigate to World Clock tab.
- **Expected Result**: Default cities (Tokyo, Mumbai, Los Angeles) are displayed with accurate relative time offsets.

---

### WCK-002: Search & Add City
- **ID**: `WCK-002`
- **Category**: World Clock
- **Steps**:
  1. Tap `+` button on World Clock screen.
  2. Search for "London" or "Paris".
  3. Tap city to add.
- **Expected Result**: Selected city is appended to the locations list and persisted in local storage.

---

### WCK-003: Timezone Math & AM/PM Format
- **ID**: `WCK-003`
- **Category**: World Clock
- **Steps**:
  1. Inspect hero clock and city cards.
- **Expected Result**: 12-hour formatted time with correct `am` / `pm` period string.

---

### WCK-004: Relative Offset Calculation
- **ID**: `WCK-004`
- **Category**: World Clock
- **Steps**:
  1. Verify offset badge (e.g. `+3h`, `-5h`, `+9h 30m`, or `Same time`).
- **Expected Result**: Accurate delta compared to device's current timezone.

---

### WCK-005: Live Minute Ticking
- **ID**: `WCK-005`
- **Category**: World Clock
- **Steps**:
  1. Keep screen open across a minute boundary (e.g. 10:59 to 11:00).
- **Expected Result**: Hero clock and list items advance automatically without manual pull-to-refresh.

---

### WCK-006: Delete City
- **ID**: `WCK-006`
- **Category**: World Clock
- **Steps**:
  1. Long-press or tap remove on a city card.
  2. Confirm removal.
- **Expected Result**: City is removed from UI and storage.

---

### WCK-007: Persistence Across Restart
- **ID**: `WCK-007`
- **Category**: World Clock
- **Steps**:
  1. Add custom cities.
  2. Force quit and restart the application.
- **Expected Result**: All added cities and their ordering are retained.

---

### WCK-008: Daylight Saving Time (DST) Transitions
- **ID**: `WCK-008`
- **Category**: World Clock
- **Steps**:
  1. Verify London during British Summer Time (BST, UTC+1) vs Greenwich Mean Time (GMT, UTC+0).
- **Expected Result**: `package:timezone` with IANA database resolves DST offset correctly based on the target timestamp.

