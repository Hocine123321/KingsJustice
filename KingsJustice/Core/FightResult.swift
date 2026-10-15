import Foundation

/// Letter rank for a finished fight.
enum FightRank: String, Sendable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    /// Accuracy is weighted: Perfect = 2, Good = 1, Miss = 0.
    static func grade(perfects: Int, goods: Int, misses: Int, hpFraction: Double, won: Bool) -> FightRank {
        guard won else { return .d }
        let total = perfects + goods + misses
        guard total > 0 else { return .c }
        let accuracy = Double(perfects * 2 + goods) / Double(total * 2)
        if accuracy >= 0.88 && hpFraction >= 0.5 { return .s }
        if accuracy >= 0.75 { return .a }
        if accuracy >= 0.58 { return .b }
        return .c
    }
}

/// Everything the result screen needs, captured once when the fight ends.
struct FightResult: Equatable, Sendable {
    var won: Bool = false
    var score: Int = 0
    var maxCombo: Int = 0
    var perfects: Int = 0
    var goods: Int = 0
    var misses: Int = 0
    var gold: Int = 0
    var hpFraction: Double = 0.0
    var duration: Double = 0.0
    var rankLetter: String = "C"
    var newBest: Bool = false
    var flawless: Bool = false
    /// The last champion fell: there is no "next champion" to offer.
    var finalVictory: Bool = false
    var bestLabel: String = ""
    var tip: String = ""
    var shareText: String = ""
    /// Fighting styles that unlocked because of this fight (display names).
    var unlocks: [String] = []
    /// This fight beat the player's earlier best combo.
    var comboRecord: Bool = false

    /// Timing accuracy as a whole percent: Perfect counts double, Miss counts zero.
    var accuracyPercent: Int {
        let total = perfects + goods + misses
        guard total > 0 else { return 0 }
        return Int((Double(perfects * 2 + goods) / Double(total * 2) * 100.0).rounded())
    }

    /// Styles that this fight's gold total newly unlocks. Thresholds match the engine: 200 gold for the
    /// Duelist, 500 for the Berserker.
    static func newUnlocks(gold: Int, hasDuelist: Bool, hasBerserker: Bool) -> [String] {
        var out: [String] = []
        if gold >= 200 && !hasDuelist { out.append("Duelist") }
        if gold >= 500 && !hasBerserker { out.append("Berserker") }
        return out
    }

    /// A short, brag-worthy line for the Share button.
    static func shareLine(won: Bool, enemy: String, rank: String, score: Int, combo: Int, mode: String, wave: Int, title: String? = nil) -> String {
        let line = baseShareLine(won: won, enemy: enemy, rank: rank, score: score, combo: combo, mode: mode, wave: wave)
        guard let t = title, !t.isEmpty else { return line }
        return line + " - " + t
    }

    private static func baseShareLine(won: Bool, enemy: String, rank: String, score: Int, combo: Int, mode: String, wave: Int) -> String {
        if mode == "survival" {
            return "I reached wave \(wave) in Survival in The King's Justice: rank \(rank), \(score) points, best combo \(combo)."
        }
        if won {
            return "I defeated \(enemy) in The King's Justice: rank \(rank), \(score) points, best combo \(combo)."
        }
        return "\(enemy) bested me in The King's Justice. Rematch incoming."
    }

    /// One tip tied to what actually went wrong, shown after a defeat.
    static func defeatTip(perfects: Int, goods: Int, misses: Int) -> String {
        let hits = perfects + goods
        if misses > hits {
            return "Watch the windup. Strike or defend as the ring closes, not before."
        }
        if perfects == 0 {
            return "Aim for the centre of the ring. Perfect hits and parries deal far more damage."
        }
        return "Spend Focus when a hard attack is coming. It widens your timing windows."
    }
}
