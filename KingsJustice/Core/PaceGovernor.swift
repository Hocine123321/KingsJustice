import Foundation

/// Fight pacing for the player's strikes. It only changes how hard YOU hit: enemy behaviour, enemy damage and timing windows are untouched.
enum PaceGovernor {
    /// How much of a champion's health each strike removes, by roster position. Later champions have more health and a harder tempo,
    /// so each strike counts for less. The first value is above 1.0 because the Hollow Conscript's slow tempo made it the longest fight.
    static let lenTable: [Double] = [1.12, 0.9, 0.8, 0.7, 0.6, 0.52, 0.42]

    /// After `startsAt` seconds a slow fight gets a "second wind": your strikes grow stronger, a little more each second, up to +50%.
    static let startsAt: Double = 75.0
    static let rampSeconds: Double = 60.0
    static let maxBoost: Double = 0.5

    /// 1.0 until `startsAt`, then rising evenly to 1.5 over `rampSeconds`.
    static func boost(seconds: Double) -> Double {
        guard seconds > startsAt else { return 1.0 }
        return 1.0 + min(maxBoost, (seconds - startsAt) / rampSeconds * maxBoost)
    }
}
