# p4c3

Hybrid strength training for CrossFit and hybrid athletes — an offline-first iOS experience built for structured progression, fatigue-aware recommendations, and fast workout logging between sets.

## What this is

**p4c3** focuses on real hybrid-training constraints: accumulated fatigue, Olympic lifts, fluctuating readiness, concurrent conditioning volume, and progressive overload. Programming adapts using readiness, consistency, RPE feedback, and progression history around core lifts (snatch, clean & jerk, back squat, front squat, deadlift, bench press).

Design intent: open the app, see today’s work, log performance quickly, and stay focused on training — not spreadsheets or overloaded trackers.

## Documentation in this repo

| Document | Contents |
|----------|-----------|
| [`p4ce_Project_Description.md`](./p4ce_Project_Description.md) | Vision, audience, problems solved |
| [`p4ce/p4ce_Project_Description.md`](./p4ce/p4ce_Project_Description.md) | Extended narrative copy |
| [`p4ce_PRD.md`](./p4ce_PRD.md) | Product requirements |

**Naming:** Docs may refer to the effort as **p4ce**; the GitHub repository is **p4c3**.

## Engineering direction (PRD-aligned)

- SwiftUI presentation layer; MVVM-oriented features  
- SwiftData persistence  
- Async/await  
- Accessibility plus loading, error, and empty states  
- Abstractions that remain backend-ready  

Cursor delivery rules live under [`.cursor/rules/`](./.cursor/rules/).

## Contributing / setup

Clone with SSH:

```bash
git clone git@github.com:mrivas-dev/p4c3.git
cd p4c3
```

Add the Xcode project or Swift package here when the app target lands in-repo.

## License

Add a `LICENSE` once legal terms are finalized.
