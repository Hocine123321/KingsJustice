import XCTest
@testable import KingsJustice

final class WeeklyGauntletTests: XCTestCase {
    func testWeekKeyIsTheMondayOfThatWeek() {
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-10-12"), "2026-10-12")   // a Monday
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-10-14"), "2026-10-12")
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-10-16"), "2026-10-12")
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-10-18"), "2026-10-12")   // the Sunday
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-10-19"), "2026-10-19")   // next Monday
        XCTAssertEqual(WeeklyGauntlet.weekKey(for: "2026-01-01"), "2025-12-29")   // across the new year
        XCTAssertNil(WeeklyGauntlet.weekKey(for: "not a date"))
    }

    func testThreeDifferentAscendingChampionsAndNeverTheKing() {
        let count = GameData.roster.count
        for w in 0..<80 {
            let week = "2026-w\(w)"
            let idx = WeeklyGauntlet.rosterIndices(week: week, rosterCount: count)
            XCTAssertEqual(idx.count, WeeklyGauntlet.length, week)
            XCTAssertEqual(Set(idx).count, idx.count, "no repeats in \(week)")
            XCTAssertEqual(idx, idx.sorted(), week)
            XCTAssertTrue(idx.allSatisfy { $0 >= 0 && $0 < count - 1 }, "the King must not appear in \(week)")
            XCTAssertEqual(idx, WeeklyGauntlet.rosterIndices(week: week, rosterCount: count), "same week, same champions")
        }
    }

    func testDifferentWeeksGiveDifferentGauntlets() {
        var seen = Set<[Int]>()
        for w in 0..<40 {
            seen.insert(WeeklyGauntlet.rosterIndices(week: "2026-w\(w)", rosterCount: GameData.roster.count))
        }
        XCTAssertGreaterThan(seen.count, 4)
    }

    func testTinyRostersDoNotCrash() {
        XCTAssertEqual(WeeklyGauntlet.rosterIndices(week: "x", rosterCount: 0), [])
        XCTAssertEqual(WeeklyGauntlet.rosterIndices(week: "x", rosterCount: 1), [])
        XCTAssertEqual(WeeklyGauntlet.rosterIndices(week: "x", rosterCount: 3), [0, 1])
    }

    func testEnemiesAreTheChosenChampionsWithTheTwistApplied() {
        let count = GameData.roster.count
        var sawMarathon = false
        var sawTempo = false
        for w in 0..<120 {
            let week = "2026-w\(w)"
            let idx = WeeklyGauntlet.rosterIndices(week: week, rosterCount: count)
            let id = WeeklyGauntlet.modifier(week: week).id
            for slot in 0..<WeeklyGauntlet.length {
                let base = GameData.roster[idx[slot]]
                let e = WeeklyGauntlet.enemy(slot: slot, week: week)
                XCTAssertEqual(e.id, base.id)
                XCTAssertEqual(e.hp, floor(base.hp * (id == "marathon" ? 1.4 : 1.0)), week)
                XCTAssertEqual(e.bpm, base.bpm + (id == "tempo" ? 10.0 : 0.0), week)
            }
            if id == "marathon" { sawMarathon = true }
            if id == "tempo" { sawTempo = true }
        }
        XCTAssertTrue(sawMarathon && sawTempo, "the sample should cover both twists")
    }

    func testScoreIsScaledOnlyWhenTheRunEndsAndTheBestIsKept() {
        var s = SaveData()
        let week = "2026-10-12"
        let mul = WeeklyGauntlet.modifier(week: week).scoreMul
        let midRun = WeeklyGauntlet.finishRun(save: &s, week: week, score: 5000, won: true, finalVictory: false)
        XCTAssertEqual(midRun.score, 5000)
        XCTAssertFalse(midRun.newBest)
        XCTAssertNil(s.bestWeekly[week])

        let done = WeeklyGauntlet.finishRun(save: &s, week: week, score: 10000, won: true, finalVictory: true)
        XCTAssertEqual(done.score, Int((10000.0 * mul).rounded()))
        XCTAssertTrue(done.newBest)
        XCTAssertEqual(s.bestWeekly[week], done.score)

        let worse = WeeklyGauntlet.finishRun(save: &s, week: week, score: 100, won: false, finalVictory: false)
        XCTAssertFalse(worse.newBest)
        XCTAssertEqual(s.bestWeekly[week], done.score, "a worse run never lowers the best")
    }

    func testEngineRunsTheGauntletInOrderWithAWeeklyLabel() {
        let e = GameEngine()
        e.startRun(mode: "weekly", enemyIndex: 0)
        let week = e.currentWeekKey
        let idx = WeeklyGauntlet.rosterIndices(week: week, rosterCount: GameData.roster.count)
        XCTAssertEqual(e.enemyDef?.id, GameData.roster[idx[0]].id)
        XCTAssertTrue(e.modeLabel.hasPrefix("WEEKLY · 1/3"))
        XCTAssertEqual(e.rosterPosition, idx[0])
        XCTAssertEqual(e.dailyMod, WeeklyGauntlet.modifier(week: week))
        e.beginFight(index: 2, keepHp: true)
        XCTAssertEqual(e.enemyDef?.id, GameData.roster[idx[2]].id)
        XCTAssertEqual(e.rosterPosition, idx[2])
        XCTAssertTrue(e.modeLabel.hasPrefix("WEEKLY · 3/3"))
    }

    func testOtherModesKeepTheirOwnPositionAndNoTwist() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 3)
        XCTAssertEqual(e.rosterPosition, 3)
        XCTAssertEqual(e.dailyMod, DailyModifiers.steady)
    }

    func testOldSavesLoadWithNoWeeklyBests() throws {
        let old = try JSONDecoder().decode(SaveData.self, from: Data("{\"gold\": 2}".utf8))
        XCTAssertEqual(old.bestWeekly, [:])
        var s = SaveData()
        s.bestWeekly["2026-10-12"] = 4321
        let back = try JSONDecoder().decode(SaveData.self, from: try JSONEncoder().encode(s))
        XCTAssertEqual(back.bestWeekly["2026-10-12"], 4321)
    }
}
