# P4CE — Design Specification

> Reference document for Cursor and AI-assisted development.
> All SwiftUI code should derive colors, spacing, and typography from these tokens.

---

## Design Philosophy

- **Dark mode first** — optimized for dark gym environments
- **Speed over decoration** — no animations that delay action
- **Athletic minimalism** — feels like a premium training notebook, not a fitness social app
- **One-handed** — all primary interactions reachable with the right thumb
- **Zero spreadsheet feeling** — data is shown when relevant, hidden when not

---

## Color Palette

### Backgrounds

| Token              | Hex       | Usage                                   |
|--------------------|-----------|-----------------------------------------|
| `bg.primary`       | `#0A0A0A` | Main app background                     |
| `bg.secondary`     | `#141414` | Cards, bottom sheets, elevated surfaces |
| `bg.tertiary`      | `#1E1E1E` | Input fields, secondary cards           |
| `bg.overlay`       | `#000000CC` | Modal overlays (80% opacity)           |

### Text

| Token              | Hex       | Usage                                   |
|--------------------|-----------|-----------------------------------------|
| `text.primary`     | `#F5F5F5` | Headings, primary labels                |
| `text.secondary`   | `#A0A0A0` | Subtitles, supporting info              |
| `text.tertiary`    | `#606060` | Disabled states, placeholders           |
| `text.inverse`     | `#0A0A0A` | Text on accent buttons                  |

### Accent

| Token              | Hex       | Usage                                   |
|--------------------|-----------|-----------------------------------------|
| `accent.primary`   | `#E8FF47` | CTAs, progress indicators, highlights  |
| `accent.secondary` | `#C8E000` | Pressed/active state of accent          |
| `accent.muted`     | `#E8FF4726` | Accent tint (15% opacity)             |

### Semantic

| Token              | Hex       | Usage                                   |
|--------------------|-----------|-----------------------------------------|
| `semantic.success` | `#4ADE80` | PR badges, completed sets               |
| `semantic.warning` | `#FACC15` | High fatigue warnings                   |
| `semantic.danger`  | `#F87171` | Pain/discomfort flags, missed sessions  |
| `semantic.info`    | `#60A5FA` | Informational tags, RPE neutral         |

### Borders & Separators

| Token              | Hex       | Usage                                   |
|--------------------|-----------|-----------------------------------------|
| `border.subtle`    | `#FFFFFF10` | Card borders, dividers                 |
| `border.default`   | `#FFFFFF20` | Input fields, active separators        |
| `border.focus`     | `#E8FF4766` | Focused input ring                     |

---

## Typography

Font: **SF Pro** (system default on iOS)

| Token              | Size  | Weight       | Line Height | Usage                         |
|--------------------|-------|--------------|-------------|-------------------------------|
| `type.display`     | 34pt  | Bold (700)   | 41pt        | Hero numbers (1RM, load)      |
| `type.title1`      | 28pt  | Bold (700)   | 34pt        | Screen titles                 |
| `type.title2`      | 22pt  | Semibold (600) | 28pt      | Section headers               |
| `type.title3`      | 20pt  | Semibold (600) | 25pt      | Card titles                   |
| `type.headline`    | 17pt  | Semibold (600) | 22pt      | List row primary labels       |
| `type.body`        | 17pt  | Regular (400)  | 22pt      | Body copy                     |
| `type.callout`     | 16pt  | Regular (400)  | 21pt      | Supporting body               |
| `type.subheadline` | 15pt  | Regular (400)  | 20pt      | Metadata, secondary info      |
| `type.footnote`    | 13pt  | Regular (400)  | 18pt      | Labels, captions              |
| `type.caption`     | 12pt  | Regular (400)  | 16pt      | Micro labels, badges          |
| `type.mono`        | 17pt  | Regular (400)  | 22pt      | Weights, percentages (tabular)|

> Use `type.mono` for all numeric workout data (weights, reps, percentages) to prevent layout jitter as values change.

---

## Spacing Scale

Based on an 4pt base unit.

| Token       | Value | Usage                                       |
|-------------|-------|---------------------------------------------|
| `space.1`   | 4pt   | Micro gaps, icon padding                    |
| `space.2`   | 8pt   | Tight element spacing                       |
| `space.3`   | 12pt  | Default inner padding                       |
| `space.4`   | 16pt  | Standard card padding, list row height pad  |
| `space.5`   | 20pt  | Section spacing                             |
| `space.6`   | 24pt  | Component separation                        |
| `space.8`   | 32pt  | Major section breaks                        |
| `space.10`  | 40pt  | Bottom sheet top padding                    |
| `space.12`  | 48pt  | Screen horizontal insets                    |
| `space.16`  | 64pt  | Large vertical breathing room               |

---

## Corner Radius

| Token          | Value | Usage                                  |
|----------------|-------|----------------------------------------|
| `radius.sm`    | 8pt   | Tags, badges, small chips              |
| `radius.md`    | 12pt  | Input fields, small cards              |
| `radius.lg`    | 16pt  | Main cards, list rows                  |
| `radius.xl`    | 20pt  | Bottom sheets, modal surfaces          |
| `radius.full`  | 999pt | Pills, circular buttons                |

---

## Touch Targets

Per Apple HIG and app product principles:

- Minimum touch target: **44×44pt**
- Preferred for primary actions: **52×52pt** or full-width
- Log Set button: **full width**, **56pt height**
- All icons in navigation and toolbars: min 44pt tap area

---

## Elevation / Shadows

The app uses **background layering** instead of drop shadows.

