import Foundation

/// Cosmetic mid-fight arena events (lightning, a bell toll, a gust...). They never touch timing or damage.
extension GameEngine {
    /// 0.35 base, rising with how hurt the champion is, with a long combo and with the player's own danger.
    func adaptiveIntensity(woundFraction: Double) -> Double {
        let comboLift = min(0.2, Double(combo) * 0.015)
        let danger = (maxhp > 0 && hp / maxhp < 0.3) ? 0.12 : 0.0
        return min(1.0, 0.35 + woundFraction * 0.5 + comboLift + danger)
    }

    func nextArenaEventDelay() -> Double {
        return 14.0 + Double.random(in: 0.0...12.0)
    }

    /// Called every frame while a fight is live.
    func tickArenaEvents(dt: Double) {
        arenaEventTimer -= dt
        if arenaEventTimer <= 0.0 {
            arenaEventTimer = nextArenaEventDelay()
            fireArenaEvent(arena: enemyDef?.arena ?? "castle")
        }
    }

    func fireArenaEvent(arena: String) {
        switch arena {
        case "swamp":
            flashScreen(color: "#d8f0dc", opacity: 0.5)      // lightning
            onSfx?(.heavy, 0.6)
            shake2(0.4)
        case "cliff":
            flashScreen(color: "#ff6a5a", opacity: 0.35)     // blood-red lightning over the sea
            onSfx?(.thud, 0.7)
        case "cathedral":
            flashScreen(color: "#9bb8ff", opacity: 0.14)     // a bell tolls
            onSfx?(.bell, 0.7)
        case "village":
            flashScreen(color: "#ff8a2a", opacity: 0.22)     // a roof collapses
            onSfx?(.heavy, 0.7)
            shake2(0.7)
        case "pass":
            flashScreen(color: "#e8f2ff", opacity: 0.10)     // a gust of wind
            onSfx?(.whoosh, 0.6)
        default:
            flashScreen(color: "#ffb060", opacity: 0.12)     // torches flare
            onSfx?(.whoosh, 0.4)
        }
    }
}
