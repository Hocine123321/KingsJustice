import XCTest
import SwiftUI
@testable import KingsJustice

final class ArenaGradeTests: XCTestCase {
    func testEveryArenaHasASubtleGrade() {
        for key in GameData.arenas.keys {
            let g = Atmosphere.grade(for: key)
            XCTAssertGreaterThan(g.opacity, 0.0, "\(key) has no grade")
            XCTAssertLessThanOrEqual(g.opacity, 0.12, "\(key) grade is too strong")
        }
    }
}

@MainActor
final class ArenaEventAndAssistTests: XCTestCase {
    func testEveryArenaEventIsCosmeticOnly() {
        let e = GameEngine()
        let hpBefore = e.hp
        let comboBefore = e.combo
        for key in GameData.arenas.keys {
            e.fireArenaEvent(arena: key)
        }
        XCTAssertEqual(e.hp, hpBefore, accuracy: 1e-9)
        XCTAssertEqual(e.combo, comboBefore)
    }

    func testEventTimerFiresAndResets() {
        let e = GameEngine()
        e.arenaEventTimer = 0.05
        e.tickArenaEvents(dt: 0.1)
        XCTAssertGreaterThanOrEqual(e.arenaEventTimer, 14.0)
    }

    func testAdaptiveIntensityRisesWithComboAndDanger() {
        let e = GameEngine()
        e.hp = 100.0
        e.maxhp = 100.0
        e.combo = 0
        let calm = e.adaptiveIntensity(woundFraction: 0.2)
        e.combo = 12
        let combo = e.adaptiveIntensity(woundFraction: 0.2)
        XCTAssertGreaterThan(combo, calm)
        e.hp = 20.0
        let danger = e.adaptiveIntensity(woundFraction: 0.2)
        XCTAssertGreaterThan(danger, combo)
        XCTAssertLessThanOrEqual(e.adaptiveIntensity(woundFraction: 1.0), 1.0)
    }

    func testTimingAssistWidensPlayerWindowsOnly() {
        let e = GameEngine()
        e.settings.difficulty = "normal"
        let base = e.currentWindows()
        e.settings.assist = true
        let assisted = e.currentWindows()
        XCTAssertEqual(assisted.perfect, base.perfect * 1.25, accuracy: 1e-6)
        XCTAssertEqual(assisted.good, base.good * 1.25, accuracy: 1e-6)
        // The enemy's parameters are unchanged by assist.
        XCTAssertEqual(e.difficultyParams("normal").enemyDmg, 0.85, accuracy: 1e-9)
    }

    func testOldSettingsLoadWithAssistOff() throws {
        let old = #"{"music":0.6}"#
        XCTAssertFalse(try JSONDecoder().decode(GameSettings.self, from: Data(old.utf8)).assist)
    }
}
