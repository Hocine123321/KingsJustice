import XCTest
@testable import KingsJustice

final class PaceGovernorTests: XCTestCase {
    func testSecondWindStartsLateRisesEvenlyAndCapsAtFiftyPercent() {
        XCTAssertEqual(PaceGovernor.boost(seconds: -3.0), 1.0, accuracy: 1e-9)
        XCTAssertEqual(PaceGovernor.boost(seconds: 60.0), 1.0, accuracy: 1e-9)
        XCTAssertEqual(PaceGovernor.boost(seconds: 75.0), 1.0, accuracy: 1e-9)
        XCTAssertEqual(PaceGovernor.boost(seconds: 105.0), 1.25, accuracy: 1e-9)
        XCTAssertEqual(PaceGovernor.boost(seconds: 135.0), 1.5, accuracy: 1e-9)
        XCTAssertEqual(PaceGovernor.boost(seconds: 600.0), 1.5, accuracy: 1e-9)
        var last = 1.0
        for s in stride(from: 0.0, through: 200.0, by: 5.0) {
            let b = PaceGovernor.boost(seconds: s)
            XCTAssertGreaterThanOrEqual(b, last)
            last = b
        }
    }

    func testStandardFightsNeverTriggerTheSecondWind() {
        XCTAssertLessThan(PaceGovernor.startsAt, 90.0, "it must still help a dragging fight")
        XCTAssertGreaterThan(PaceGovernor.startsAt, 66.0, "a typical fight (about 60 s) must be left alone")
    }

    func testStrikeTableCoversEveryChampionAndNeverGrowsAfterTheFirst() {
        XCTAssertEqual(PaceGovernor.lenTable.count, 7)
        XCTAssertEqual(PaceGovernor.lenTable.count, GameData.roster.count)
        for i in 1..<PaceGovernor.lenTable.count {
            XCTAssertLessThanOrEqual(PaceGovernor.lenTable[i], PaceGovernor.lenTable[i - 1], "champion \(i)")
        }
        for v in PaceGovernor.lenTable { XCTAssertTrue(v > 0.3 && v < 1.3, "\(v)") }
    }

    func testEngineUsesTheTableAndTheBoost() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 0)
        e.t = 10.0
        XCTAssertEqual(e.lenFactor(), PaceGovernor.lenTable[0], accuracy: 1e-9)
        e.t = 105.0
        XCTAssertEqual(e.lenFactor(), PaceGovernor.lenTable[0] * 1.25, accuracy: 1e-9)
        e.startRun(mode: "duel", enemyIndex: 6)
        e.t = 10.0
        XCTAssertEqual(e.lenFactor(), PaceGovernor.lenTable[6], accuracy: 1e-9)
    }

    func testTheSecondWindNeverTouchesEnemyDamage() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 2)
        e.t = 10.0
        let early = e.earlyEase()
        e.t = 130.0
        XCTAssertEqual(e.earlyEase(), early, accuracy: 1e-9)
    }
}
