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

> Colors use the **OKLCH** color space — perceptually uniform, great for dark UIs.
> Source of truth: extracted from `screens/Home Dashboard.jsx` (T token object).

### Core Tokens (from design file)

```js
const T = {
  bg:        'oklch(0.155 0.005 250)',  // main background
  bgDeep:    'oklch(0.12  0.005 250)',  // deepest bg (tab bar brutal variant)
  surf:      'oklch(0.205 0.006 250)',  // cards, surfaces
  surfHi:    'oklch(0.245 0.006 250)',  // elevated / highlighted surface
  line:      'oklch(0.27  0.005 250)',  // borders, dividers
  lineSoft:  'oklch(0.225 0.005 250)',  // subtle separators
  text:      'oklch(0.97  0.005 90)',   // primary text
  textDim:   'oklch(0.80  0.005 90)',   // secondary text
  muted:     'oklch(0.55  0.010 250)',  // metadata, labels
  dim:       'oklch(0.40  0.010 250)',  // disabled / de-emphasized
  lime:      'oklch(0.86  0.20 124)',   // accent — CTA, PRs, highlights
  limeDeep:  'oklch(0.70  0.18 124)',   // pressed/active accent
  limeInk:   'oklch(0.18  0.05 124)',   // text ON lime buttons
  red:       'oklch(0.70  0.18 25)',    // danger / pain flags
  amber:     'oklch(0.82  0.16 78)',    // warning / medium readiness
  green:     'oklch(0.78  0.16 145)',   // success / high readiness
}
```

### Semantic Usage

| Token       | Usage                                              |
|-------------|----------------------------------------------------|
| `bg`        | Main app background                                |
| `bgDeep`    | Deepest layer (nav bar background)                 |
| `surf`      | Cards, hero cards, stat tiles, session rows        |
| `surfHi`    | Date badges, nested elevated elements              |
| `line`      | Borders, grid lines, inactive readiness bars       |
| `lineSoft`  | Subtle dividers, section separators                |
| `text`      | Primary labels, headings, values                   |
| `textDim`   | Secondary labels, supporting info                  |
| `muted`     | Metadata captions, monospace tags (VOLUME, STREAK) |
| `dim`       | Inactive tab icons, separators                     |
| `lime`      | **Primary accent** — CTAs, PR values, active tags  |
| `limeDeep`  | Pressed state of lime buttons                      |
| `limeInk`   | Text/icons that sit ON lime background             |
| `red`       | Fatigue danger, pain flags, low readiness          |
| `amber`     | Medium readiness (5–6/10)                          |
| `green`     | High readiness labels ("PRIMED")                   |

### SwiftUI OKLCH Note

SwiftUI does not natively support OKLCH syntax yet. Use `Color(hue:saturation:brightness:)` or convert to sRGB hex for `Assets.xcassets`. Approximate hex equivalents:

| Token      | Approx Hex  |
|------------|-------------|
| `bg`       | `#121418`   |
| `surf`     | `#1C2026`   |
| `surfHi`   | `#252B33`   |
| `line`     | `#363D47`   |
| `lineSoft` | `#272E38`   |
| `text`     | `#F7F7F0`   |
| `textDim`  | `#C4C4B8`   |
| `muted`    | `#6B7280`   |
| `dim`      | `#3F4550`   |
| `lime`     | `#D4F53C`   |
| `limeDeep` | `#9EBF1A`   |
| `limeInk`  | `#1A2605`   |
| `red`      | `#E05A3A`   |
| `amber`    | `#F0C040`   |
| `green`    | `#5DBF78`   |

---

## Typography

Three font families — extracted from design file:

```js
const fontSans    = '"Geist", -apple-system, system-ui, sans-serif';
const fontDisplay = '"Antonio", "Geist", system-ui, sans-serif';
const fontMono    = '"JetBrains Mono", ui-monospace, monospace';
```

| Role          | Font          | Usage                                                  |
|---------------|---------------|--------------------------------------------------------|
| `fontDisplay` | **Antonio**   | Hero workout names, large numbers, CTA labels, stats   |
| `fontSans`    | **Geist**     | Body text, secondary labels, greeting, session names   |
| `fontMono`    | **JetBrains Mono** | ALL metadata tags (VOLUME, STREAK, LAST · MON), dates, PRE labels, letter-spaced caps |

### iOS Implementation Note

Antonio and Geist are not system fonts — register them as custom fonts in the Xcode project (`Info.plist` → `UIAppFonts`). For monospace numerics, `JetBrains Mono` can be replaced with `.monospacedDigit()` modifier on SF Pro where custom font loading is impractical.

### Key Sizing Patterns (from design)

| Element                     | Font          | Size  | Weight | Letter Spacing |
|-----------------------------|---------------|-------|--------|----------------|
| Workout name hero           | Antonio       | 68–76pt | 700  | -1.4 to -1.6   |
| Sub-label (21–15–9)         | Antonio       | 18–22pt | 500  | +0.4           |
| Stats large number          | Antonio       | 24–30pt | 600–700 | -0.5         |
| CTA button label            | Antonio       | 26–30pt | 700  | +1.5           |
| Section date / greeting     | Geist         | 14–22pt | 500–600 | -0.3          |
| Session name                | Geist         | 13–16pt | 500  | 0              |
| Metadata caps (VOLUME etc.) | JetBrains Mono | 9–11pt | 500–600 | +1.3 to +1.6 |
| Tag labels (TODAY, METCON)  | JetBrains Mono | 10pt  | 500  | +1.6           |

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

**MVP layout (P4CE-4):** Reference wireframe [`wireframes/P4CE-4-dashboard-wireframe.html`](wireframes/P4CE-4-dashboard-wireframe.html) and IA [`wireframes/IA-P4CE-4.md`](wireframes/IA-P4CE-4.md). **SwiftUI shell:** `DashboardView` + `MainTabView` in the app target (story P4CE-6).

- Today's planned workout card (main session identity, prescription, scannable in seconds)
- Key metrics snapshot: **last session** + **weekly volume**
- Quick-start CTA (full width, thumb zone — see wireframe)
- Settings / profile: **not** a root tab in MVP; use toolbar or header affordance on Dashboard (e.g. `gearshape`)

**Phase 2 (out of P4CE-4 wireframe scope unless a later story pulls them in):**
- Readiness score ring on home
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

**MVP (P4CE-4 / Jira):** four bottom tabs. Prototype [`screens/Home Dashboard.jsx`](screens/Home%20Dashboard.jsx) used *Home / Log / Program / Analytics*; repo naming aligns with Jira as below (details: [`wireframes/IA-P4CE-4.md`](wireframes/IA-P4CE-4.md)).

```
TabBar (bottom)
├── Dashboard   — SF Symbol: house.fill
├── Workout     — bolt.fill (session / logging entry; maps to JSX "Log")
├── Strength    — figure.strengthtraining.traditional or calendar.badge.clock (maps to JSX "Program")
└── Analytics   — chart.line.uptrend.xyaxis
```

- Tab bar background: `bg.secondary` with `border.subtle` top stroke
- Active icon tint: `accent.primary`
- Inactive icon tint: `text.tertiary`
- Labels optional: short text under icons is acceptable for MVP clarity (wireframe shows labels)
- **Settings** is not a tab in MVP; access from Dashboard navigation affordance

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

---

## Simulator reference

**Default Xcode destination** for layout checks: **iPhone 17 Pro**. `_design/tokens/tokens.json` → `screens.phone` matches **402 × 874** pt logical (same class as iPhone 17 Pro in current Xcode simulator runtimes).
