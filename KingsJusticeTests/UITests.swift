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

    func testTrainingMoveListCoversEveryMoveInTouchWording() {
        let ids = TrainingGuide.moves.map { $0.id }
        for needed in InputPalette.defendInputs + ["grab", "strike", "focus", "heal"] {
            XCTAssertTrue(ids.contains(needed), needed)
        }
        for m in TrainingGuide.moves {
            XCTAssertFalse(m.how.contains("Space"), m.id)
            if let key = m.paletteKey { XCTAssertNotEqual(InputPalette.hex(for: key), "#ffffff", m.id) }
        }
        XCTAssertTrue(TrainingGuide.moves.first(where: { $0.id == "focus" })!.how.contains("do not get easier"))
    }

    func testEveryDrillMatchesItsMoveInput() {
        XCTAssertEqual(TrainingGuide.drills.count, 5)
        for d in TrainingGuide.drills {
            XCTAssertEqual(GameData.moves[d.move]?.input, d.id, d.id)
        }
        XCTAssertNil(TrainingGuide.drillMove(for: nil))
        XCTAssertNil(TrainingGuide.drillMove(for: "nonsense"))
        XCTAssertEqual(TrainingGuide.drillMove(for: "jump"), "high")
    }

    func testDrillRoundsOnlyAskForTheChosenInput() {
        for d in TrainingGuide.drills {
            let e = GameEngine()
            e.startRun(mode: "training", enemyIndex: 0)
            e.drill = d.id
            e.round = 0
            e.buildRound()
            XCTAssertFalse(e.events.isEmpty, d.id)
            XCTAssertTrue(e.events.allSatisfy { $0.input == d.id }, d.id)
            XCTAssertTrue(e.modeLabel.contains("\(d.id.uppercased()) DRILL"), d.id)
        }
    }

    func testDrillIsIgnoredOutsideTrainingAndClearedOnNewRun() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 0)
        e.drill = "jump"
        e.round = 0
        e.buildRound()
        XCTAssertTrue(e.events.contains { $0.input != "jump" })
        e.startRun(mode: "training", enemyIndex: 0)
        XCTAssertNil(e.drill)
    }

    func testSettingsHintsStayShortAndAssistSaysEnemiesAreUnchanged() {
        XCTAssertEqual(SettingsHints.all.count, 7)
        for h in SettingsHints.all {
            XCTAssertFalse(h.isEmpty)
            XCTAssertLessThanOrEqual(h.count, 80, h)
        }
        XCTAssertTrue(SettingsHints.assist.contains("Enemies are not changed"))
    }

    func testPauseKickNamesTheMode() {
        let e = GameEngine()
        e.startRun(mode: "training", enemyIndex: 0)
        XCTAssertTrue(e.modeLabel.contains("TRAINING"))
    }

    func testMetronomePulsePeaksOnTheBeat() {
        XCTAssertEqual(TrainingGuide.metronomePulse(phase: 0.0), 1.0, accuracy: 1e-9)
        XCTAssertEqual(TrainingGuide.metronomePulse(phase: 0.5), 0.0, accuracy: 1e-9)
        XCTAssertGreaterThan(TrainingGuide.metronomePulse(phase: 0.1), TrainingGuide.metronomePulse(phase: 0.2))
        XCTAssertEqual(TrainingGuide.metronomePulse(phase: 1.0), 1.0, accuracy: 1e-9)
    }

    func testEngineBeatPhaseFollowsTheClock() {
        let e = GameEngine()
        e.bpm = 120.0   // one beat every 0.5 s
        e.t = 0.25
        XCTAssertEqual(e.beatPhase, 0.5, accuracy: 1e-9)
        e.t = 1.0
        XCTAssertEqual(e.beatPhase, 0.0, accuracy: 1e-9)
        e.t = -0.1
        XCTAssertEqual(e.beatPhase, 0.8, accuracy: 1e-9)
    }

    func testPauseAndTrainingViewsBuild() {
        _ = PauseView(engine: GameEngine(), onSelectSettings: {})
        _ = TrainingGuideView(onDone: {})
        _ = TrainingMetronomeView(clock: GameEngine())
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
