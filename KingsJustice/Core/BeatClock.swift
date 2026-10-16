import Foundation

/// A clock that counts beats continuously, so the tempo can drift during a fight (it speeds up as the champion weakens)
/// and every beat is still counted exactly once. Used by the optional Beat Sync mode.
enum BeatClock {
    /// The beat count after `dt` more seconds at `bpm`.
    static func advance(beatPos: Double, dt: Double, bpm: Double) -> Double {
        return beatPos + dt * bpm / 60.0
    }

    /// Seconds from now until the next whole beat that is at least `minGapBeats` away.
    static func secondsToBeat(beatPos: Double, bpm: Double, minGapBeats: Double = 0.0) -> Double {
        guard bpm > 0.0 else { return 0.0 }
        let target = ceil(beatPos + minGapBeats)
        return (target - beatPos) * (60.0 / bpm)
    }
}
