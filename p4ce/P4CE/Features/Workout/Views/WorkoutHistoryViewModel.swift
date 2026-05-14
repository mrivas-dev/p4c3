import Foundation

/// Pure grouping helpers for workout history (P4CE-16) — testable without SwiftUI.
enum WorkoutHistoryViewModel {
    static func groupByWeek(
        sessions: [WorkoutSession],
        calendar: Calendar = .current,
        now: Date = Date()
    ) -> [(weekLabel: String, sessions: [WorkoutSession])] {
        guard !sessions.isEmpty else { return [] }

        var buckets: [Date: [WorkoutSession]] = [:]
        for session in sessions {
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: session.date) else { continue }
            buckets[interval.start, default: []].append(session)
        }

        let weekStartsDesc = buckets.keys.sorted(by: >)
        let referenceYear = calendar.component(.year, from: now)
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: now)

        return weekStartsDesc.compactMap { weekStart in
            guard var weekSessions = buckets[weekStart], !weekSessions.isEmpty else { return nil }
            weekSessions.sort { $0.date > $1.date }

            guard let interval = calendar.dateInterval(of: .weekOfYear, for: weekSessions[0].date) else {
                return nil
            }

            let label: String
            if let currentWeek, interval == currentWeek {
                label = "This week"
            } else {
                label = weekRangeLabel(for: interval, calendar: calendar, referenceYear: referenceYear)
            }

            return (weekLabel: label, sessions: weekSessions)
        }
    }

    private static func weekRangeLabel(
        for interval: DateInterval,
        calendar: Calendar,
        referenceYear: Int
    ) -> String {
        let start = interval.start
        guard let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
            return start.formatted(.dateTime.month(.abbreviated).day())
        }

        let sm = calendar.component(.month, from: start)
        let em = calendar.component(.month, from: lastDay)
        let sy = calendar.component(.year, from: start)
        let ey = calendar.component(.year, from: lastDay)

        let mdStyle = Date.FormatStyle().month(.abbreviated).day()
        let mdYearStyle = Date.FormatStyle().month(.abbreviated).day().year(.defaultDigits)

        if sm == em {
            let d1 = calendar.component(.day, from: start)
            let d2 = calendar.component(.day, from: lastDay)
            let monthWord = start.formatted(Date.FormatStyle().month(.abbreviated))
            if sy == referenceYear, ey == referenceYear {
                return "\(monthWord) \(d1)–\(d2)"
            }
            return "\(monthWord) \(d1)–\(d2), \(sy)"
        }

        if sy == referenceYear, ey == referenceYear {
            return "\(start.formatted(mdStyle))–\(lastDay.formatted(mdStyle))"
        }
        return "\(start.formatted(mdYearStyle))–\(lastDay.formatted(mdYearStyle))"
    }
}
