# PRD — Hybrid Strength + CrossFit Tracking App

# Product Name
P4CE

---

# 1. Product Vision

A mobile-first training companion for CrossFit and hybrid athletes who want structured strength progression without sacrificing flexibility from daily WOD programming.

The app combines:
- periodized strength programming
- Olympic lifting tracking
- fatigue management
- CrossFit integration
- recovery awareness
- lightweight analytics

The goal is:
> Help athletes become stronger, more technically efficient, and more consistent while surviving CrossFit volume sustainably.

---

# 2. Target User

## Primary User
Intermediate to advanced CrossFit athletes training:
- 4–6x/week
- already tracking lifts manually
- struggling with fatigue management
- wanting structured progression

## Secondary User
Hybrid athletes:
- CrossFit + powerlifting
- CrossFit + bodybuilding
- garage gym athletes
- amateur competitors

---

# 3. Core Problem

Most CrossFit athletes:
- improvise strength work
- overtrain unintentionally
- lack progression structure
- cannot periodize around WOD fatigue
- use spreadsheets that become chaotic

Current apps are usually:
- pure bodybuilding
- pure powerlifting
- pure CrossFit logging

Very few bridge:
- Olympic lifting
- fatigue management
- autoregulation
- CrossFit coexistence

---

# 4. Product Goals

## User Goals
- Improve major lifts
- Track progression clearly
- Avoid burnout
- Auto-calculate percentages
- Adapt training around fatigue
- Build sustainable consistency

## Business Goals
- High retention through daily usage
- Subscription model
- Expand into coaching templates
- Potential coach-athlete platform

---

# 5. MVP Scope

## Core Features

### Athlete Profile
Users can configure:
- Age
- Weight
- Training frequency
- Experience level
- 1RMs for:
  - Snatch
  - Clean & Jerk
  - Back Squat
  - Front Squat
  - Deadlift
  - Bench Press

---

### Program Generator
The app generates:
- 4-day strength structure
- optional 5th day
- monthly mesocycles

Includes:
- accumulation
- intensification
- peak
- deload

Automatically calculates:
- sets
- reps
- percentages
- estimated loads

---

### Daily Session Screen

#### Pre-WOD
Displays:
- main lift
- warmup
- working sets
- percentages
- target RPE

#### Post-WOD
Displays:
- accessories
- recovery work
- mobility

---

### Workout Logging
Track:
- completed reps
- actual load
- RPE
- notes
- pain/discomfort

---

### Fatigue System
Daily readiness scoring based on:
- sleep
- soreness
- stress
- motivation
- fatigue

The app adapts:
- intensity
- volume
- recommendations

Example:
> “Reduce squat volume by 15% today.”

---

### Progress Dashboard

Graphs:
- estimated 1RM trends
- volume load
- fatigue vs performance
- consistency streaks

---

# 6. Technical Architecture

## Frontend
### Mobile App
- React Native
- Expo

Goals:
- fast iteration
- smooth UX
- offline-first logging
- scalable mobile architecture

---

## Backend

### Core Stack
- NestJS
- PostgreSQL
- Prisma ORM
- Redis (future caching/jobs)
- JWT Authentication

### Why NestJS
The application will eventually require:
- progression engines
- autoregulation systems
- fatigue adaptation logic
- analytics processing
- coach-athlete workflows
- AI-assisted recommendations

NestJS provides:
- modular architecture
- TypeScript-first development
- scalable domain separation
- enterprise-grade maintainability

---

## Infrastructure

### Recommended Hosting
- Railway / Render / Fly.io for early-stage backend hosting
- Neon or managed PostgreSQL
- Cloudflare for CDN and edge protection

---

## Core Backend Modules

### Auth Module
- JWT auth
- refresh tokens
- social login support (future)

### Users Module
- athlete profile
- settings
- goals

### Programs Module
- mesocycles
- weekly progression
- deload logic

### Workouts Module
- workout sessions
- exercise logging
- set tracking

### Readiness Module
- fatigue scoring
- adaptive recommendations

### Analytics Module
- progression tracking
- estimated 1RM calculations
- training load analysis

---

# 7. Database Design

## Main Entities

### User
- id
- email
- username
- training_frequency
- experience_level

### LiftProfile
- user_id
- lift_type
- one_rep_max

### Program
- user_id
- phase
- week
- intensity
- volume

### WorkoutSession
- user_id
- date
- readiness_score
- duration

### ExerciseLog
- session_id
- exercise
- weight
- reps
- RPE

### RecoveryMetrics
- sleep_score
- soreness_score
- fatigue_score

---

# 8. UX Principles

## Fast Logging
The user is usually exhausted after training.

The app must:
- minimize taps
- support one-handed use
- prioritize speed

---

## Minimal Cognitive Load
Avoid:
- spreadsheet feeling
- excessive charts
- unnecessary complexity

The app should feel:
- focused
- athletic
- premium
- calm

---

## Training-First UX
Every screen should answer:
> “What do I do next?”

---

# 9. Future Features

## Apple Watch Integration
Track:
- heart rate
- workout duration
- recovery indicators

---

## AI Recommendations
Future adaptive coaching:
- volume adjustments
- recovery suggestions
- progression recommendations

---

## Video Analysis
Olympic lift analysis:
- bar path
- pull timing
- receiving positions

---

## Coach Platform
Coaches can:
- assign programs
- review athlete data
- comment on workouts

---

# 10. Monetization

## Free Tier
- basic tracking
- workout logging
- manual programs

## Premium Tier
- auto periodization
- analytics
- adaptive fatigue system
- advanced progression
- coach tools

---

# 11. Success Metrics

## Engagement
- workouts logged/week
- weekly active users

## Retention
- 30-day retention
- mesocycle completion rate

## Performance
- average lift increase over 12 weeks

---

# 12. Biggest Product Risk

The app becoming:
- too complex
- too scientific
- too spreadsheet-heavy

The experience should remain:
- fast
- clear
- adaptable
- athlete-centered
