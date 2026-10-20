import Foundation

/// Wires a champion's `aggression` into the fight. An aggressive champion sometimes presses a second defend round
/// straight after the first, skipping your strike round, and you see a "No opening!" cue when it happens.
/// Calm champions (aggression 0.55 or less) never do. It only makes a champion more relentless; it never gives you more room.
enum AggressionPressure {
    static let startsAbove: Double = 0.55
    static let slope: Double = 0.4
    static let cap: Double = 0.18
    static let perPhase: Double = 0.04
    static let phaseCap: Double = 0.26
    /// No pressing in the opening rounds of a fight.
    static let firstRound: Int = 4

    /// Chance, after a defend round, that the next round is a defend round again.
    static func chance(aggression: Double, phasesActive: Int) -> Double {
        let base = min(cap, max(0.0, (aggression - startsAbove) * slope))
        guard base > 0.0 else { return 0.0 }
        return min(phaseCap, base + perPhase * Double(max(0, phasesActive)))
    }
}
