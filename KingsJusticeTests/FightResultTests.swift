import XCTest
@testable import KingsJustice

final class FightResultTests: XCTestCase {
    func testCleanFlawlessWinIsRankS() {
        XCTAssertEqual(FightRank.grade(perfects: 20, goods: 2, misses: 0, hpFraction: 0.9, won: true), .s)
    }

    func testSloppyWinIsLowerRank() {
        XCTAssertEqual(FightRank.grade(perfects: 4, goods: 8, misses: 8, hpFraction: 0.3, won: true), .c)
    }

    func testGoodAccuracyButHurtCapsBelowS() {
        XCTAssertEqual(FightRank.grade(perfects: 20, goods: 2, misses: 0, hpFraction: 0.2, won: true), .a)
    }

    func testLossIsAlwaysD() {
        XCTAssertEqual(FightRank.grade(perfects: 30, goods: 0, misses: 0, hpFraction: 1.0, won: false), .d)
    }

    func testDefeatTipsMatchWhatWentWrong() {
        XCTAssertTrue(FightResult.defeatTip(perfects: 1, goods: 1, misses: 9).contains("windup"))
        XCTAssertTrue(FightResult.defeatTip(perfects: 0, goods: 8, misses: 1).contains("Perfect"))
        XCTAssertTrue(FightResult.defeatTip(perfects: 5, goods: 5, misses: 1).contains("Focus"))
    }
}

final class ShareLineTests: XCTestCase {
    func testShareLines() {
        let win = FightResult.shareLine(won: true, enemy: "Hollow Conscript", rank: "S", score: 14982, combo: 17, mode: "duel", wave: 0)
        XCTAssertTrue(win.contains("Hollow Conscript") && win.contains("rank S") && win.contains("14982"))
        let surv = FightResult.shareLine(won: true, enemy: "x", rank: "A", score: 1, combo: 2, mode: "survival", wave: 7)
        XCTAssertTrue(surv.contains("wave 7"))
        let loss = FightResult.shareLine(won: false, enemy: "The King", rank: "D", score: 0, combo: 0, mode: "duel", wave: 0)
        XCTAssertTrue(loss.contains("The King") && loss.contains("Rematch"))
    }
}

final class RushCompletionTests: XCTestCase {
    func testGauntletNeedsEveryChampion() {
        var s = SaveData()
        s.bestRush = 2
        XCTAssertFalse(Achievements.unlocked(save: s, rosterIds: ["a", "b", "c"]).contains("gauntlet"))
        s.bestRush = 3
        XCTAssertTrue(Achievements.unlocked(save: s, rosterIds: ["a", "b", "c"]).contains("gauntlet"))
    }

    func testFinalVictoryDefaultsOff() {
        XCTAssertFalse(FightResult().finalVictory)
    }
}

final class AccuracyAndGlowTests: XCTestCase {
    func testAccuracyPercent() {
        var r = FightResult()
        XCTAssertEqual(r.accuracyPercent, 0)
        r.perfects = 10
        XCTAssertEqual(r.accuracyPercent, 100)
        r.perfects = 5
        r.goods = 5
        XCTAssertEqual(r.accuracyPercent, 75)
        r.misses = 10
        // (5 perfect x2 + 5 good) / (20 notes x2) = 37.5, rounded to 38
        XCTAssertEqual(r.accuracyPercent, 38)
    }

    @MainActor
    func testPerfectGlowFadesAndRespectsFlashSetting() {
        let e = GameEngine()
        e.on = true
        e.started = true
        e.over = true
        e.perfectGlowLevel = 1.0
        XCTAssertEqual(e.rsPerfectGlow, 1.0, accuracy: 1e-9)
        e.tick(dt: 0.1)
        XCTAssertLessThan(e.rsPerfectGlow, 1.0)
        e.settings.flash = false
        XCTAssertEqual(e.rsPerfectGlow, 0.0, accuracy: 1e-9)
    }
}
