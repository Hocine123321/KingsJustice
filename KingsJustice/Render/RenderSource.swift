import Foundation

struct RenderNote: Identifiable, Sendable {
    let id: String
    let time: Double
    let kind: String
    let input: String
    let lane: Int
    let colorHex: String
    let ringStyle: String
    let tellDone: Double
    let state: String
    let flag: String?
    let origLane: Int?
    let shifted: Bool
    let feint: Bool
    let feintOk: Bool

    init(
        id: String = UUID().uuidString,
        time: Double,
        kind: String,
        input: String,
        lane: Int,
        colorHex: String,
        ringStyle: String,
        tellDone: Double,
        state: String,
        flag: String? = nil,
        origLane: Int? = nil,
        shifted: Bool = false,
        feint: Bool = false,
        feintOk: Bool = false
    ) {
        self.id = id
        self.time = time
        self.kind = kind
        self.input = input
        self.lane = lane
        self.colorHex = colorHex
        self.ringStyle = ringStyle
        self.tellDone = tellDone
        self.state = state
        self.flag = flag
        self.origLane = origLane
        self.shifted = shifted
        self.feint = feint
        self.feintOk = feintOk
    }
}

enum RenderFX: Sendable {
    case spark(x: Double, y: Double, n: Int)
    case blood(x: Double, y: Double, n: Int, dir: Double, power: Double)
    case stain(x: Double, y: Double, r: Double)
    case flashHurt
    case floatText(text: String, x: Double, y: Double, color: String, big: Bool)
    case shockwave(x: Double, y: Double, color: String)
}

protocol RenderSource: AnyObject {
    var rsTime: Double { get }
    var rsEnemy: EnemyDef? { get }
    var rsStyle: StyleDef { get }
    var rsPlayerPose: [Double] { get }
    var rsEnemyPose: [Double] { get }
    var rsEvents: [RenderNote] { get }
    var rsShake: Double { get }
    var rsHurt: Double { get }
    var rsRoundIsDefend: Bool { get }
    var rsArenaKey: String { get }
    var rsHitStop: Bool { get }
    var rsWound: Double { get }
    var rsFlash: Double { get }
    var rsFocusActive: Bool { get }
    var rsPerfectGlow: Double { get }
    var rsKillCam: Double { get }
    func rsDrainFX() -> [RenderFX]
}

extension RenderSource {
    var rsKillCam: Double { return 0.0 }
}
