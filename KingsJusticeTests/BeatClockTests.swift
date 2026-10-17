import XCTest
@testable import KingsJustice

final class BeatClockTests: XCTestCase {
    func testBeatsAreCountedContinuouslyAsTheTempoChanges() {
        var pos = -2.5
        // 10 seconds at 90 BPM, then 10 seconds at 100 BPM.
        for _ in 0..<600 { pos = BeatClock.advance(beatPos: pos, dt: 1.0 / 60.0, bpm: 90.0) }
        for _ in 0..<600 { pos = BeatClock.advance(beatPos: pos, dt: 1.0 / 60.0, bpm: 100.0) }
        XCTAssertEqual(pos, -2.5 + 15.0 + (100.0 / 60.0) * 10.0, accuracy: 1e-6)
    }

    func testSecondsToBeatLandsOnAWholeBeatAndNeverMovesBackwards() {
        for bpm in [76.0, 90.0, 112.0] {
            var p = -2.5
            while p < 20.0 {
                let d = BeatClock.secondsToBeat(beatPos: p, bpm: bpm, minGapBeats: 0.15 / (60.0 / bpm))
                XCTAssertGreaterThanOrEqual(d, 0.0)
                XCTAssertLessThanOrEqual(d, (60.0 / bpm) + 0.15 + 1e-9, "never waits more than one beat plus the 0.15 s gap")
                let landed = p + d * bpm / 60.0
                XCTAssertEqual(landed, landed.rounded(), accuracy: 1e-9, "lands on a whole beat at \(bpm) BPM, pos \(p)")
                p += 0.137
            }
        }
    }

    func testTheMinimumGapIsRespected() {
        let gap = 0.15 / (60.0 / 90.0)
        for i in 0..<200 {
            let p = Double(i) * 0.0731
            let d = BeatClock.secondsToBeat(beatPos: p, bpm: 90.0, minGapBeats: gap)
            XCTAssertGreaterThanOrEqual(d * 90.0 / 60.0, gap - 1e-9, "pos \(p)")
        }
    }

    func testBadTempoIsHarmless() {
        XCTAssertEqual(BeatClock.secondsToBeat(beatPos: 1.3, bpm: 0.0), 0.0)
        XCTAssertEqual(BeatClock.secondsToBeat(beatPos: 1.3, bpm: -5.0), 0.0)
    }

    func testBeatSyncIsOffByDefaultAndOldSettingsLoadWithItOff() throws {
        XCTAssertFalse(GameSettings().beatSync)
        let old = try JSONDecoder().decode(GameSettings.self, from: Data("{\"music\": 0.5}".utf8))
        XCTAssertFalse(old.beatSync)
        var s = GameSettings()
        s.beatSync = true
        let back = try JSONDecoder().decode(GameSettings.self, from: try JSONEncoder().encode(s))
        XCTAssertTrue(back.beatSync)
    }

    func testEngineCountsBeatsFromTheStartOfTheFight() {
        let e = GameEngine()
        e.settings.beatSync = true
        e.startRun(mode: "duel", enemyIndex: 0)
        e.on = true
        var frames = 0
        while !e.started && frames < 600 { e.tick(dt: 1.0 / 60.0); frames += 1 }
        XCTAssertTrue(e.started)
        XCTAssertEqual(e.beatPos, -2.5, accuracy: 0.2, "the lead-in starts 2.5 beats before beat zero")
        let before = e.beatPos
        for _ in 0..<120 { e.tick(dt: 1.0 / 60.0) }
        XCTAssertGreaterThan(e.beatPos, before + 1.0, "two seconds at about 80 BPM is about 2.7 beats")
        UIAudio.stopMusic(fade: false)
    }

    func testWithBeatSyncOnEveryRoundStartsOnAWholeBeat() {
        let e = GameEngine()
        e.settings.beatSync = true
        e.startRun(mode: "duel", enemyIndex: 0)
        e.on = true
        var frames = 0
        while !e.started && frames < 600 { e.tick(dt: 1.0 / 60.0); frames += 1 }
        for _ in 0..<(60 * 20) { e.tick(dt: 1.0 / 60.0) }
        e.round = 0
        e.buildRound()
        let B = 60.0 / e.bpm
        let beatsToStart = e.beatPos + (e.roundBase - e.t) / B
        XCTAssertEqual(beatsToStart, beatsToStart.rounded(), accuracy: 1e-6, "round starts \(beatsToStart) beats in")
        XCTAssertGreaterThan(e.roundBase, e.t, "the round starts in the future")
        UIAudio.stopMusic(fade: false)
    }
}
