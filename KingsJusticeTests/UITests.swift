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

    func testRootViewBuilds() {
        _ = RootView()
    }
}
