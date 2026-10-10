import Foundation

/// A run-long upgrade chosen between Survival waves. Boons only strengthen the player or trade
/// safety for power; none of them touch enemy AI or timing.
struct Boon: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let desc: String
    let maxStacks: Int
}

enum BoonCatalog {
    static let all: [Boon] = [
        Boon(id: "keen", name: "Keen Edge", desc: "+12% damage dealt.", maxStacks: 5),
        Boon(id: "ward", name: "Iron Ward", desc: "10% less damage taken.", maxStacks: 4),
        Boon(id: "vigor", name: "Vigor", desc: "+12 max health and heal 12 now.", maxStacks: 5),
        Boon(id: "mend", name: "Mending Draught", desc: "Heal 35% of your health now.", maxStacks: 99),
        Boon(id: "glass", name: "Glass Cannon", desc: "+35% damage dealt, but 25% more damage taken.", maxStacks: 1),
        Boon(id: "greed", name: "Spoils of War", desc: "+40% gold from each victory.", maxStacks: 3)
    ]

    static func boon(_ id: String) -> Boon? {
        return all.first(where: { $0.id == id })
    }

    static func stacks(_ id: String, in taken: [String]) -> Int {
        return taken.filter { $0 == id }.count
    }

    /// Three different boons that are not yet maxed out, picked deterministically from a seed.
    static func offer(taken: [String], seed: UInt32, count: Int = 3) -> [Boon] {
        var pool = all.filter { stacks($0.id, in: taken) < $0.maxStacks }
        var out: [Boon] = []
        var state = UInt64(seed) &+ 0x9E3779B97F4A7C15
        while out.count < count && !pool.isEmpty {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let idx = Int((state >> 33) % UInt64(pool.count))
            out.append(pool.remove(at: idx))
        }
        return out
    }

    static func damageDealtMul(_ taken: [String]) -> Double {
        var m = 1.0 + 0.12 * Double(stacks("keen", in: taken))
        if stacks("glass", in: taken) > 0 { m *= 1.35 }
        return m
    }

    static func damageTakenMul(_ taken: [String]) -> Double {
        var m = pow(0.9, Double(stacks("ward", in: taken)))
        if stacks("glass", in: taken) > 0 { m *= 1.25 }
        return m
    }

    static func maxHealthBonus(_ taken: [String]) -> Double {
        return 12.0 * Double(stacks("vigor", in: taken))
    }

    static func goldMul(_ taken: [String]) -> Double {
        return 1.0 + 0.4 * Double(stacks("greed", in: taken))
    }
}
