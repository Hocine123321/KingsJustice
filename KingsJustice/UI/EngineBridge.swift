import Foundation
import Combine

/// Information about a purchasable tonic item.
public struct TonicInfo: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let desc: String
    public let price: Int
    public let owned: Int
    
    public init(id: String, name: String, desc: String, price: Int, owned: Int) {
        self.id = id
        self.name = name
        self.desc = desc
        self.price = price
        self.owned = owned
    }
}

/// Protocol defining the exact engine interface required by the UI.
public protocol UIEngine: ObservableObject {
    var hp: Double { get }
    var maxhp: Double { get }
    var khp: Double { get }
    var kmax: Double { get }
    var focus: Double { get }
    var score: Int { get }
    var combo: Int { get }
    var gold: Int { get }
    var judgeText: String { get }
    var judgeColorHex: String { get }
    var judgeStamp: Double { get }
    var roundIsDefend: Bool { get }
    var paused: Bool { get }
    var over: Bool { get }
    var won: Bool { get }
    var tipText: String? { get }
    var potionCount: Int { get }
    var started: Bool { get }
    var enemyName: String { get }
    var enemyTitle: String { get }
    
    var settings: GameSettings { get set }
    var save: SaveData { get }
    
    func startRun(mode: String, enemyIndex: Int)
    func beginFight(index: Int)
    func input(kind: String, lane: Int)
    func useFocus()
    func drinkPotion()
    func pause()
    func resume()
    func quitToMenu()
    func saveAll()
    func tick(dt: Double)
    func tonicCatalog() -> [TonicInfo]
    func buy(_ id: String) -> Bool
    func canBuy(_ id: String) -> Bool
    func unlockedStyles() -> [String]
}

/// Mock implementation of UIEngine for previewing and isolated UI testing.
public final class MockGameEngine: UIEngine, ObservableObject {
    @Published public var hp: Double = 100.0
    @Published public var maxhp: Double = 100.0
    @Published public var khp: Double = 90.0
    @Published public var kmax: Double = 100.0
    @Published public var focus: Double = 45.0
    @Published public var score: Int = 1250
    @Published public var combo: Int = 7
    @Published public var gold: Int = 120
    @Published public var judgeText: String = "PERFECT"
    @Published public var judgeColorHex: String = "#d9b45a"
    @Published public var judgeStamp: Double = 1.0
    @Published public var roundIsDefend: Bool = true
    @Published public var paused: Bool = false
    @Published public var over: Bool = false
    @Published public var won: Bool = false
    @Published public var tipText: String? = "Parry when the ring closes on the center target!"
    @Published public var potionCount: Int = 1
    @Published public var started: Bool = false
    @Published public var enemyName: String = "Hollow Conscript"
    @Published public var enemyTitle: String = "Broken Foot-Soldier"
    
    public var settings: GameSettings = GameSettings()
    public var save: SaveData = SaveData()
    
    public init() {}
    
    public func startRun(mode: String, enemyIndex: Int) {
        started = true
        paused = false
        over = false
    }
    
    public func beginFight(index: Int) {
        started = true
        paused = false
        over = false
    }
    
    public func input(kind: String, lane: Int) {
        judgeText = "GOOD"
        judgeColorHex = "#8fd0a0"
        combo += 1
        score += 100
    }
    
    public func useFocus() {
        if focus >= 50.0 {
            focus -= 50.0
        }
    }
    
    public func drinkPotion() {
        if potionCount > 0 {
            potionCount -= 1
            hp = min(maxhp, hp + maxhp * 0.35)
        }
    }
    
    public func pause() {
        paused = true
    }
    
    public func resume() {
        paused = false
    }
    
    public func quitToMenu() {
        started = false
        paused = false
        over = false
    }
    
    public func saveAll() {}
    
    public func tick(dt: Double) {}
    
    public func tonicCatalog() -> [TonicInfo] {
        return [
            TonicInfo(id: "heal", name: "Healing Draught", desc: "Restore 35% health mid-fight.", price: 60, owned: potionCount),
            TonicInfo(id: "focus", name: "Battle Focus", desc: "Start fight with half Focus meter.", price: 50, owned: save.invFocus),
            TonicInfo(id: "edge", name: "Whetstone", desc: "+25% damage dealt next fight.", price: 70, owned: save.invEdge),
            TonicInfo(id: "tough", name: "Iron Bark", desc: "-20% damage taken next fight.", price: 65, owned: save.invTough)
        ]
    }
    
    public func buy(_ id: String) -> Bool {
        guard canBuy(id) else { return false }
        gold -= 50
        if id == "heal" { potionCount += 1 }
        return true
    }
    
    public func canBuy(_ id: String) -> Bool {
        return gold >= 50
    }
    
    public func unlockedStyles() -> [String] {
        var result: [String] = ["knight"]
        if save.unlockedDuelist { result.append("duelist") }
        if save.unlockedBerserker { result.append("berserker") }
        return result
    }
}
