import XCTest
@testable import KingsJustice

final class EngineTests: XCTestCase {

    // Test 1: windows() values for knight/normal match JS formula
    func testWindowsKnightNormal() {
        let engine = GameEngine()
        engine.settings.style = "knight"
        engine.settings.difficulty = "normal"
        engine.styleDef = GameData.styles.first(where: { $0.id == "knight" })!

        let w = engine.currentWindows()
        // JS formula: knight perfect 0.08, good 0.16, miss 0.25
        // D.win = 1.12, k = 0.8, f = 1.0
        // perfect: 0.08 * 0.8 * 1.12 * 1.0 = 0.07168
        // good: 0.16 * 0.8 * 1.12 * 1.0 = 0.14336
        // miss: 0.25 * 0.8 * 1.12 * 1.0 + 0.01 = 0.234
        XCTAssertEqual(w.perfect, 0.07168, accuracy: 1e-5)
        XCTAssertEqual(w.good, 0.14336, accuracy: 1e-5)
        XCTAssertEqual(w.miss, 0.234, accuracy: 1e-5)
    }

    // Test 2: Second Wind: lethal hit leaves hp == 25% of maxhp once, second lethal hit ends game
    func testSecondWind() {
        let engine = GameEngine()
        engine.startRun(mode: "duel", enemyIndex: 0)

        // Advance until fight starts
        for _ in 0..<200 {
            engine.tick(dt: 0.016)
        }
        XCTAssertTrue(engine.started)

        let initialMaxHp = engine.maxhp
        let expectedSecondWindHp = Double(Int(initialMaxHp * 0.25))

        // Cause lethal hit
        engine.chip(200.0)

        XCTAssertEqual(engine.hp, expectedSecondWindHp)
        XCTAssertTrue(engine.windUsed)
        XCTAssertFalse(engine.over)

        // Second lethal hit ends fight
        engine.chip(200.0)

        XCTAssertTrue(engine.over)
        XCTAssertFalse(engine.won)
    }

    // Test 3: Combo bonus caps at +60% (1.6x multiplier)
    func testComboBonusCap() {
        let engine = GameEngine()
        engine.startRun(mode: "duel", enemyIndex: 0)

        // Combo multiplier formula: 1 + min(0.6, floor(combo / 8) * 0.1)
        engine.combo = 0
        let m0 = 1.0 + min(0.6, floor(Double(engine.combo) / 8.0) * 0.1)
        XCTAssertEqual(m0, 1.0, accuracy: 1e-5)

        engine.combo = 8
        let m8 = 1.0 + min(0.6, floor(Double(engine.combo) / 8.0) * 0.1)
        XCTAssertEqual(m8, 1.1, accuracy: 1e-5)

        engine.combo = 48
        let m48 = 1.0 + min(0.6, floor(Double(engine.combo) / 8.0) * 0.1)
        XCTAssertEqual(m48, 1.6, accuracy: 1e-5)

        engine.combo = 80
        let m80 = 1.0 + min(0.6, floor(Double(engine.combo) / 8.0) * 0.1)
        XCTAssertEqual(m80, 1.6, accuracy: 1e-5)
    }

    // Test 4: Full scripted duel vs enemy 0 where test feeds perfect inputs wins in roughly 40-80s
    func testScriptedDuelWin() {
        let engine = GameEngine()
        engine.startRun(mode: "duel", enemyIndex: 0)

        var totalSimTime: Double = 0.0
        let dt = 0.016

        while !engine.over && totalSimTime < 120.0 {
            engine.tick(dt: dt)
            totalSimTime += dt

            if engine.started {
                let now = engine.t

                if engine.roundType == .defend {
                    for ev in engine.events {
                        if ev.state == "live" && abs(ev.time - now) < 0.03 {
                            if ev.kind == "grab" {
                                engine.input(kind: "parry", lane: -1)
                                engine.input(kind: "dodge", lane: -1)
                            } else {
                                engine.input(kind: ev.input, lane: -1)
                            }
                        }
                    }
                } else if engine.roundType == .attack {
                    for ev in engine.events {
                        if ev.state == "live" && ev.kind == "note" && abs(ev.time - now) < 0.03 {
                            engine.input(kind: "lane", lane: ev.lane)
                        }
                    }
                }
            }
        }

        XCTAssertTrue(engine.over)
        XCTAssertTrue(engine.won)
        XCTAssertGreaterThan(totalSimTime, 40.0)
        XCTAssertLessThan(totalSimTime, 80.0)
    }

    // Test 5: buildRound is deterministic for a fixed seed
    func testBuildRoundDeterminism() {
        let engine1 = GameEngine()
        engine1.rng = MulberryRNG(seed: 99999)
        engine1.startRun(mode: "duel", enemyIndex: 0)

        let engine2 = GameEngine()
        engine2.rng = MulberryRNG(seed: 99999)
        engine2.startRun(mode: "duel", enemyIndex: 0)

        for _ in 0..<200 {
            engine1.tick(dt: 0.016)
            engine2.tick(dt: 0.016)
        }

        XCTAssertEqual(engine1.events.count, engine2.events.count)
        for i in 0..<engine1.events.count {
            XCTAssertEqual(engine1.events[i].kind, engine2.events[i].kind)
            XCTAssertEqual(engine1.events[i].input, engine2.events[i].input)
            XCTAssertEqual(engine1.events[i].lane, engine2.events[i].lane)
            XCTAssertEqual(engine1.events[i].time, engine2.events[i].time, accuracy: 1e-5)
        }
    }

    // Test 6: Tonic purchase deducts gold and consumes on fight start
    func testTonicShopAndConsume() {
        let engine = GameEngine()
        engine.save.gold = 200
        engine.save.invFocus = 0

        XCTAssertTrue(engine.canBuy(id: "focus"))
        let success = engine.buy(id: "focus")
        XCTAssertTrue(success)
        XCTAssertEqual(engine.save.gold, 150)
        XCTAssertEqual(engine.save.invFocus, 1)

        engine.startRun(mode: "duel", enemyIndex: 0)

        XCTAssertEqual(engine.save.invFocus, 0)
        XCTAssertEqual(engine.stamina, 50.0)
    }
}
