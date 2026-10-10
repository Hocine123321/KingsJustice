import Foundation

/// The twist applied to the Daily Challenge. Everyone gets the same one on the same day.
/// Modifiers only change the player's risk and the champion's size, never enemy AI.
struct DailyModifier: Equatable, Sendable {
    let id: String
    let name: String
    let desc: String
    let scoreMul: Double
}

enum DailyModifiers {
    static let all: [DailyModifier] = [
        DailyModifier(id: "steady", name: "Steady Hands", desc: "No twist today.", scoreMul: 1.0),
        DailyModifier(id: "brittle", name: "Brittle", desc: "You take 30% more damage. Score x1.3.", scoreMul: 1.3),
        DailyModifier(id: "marathon", name: "Marathon", desc: "The champion has 40% more health. Score x1.25.", scoreMul: 1.25),
        DailyModifier(id: "tempo", name: "Quickstep", desc: "The tempo is 10 BPM faster. Score x1.25.", scoreMul: 1.25),
        DailyModifier(id: "onechance", name: "One Chance", desc: "No Second Wind. Score x1.2.", scoreMul: 1.2)
    ]

    static var steady: DailyModifier { return all[0] }

    private static func hash(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for scalar in s.unicodeScalars {
            h ^= scalar.value
            h = h &* 16777619
        }
        return h
    }

    /// Same date string always gives the same modifier.
    static func forDate(_ date: String) -> DailyModifier {
        return all[Int(hash(date + "#mod") % UInt32(all.count))]
    }

    private static func formatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }

    /// The calendar day before a yyyy-MM-dd string, or nil if it cannot be parsed.
    static func previousDay(of date: String) -> String? {
        let f = formatter()
        guard let d = f.date(from: date) else { return nil }
        guard let prev = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: d) else { return nil }
        return f.string(from: prev)
    }

    /// New streak length after winning the daily on `today`. Already counted today: unchanged.
    static func nextStreak(current: Int, lastWin: String, today: String) -> Int {
        if lastWin == today { return max(current, 1) }
        if let yesterday = previousDay(of: today), lastWin == yesterday { return current + 1 }
        return 1
    }
}
