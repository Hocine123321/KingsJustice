import XCTest
@testable import KingsJustice

final class BoonTests: XCTestCase {
    func testOfferIsThreeDistinctBoons() {
        let offer = BoonCatalog.offer(taken: [], seed: 42)
        XCTAssertEqual(offer.count, 3)
        XCTAssertEqual(Set(offer.map { $0.id }).count, 3)
    }

    func testOfferIsDeterministicForASeed() {
        XCTAssertEqual(BoonCatalog.offer(taken: [], seed: 7), BoonCatalog.offer(taken: [], seed: 7))
    }

    func testMaxedBoonsAreNotOffered() {
        let taken = ["glass"]
        for seed in 0..<40 {
            XCTAssertFalse(BoonCatalog.offer(taken: taken, seed: UInt32(seed)).contains { $0.id == "glass" })
        }
    }

    func testMultipliers() {
        XCTAssertEqual(BoonCatalog.damageDealtMul([]), 1.0, accuracy: 1e-9)
        XCTAssertEqual(BoonCatalog.damageDealtMul(["keen", "keen"]), 1.24, accuracy: 1e-9)
        XCTAssertEqual(BoonCatalog.damageTakenMul(["ward"]), 0.9, accuracy: 1e-9)
        // Glass Cannon is a real trade: more damage out, more damage in.
        XCTAssertGreaterThan(BoonCatalog.damageDealtMul(["glass"]), 1.0)
        XCTAssertGreaterThan(BoonCatalog.damageTakenMul(["glass"]), 1.0)
        XCTAssertEqual(BoonCatalog.maxHealthBonus(["vigor", "vigor"]), 24.0, accuracy: 1e-9)
        XCTAssertEqual(BoonCatalog.goldMul(["greed"]), 1.4, accuracy: 1e-9)
    }

    @MainActor
    func testChoosingBoonsAppliesAndClearsOffer() {
        let e = GameEngine()
        e.hp = 40.0
        e.maxhp = 100.0
        e.boonOffer = BoonCatalog.offer(taken: [], seed: 1)
        e.chooseBoon("vigor")
        XCTAssertEqual(e.boons, ["vigor"])
        XCTAssertTrue(e.boonOffer.isEmpty)
        XCTAssertEqual(e.maxhp, 112.0, accuracy: 1e-9)
        XCTAssertEqual(e.hp, 52.0, accuracy: 1e-9)
        e.chooseBoon("mend")
        XCTAssertEqual(e.hp, 52.0 + 112.0 * 0.35, accuracy: 1e-9)
    }

    @MainActor
    func testBoonsResetWhenAnotherRunStarts() {
        let e = GameEngine()
        e.boons = ["keen", "glass"]
        e.startRun(mode: "duel", enemyIndex: 0)
        XCTAssertTrue(e.boons.isEmpty)
        UIAudio.stopMusic(fade: false)
    }
}
