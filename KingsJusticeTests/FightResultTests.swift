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
