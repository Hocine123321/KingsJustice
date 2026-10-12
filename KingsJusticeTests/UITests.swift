import XCTest
import SwiftUI
@testable import KingsJustice

@MainActor
final class UITests: XCTestCase {
    func testEngineConformsToUIEngine() {
        let e = GameEngine()
        XCTAssertEqual(e.tonicCatalog().count, 4)
        XCTAssertTrue(e.unlockedStyles().contains("knight"))
    }

    func testGlueMapsEvents() {
        let e = GameEngine()
        XCTAssertEqual(e.rsArenaKey, "castle")
        XCTAssertTrue(e.rsEvents.isEmpty)
        XCTAssertTrue(e.rsDrainFX().isEmpty)
    }

    func testMenuHasTwoMainModesAndThreeExtras() {
        XCTAssertEqual(MenuModeCatalog.main.map { $0.id }, ["duel", "survival"])
        XCTAssertEqual(MenuModeCatalog.extras.map { $0.id }, ["rush", "daily", "training"])
    }

    func testOnlyMainModesGetCardArt() {
        for m in MenuModeCatalog.main { XCTAssertNotNil(MenuModeCatalog.art(for: m.id), m.id) }
        for m in MenuModeCatalog.extras { XCTAssertNil(MenuModeCatalog.art(for: m.id), m.id) }
        XCTAssertNotEqual(MenuModeCatalog.art(for: "duel"), MenuModeCatalog.art(for: "survival"))
    }

    func testModeArtShapesFillTheirRect() {
        let r = CGRect(x: 0, y: 0, width: 46, height: 46)
        for path in [CrossedBladesShape().path(in: r), RisingWavesShape().path(in: r)] {
            XCTAssertFalse(path.isEmpty)
            XCTAssertTrue(r.insetBy(dx: -1, dy: -1).contains(path.boundingRect))
        }
    }

    func testHowToPlayBuildsAndFirstRunIsPending() {
        _ = HowToPlayView(onDone: {})
        XCTAssertNotEqual(GameEngine().save.seen["howto"], true)
    }

    func testTipsUseTouchWording() {
        for (key, tip) in EngineTips.tips {
            XCTAssertFalse(tip.description.contains("Space"), key)
            XCTAssertFalse(tip.description.contains("press W"), key)
            XCTAssertFalse(tip.description.contains("press S"), key)
            XCTAssertFalse(tip.description.contains("(A or"), key)
        }
    }

    func testRootViewBuilds() {
        _ = RootView()
    }
}
