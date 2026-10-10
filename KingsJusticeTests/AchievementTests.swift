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
        s.gold = 99999
        XCTAssertEqual(Achievements.unlocked(save: s, rosterIds: roster).count, Achievements.all.count)
    }
}
