import XCTest
@testable import KingsJustice

final class DailyModifierTests: XCTestCase {
    func testSameDateSameModifier() {
        XCTAssertEqual(DailyModifiers.forDate("2026-10-10"), DailyModifiers.forDate("2026-10-10"))
    }

    func testEveryModifierGetsUsedOverAMonth() {
        var seen = Set<String>()
        for day in 1...31 {
            let d = String(format: "2026-10-%02d", day)
            seen.insert(DailyModifiers.forDate(d).id)
        }
        XCTAssertEqual(seen.count, DailyModifiers.all.count)
    }

    func testPreviousDayHandlesMonthEdges() {
        XCTAssertEqual(DailyModifiers.previousDay(of: "2026-10-01"), "2026-09-30")
        XCTAssertEqual(DailyModifiers.previousDay(of: "2026-01-01"), "2025-12-31")
        XCTAssertNil(DailyModifiers.previousDay(of: "garbage"))
    }

    func testStreakRules() {
        // First ever win starts at 1.
        XCTAssertEqual(DailyModifiers.nextStreak(current: 0, lastWin: "", today: "2026-10-10"), 1)
        // Won yesterday: extends.
        XCTAssertEqual(DailyModifiers.nextStreak(current: 3, lastWin: "2026-10-09", today: "2026-10-10"), 4)
        // Missed a day: restarts.
        XCTAssertEqual(DailyModifiers.nextStreak(current: 5, lastWin: "2026-10-07", today: "2026-10-10"), 1)
        // Already won today: not double counted.
        XCTAssertEqual(DailyModifiers.nextStreak(current: 4, lastWin: "2026-10-10", today: "2026-10-10"), 4)
    }

    func testModifiersNeverMakeThePlayerSafeForFree() {
        for m in DailyModifiers.all where m.id != "steady" {
            XCTAssertGreaterThan(m.scoreMul, 1.0, "\(m.id) is a handicap, so it should pay more score")
        }
    }
}
