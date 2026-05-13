# Information architecture — P4CE-4 (Dashboard & tab bar)

**Source of truth for MVP bottom navigation:** [P4CE-4](https://p4ce.atlassian.net/jira/software/projects/P4CE/boards/1?selectedIssue=P4CE-4) acceptance criteria.

## Decision: four tabs (MVP)

Jira defines the tab bar as **Dashboard, Workout, Strength, Analytics**. The repo adopts this for MVP.

## Mapping from prototype filenames

The interactive reference [`screens/Home Dashboard.jsx`](../screens/Home%20Dashboard.jsx) used labels **Home / Log / Program / Analytics**. Line up with P4CE-4 as follows:

| P4CE-4 (Jira) | Prototype (JSX) | Product intent |
|-----------------|-----------------|----------------|
| **Dashboard** | Home | Today-first home; entry screen |
| **Workout** | Log | Start/resume logging; active session flows |
| **Strength** | Program | Mesocycle / weekly structure; lift assignments |
| **Analytics** | Analytics | Trends, volume, PR history |

Icons for SwiftUI (see [DESIGN.md](../DESIGN.md) iconography): `house.fill`, `bolt.fill` (or `figure.strengthtraining.traditional` for workout context—prefer `bolt.fill` for quick “go train”), `figure.strengthtraining.traditional` or `calendar.badge.clock` for Strength/program, `chart.line.uptrend.xyaxis` for Analytics.

## Five-tab design doc (superseded for MVP tab bar)

[`DESIGN.md`](../DESIGN.md) previously listed **Dashboard, Today, Program, Analytics, Settings** as peer tabs. **Settings is not a root tab in P4CE-4 MVP.** Settings / profile are reached from **Dashboard** via navigation bar affordance (e.g. `gearshape` toolbar) or a secondary row—exact control TBD at implementation time.

## Post-MVP (not in P4CE-4 wireframe scope)

- Dedicated **Readiness** top-level entry (may stay in Dashboard card or Settings until a future epic).
- Readiness ring and **recent PRs strip** on Dashboard: documented in DESIGN.md as **phase 2** enhancements unless added by a later story.
