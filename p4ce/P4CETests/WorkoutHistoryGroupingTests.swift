import XCTest
@testable import P4CE

final class WorkoutHistoryGroupingTests: XCTestCase {
    func testGroupByWeek_returnsEmptyForEmptyInput() {
        let (cal, now) = Self.utcCalendarNow()
        let groups = WorkoutHistoryViewModel.groupByWeek(sessions: [], calendar: cal, now: now)
        XCTAssertTrue(groups.isEmpty)
    }

    func testGroupByWeek_coalescesSessionsInSameWeek_newestSessionFirstInBucket() {
        let (cal, now) = Self.utcCalendarNow()
        guard let week = cal.dateInterval(of: .weekOfYear, for: now) else {
            XCTFail("missing week interval")
            return
        }
        let early = week.start
        guard let mid = cal.date(byAdding: .day, value: 2, to: week.start) else {
            XCTFail("missing date")
            return
        }

        let older = WorkoutSession(date: early, status: .finished)
        let newer = WorkoutSession(date: mid, status: .finished)
        let groups = WorkoutHistoryViewModel.groupByWeek(sessions: [older, newer], calendar: cal, now: now)

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].sessions.count, 2)
        XCTAssertEqual(groups[0].sessions[0].id, newer.id)
        XCTAssertEqual(groups[0].sessions[1].id, older.id)
    }

    func testGroupByWeek_splitsAcrossWeekBoundaries_newestWeekFirst() {
        let (cal, now) = Self.utcCalendarNow()
        guard let thisWeek = cal.dateInterval(of: .weekOfYear, for: now) else {
            XCTFail("missing week interval")
            return
        }
        guard let prevWeekAnchor = cal.date(byAdding: .day, value: -10, to: now) else {
            XCTFail("missing prior date")
            return
        }
        guard let prevWeek = cal.dateInterval(of: .weekOfYear, for: prevWeekAnchor),
              prevWeek != thisWeek else {
            XCTFail("expected distinct calendar weeks for test anchors")
            return
        }

        let current = WorkoutSession(date: thisWeek.start, status: .finished)
        let prior = WorkoutSession(date: prevWeek.start, status: .finished)

        let groups = WorkoutHistoryViewModel.groupByWeek(sessions: [prior, current], calendar: cal, now: now)
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].sessions.count, 1)
        XCTAssertEqual(groups[0].sessions[0].id, current.id)
        XCTAssertEqual(groups[1].sessions[0].id, prior.id)
    }

    func testGroupByWeek_thisWeekLabel() {
        let (cal, now) = Self.utcCalendarNow()
        guard let week = cal.dateInterval(of: .weekOfYear, for: now) else {
            XCTFail("missing week interval")
            return
        }
        let session = WorkoutSession(date: week.start, status: .finished)
        let groups = WorkoutHistoryViewModel.groupByWeek(sessions: [session], calendar: cal, now: now)
        XCTAssertEqual(groups.first?.weekLabel, "This week")
    }

    private static func utcCalendarNow() -> (Calendar, Date) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 5
        comps.day = 14
        comps.hour = 15
        guard let now = cal.date(from: comps) else {
            fatalError("expected fixed preview date")
        }
        return (cal, now)
    }
}
