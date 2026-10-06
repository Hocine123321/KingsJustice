import Foundation

// MARK: - FX & Visual Events

public enum FXEvent: Equatable {
    case spark(x: Double, y: Double, count: Int)
    case blood(x: Double, y: Double, count: Int, dir: Double, power: Double)
    case stain(x: Double, y: Double, radius: Double)
    case flashHurt(opacity: Double)
    case flashScreen(color: String, opacity: Double)
}

// MARK: - Pose Request

public struct PoseRequest: Equatable {
    public var values: [Double]
    public var speed: Double

    public init(values: [Double], speed: Double = 9.0) {
        self.values = values
        self.speed = speed
    }
}

// MARK: - Pose State (mutable internal pose tracker)

public struct PoseState: Equatable {
    public var cur: [Double]
    public var tgt: [Double]
    public var spd: Double

    public init(values: [Double], spd: Double = 9.0) {
        self.cur = values
        self.tgt = values
        self.spd = spd
    }

    public mutating func setTarget(_ target: [Double], speed: Double = 14.0) {
        self.tgt = target
        self.spd = speed
    }

    public mutating func step(dt: Double) {
        let k = 1.0 - exp(-spd * dt)
        for i in 0..<min(cur.count, tgt.count) {
            cur[i] += (tgt[i] - cur[i]) * k
        }
    }

    public var request: PoseRequest {
        return PoseRequest(values: cur, speed: spd)
    }
}

// MARK: - Note Event

public struct NoteEvent: Identifiable, Equatable {
    public let id: Int
    public var time: Double
    public var kind: String
    public var input: String
    public var lane: Int
    public var flag: String?
    public var state: String
    public var tellDone: Bool
    public var group: Int
    public var dmg: Double
    public var tell: Double
    public var pose: String?
    public var feint: Bool
    public var feintAt: Double
    public var feintOk: Bool
    public var feintBit: Int
    public var armorHit: Int
    public var orig: Int
    public var counter: Bool
    public var shifted: Bool
    public var dep: Int?
    public var _sh: Int
    public var grabPresses: [String: Double]

    public init(
        id: Int,
        time: Double,
        kind: String,
        input: String,
        lane: Int,
        flag: String? = nil,
        state: String = "live",
        tellDone: Bool = false,
        group: Int = 0,
        dmg: Double = 12.0,
        tell: Double = 0.0,
        pose: String? = nil,
        feint: Bool = false,
        feintAt: Double = 0.0,
        feintOk: Bool = false,
        feintBit: Int = 0,
        armorHit: Int = 0,
        orig: Int = 0,
        counter: Bool = false,
        shifted: Bool = false,
        dep: Int? = nil,
        _sh: Int = 0,
        grabPresses: [String: Double] = [:]
    ) {
        self.id = id
        self.time = time
        self.kind = kind
        self.input = input
        self.lane = lane
        self.flag = flag
        self.state = state
        self.tellDone = tellDone
        self.group = group
        self.dmg = dmg
        self.tell = tell
        self.pose = pose
        self.feint = feint
        self.feintAt = feintAt
        self.feintOk = feintOk
        self.feintBit = feintBit
        self.armorHit = armorHit
        self.orig = orig
        self.counter = counter
        self.shifted = shifted
        self.dep = dep
        self._sh = _sh
        self.grabPresses = grabPresses
    }
}

// MARK: - Shop Item

public struct ShopTonic: Identifiable, Equatable {
    public var id: String
    public var name: String
    public var desc: String
    public var price: Int
    public var owned: Int

    public init(id: String, name: String, desc: String, price: Int, owned: Int) {
        self.id = id
        self.name = name
        self.desc = desc
        self.price = price
        self.owned = owned
    }
}

// MARK: - Difficulty Parameters

public struct DifficultyParams {
    public let win: Double
    public let take: Double
    public let tempo: Double
    public let enemyDmg: Double

    public init(win: Double, take: Double, tempo: Double, enemyDmg: Double) {
        self.win = win
        self.take = take
        self.tempo = tempo
        self.enemyDmg = enemyDmg
    }
}

// MARK: - Timing Windows Calculation Result

public struct TimingWindowsCalc {
    public let perfect: Double
    public let good: Double
    public let miss: Double

    public init(perfect: Double, good: Double, miss: Double) {
        self.perfect = perfect
        self.good = good
        self.miss = miss
    }
}

// MARK: - Mulberry32 Seeded PRNG

public final class MulberryRNG {
    private var state: UInt32

    public init(seed: UInt32) {
        self.state = seed
    }

    public func next() -> Double {
        state = state &+ 0x6D2B79F5
        var t = state
        t = (t ^ (t >> 15)) &* (t | 1)
        let t2 = t &+ ((t ^ (t >> 7)) &* (t | 61))
        let t3 = t2 ^ t
        let result = (t3 ^ (t3 >> 14))
        return Double(result) / 4294967296.0
    }
}

// MARK: - Pose Dictionary Constant (PZ)

