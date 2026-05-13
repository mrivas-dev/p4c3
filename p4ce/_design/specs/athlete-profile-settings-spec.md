# Spec — Athlete Profile & Settings

> **Jira:** Epic **P4CE-7** (Athlete Profile & Settings) · Design story **P4CE-8** (wireframes & data model)
> Status: Draft · Author: Claude / M · Date: 2026-05-13  
> Wireframes: `_design/wireframes/P4CE-8-athlete-profile-wireframe.html` · `_design/wireframes/IA-P4CE-8.md`

---

## 1. Overview

The Athlete Profile & Settings feature is the configuration layer of the app. It answers the question:

> "Who am I, and how should the app train me?"

The profile is the prerequisite for everything else — 1RMs unlock percentage-based programming, training frequency shapes mesocycle structure, and unit preference affects every number the athlete ever sees.

**Entry point:** `gearshape.fill` toolbar icon on the Dashboard (top-right). Not a root tab.

**First-launch onboarding:** a lightweight bottom-sheet wizard that collects the minimum viable profile before the athlete sees the Dashboard for the first time.

---

## 2. User Stories

- **As an athlete**, I want to enter my current 1RMs so the app can calculate working percentages automatically.
- **As an athlete**, I want to set my training frequency so the program generator builds a realistic weekly structure.
- **As an athlete**, I want to choose kg or lb once and never think about it again.
- **As an athlete**, I want to update my 1RMs as I hit new PRs, without rebuilding my profile from scratch.

---

## 3. Screen Inventory

### 3.1 Onboarding Flow (First Launch Only)

A 3-step bottom sheet wizard presented on first app launch. Auto-dismissed after completion; never shown again (persisted via SwiftData).

The wizard is intentionally minimal — collect only what the engine needs. No profile photo, no biography, no social handles.

#### Step 1 — Identity

| Field           | Type             | Notes                                     |
|-----------------|------------------|-------------------------------------------|
| Name (optional) | Text field       | Used for greeting on Dashboard only       |
| Body weight     | Numeric stepper  | Paired with unit toggle (kg / lb)         |
| Unit preference | Segmented picker | `kg` / `lb`. Persists globally.           |

UX notes:
- Default unit: kg
- Body weight is optional but surfaced here because the athlete is already thinking in kilos

#### Step 2 — Training Context

| Field              | Type              | Options                          |
|--------------------|-------------------|----------------------------------|
| Training frequency | Segmented / wheel | 3×, 4×, 5×, 6× per week         |
| Experience level   | Segmented picker  | Beginner · Intermediate · Advanced · Elite |

UX notes:
- Frequency directly controls mesocycle day structure (Step 3 uses this to shape 1RM entry)
- Experience level adjusts deload frequency and RPE defaults in the algorithm layer
- No descriptions needed inline — the labels are self-explanatory for the target user

#### Step 3 — 1RM Setup

Scrollable list of core lifts. Each row has:
- Lift name (Antonio, 18pt)
- Current 1RM numeric input (monospacedDigit, large tap target)
- Unit label (kg/lb — inherited from Step 1)
- Skip affordance per lift (dim state, value = 0, shown as "–")

Core lifts (fixed order):
1. Back Squat
2. Front Squat
3. Deadlift
4. Bench Press
5. Snatch
6. Clean & Jerk

UX notes:
- Olympic lifts are listed last; strength athletes may not have them
- All fields are optional at onboarding — 1RMs can be filled in later from Settings
- A lift with no 1RM shows "–" on Dashboard; percentage calculations are disabled for that lift
- Keyboard: numeric pad. Decimal separator allowed (e.g. 142.5 kg).

**Completion CTA:** full-width lime button "LET'S GO" → dismisses sheet → reveals Dashboard.

---

### 3.2 Settings Screen

Accessible via `gearshape.fill` in the Dashboard toolbar. Presented as a `NavigationStack` pushed from the toolbar, not a sheet (so it can host sub-navigation).

#### Section: Athlete

| Row               | Detail                                        |
|-------------------|-----------------------------------------------|
| Name              | Inline editable text field                    |
| Body weight       | Numeric field + unit badge                    |
| Unit preference   | `kg` / `lb` toggle — changing this converts all stored values on screen (display only; storage is always in kg internally) |
| Training frequency | Tappable → picker                            |
| Experience level  | Tappable → picker                             |

#### Section: 1-Rep Maxes

One row per core lift. Tapping a row opens a focused **1RM Edit Sheet** (see §3.3).

| Row         | Right-side value       |
|-------------|------------------------|
| Back Squat  | `142.5 kg`             |
| Front Squat | `120 kg`               |
| Deadlift    | `180 kg`               |
| Bench Press | `100 kg`               |
| Snatch      | `80 kg`                |
| Clean & Jerk | `105 kg`              |

Empty state (no value entered): shows `—` in `textDim`.

#### Section: Preferences (Phase 2, placeholder only in MVP)

