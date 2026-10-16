import Foundation

/// Three seeded champions back to back on one health bar, with one twist, new every Monday (UTC).
enum WeeklyGauntlet {
    static let length = 3

    private static func formatter() -> DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }

    /// The Monday of the week that contains `date` (both yyyy-MM-dd, UTC), or nil if `date` is not a date.
    static func weekKey(for date: String) -> String? {
        let f = formatter()
        guard let d = f.date(from: date) else { return nil }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? cal.timeZone
        let weekday = cal.component(.weekday, from: d)   // 1 is Sunday, 7 is Saturday
        let daysBack = (weekday + 5) % 7                  // Monday 0 ... Sunday 6
        guard let monday = cal.date(byAdding: .day, value: -daysBack, to: d) else { return nil }
        return f.string(from: monday)
    }

    private static func hash(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for scalar in s.unicodeScalars {
            h ^= scalar.value
            h = h &* 16777619
        }
        return h
    }

    /// Three different roster positions for the week, easiest first. The final champion (the King) never appears.
    static func rosterIndices(week: String, rosterCount: Int) -> [Int] {
        let pool = max(0, rosterCount - 1)
        guard pool > length else { return Array(0..<pool) }
        var state = hash(week + "#gauntlet")
        var candidates = Array(0..<pool)
        var chosen: [Int] = []
        for _ in 0..<length {
            state = state &* 1664525 &+ 1013904223
            let pick = Int(state >> 8) % candidates.count
            chosen.append(candidates.remove(at: pick))
        }
        return chosen.sorted()
    }

    /// The week's twist, picked from the same list as the Daily Challenge.
    static func modifier(week: String) -> DailyModifier {
        return DailyModifiers.forDate(week + "#weekly")
    }

    /// The champion for one slot of the gauntlet, with the twist applied to health and tempo like the Daily Challenge does.
    static func enemy(slot: Int, week: String) -> EnemyDef {
        let idxs = rosterIndices(week: week, rosterCount: GameData.roster.count)
        let base = GameData.roster[idxs[max(0, min(slot, idxs.count - 1))]]
        let id = modifier(week: week).id
        let hpMul: Double = (id == "marathon") ? 1.4 : 1.0
        let bpmAdd: Double = (id == "tempo") ? 10.0 : 0.0
        return EnemyDef(
            id: base.id,
            name: base.name,
            title: base.title,
            hp: floor(base.hp * hpMul),
            arena: base.arena,
            bpm: base.bpm + bpmAdd,
            look: base.look,
            intro: base.intro,
            ai: base.ai,
            defendPatterns: base.defendPatterns,
            attackPatterns: base.attackPatterns,
            phases: base.phases,
            reward: base.reward
        )
    }

    /// Applies the twist's score multiplier once, when the run ends, and keeps the week's best.
    /// Returns the final score and whether it is a new best for the week. Does nothing while the run goes on.
    static func finishRun(save: inout SaveData, week: String, score: Int, won: Bool, finalVictory: Bool) -> (score: Int, newBest: Bool) {
        let runEnded = !won || finalVictory
        guard runEnded else { return (score, false) }
        let scaled = Int((Double(score) * modifier(week: week).scoreMul).rounded())
        let previous = save.bestWeekly[week] ?? 0
        guard scaled > previous else { return (scaled, false) }
        save.bestWeekly[week] = scaled
        return (scaled, true)
    }
}

extension GameEngine {
    var currentWeekKey: String {
        let today = todayDateString()
        return WeeklyGauntlet.weekKey(for: today) ?? today
    }

    /// Index into the difficulty tables: the champion's place in the roster for fixed-order modes.
    var rosterPosition: Int {
        guard mode == "weekly" else { return enemyIdx }
        let idxs = WeeklyGauntlet.rosterIndices(week: currentWeekKey, rosterCount: GameData.roster.count)
        return idxs.isEmpty ? 0 : idxs[max(0, min(enemyIdx, idxs.count - 1))]
    }
}
