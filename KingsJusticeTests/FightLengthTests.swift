import XCTest
@testable import KingsJustice

/// Plays whole fights with an automatic, perfectly timed player and measures how long they take.
/// The design target for a standard fight is about 60 seconds.
@MainActor
final class FightLengthTests: XCTestCase {
    struct Outcome {
        let seconds: Double
        let won: Bool
        let finished: Bool
    }

    private func autoPlay(mode: String, enemyIndex: Int) -> Outcome {
        let e = GameEngine()
        e.settings.difficulty = "normal"
        e.startRun(mode: mode, enemyIndex: enemyIndex)
        let dt = 1.0 / 60.0
        var frames = 0
        let maxFrames = 60 * 400

        while !e.over && frames < maxFrames {
            e.tick(dt: dt)
            frames += 1
            guard e.started && !e.over else { continue }

            let due = e.events.filter { $0.state == "live" && abs($0.time - e.t) <= dt * 0.5 + 1e-6 }
            for ev in due {
                if e.roundType == .attack {
                    e.input(kind: "lane", lane: ev.lane)
                } else if ev.input == "grab" {
                    e.input(kind: "parry", lane: 0)
                    e.input(kind: "dodge", lane: 0)
                } else {
                    e.input(kind: ev.input, lane: 0)
                }
            }
        }
        let outcome = Outcome(seconds: e.t, won: e.won, finished: e.over)
        UIAudio.stopMusic(fade: false)
        return outcome
    }

    func testEveryChampionFightHasASaneLength() {
        var lines: [String] = []
        var failures: [String] = []
        for (i, champion) in GameData.roster.enumerated() {
            let r = autoPlay(mode: "duel", enemyIndex: i)
            let line = "FIGHTLEN champion=\(champion.name) seconds=\(Int(r.seconds.rounded())) won=\(r.won) finished=\(r.finished)"
            lines.append(line)
            print(line)
            if !r.finished { failures.append("\(champion.name) never ended") }
            else if r.seconds < 20 || r.seconds > 170 { failures.append("\(champion.name) lasted \(Int(r.seconds))s") }
        }
        XCTAssertTrue(failures.isEmpty, "Fight length out of range: \(failures.joined(separator: "; "))  [\(lines.joined(separator: " | "))]")
    }
}
