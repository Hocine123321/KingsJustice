import XCTest
@testable import KingsJustice

final class GuidedPracticeTests: XCTestCase {
    func testOnlyTheCurrentInputCountsAndFourCleanAnswersFinishAStep() {
        var g = GuidedPractice()
        XCTAssertEqual(g.currentDrill, "parry")
        XCTAssertEqual(g.register(input: "duck"), .ignored)
        XCTAssertEqual(g.count, 0)
        XCTAssertEqual(g.register(input: "parry"), .counted)
        XCTAssertEqual(g.register(input: "parry"), .counted)
        XCTAssertEqual(g.register(input: "parry"), .counted)
        XCTAssertEqual(g.register(input: "parry"), .stepDone)
        XCTAssertEqual(g.currentDrill, "duck")
        XCTAssertEqual(g.count, 0)
    }

    func testWalkingEveryStepFinishesExactlyOnce() {
        var g = GuidedPractice()
        var outcomes: [GuidedPractice.Outcome] = []
        for step in GuidedPractice.steps {
            for _ in 0..<GuidedPractice.required { outcomes.append(g.register(input: step)) }
        }
        XCTAssertEqual(outcomes.filter { $0 == .stepDone }.count, GuidedPractice.steps.count - 1)
        XCTAssertEqual(outcomes.filter { $0 == .allDone }.count, 1)
        XCTAssertEqual(outcomes.last, .allDone)
        XCTAssertTrue(g.finished)
        XCTAssertNil(g.currentDrill)
        XCTAssertEqual(g.register(input: "parry"), .ignored)
    }

    func testEveryStepIsARealDrill() {
        let drillIds = TrainingGuide.drills.map { $0.id }
        for step in GuidedPractice.steps { XCTAssertTrue(drillIds.contains(step), step) }
    }

    func testProgressTextShowsTheStepAndCount() {
        var g = GuidedPractice()
        _ = g.register(input: "parry")
        _ = g.register(input: "parry")
        XCTAssertEqual(g.progressText, "PARRY 2/4 (1/5)")
    }

    func testEngineAdvancesTheDrillAndFinishesCleanly() {
        let e = GameEngine()
        e.startRun(mode: "training", enemyIndex: 0)
        e.startGuidedPractice()
        XCTAssertTrue(e.guidedActive)
        XCTAssertEqual(e.drill, "parry")
        e.registerGuidedSuccess(input: "parry")
        e.registerGuidedSuccess(input: "parry")
        XCTAssertTrue(e.modeLabel.contains("TRAINING"))
        XCTAssertTrue(e.modeLabel.contains("PARRY 2/4"))
        e.registerGuidedSuccess(input: "parry")
        e.registerGuidedSuccess(input: "parry")
        XCTAssertEqual(e.drill, "duck")
        for step in GuidedPractice.steps.dropFirst() {
            for _ in 0..<GuidedPractice.required { e.registerGuidedSuccess(input: step) }
        }
        XCTAssertNil(e.drill)
        XCTAssertFalse(e.guidedActive)
    }

    func testGuidedPracticeIsTrainingOnlyAndStopsOnANewRunOrACancel() {
        let e = GameEngine()
        e.startRun(mode: "duel", enemyIndex: 0)
        e.startGuidedPractice()
        XCTAssertFalse(e.guidedActive)

        e.startRun(mode: "training", enemyIndex: 0)
        e.startGuidedPractice()
        e.cancelGuidedPractice()
        XCTAssertFalse(e.guidedActive)
        e.startGuidedPractice()
        e.startRun(mode: "training", enemyIndex: 0)
        XCTAssertFalse(e.guidedActive)
    }
}