- Theme (locked to Dark Mode in MVP, greyed out)
- Notification reminders (future)

#### Destructive Zone

- **Reset 1RMs** — clears all 1RM values (confirm via `.destructive` alert)

---

### 3.3 1RM Edit Sheet

Bottom sheet triggered by tapping any lift row in Settings.

Content:
- Lift name header (Antonio, 24pt)
- Current 1RM large numeric display
- Stepper buttons `−` / `+` with 2.5 kg / 5 lb increments
- Direct text field input (numeric, decimal allowed)
- "SAVE" CTA (full-width lime button, 56pt)
- Cancel / dismiss via drag or `×` icon

UX notes:
- The +/− increment is intentional — athletes often update 1RMs by small jumps after a PR
- After saving, the Settings row updates instantly (SwiftData autosave)
- 1RM history is not tracked in MVP (single current value per lift); scheduled for Phase 2

---

## 4. Data Model (SwiftData)

```swift
@Model
final class AthleteProfile {
    var name: String
    var bodyWeightKg: Double?       // always stored in kg
    var unitPreference: UnitSystem  // .kg / .lb (enum)
    var trainingFrequency: Int      // 3–6 days/week
    var experienceLevel: ExperienceLevel
    var onboardingCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var liftMaxes: [LiftMax]
}

@Model
final class LiftMax {
    var lift: CoreLift              // enum: backSquat, frontSquat, deadlift, benchPress, snatch, cleanAndJerk
    var oneRepMaxKg: Double         // always stored in kg
    var updatedAt: Date
}

enum CoreLift: String, Codable, CaseIterable {
    case backSquat      = "Back Squat"
    case frontSquat     = "Front Squat"
    case deadlift       = "Deadlift"
    case benchPress     = "Bench Press"
    case snatch         = "Snatch"
    case cleanAndJerk   = "Clean & Jerk"
}

enum ExperienceLevel: String, Codable {
    case beginner, intermediate, advanced, elite
}

enum UnitSystem: String, Codable {
    case kg, lb
}
```

**Persistence rule:** only one `AthleteProfile` instance ever exists. Query with `.first`.

**Unit conversion:** display layer only. All storage is in kg. `func displayValue(for kg: Double, unit: UnitSystem) -> Double` lives in `Core/Algorithms/UnitConversion.swift`.

---

## 5. UX Rules (Feature-Specific)

| Rule | Rationale |
|------|-----------|
| All 1RM inputs use numeric keyboard, decimal allowed | Weights like 102.5 kg are common in strength training |
| Increment buttons jump 2.5 kg / 5 lb | Standard plate math increments |
| Unit conversion is display-only; storage is always kg | Prevents precision loss and makes algorithm layer unit-agnostic |
| Onboarding sheet cannot be dismissed mid-flow without completing or explicitly skipping | Prevents broken profile state on first launch |
| "Skip" on onboarding is a single tap at the bottom of Step 3 ("I'll set these later") | Respects athlete autonomy; doesn't block access |
| Settings changes apply immediately (SwiftData autosave) | No explicit "Save" button on the Settings screen itself |
| Destructive actions (Reset 1RMs) require a confirmation alert | Standard iOS pattern; accidental data loss is catastrophic for athletes mid-cycle |

---

## 6. Files & Architecture

```
Features/
└── Settings/
    ├── SettingsView.swift              # Root Settings NavigationStack
    ├── SettingsViewModel.swift         # Reads/writes AthleteProfile from SwiftData
    ├── OnboardingSheetView.swift       # 3-step first-launch wizard
    ├── OnboardingViewModel.swift
    ├── OneRMEditSheetView.swift        # Per-lift bottom sheet
    └── OneRMEditViewModel.swift

Core/
├── Models/
│   ├── AthleteProfile.swift
│   ├── LiftMax.swift
│   └── CoreLift.swift
└── Algorithms/
    └── UnitConversion.swift
```

---

## 7. Out of Scope (MVP)

- 1RM history / progression chart (Phase 2)
- Light mode (dark only for MVP per CLAUDE.md)
- Notification scheduling
- iCloud sync
- Athlete photo
- Goal tracking
- Coach view

---

## 8. Acceptance Criteria (Design Story — P4CE-8)

- [x] Onboarding flow wireframe covers all 3 steps with correct field inventory
- [x] Settings screen wireframe covers Athlete section and 1RM section with correct row structure
- [x] 1RM Edit Sheet wireframe shows stepper, text field, and CTA
- [x] Data model schema reviewed and signed off (field names, types, storage unit) — see `IA-P4CE-8.md`
- [x] Navigation flow documented (entry points, sheet vs push)
- [x] Wireframes shared in `_design/wireframes/` before implementation begins

---

## 9. References

- `_design/DESIGN.md` — color tokens, typography, component patterns
- `_design/tokens/tokens.json` — spacing and screen dimensions
- `p4ce_PRD.md` §5 — Athlete Profile feature definition
- `CLAUDE.md` — architecture, feature folder conventions
