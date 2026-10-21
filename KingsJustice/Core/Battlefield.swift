import Foundation

/// The name and one-line description of the battlefield, authored for each arena. The fight intro shows them.
protocol BattlefieldProviding: AnyObject {
    var battlefieldName: String { get }
    var battlefieldSub: String { get }
}

extension GameEngine: BattlefieldProviding {
    var battlefieldName: String { return GameData.arenas[rsArenaKey]?.name ?? "" }
    var battlefieldSub: String { return GameData.arenas[rsArenaKey]?.sub ?? "" }
}
