import Foundation

public struct RenderNote: Identifiable, Sendable {
    public let id: String
    public let time: Double
    public let kind: String
    public let input: String
    public let lane: Int
    public let colorHex: String
    public let ringStyle: String
    public let tellDone: Double
    public let state: String
    public let flag: String?
    public let origLane: Int?
    public let shifted: Bool
    public let feint: Bool
    public let feintOk: Bool

    public init(
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

public enum RenderFX: Sendable {
    case spark(x: Double, y: Double, n: Int)
    case blood(x: Double, y: Double, n: Int, dir: Double, power: Double)
    case stain(x: Double, y: Double, r: Double)
    case flashHurt
}

public protocol RenderSource: AnyObject {
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
    func rsDrainFX() -> [RenderFX]
}