| Level | Background Token   | Context                     |
|-------|--------------------|-----------------------------|
| 0     | `bg.primary`       | App background               |
| 1     | `bg.secondary`     | Cards, list rows             |
| 2     | `bg.tertiary`      | Nested inputs, inner cards   |
| 3     | `bg.overlay`       | Sheets, dialogs              |

Avoid hard drop shadows — use `border.subtle` strokes for separation.

---

## Component Patterns

### Set Row
- Background: `bg.secondary`
- Corner radius: `radius.lg`
- Padding: `space.4` horizontal, `space.3` vertical
- Set number: `type.footnote`, `text.tertiary`
- Weight: `type.headline` + `type.mono`, `text.primary`
- Reps: `type.headline` + `type.mono`, `text.primary`
- RPE badge: `type.caption`, `accent.muted` bg, `accent.primary` text
- Completed state: `semantic.success` checkmark, row opacity 0.6

### Log Set Button (primary CTA)
- Background: `accent.primary`
- Label color: `text.inverse`
- Height: 56pt
- Corner radius: `radius.lg`
- Typography: `type.headline`
- Pressed state: `accent.secondary` background, scale 0.97

### Readiness Card
- Background: `bg.secondary`
- Score display: `type.display`, colored by score range
  - 80–100: `semantic.success`
  - 60–79: `semantic.warning`
  - 0–59: `semantic.danger`
- Border: `border.subtle`

### Section Header
- Typography: `type.subheadline`, `text.secondary`
- All caps, letter spacing +0.5
- No decorative lines

### Bottom Sheet
- Background: `bg.secondary`
- Top drag handle: 4×36pt pill, `border.default`
- Corner radius top: `radius.xl`
- Side padding: `space.6`

### Navigation Bar
- Background: `bg.primary` (transparent blur)
- Title: `type.title3`, `text.primary`
- Back/close: SF Symbol, `text.secondary`

---

## Screen Inventory

### 1. Dashboard (Home)
**Purpose:** "What do I do today?"
- Today's workout card (main lift, sets, load)
- Readiness score ring
- Quick-log CTA
- Recent PRs strip

### 2. Active Session
**Purpose:** Ultra-fast logging during training
- Current exercise header
- Set list with inline input
- "Log Set" primary button (always visible, bottom)
- RPE selector (bottom sheet, appears after logging)
- Rest timer (minimal overlay)

### 3. Program View
**Purpose:** See the current mesocycle structure
- Week/phase selector
- Day-by-day overview
- Lift assignments per day

### 4. Lift Detail / Analytics
**Purpose:** Track progression on a single lift
- 1RM trend chart (Swift Charts, line)
- Volume chart (bar)
- PR history list
- Recent sessions

### 5. Readiness Check-in
**Purpose:** Daily morning quick survey
- 5 sliders: Sleep / Soreness / Stress / Motivation / Fatigue
- Score result
- Adapted recommendation for today

### 6. Settings / Profile
**Purpose:** Configure 1RMs, training frequency, preferences
- Athlete profile
- 1RM input per lift
- Program configuration

---

## Navigation Structure

```
TabBar (bottom)
├── Dashboard       — House icon
├── Today           — Lightning bolt icon  (active session)
├── Program         — Calendar icon
├── Analytics       — Chart icon
└── Settings        — Gear icon
```

- Tab bar background: `bg.secondary` with `border.subtle` top stroke
- Active icon tint: `accent.primary`
- Inactive icon tint: `text.tertiary`
- No labels (icons only for clean look, or icons + short labels)

---

## Motion & Animation

- Prefer **instant** state changes for workout logging (no delay)
- Use `easeOut` at 0.2s max for UI transitions
- Bottom sheet: spring animation, `response: 0.35`, `dampingFraction: 0.85`
- Avoid skeleton loaders — all data is local, so loading should be imperceptible
- PR flash: brief `semantic.success` background pulse on the row (0.4s)

---

## Iconography

Use **SF Symbols** exclusively.

Key symbols:
- Barbell / Weight: `dumbbell.fill`
- Strength: `figure.strengthtraining.traditional`
- Readiness: `heart.text.square.fill`
- Analytics: `chart.line.uptrend.xyaxis`
- Program: `calendar.badge.clock`
- Settings: `gearshape.fill`
- Rest timer: `timer`
- Log/check: `checkmark.circle.fill`
- RPE: `gauge.medium`
- Add set: `plus.circle.fill`
- PR: `trophy.fill`

---

## Accessibility

- Minimum contrast ratio: 4.5:1 for body text
- Support Dynamic Type where it doesn't break layout (callout and below)
- All interactive elements have `.accessibilityLabel`
- VoiceOver ordering follows visual hierarchy

---

## SwiftUI Implementation Notes

```swift
// Color usage example
Text("Back Squat")
    .foregroundStyle(Color("text.primary"))
    .font(.headline)
    .fontDesign(.default)

// Monospaced numbers
Text("142.5 kg")
    .font(.headline.monospacedDigit())

// Card background
RoundedRectangle(cornerRadius: 16)
    .fill(Color("bg.secondary"))
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
    )

// Primary CTA button
Button("Log Set") { ... }
    .frame(maxWidth: .infinity)
    .frame(height: 56)
    .background(Color("accent.primary"))
    .foregroundStyle(Color("text.inverse"))
    .clipShape(RoundedRectangle(cornerRadius: 16))
```

> Define all color tokens in `Assets.xcassets` with dark/light variants (dark is the primary, light is optional).
