import XCTest
@testable import KingsJustice

@MainActor
final class AggressionPressureTests: XCTestCase {
    func testCalmChampionsNeverPressAndTheChanceRisesWithAggression() {
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.0, phasesActive: 0), 0.0)
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.30, phasesActive: 2), 0.0, "calm champions stay calm even in a phase")
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.55, phasesActive: 1), 0.0)
        var last = 0.0
        for a in stride(from: 0.56, through: 1.0, by: 0.04) {
            let c = AggressionPressure.chance(aggression: a, phasesActive: 0)
            XCTAssertGreaterThanOrEqual(c, last)
            XCTAssertLessThanOrEqual(c, AggressionPressure.cap + 1e-9)
            last = c
        }
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.95, phasesActive: 0), 0.16, accuracy: 1e-9)
    }

    func testPhasesAddAFixedAmountUpToTheCap() {
        let base = AggressionPressure.chance(aggression: 0.85, phasesActive: 0)
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.85, phasesActive: 1), base + AggressionPressure.perPhase, accuracy: 1e-9)
        XCTAssertLessThanOrEqual(AggressionPressure.chance(aggression: 1.0, phasesActive: 9), AggressionPressure.phaseCap + 1e-9)
        XCTAssertEqual(AggressionPressure.chance(aggression: 0.85, phasesActive: -3), base, accuracy: 1e-9)
    }

    func testAggressionNeverFallsAcrossTheRoster() {
        var last = 0.0
        for e in GameData.roster {
            XCTAssertGreaterThanOrEqual(e.ai.aggression, last, e.id)
            last = e.ai.aggression
        }
    }

    private func pressedCount(enemyIndex: Int, mode: String = "duel", trials: Int = 300) -> Int {
        let e = GameEngine()
        e.startRun(mode: mode, enemyIndex: enemyIndex)
        var pressed = 0
        for _ in 0..<trials {
            e.round = 4          // an even round: a defend round, after the opening
            e.pressing = false
            e.startRound2()
            if e.round == 6 { pressed += 1 }
            XCTAssertTrue(e.round == 5 || e.round == 6)
        }
        UIAudio.stopMusic(fade: false)
        return pressed
    }

    func testTheKingPressesSometimesButNeverOften() {
        let n = pressedCount(enemyIndex: 6)
        XCTAssertGreaterThan(n, 15, "about 16% of 300")
        XCTAssertLessThan(n, 110)
    }

    func testTheFirstChampionNeverPresses() {
        XCTAssertEqual(pressedCount(enemyIndex: 0), 0)
        XCTAssertEqual(pressedCount(enemyIndex: 1), 0)
    }

    func testTheTrainingYardNeverPresses() {
        XCTAssertEqual(pressedCount(enemyIndex: 6, mode: "training"), 0)
    }

    func testTheOpeningRoundsAreSafe() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 6)
        for r in [0, 2] {
            for _ in 0..<100 {
                e.round = r
                e.startRound2()
                XCTAssertEqual(e.round, r + 1, "no pressing before round \(AggressionPressure.firstRound)")
            }
        }
        UIAudio.stopMusic(fade: false)
    }

    func testThePressCueShowsOnceOnTheNextRoundAndClears() {
        let e = GameEngine()
        // The first champion never presses, so the flag cannot be set again by this round's own roll.
        e.startRun(mode: "duel", enemyIndex: 0)
        e.pressing = true
        e.round = 6
        e.startRound2()
        XCTAssertFalse(e.pressing, "the cue is consumed")
        UIAudio.stopMusic(fade: false)
    }
}
