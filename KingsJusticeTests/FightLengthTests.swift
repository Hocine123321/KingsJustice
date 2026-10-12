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
        e.on = true
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

    /// A believable human: most hits Perfect or Good, about one in ten missed.
    private func typicalPlay(mode: String, enemyIndex: Int, seed: UInt64) -> Outcome {
        let e = GameEngine()
        e.settings.difficulty = "normal"
        e.startRun(mode: mode, enemyIndex: enemyIndex)
        e.on = true
        var rng = seed
        func roll() -> Double {
            rng = rng &* 6364136223846793005 &+ 1442695040888963407
            return Double((rng >> 33) % 10_000) / 10_000.0
        }

        let dt = 1.0 / 60.0
        var frames = 0
        var plan: [Int: Double] = [:]      // event id -> time to press (absent = deliberately missed)
        var decided = Set<Int>()
        var pressed = Set<Int>()
        var lastRoundKey = -2

        while !e.over && frames < 60 * 400 {
            e.tick(dt: dt)
            frames += 1
            guard e.started && !e.over else { continue }

            // Event ids restart every round, so forget our bookkeeping whenever a new round's events appear.
            let roundKey = e.events.first.map { Int($0.time * 1000.0) } ?? -1
            if roundKey != lastRoundKey {
                lastRoundKey = roundKey
                plan.removeAll()
                decided.removeAll()
                pressed.removeAll()
            }

            let w = e.currentWindows()
            for ev in e.events where ev.state == "live" && !decided.contains(ev.id) {
                decided.insert(ev.id)
                let r = roll()
                if r < 0.10 {
                    continue                                   // miss
                } else if r < 0.55 {
                    plan[ev.id] = ev.time + (roll() - 0.5) * w.perfect * 0.8       // perfect
                } else {
                    let sign = roll() < 0.5 ? -1.0 : 1.0
                    plan[ev.id] = ev.time + sign * (w.perfect * 1.3 + roll() * (w.good - w.perfect * 1.3) * 0.8)   // good
                }
            }

            let due = e.events.filter { ev in
                guard ev.state == "live", !pressed.contains(ev.id), let when = plan[ev.id] else { return false }
                return e.t >= when
            }
            for ev in due {
                pressed.insert(ev.id)
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

    func testTypicalPlayerFightLengths() {
        var failures: [String] = []
        var averages: [(String, Double)] = []
        for (i, champion) in GameData.roster.enumerated() {
            var secs: [Double] = []
            var wins = 0
            for k in 0..<3 {
                let r = typicalPlay(mode: "duel", enemyIndex: i, seed: UInt64(1000 + i * 17 + k))
                secs.append(r.seconds)
                if r.won { wins += 1 }
                if !r.finished { failures.append("\(champion.name) never ended") }
            }
            let avg = secs.reduce(0, +) / Double(secs.count)
            averages.append((champion.name, avg))
            print("FIGHTLEN typical champion=\(champion.name) avg=\(Int(avg.rounded()))s runs=\(secs.map { Int($0.rounded()) }) wins=\(wins)/3")
        }
        // Design target: a standard fight lasts about 60 seconds for a typical player.
        for (name, avg) in averages where avg < 35 || avg > 90 {
            failures.append("\(name) averages \(Int(avg.rounded()))s for a typical player (target about 60s)")
        }
        XCTAssertTrue(failures.isEmpty, failures.joined(separator: "; "))
    }
}
