import Foundation

/// A per-arena musical identity: chord roots, a 4-bar melody and a drum feel.
/// Degrees index into the arena's scale; -1 in a melody row is a rest.
struct MusicTheme: Sendable {
    /// Scale-degree index of the chord root for each of the four bars.
    let chordDegrees: [Int]
    /// Four bars of sixteen steps.
    let melody: [[Int]]
    let kickSteps: Set<Int>
    let snareSteps: Set<Int>
    /// Hats play every N steps; 0 means no hats.
    let hatStride: Int
    /// Tom roll on the last beat of bar four.
    let tomFill: Bool
}

enum MusicThemes {
    /// Returns nil for unknown styles so the original generic pattern still plays.
    static func theme(for style: String) -> MusicTheme? {
        return all[style]
    }

    static let all: [String: MusicTheme] = [
        // Castle: a steady martial march with a heroic call.
        "castle": MusicTheme(
            chordDegrees: [0, 5, 3, 4],
            melody: [
                [4, -1, -1, -1, 2, -1, 4, -1, 5, -1, -1, -1, 4, -1, 2, -1],
                [5, -1, -1, -1, 4, -1, 2, -1, 0, -1, -1, -1, 2, -1, -1, -1],
                [3, -1, 5, -1, 3, -1, -1, -1, 2, -1, 3, -1, 4, -1, -1, -1],
                [4, -1, -1, 4, 5, -1, 6, -1, 4, -1, -1, -1, 2, -1, 0, -1]
            ],
            kickSteps: [0, 8], snareSteps: [4, 12], hatStride: 2, tomFill: true
        ),
        // Burning village: frantic running arpeggios over a falling bass line.
        "village": MusicTheme(
            chordDegrees: [0, 6, 5, 4],
            melody: [
                [0, -1, 2, -1, 4, -1, 2, -1, 0, -1, 2, -1, 4, -1, 6, -1],
                [6, -1, 1, -1, 3, -1, 1, -1, 6, -1, 1, -1, 3, -1, 5, -1],
                [5, -1, 0, -1, 2, -1, 0, -1, 5, -1, 0, -1, 2, -1, 4, -1],
                [4, -1, 6, -1, 1, -1, 6, -1, 4, 2, 4, 6, 4, -1, -1, -1]
            ],
            kickSteps: [0, 3, 8, 10], snareSteps: [4, 12], hatStride: 1, tomFill: true
        ),
        // Frozen pass: sparse, icy, long held notes.
        "pass": MusicTheme(
            chordDegrees: [0, 2, 5, 6],
            melody: [
                [4, -1, -1, -1, -1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, -1],
                [4, -1, -1, -1, -1, -1, -1, -1, 6, -1, -1, -1, 4, -1, -1, -1],
                [5, -1, -1, -1, -1, -1, -1, -1, 4, -1, -1, -1, -1, -1, -1, -1],
                [6, -1, -1, -1, 4, -1, -1, -1, 2, -1, -1, -1, 0, -1, -1, -1]
            ],
            kickSteps: [0, 8], snareSteps: [12], hatStride: 4, tomFill: false
        ),
        // Swamp: slithering half-step crawl, syncopated and heavy.
        "swamp": MusicTheme(
            chordDegrees: [0, 1, 0, 6],
            melody: [
                [0, -1, -1, 1, -1, -1, 0, -1, -1, 1, -1, -1, 2, -1, 1, -1],
                [1, -1, -1, 3, -1, -1, 1, -1, -1, 3, -1, -1, 4, -1, 3, -1],
                [0, -1, -1, 1, -1, -1, 0, -1, -1, 1, -1, -1, 2, -1, 1, -1],
                [6, -1, -1, 4, -1, -1, 3, -1, -1, 1, -1, -1, 0, -1, -1, -1]
            ],
            kickSteps: [0, 7, 10], snareSteps: [12], hatStride: 4, tomFill: true
        ),
        // Execution cliff: relentless dread, tritone stabs over a four-on-the-floor pulse.
        "cliff": MusicTheme(
            chordDegrees: [0, 1, 4, 1],
            melody: [
                [4, -1, -1, 4, -1, -1, 4, -1, -1, -1, -1, -1, 4, -1, -1, -1],
                [5, -1, -1, 5, -1, -1, 5, -1, -1, -1, -1, -1, 1, -1, -1, -1],
                [6, -1, -1, 6, -1, -1, 6, -1, -1, -1, -1, -1, 4, -1, 4, -1],
                [4, -1, 5, -1, 4, -1, 1, -1, 0, -1, -1, -1, 0, -1, -1, -1]
            ],
            kickSteps: [0, 4, 8, 12], snareSteps: [6, 14], hatStride: 2, tomFill: true
        ),
        // Cathedral: slow sacred suspensions, almost no percussion.
        "cathedral": MusicTheme(
            chordDegrees: [0, 5, 2, 6],
            melody: [
                [4, -1, -1, -1, -1, -1, -1, -1, 2, -1, -1, -1, -1, -1, -1, -1],
                [5, -1, -1, -1, -1, -1, -1, -1, 4, -1, -1, -1, -1, -1, -1, -1],
                [4, -1, -1, -1, -1, -1, -1, -1, 6, -1, -1, -1, -1, -1, -1, -1],
                [6, -1, -1, -1, 4, -1, -1, -1, 2, -1, -1, -1, 0, -1, -1, -1]
            ],
            kickSteps: [0], snareSteps: [], hatStride: 0, tomFill: false
        )
    ]
}
