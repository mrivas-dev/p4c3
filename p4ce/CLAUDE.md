# Claude.md

## Project
iOS-first training app for CrossFit and hybrid athletes.

Focus:
- adaptive strength progression
- Olympic lifting
- fatigue management
- ultra-fast workout logging
- offline-first experience

Core lifts:
- Snatch
- Clean & Jerk
- Back Squat
- Front Squat
- Deadlift
- Bench Press

---

# Tech Stack

- SwiftUI
- SwiftData
- Swift Charts
- MVVM architecture
- XCTest + Swift Testing

No backend initially.
Local persistence only.

---

# Product Principles

- Fast over flashy
- Minimal UI
- One-handed interaction
- Dark mode first
- Zero spreadsheet feeling
- Minimal typing
- Instant interactions

Users are tired during training.
Every tap matters.

---

# UX Rules

- Large touch targets
- Minimize navigation depth
- Prefer bottom sheets over full-screen flows
- Avoid modal spam
- Logging a set should take <3 seconds
- Never block UI with loaders unless absolutely necessary

---

# Architecture

Feature-based structure:

Features/
- Dashboard
- Workout
- Strength
- Readiness
- Analytics
- Settings

Core/
- Models
- Services
- Persistence
- Algorithms
- UI

---

# Coding Rules

- Prefer simple SwiftUI over abstraction
- Avoid premature optimization
- Keep business logic outside Views
- Use pure functions for training algorithms
- Avoid massive ViewModels
- Keep files small and focused

---

# Training Engine

The programming engine is the core product value.

Must support:
- percentage-based progression
- fatigue adjustments
- deload logic
- RPE tracking
- progression blocks

Never hardcode training logic inside UI components.

---

# Persistence

Use SwiftData.

Requirements:
- autosave workouts
- offline-first
- preserve unfinished sessions
- no network dependency

---

# Analytics

Track:
- estimated 1RM
- volume
- PRs
- consistency
- fatigue trends

Use Swift Charts.

---

# Testing Priorities

Critical:
- progression calculations
- fatigue scoring
- percentage math
- deload triggers
- workout generation

UI tests are secondary to algorithm correctness.

---

# Design Inspiration

Apps:
- Strong
- Hevy
- Train Heroic
- Athlytic

Desired feeling:
“minimal training notebook for serious athletes”

---

# Xcode / Simulator

Primary simulator for local builds and Previews alignment: **iPhone 17 Pro** (logical **402 × 874** pt; see `_design/tokens/tokens.json` → `screens.phone`).

Example:

```bash
cd p4ce/p4ce && xcodegen generate && xcodebuild -scheme P4CE \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
```

Use the exact simulator name/OS from Xcode’s Devices list (`xcrun simctl list devices`) if `-destination` does not resolve.

URL for jira project: https://p4ce.atlassian.net/jira/software/projects/P4CE/boards/1