import Foundation
import Combine

// MARK: - UIEngine conformance (names the SwiftUI layer expects)

extension GameEngine: UIEngine {
    var focus: Double { return stamina }
    var judgeColorHex: String { return judgeColor }
    var roundIsDefend: Bool { return roundType == .defend }
    var tipText: String? { return tutorialTip }
    var potionCount: Int { return potion }

    func beginFight(index: Int) {
        beginFight(index: index, keepHp: false)
    }

    func tonicCatalog() -> [TonicInfo] {
        var out: [TonicInfo] = []
        for t in tonics {
            out.append(TonicInfo(id: t.id, name: t.name, desc: t.desc, price: t.price, owned: t.owned))
        }
        return out
    }

    func buy(_ id: String) -> Bool {
        return buy(id: id)
    }

    func canBuy(_ id: String) -> Bool {
        return canBuy(id: id)
    }

    func unlockedStyles() -> [String] {
        var result: [String] = ["knight"]
        if save.unlockedDuelist { result.append("duelist") }
        if save.unlockedBerserker { result.append("berserker") }
        return result
    }
}

// MARK: - RenderSource conformance (what the Canvas scene reads each frame)

extension GameEngine: RenderSource {
    var rsTime: Double { return t }
    var rsEnemy: EnemyDef? { return enemyDef }
    var rsStyle: StyleDef { return styleDef }
    var rsPlayerPose: [Double] { return playerPoseState.cur }
    var rsEnemyPose: [Double] { return enemyPoseState.cur }
    var rsShake: Double { return shake }
    var rsHurt: Double { return hurtLevel }
    var rsRoundIsDefend: Bool { return roundType == .defend }
    var rsArenaKey: String { return enemyDef?.arena ?? "castle" }
    var rsHitStop: Bool { return hitStop > 0 }
    var rsWound: Double {
        if kmax <= 0 { return 0 }
        return max(0.0, min(1.0, 1.0 - khp / kmax)) * 0.8
    }
    var rsFlash: Double { return flashOpacity }
    var rsFocusActive: Bool { return focusUntil > t }
    var rsPerfectGlow: Double { return 0.0 }
    var rsKillCam: Double {
        guard over && won else { return 0.0 }
        let rampIn = min(1.0, endClock / 0.3)
        let rampOut = endClock < 1.6 ? 1.0 : max(0.0, 1.0 - (endClock - 1.6) / 0.4)
        return rampIn * rampOut
    }

    var rsEvents: [RenderNote] {
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

    func rsDrainFX() -> [RenderFX] {
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
            case .floatText(let text, let x, let y, let color, let big):
                out.append(RenderFX.floatText(text: text, x: x, y: y, color: color, big: big))
            }
        }
        fxQueue.removeAll()
        return out
    }
}
