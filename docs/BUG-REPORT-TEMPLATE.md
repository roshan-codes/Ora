# Ora QA Bug Report Template

Please use this standard template when reporting any functional, visual, audio, or background execution defects found during QA testing.

---

### Bug Summary
*A clear, concise one-line description of the issue (e.g. `[Alarm Ringing] Audio fails to loop after 30 seconds when screen is locked`).*

---

### Environment Details
- **App Version**: `1.0.0 (Build 1)`
- **Device Model**: *(e.g. iPhone 16 Plus / Google Pixel 8)*
- **OS Version**: *(e.g. iOS 18.0 / Android 14)*
- **Build Mode**: *(Debug / Profile / Release)*
- **Battery Optimization Status**: *(Unrestricted / Optimized)*
- **Notification Permission**: *(Granted / Denied)*

---

### Severity & Priority
- **Severity**:
  - [ ] **Critical** (Alarm did not ring, data loss, app crash on launch)
  - [ ] **Major** (Ringing screen blocked, incorrect snooze interval)
  - [ ] **Minor** (Text clipping, typo, slight layout misalignment)
  - [ ] **Trivial** (Cosmetic styling quirk)
- **Priority**:
  - [ ] **P0** (Blocker - immediate release block)
  - [ ] **P1** (High - must fix before next sprint)
  - [ ] **P2** (Medium - standard defect backlog)
  - [ ] **P3** (Low - polish)

---

### Steps to Reproduce
1. Open the app to `[Screen Name]`.
2. Perform `[Action 1]`.
3. Perform `[Action 2]`.
4. Observe behavior.

---

### Expected Result
*What the application should have done according to specifications.*

---

### Actual Result
*What actually happened during testing.*

---

### Diagnostic Logs & Console Output
```text
// Paste relevant log lines from the Alarm Debug Console or flutter run output here
```

---

### Visual Evidence
*(Attach screenshots, screen recordings, or photos of the physical device)*

---

### Workaround (if any)
*Describe any temporary steps that mitigate the problem.*

