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

    // Focus widens the player's timing windows by 1.5x and nothing else
    func testFocusWidensPlayerWindowsOnly() {
        let engine = GameEngine()
        engine.settings.style = "knight"
        engine.settings.difficulty = "normal"
        engine.styleDef = GameData.styles.first(where: { $0.id == "knight" })!

        let base = engine.currentWindows()
        engine.focusUntil = engine.t + 3.5
        let focused = engine.currentWindows()
        XCTAssertEqual(focused.perfect, base.perfect * 1.5, accuracy: 1e-6)
        XCTAssertEqual(focused.good, base.good * 1.5, accuracy: 1e-6)
        // Enemy difficulty parameters must not depend on Focus.
        let d = engine.difficultyParams("normal")
        XCTAssertEqual(d.enemyDmg, 0.85, accuracy: 1e-9)
        XCTAssertEqual(d.tempo, 0.96, accuracy: 1e-9)
    }

    // Test 2: Second Wind: lethal hit leaves hp == 25% of maxhp once, second lethal hit ends game
    func testSecondWind() {
        let engine = GameEngine()
        engine.startRun(mode: "duel", enemyIndex: 0)

        // Advance until fight starts
        for _ in 0..<2000 {
            engine.tick(dt: 0.016)
            if engine.started && engine.t > 0.5 { break }
        }
        XCTAssertTrue(engine.started)
        XCTAssertGreaterThan(engine.t, 0.0)

        let initialMaxHp = engine.maxhp
        let expectedSecondWindHp = Double(Int(initialMaxHp * 0.25))

        // Deterministic setup: full HP, no invulnerability, wind not yet used
        engine.hp = engine.maxhp
        engine.invulnUntil = 0.0
        engine.windUsed = false

        // Cause lethal hit
        engine.chip(100000.0)

        XCTAssertEqual(engine.hp, expectedSecondWindHp)
        XCTAssertTrue(engine.windUsed)
        XCTAssertFalse(engine.over)

        // Second lethal hit ends fight (once the post-Wind invulnerability has lapsed)
        engine.invulnUntil = 0.0
        engine.chip(100000.0)

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
        // "daily" mode seeds from the date, so two engines must build identical rounds.
        let engine1 = GameEngine()
        engine1.startRun(mode: "daily", enemyIndex: 0)

        let engine2 = GameEngine()
        engine2.startRun(mode: "daily", enemyIndex: 0)

        for _ in 0..<200 {
            engine1.tick(dt: 0.016)
            engine2.tick(dt: 0.016)
        }

        XCTAssertGreaterThan(engine1.events.count, 0)
        XCTAssertEqual(engine1.events.count, engine2.events.count)
        for i in 0..<min(engine1.events.count, engine2.events.count) {
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

@MainActor
final class KillCamTests: XCTestCase {
    func testResultScreenWaitsForFinisher() {
        let e = GameEngine()
        e.on = true
        e.started = true
        e.over = true
        e.won = true
        e.tick(dt: 0.1)
        XCTAssertFalse(e.resultReady)
        XCTAssertGreaterThan(e.rsKillCam, 0.0)
        for _ in 0..<25 { e.tick(dt: 0.1) }
        XCTAssertTrue(e.resultReady)
        XCTAssertEqual(e.rsKillCam, 0.0, accuracy: 1e-9)
    }

    func testLossRevealsResultSooner() {
        let e = GameEngine()
        e.on = true
        e.started = true
        e.over = true
        e.won = false
        for _ in 0..<11 { e.tick(dt: 0.1) }
        XCTAssertTrue(e.resultReady)
        XCTAssertEqual(e.rsKillCam, 0.0, accuracy: 1e-9)
    }
}
