import Foundation

/// Lifetime numbers kept in the save: fights, wins, accuracy, best combo, S ranks and a record per champion.
enum LifetimeStats {
    /// Folds one finished fight into the save. The Training Yard never counts.
    /// Returns true when the fight beat an earlier best combo (the very first fight never reports a record).
    @discardableResult
    static func record(into save: inout SaveData, enemyId: String, won: Bool, maxCombo: Int,
                       perfects: Int, goods: Int, misses: Int, rank: String, training: Bool) -> Bool {
        guard !training else { return false }
        let hadCombo = save.bestCombo > 0
        save.fights += 1
        if won {
            save.wins += 1
            save.champWins[enemyId, default: 0] += 1
        } else {
            save.champLosses[enemyId, default: 0] += 1
        }
        save.perfectHits += perfects
        save.goodHits += goods
        save.missedHits += misses
        if rank == "S" { save.sRanks += 1 }
        let beatBest = maxCombo > save.bestCombo
        if beatBest { save.bestCombo = maxCombo }
        return beatBest && hadCombo
    }

    /// Whole-percent win rate, or nil before the first fight.
    static func winRatePercent(_ s: SaveData) -> Int? {
        guard s.fights > 0 else { return nil }
        return Int((Double(s.wins) / Double(s.fights) * 100.0).rounded())
    }

    /// Whole-percent timing accuracy (Perfect counts double, Miss zero, like the result screen), or nil with no notes yet.
    static func accuracyPercent(_ s: SaveData) -> Int? {
        let total = s.perfectHits + s.goodHits + s.missedHits
        guard total > 0 else { return nil }
        return Int((Double(s.perfectHits * 2 + s.goodHits) / Double(total * 2) * 100.0).rounded())
    }

    /// "3 won, 1 lost" for one champion, or nil if you have never faced them.
    static func championRecord(_ s: SaveData, id: String) -> String? {
        let w = s.champWins[id] ?? 0
        let l = s.champLosses[id] ?? 0
        guard w + l > 0 else { return nil }
        return "\(w) won, \(l) lost"
    }
}
