import Foundation
import Combine

// MARK: - UIEngine conformance (names the SwiftUI layer expects)

extension GameEngine: UIEngine {
    public var focus: Double { return stamina }
    public var judgeColorHex: String { return judgeColor }
    public var roundIsDefend: Bool { return roundType == .defend }
    public var tipText: String? { return tutorialTip }
    public var potionCount: Int { return potion }

    public func tonicCatalog() -> [TonicInfo] {
        var out: [TonicInfo] = []
        for t in tonics {
            out.append(TonicInfo(id: t.id, name: t.name, desc: t.desc, price: t.price, owned: t.owned))
        }
        return out
    }

    public func buy(_ id: String) -> Bool {
        return buy(id: id)
    }

    public func canBuy(_ id: String) -> Bool {
        return canBuy(id: id)
    }

    public func unlockedStyles() -> [String] {
        var result: [String] = ["knight"]
        if save.unlockedDuelist { result.append("duelist") }
        if save.unlockedBerserker { result.append("berserker") }
        return result
    }
}

// MARK: - RenderSource conformance (what the Canvas scene reads each frame)

extension GameEngine: RenderSource {
    public var rsTime: Double { return t }
    public var rsEnemy: EnemyDef? { return enemyDef }
    public var rsStyle: StyleDef { return styleDef }
    public var rsPlayerPose: [Double] { return playerPoseState.cur }
    public var rsEnemyPose: [Double] { return enemyPoseState.cur }
    public var rsShake: Double { return shake }
    public var rsHurt: Double { return hurtLevel }
    public var rsRoundIsDefend: Bool { return roundType == .defend }
    public var rsArenaKey: String { return enemyDef?.arena ?? "castle" }
    public var rsHitStop: Bool { return hitStop > 0 }
    public var rsWound: Double {
        if kmax <= 0 { return 0 }
        return max(0.0, min(1.0, 1.0 - khp / kmax)) * 0.8
    }
    public var rsFlash: Double { return flashOpacity }
    public var rsFocusActive: Bool { return focusUntil > t }
    public var rsPerfectGlow: Double { return 0.0 }

    public var rsEvents: [RenderNote] {
        var out: [RenderNote] = []
        for e in events {
            if e.state != "live" { continue }
            let move: MoveDef? = GameData.moves[e.kind]
            let color: String = move?.color ?? "#d9b45a"
            let ring: String = move?.ringStyle ?? "solid"
            let note = RenderNote(
                id: String(e.id),
                time: e.time,
                kind: e.kind,
                input: e.input,
                lane: e.lane,
                colorHex: color,
                ringStyle: ring,
                tellDone: e.tell,
                state: e.state,
                flag: e.flag,
                origLane: e.orig,
                shifted: e.shifted,
                feint: e.feint,
                feintOk: e.feintOk
            )
            out.append(note)
        }
        return out
    }

    public func rsDrainFX() -> [RenderFX] {
        var out: [RenderFX] = []
        for fx in fxQueue {
            switch fx {
            case .spark(let x, let y, let count):
                out.append(RenderFX.spark(x: x, y: y, n: count))
            case .blood(let x, let y, let count, let dir, let power):
                out.append(RenderFX.blood(x: x, y: y, n: count, dir: dir, power: power))
            case .stain(let x, let y, let radius):
                out.append(RenderFX.stain(x: x, y: y, r: radius))
            case .flashHurt:
                out.append(RenderFX.flashHurt)
            case .flashScreen:
                break
            }
        }
        fxQueue.removeAll()
        return out
    }
}
