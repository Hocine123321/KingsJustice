import XCTest
@testable import KingsJustice

final class HallOfRecordsTests: XCTestCase {
    func testFirstRunTakesFirstPlaceAndZeroNeverCounts() {
        var list: [Int] = []
        XCTAssertNil(HallOfRecords.insert(&list, value: 0))
        XCTAssertTrue(list.isEmpty)
        XCTAssertEqual(HallOfRecords.insert(&list, value: 4), 1)
        XCTAssertEqual(list, [4])
    }

    func testListStaysHighestFirstAndCappedAtFive() {
        var list: [Int] = []
        for v in [3, 9, 5, 7, 1, 8, 6] { HallOfRecords.insert(&list, value: v) }
        XCTAssertEqual(list, [9, 8, 7, 6, 5])
    }

    func testReturnsThePlaceOrNilWhenItMissesTheList() {
        var list = [9, 8, 7, 6, 5]
        XCTAssertNil(HallOfRecords.insert(&list, value: 4))
        XCTAssertNil(HallOfRecords.insert(&list, value: 5), "a tie with the last place does not displace it")
        XCTAssertEqual(HallOfRecords.insert(&list, value: 10), 1)
        XCTAssertEqual(HallOfRecords.insert(&list, value: 7), 5)
        XCTAssertEqual(list, [10, 9, 8, 7, 7])
    }

    func testTiesRankBelowEarlierRuns() {
        var list = [6, 4]
        XCTAssertEqual(HallOfRecords.insert(&list, value: 6), 2)
        XCTAssertEqual(list, [6, 6, 4])
    }

    func testTopDailyOrdersByScoreThenNewestDay() {
        let best = ["2026-10-01": 900, "2026-10-02": 1500, "2026-10-03": 900, "2026-10-04": 0, "2026-10-05": 700]
        let top = HallOfRecords.topDaily(best, count: 3)
        XCTAssertEqual(top.map { $0.date }, ["2026-10-02", "2026-10-03", "2026-10-01"])
        XCTAssertEqual(top.map { $0.score }, [1500, 900, 900])
        XCTAssertTrue(HallOfRecords.topDaily([:]).isEmpty)
    }

    func testOldSavesLoadEmptyAndListsRoundTrip() throws {
        let old = try JSONDecoder().decode(SaveData.self, from: Data("{\"gold\": 1}".utf8))
        XCTAssertEqual(old.topSurvival, [])
        XCTAssertEqual(old.topRush, [])
        var s = SaveData()
        HallOfRecords.insert(&s.topSurvival, value: 12)
        HallOfRecords.insert(&s.topRush, value: 3)
        let back = try JSONDecoder().decode(SaveData.self, from: try JSONEncoder().encode(s))
        XCTAssertEqual(back.topSurvival, [12])
        XCTAssertEqual(back.topRush, [3])
    }

    func testResultStartsWithoutARecordPlace() {
        XCTAssertEqual(FightResult().recordRank, 0)
    }
}
