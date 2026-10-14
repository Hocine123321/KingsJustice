import Foundation

struct Achievement: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let desc: String
}

/// Achievements are derived from the save, so they need no extra stored state and old saves earn them too.
enum Achievements {
    static let all: [Achievement] = [
        Achievement(id: "first_blood", name: "First Blood", desc: "Defeat any champion."),
        Achievement(id: "slayer", name: "Kingslayer", desc: "Defeat every champion in Trial by Combat."),
        Achievement(id: "untouchable", name: "Untouchable", desc: "Win a fight without taking a hit."),
        Achievement(id: "ghost", name: "Ghost", desc: "Win 10 fights without taking a hit."),
        Achievement(id: "survivor5", name: "Survivor", desc: "Reach wave 5 in Survival."),
        Achievement(id: "survivor10", name: "Unbroken", desc: "Reach wave 10 in Survival."),
        Achievement(id: "devotee", name: "Devotee", desc: "Win the Daily Challenge 3 days in a row."),
        Achievement(id: "loyal", name: "Loyal Subject", desc: "Win the Daily Challenge 7 days in a row."),
        Achievement(id: "gauntlet", name: "Gauntlet", desc: "Defeat every champion in a single Boss Rush."),
        Achievement(id: "rich", name: "Coin of the Realm", desc: "Hold 1,000 gold.")
    ]

    static func unlocked(save: SaveData, rosterIds: [String]) -> Set<String> {
        var out = Set<String>()
        if save.kills >= 1 { out.insert("first_blood") }
        if !rosterIds.isEmpty && rosterIds.allSatisfy({ save.beat.contains($0) }) { out.insert("slayer") }
        if save.flawless >= 1 { out.insert("untouchable") }
        if save.flawless >= 10 { out.insert("ghost") }
        if save.bestSurvival >= 5 { out.insert("survivor5") }
        if save.bestSurvival >= 10 { out.insert("survivor10") }
        if save.bestDailyStreak >= 3 { out.insert("devotee") }
        if save.bestDailyStreak >= 7 { out.insert("loyal") }
        if !rosterIds.isEmpty && save.bestRush >= rosterIds.count { out.insert("gauntlet") }
        if save.gold >= 1000 { out.insert("rich") }
        return out
    }
}

extension Achievements {
    /// A cosmetic title each achievement grants. Wearing one changes nothing about the fight.
    static let titles: [String: String] = [
        "first_blood": "the Blooded",
        "slayer": "Kingslayer",
        "untouchable": "the Untouchable",
        "ghost": "the Ghost",
        "survivor5": "the Survivor",
        "survivor10": "the Unbroken",
        "devotee": "the Devoted",
        "loyal": "the Loyal",
        "gauntlet": "of the Gauntlet",
        "rich": "the Wealthy"
    ]

    /// The title the player chose to wear, or nil when none is chosen or it is not earned (so an old or edited save can't show one early).
    static func wornTitle(save: SaveData, rosterIds: [String]) -> String? {
        guard !save.title.isEmpty, unlocked(save: save, rosterIds: rosterIds).contains(save.title) else { return nil }
        return titles[save.title]
    }
}
