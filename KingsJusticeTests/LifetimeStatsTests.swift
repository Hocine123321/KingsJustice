import XCTest
@testable import KingsJustice

final class LifetimeStatsTests: XCTestCase {
    private func fight(_ s: inout SaveData, id: String = "a", won: Bool = true, combo: Int = 5,
                       p: Int = 10, g: Int = 5, m: Int = 1, rank: String = "B", training: Bool = false) -> Bool {
        return LifetimeStats.record(into: &s, enemyId: id, won: won, maxCombo: combo, perfects: p, goods: g, misses: m, rank: rank, training: training)
    }

    func testTrainingYardNeverCounts() {
        var s = SaveData()
        XCTAssertFalse(fight(&s, training: true))
        XCTAssertEqual(s, SaveData())
    }

    func testWinsLossesAndHitsAccumulate() {
        var s = SaveData()
        _ = fight(&s, id: "a", won: true)
        _ = fight(&s, id: "a", won: false)
        _ = fight(&s, id: "b", won: true)
        XCTAssertEqual(s.fights, 3)
        XCTAssertEqual(s.wins, 2)
        XCTAssertEqual(s.champWins, ["a": 1, "b": 1])
        XCTAssertEqual(s.champLosses, ["a": 1])
        XCTAssertEqual(s.perfectHits, 30)
        XCTAssertEqual(s.goodHits, 15)
        XCTAssertEqual(s.missedHits, 3)
        XCTAssertEqual(LifetimeStats.championRecord(s, id: "a"), "1 won, 1 lost")
        XCTAssertNil(LifetimeStats.championRecord(s, id: "zzz"))
    }

    func testOnlyRankSCountsAsAnSRank() {
        var s = SaveData()
        _ = fight(&s, rank: "S")
        _ = fight(&s, rank: "A")
        _ = fight(&s, rank: "S")
        XCTAssertEqual(s.sRanks, 2)
    }

    func testComboRecordIsReportedOnlyWhenBeatingAnEarlierBest() {
        var s = SaveData()
        XCTAssertFalse(fight(&s, combo: 8), "the first fight sets a baseline, not a record")
        XCTAssertEqual(s.bestCombo, 8)
        XCTAssertFalse(fight(&s, combo: 8), "equalling is not a record")
        XCTAssertFalse(fight(&s, combo: 3))
        XCTAssertTrue(fight(&s, combo: 12))
        XCTAssertEqual(s.bestCombo, 12)
    }

    func testRatesUseTheSameFormulaAsTheResultScreen() {
        var s = SaveData()
        XCTAssertNil(LifetimeStats.winRatePercent(s))
        XCTAssertNil(LifetimeStats.accuracyPercent(s))
        _ = fight(&s, won: true, p: 6, g: 2, m: 2)
        _ = fight(&s, won: false, p: 4, g: 0, m: 6)
        XCTAssertEqual(LifetimeStats.winRatePercent(s), 50)
        var r = FightResult()
        r.perfects = 10; r.goods = 2; r.misses = 8
        XCTAssertEqual(LifetimeStats.accuracyPercent(s), r.accuracyPercent)
    }

    func testOldSavesLoadWithZeroStatsAndNewOnesRoundTrip() throws {
        let old = try JSONDecoder().decode(SaveData.self, from: Data("{\"gold\": 7}".utf8))
        XCTAssertEqual(old.fights, 0)
        XCTAssertEqual(old.champWins, [:])
        var s = SaveData()
        _ = fight(&s, id: "x", rank: "S")
        let back = try JSONDecoder().decode(SaveData.self, from: try JSONEncoder().encode(s))
        XCTAssertEqual(back, s)
    }

    func testVeteranAndDeadeyeThresholds() {
        var s = SaveData()
        s.fights = 24
        s.sRanks = 4
        XCTAssertTrue(Achievements.unlocked(save: s, rosterIds: ["a"]).isEmpty)
        s.fights = 25
        s.sRanks = 5
        XCTAssertEqual(Achievements.unlocked(save: s, rosterIds: ["a"]), ["veteran", "deadeye"])
        XCTAssertEqual(Achievements.titles["veteran"], "the Veteran")
    }

    func testResultStartsWithoutAComboRecord() {
        XCTAssertFalse(FightResult().comboRecord)
    }
}
