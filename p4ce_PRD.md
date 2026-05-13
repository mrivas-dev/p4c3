# Product Requirements Document (PRD)

## Hybrid Strength Training App for CrossFit Athletes

---

# 1. Product Summary

## Product Name

Working title: **P4CE**
(placeholder — branding subject to iteration)

## Product Type

Mobile-first iOS application.

## Product Category

Fitness / Strength Training / CrossFit Programming.

## Primary Goal

Help CrossFit and hybrid athletes improve strength and Olympic lifting performance through adaptive programming, fatigue-aware progression, and ultra-fast workout logging.

---

# 2. Problem Statement

CrossFit and hybrid athletes typically manage strength progression using:

* spreadsheets
* notebooks
* fragmented apps
* generic workout trackers

These tools fail to account for:

* accumulated conditioning fatigue
* Olympic lift complexity
* fluctuating readiness
* concurrent training stress

Most existing fitness apps are:

* bodybuilding-focused
* overly complex
* slow to use during training
* not optimized for hybrid athletes

Athletes need a tool that:

* adapts training intensity dynamically
* simplifies progression management
* works instantly during workouts
* minimizes cognitive overhead

---

# 3. Product Vision

Create the simplest and most effective strength progression system for hybrid athletes.

The app should feel:

* fast
* minimal
* training-focused
* effortless during workouts

The product should behave like:

> “a smart training notebook with adaptive programming built in.”

---

# 4. Goals & Success Metrics

## Business Goals

* Build a highly retainable training tool
* Validate demand for hybrid athlete programming software
* Establish a scalable foundation for future coaching/sync features

---

## User Goals

Users should be able to:

* improve strength consistently
* manage fatigue effectively
* log workouts rapidly
* understand training trends
* follow structured programming without spreadsheets

---

## Success Metrics

### Engagement

* Daily Active Users (DAU)
* Weekly workout completion rate
* Average workouts logged per week

### Retention

* 30-day retention
* 90-day retention
* Training cycle completion rate

### Product Usage

* Average session duration
* Percentage of users logging RPE
* Readiness score completion rate

### Performance Outcomes

* PR frequency
* Estimated 1RM progression
* Program adherence rate

---

# 5. Target Audience

## Primary Audience

Intermediate to advanced:

* CrossFit athletes
* Hybrid athletes
* Functional fitness competitors

---

## User Characteristics

Users:

* train 4–6 days/week
* perform both strength and conditioning
* care about structured progression
* value simplicity and speed
* often train under fatigue

---

# 6. User Personas

---

## Persona 1 — Competitive CrossFit Athlete

### Goals

* Increase Olympic lift numbers
* Maintain conditioning performance
* Avoid overtraining

### Frustrations

* Spreadsheet management
* Inconsistent progression
* Poor fatigue management

---

## Persona 2 — Hybrid Strength Athlete

### Goals

* Balance endurance + strength
* Improve core lifts systematically
* Track performance trends

### Frustrations

* Generic workout apps
* Lack of adaptive progression
* Slow logging interfaces

---

# 7. Core Features

---

# 7.1 Adaptive Strength Programming

## Description

Automatically generate structured 4–5 day strength cycles.

## Requirements

* User enters 1RMs
* App generates progression percentages
* Program adjusts based on readiness/fatigue
* Support deload weeks
* Support progression blocks

## Supported Lifts

* Snatch
* Clean & Jerk
* Back Squat
* Front Squat
* Deadlift
* Bench Press

---

# 7.2 Workout Logging

## Description

Fast set-by-set workout tracking.

## Requirements

Users can log:

* weight
* reps
* RPE
* notes
* completion status

## UX Requirements

* one-handed interaction
* minimal typing
* large touch targets
* fast save behavior
* offline persistence

---

# 7.3 Readiness & Fatigue Scoring

## Description

Daily readiness questionnaire that influences training recommendations.

## Inputs

