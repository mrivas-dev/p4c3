# Information architecture — P4CE-8 (Athlete Profile & Settings)

**Epic:** [P4CE-7 — Athlete Profile & Settings](https://p4ce.atlassian.net/browse/P4CE-7)  
**Design story:** [P4CE-8 — Design Athlete Profile & Settings — wireframes & data model](https://p4ce.atlassian.net/browse/P4CE-8)

**Wireframes:** [`P4CE-8-athlete-profile-wireframe.html`](P4CE-8-athlete-profile-wireframe.html)  
**Full spec:** [`../specs/athlete-profile-settings-spec.md`](../specs/athlete-profile-settings-spec.md)

---

## Entry points

| Flow | Presentation | Trigger |
|------|----------------|---------|
| First launch onboarding | Large bottom sheet (3 steps), blocks Dashboard until completed or skipped via Step 3 | App launch when `onboardingCompleted == false` |
| Settings | `NavigationStack` **push** from Dashboard | Toolbar button `gearshape.fill` (top-trailing) |
| Per-lift 1RM edit | **Sheet** (modal presentation) | Tap any row under **1-Rep maxes** on Settings |

Settings is **not** a root tab in MVP (aligned with P4CE-4 / [`IA-P4CE-4.md`](IA-P4CE-4.md)).

---

## Navigation graph (text)

```
Dashboard (MainTabView)
  └─ Toolbar: gearshape.fill
       └─ NavigationStack push → SettingsView (root)
            ├─ Inline rows → pickers / text (Athlete section)
            ├─ 1RM row tap
            │    └─ .sheet → OneRMEditSheetView (per CoreLift)
            └─ Reset 1RMs → confirmation alert → cascade delete lift max values
```

Onboarding is orthogonal: presented as a full-width sheet overlay on first launch before the user can interact with the tab bar.

---

## SwiftData model — engineering sign-off

Status: **Approved for implementation** (2026-05-13). Canonical schema lives in [`../specs/athlete-profile-settings-spec.md`](../specs/athlete-profile-settings-spec.md) §4.

| Decision | Choice |
|----------|--------|
| Storage unit for weights | **Kilograms only** in persistence |
| Unit preference | `UnitSystem` enum; affects **display** and increment labels (2.5 kg vs 5 lb), not stored lift values |
| Cardinality | **Single** `AthleteProfile` instance; query `.first` at runtime |
| Lift rows | `LiftMax` records keyed by `CoreLift`; use cascade delete from profile |
| Timestamps | `createdAt` / `updatedAt` on profile; `updatedAt` on each `LiftMax` |
| Onboarding flag | `onboardingCompleted: Bool` on `AthleteProfile` |

**Implementation note:** `@Model` classes should live under `P4CE/Core/Models/` per spec §6; replace placeholder `SeedModel` when the implementation story lands.

---

## Jira acceptance checklist (P4CE-8)

- [x] Wireframe covers all 3 onboarding steps with correct field inventory  
- [x] Wireframe covers Settings (Athlete + 1RM + Preferences placeholder + destructive zone)  
- [x] 1RM Edit Sheet wireframe (stepper, text input, SAVE)  
- [x] Navigation flow documented (toolbar → push; 1RM → sheet)  
- [x] SwiftData schema reviewed and signed off (this file, § above)  
- [x] Wireframes saved under `_design/wireframes/`  
- [x] `DESIGN.md` Screen Inventory updated to reference P4CE-8 wireframes  