public enum EnginePoses {
    public static let kIdle: [Double]  = [420.0, 0.0, -40.0, 40.0, 80.0, 0.0, 0.0, 0.0]
    public static let kGuard: [Double] = [445.0, 3.0, -30.0, 50.0, 85.0, 0.9, 0.0, 2.0]
    public static let kParry: [Double] = [482.0, -2.0, -5.0, 5.0, 40.0, 0.2, 0.0, 0.0]
    public static let kWind: [Double]  = [440.0, 8.0, 70.0, 95.0, 115.0, 0.0, 0.0, 3.0]
    public static let kSlash: [Double] = [500.0, -4.0, -5.0, 5.0, 35.0, 0.0, 0.0, 0.0]
    public static let kThrust: [Double] = [512.0, -6.0, 5.0, -5.0, 0.0, 0.0, 0.0, 2.0]
    public static let kOver: [Double]  = [480.0, 6.0, 98.0, 122.0, 142.0, 0.0, 0.0, 6.0]
    public static let kDuck: [Double]  = [430.0, 14.0, -20.0, 30.0, 80.0, 0.6, 0.0, 34.0]
    public static let kJump: [Double]  = [440.0, -4.0, -60.0, 20.0, 60.0, 0.0, 0.0, -30.0]
    public static let kDodge: [Double] = [380.0, -12.0, -40.0, 40.0, 80.0, 0.0, 0.0, 4.0]
    public static let kHurt: [Double]  = [395.0, -18.0, -75.0, -55.0, -35.0, -0.4, 0.0, 8.0]
    public static let kDead: [Double]  = [540.0, -40.0, -95.0, -80.0, -60.0, 0.0, 1.0, 0.0]
    public static let kWin: [Double]   = [470.0, 2.0, 60.0, 40.0, 100.0, 0.0, 0.0, 0.0]
    public static let kStun: [Double]  = [420.0, -14.0, -60.0, 30.0, 40.0, 0.0, 0.0, 10.0]

    public static let gIdle: [Double]    = [900.0, 0.0, -40.0, 45.0, 70.0, 0.0, 0.0, 0.0]
    public static let gWind: [Double]    = [880.0, -8.0, 98.0, 122.0, 142.0, 0.0, 0.0, 6.0]
    public static let gWindL: [Double]   = [885.0, 6.0, -20.0, 30.0, -25.0, 0.0, 0.0, 18.0]
    public static let gWindH: [Double]   = [880.0, -10.0, 120.0, 130.0, 160.0, 0.0, 0.0, 2.0]
    public static let gLunge: [Double]   = [820.0, 10.0, 10.0, -5.0, 20.0, 0.0, 0.0, 10.0]
    public static let gThrow: [Double]   = [895.0, -6.0, 110.0, 60.0, 60.0, 0.0, 0.0, 2.0]
    public static let gStrike: [Double]  = [760.0, 8.0, -20.0, -15.0, 10.0, 0.0, 0.0, -2.0]
    public static let gStrikeL: [Double] = [775.0, 12.0, -8.0, -12.0, -10.0, 0.0, 0.0, 16.0]
    public static let gSwing: [Double]   = [800.0, -4.0, 75.0, 100.0, 125.0, 0.0, 0.0, 3.0]
    public static let gParried: [Double] = [930.0, 8.0, -10.0, 10.0, 50.0, 0.0, 0.0, 3.0]
    public static let gBlockH: [Double]  = [880.0, -4.0, 60.0, 95.0, 115.0, 0.0, 0.0, 0.0]
    public static let gBlockL: [Double]  = [885.0, 4.0, -30.0, -20.0, -55.0, 0.0, 0.0, 14.0]
    public static let gHurt: [Double]    = [945.0, 10.0, -70.0, -60.0, -30.0, 0.0, 0.0, 6.0]
    public static let gDead: [Double]    = [1010.0, 18.0, -95.0, -80.0, -60.0, 0.0, 1.0, 0.0]
    public static let gStun: [Double]    = [920.0, -12.0, -60.0, 30.0, 40.0, 0.0, 0.0, 10.0]
    public static let gWin: [Double]     = [640.0, 2.0, -20.0, 10.0, 30.0, 0.0, 0.0, 0.0]
}

// MARK: - Tips Reference Dictionary

public struct TipInfo {
    public let title: String
    public let description: String
}

public enum EngineTips {
    public static let tips: [String: TipInfo] = [
        "slash": TipInfo(title: "Parry", description: "Press PARRY (Space / tap) just as the ring closes on the red circle."),
        "low": TipInfo(title: "Low sweep", description: "Duck it: press S or tap DUCK as the ring closes."),
        "high": TipInfo(title: "Overhead", description: "Jump over it: press W or tap JUMP."),
        "unblockable": TipInfo(title: "Unblockable", description: "Red dashed ring: you cannot parry this. DODGE it (A or tap DODGE). A clean dodge stuns him."),
        "feint": TipInfo(title: "Feint", description: "The ring flickers: he is faking. Wait for it to settle, then parry."),
        "double": TipInfo(title: "Double strike", description: "Two hits half a beat apart. Parry twice."),
        "triple": TipInfo(title: "Triple strike", description: "Three quick hits. Tap parry three times in rhythm."),
        "grab": TipInfo(title: "Grab", description: "Press PARRY and DODGE together to break his grip."),
        "ranged": TipInfo(title: "Thrown weapon", description: "Parry it as it arrives. Small damage, long warning."),
        "sweep_combo": TipInfo(title: "Sweep combo", description: "Duck, then jump."),
        "note:P": TipInfo(title: "He parries", description: "Blue-ringed notes will be blocked. Hit them PERFECT to break his guard and open him up."),
        "note:BH": TipInfo(title: "High guard", description: "His guard covers high strikes. Use Slash or Thrust on these."),
        "note:BL": TipInfo(title: "Low guard", description: "His guard covers low strikes. Use Thrust or Overhead on these."),
        "note:S+": TipInfo(title: "Sidestep", description: "Green-arrow notes slide to the next lane right at the end. Hit the lane they land in."),
        "note:S-": TipInfo(title: "Sidestep", description: "Green-arrow notes slide to the next lane right at the end. Hit the lane they land in."),
        "note:A": TipInfo(title: "Armour", description: "Boxed notes need two hits in the same lane."),
        "note:C": TipInfo(title: "Counter", description: "Red-cross notes provoke a counter. Be ready to parry right after.")
    ]
}