* sleep quality
* soreness
* perceived fatigue
* motivation
* prior session intensity

## Outputs

* readiness score
* training recommendations
* intensity adjustments

---

# 7.4 Progress Analytics

## Description

Provide performance visibility over time.

## Metrics

* estimated 1RM trends
* volume trends
* consistency streaks
* PR history
* fatigue correlation
* progression velocity

---

# 7.5 Offline-First Architecture

## Description

App must work fully offline.

## Requirements

* no authentication
* instant startup
* local persistence
* no dependency on network connectivity

---

# 8. Functional Requirements

---

## Authentication

### V1

* No authentication

### Future

* Optional account sync

---

## User Profile

### Users can:

* set bodyweight
* configure units
* set training days
* input/edit 1RMs

---

## Workout Engine

### System must:

* generate cycles
* calculate percentages
* track progression
* estimate fatigue
* recommend deloads

---

## Logging Engine

### System must:

* autosave workouts
* support offline logging
* preserve unfinished sessions

---

## Analytics Engine

### System must:

* calculate estimated 1RMs
* aggregate volume
* track trends over time

---

# 9. Non-Functional Requirements

---

## Performance

* App launch under 2 seconds
* Logging interaction under 100ms perceived latency
* Offline reliability

---

## Usability

* Minimal interaction friction
* Dark mode optimized
* Accessible touch targets

---

## Reliability

* No data loss during logging
* Autosave critical actions

---

## Scalability

Architecture should support future:

* sync
* cloud backup
* coaching systems
* social features

---

# 10. UX Principles

---

## Fast Logging

The user is often:

* tired
* sweaty
* distracted

Logging must require minimal interaction.

---

## Minimal Cognitive Load

The app handles:

* percentages
* progression calculations
* readiness adjustments

Users focus on training.

---

## Athlete-Focused Design

The interface should feel:

* clean
* dark
* high contrast
* performance-oriented

Avoid:

* social feed aesthetics
* excessive animations
* cluttered dashboards

---

# 11. Technical Requirements

---

## Platform

iOS only.

---

## Frameworks

### Frontend

* SwiftUI

### Persistence

* SwiftData

### Charts

* Swift Charts

### Testing

* XCTest
* Swift Testing

---

## Architecture

* MVVM
* Feature modularization
* Offline-first

---

# 12. Data Models

---

## UserProfile

Fields:

* bodyweight
* units
* training days
* recovery preferences

---

## Lift

Fields:

* movement type
* 1RM
* training max
* progression state

---

## Workout

Fields:

* date
* exercises
* readiness score
* completion state

---

## WorkoutSet

Fields:

* reps
* weight
* RPE
* completion status

---

## ReadinessEntry

Fields:

* sleep
* soreness
* fatigue
* motivation
* readiness score

---

# 13. MVP Scope

---

## Included in V1

* workout generation
* local persistence
* fatigue scoring
* workout logging
* progression tracking
* analytics dashboard

---

## Excluded from V1

* social features
* cloud sync
* coaching marketplace
* AI coaching
* wearable integrations
* video analysis

---

# 14. Future Roadmap

---

## Phase 2

* iCloud sync
* Apple Watch support
* Live Activities
* Widgets

---

## Phase 3

* Coach dashboards
* Shared programming
* Team systems
* Remote coaching

---

## Phase 4

* AI-assisted progression
* Auto fatigue adaptation
* Recovery prediction
* Wearable integrations

---

# 15. Risks

---

## Product Risks

* progression quality insufficient
* fatigue scoring inaccurate
* onboarding complexity

---

## Technical Risks

* data migration challenges
* local persistence scaling
* analytics performance with large histories

---

# 16. Key Product Differentiators

Unlike generic workout trackers, this app:

* understands CrossFit fatigue
* supports Olympic lifting progression
* adapts programming dynamically
* prioritizes speed during training
* minimizes logging friction

Core positioning:

> “Adaptive strength progression for hybrid athletes.”
