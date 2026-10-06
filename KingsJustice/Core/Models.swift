import Foundation
import SwiftUI

// MARK: - Static game data (generated into Data/GameData.swift from the original JS)

struct MoveDef {
    let id: String
    let tellBeats: Double
    let label: String
    let color: String        // "#rrggbb"
    let ringStyle: String    // solid | dashed | double | red
    let input: String        // parry | duck | jump | dodge | grab
    let dmg: Double
    let pose: String
    let sfx: String
}

struct TimingWindows {
    let perfect: Double
    let good: Double
    let miss: Double
}

struct SpecialDef {
    let id: String
    let name: String
    let desc: String
    let charge: String
    let need: Int
}

struct LookDef {
    let colors: [String]     // 3 hex colours
    let trim: String
    let eye: String
    let helm: String         // greathelm | horned | crown | hood | cowl | skull | bare
    let cape: String         // cloak | cloakK | rags | none
    let weapon: String
    let size: Double
    let shield: Bool
    let glow: String?
}

struct StyleDef {
    let id: String
    let name: String
    let desc: String
    let weapon: String
    let windows: TimingWindows
    let dmgMul: Double
    let takeMul: Double
    let parryBonus: Double
    let special: SpecialDef
    let look: LookDef
}

struct AIDef {
    let aggression: Double
    let parryChance: Double
    let feintChance: Double
    let comboLength: Int
    let special: String
}

struct PhaseDef {
    let at: Double
    let bpmAdd: Double
    let newPatternPool: String
    let line: String
}

struct DefendNote {            // [time in beats, move id]
    let time: Double
    let move: String
}

struct AttackNote {            // [time in beats, lane 0..2]
    let time: Double
    let lane: Int
}

struct EnemyDef {
    let id: String
    let name: String
    let title: String
    let hp: Double
    let arena: String
    let bpm: Double
    let look: LookDef
    let intro: String
    let ai: AIDef
    let defendPatterns: [[DefendNote]]
    let attackPatterns: [[AttackNote]]
    let phases: [PhaseDef]
    let reward: Int
}

struct ArenaLight {
    let ambient: String
    let key: String
    let keyLX: Double
    let keyLY: Double
    let keyRX: Double
    let keyRY: Double
    let keyOp: Double
    let fog: String
    let fogOp: Double
}

struct ArenaWeather {
    let type: String       // embers | snow | rain | ash | fireflies | ...
    let count: Int
    let color: String
    let wind: Double
}

struct ArenaMusic {
    let root: Int
    let scale: String      // minor | phrygian | ...
    let tempo: Double
}

/// One arena. `bg`, `cl`, `gnd`, `fg` are SVG markup strings (a fragment, not a full document) in a
/// 1600x900 world. They may reference gradients/filters by `url(#id)`; arena-local ones are defined
/// inside the fragment, shared ones (sky, wall, mud, b6 ...) are in `SharedSVGDefs.markup`.
struct ArenaDef {
    let key: String
    let name: String
    let sub: String
    let bg: String
    let cl: String
    let gnd: String
    let fg: String
    let light: ArenaLight
    let weather: ArenaWeather
    let music: ArenaMusic
}

// MARK: - Settings & save (persisted in UserDefaults as JSON)

struct GameSettings: Codable, Equatable {
    var music: Double = 0.8
    var sfx: Double = 0.9
    var difficulty: String = "normal"   // easy | normal | hard | brutal
    var offset: Double = 0              // audio/visual latency offset, ms
    var shake: Double = 1
    var blood: Int = 2
    var quality: String = "high"
    var haptics: Bool = true
    var flash: Bool = true
    var guide: Bool = true
    var style: String = "knight"
    var leftHand: Bool = false
}

struct SaveData: Codable, Equatable {
    var gold: Int = 0
    var beat: [String] = []
    var bestSurvival: Int = 0
    var bestRush: Int = 0
    var bestDaily: [String: Int] = [:]
    var unlockedDuelist: Bool = false
    var unlockedBerserker: Bool = false
    var kills: Int = 0
    var invHeal: Int = 0
    var invFocus: Int = 0
    var invEdge: Int = 0
    var invTough: Int = 0
    var seen: [String: Bool] = [:]
}

// MARK: - Shared enums

enum SfxKind: String {
    case clang, thud, slash, whoosh, heartbeat, bell, heavy, parry, perfect, hurt, block, miss, uiTap, uiConfirm, focus, potion, win, lose
}

enum RoundType: String { case attack, defend }

enum Grade: String { case perfect, good, miss }
