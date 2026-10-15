import XCTest
@testable import KingsJustice

final class AchievementTests: XCTestCase {
    private let roster = ["a", "b", "c"]

    func testFreshSaveUnlocksNothing() {
        XCTAssertTrue(Achievements.unlocked(save: SaveData(), rosterIds: roster).isEmpty)
    }

    func testThresholds() {
        var s = SaveData()
        s.kills = 1
        s.flawless = 10
        s.bestSurvival = 5
        s.bestDailyStreak = 3
        s.gold = 1000
        let got = Achievements.unlocked(save: s, rosterIds: roster)
        XCTAssertEqual(got, ["first_blood", "untouchable", "ghost", "survivor5", "devotee", "rich"])
    }

    func testKingslayerNeedsEveryChampion() {
        var s = SaveData()
        s.beat = ["a", "b"]
        XCTAssertFalse(Achievements.unlocked(save: s, rosterIds: roster).contains("slayer"))
        s.beat = ["a", "b", "c"]
        XCTAssertTrue(Achievements.unlocked(save: s, rosterIds: roster).contains("slayer"))
    }

    func testEveryAchievementIsReachable() {
        var s = SaveData()
        s.kills = 99
        s.beat = roster
        s.flawless = 99
        s.bestSurvival = 99
        s.bestDailyStreak = 99
        s.bestRush = 99
        s.gold = 99999
        s.fights = 99
        s.sRanks = 99
        XCTAssertEqual(Achievements.unlocked(save: s, rosterIds: roster).count, Achievements.all.count)
    }

    func testEveryAchievementGrantsADistinctTitle() {
        var seen = Set<String>()
        for a in Achievements.all {
            guard let t = Achievements.titles[a.id] else { return XCTFail("no title for \(a.id)") }
            XCTAssertTrue(seen.insert(t).inserted, "duplicate title \(t)")
        }
        XCTAssertEqual(Achievements.titles.count, Achievements.all.count)
    }

    func testTitleShowsOnlyWhenWornAndEarned() {
        var s = SaveData()
        XCTAssertNil(Achievements.wornTitle(save: s, rosterIds: roster))
        s.title = "ghost"
        XCTAssertNil(Achievements.wornTitle(save: s, rosterIds: roster), "not earned yet")
        s.flawless = 10
        XCTAssertEqual(Achievements.wornTitle(save: s, rosterIds: roster), "the Ghost")
        s.title = "nonsense"
        XCTAssertNil(Achievements.wornTitle(save: s, rosterIds: roster))
    }

    func testOldSavesStillLoadAndTheTitleSurvivesARoundTrip() throws {
        let old = try JSONDecoder().decode(SaveData.self, from: Data("{\"gold\": 5}".utf8))
        XCTAssertEqual(old.gold, 5)
        XCTAssertEqual(old.title, "")
        var s = SaveData()
        s.title = "slayer"
        let back = try JSONDecoder().decode(SaveData.self, from: try JSONEncoder().encode(s))
        XCTAssertEqual(back.title, "slayer")
    }
}
