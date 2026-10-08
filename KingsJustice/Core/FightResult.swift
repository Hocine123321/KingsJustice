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
    var bestLabel: String = ""
    var tip: String = ""

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
