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
    var offset: Double = 0   // audio/visual latency offset, ms
    var shake: Double = 1
    var blood: Int = 2
    var quality: String = "high"
    var haptics: Bool = true
    var flash: Bool = true
    var guide: Bool = true
    var style: String = "knight"
    var leftHand: Bool = false
    var colorSafe: Bool = false   // colour-blind friendly circle and button colours

    init() {}

    /// Tolerant decoding: a field missing from an older save falls back to its default,
    /// so adding new fields never wipes existing progress.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.music = try c.decodeIfPresent(Double.self, forKey: .music) ?? 0.8
        self.sfx = try c.decodeIfPresent(Double.self, forKey: .sfx) ?? 0.9
        self.difficulty = try c.decodeIfPresent(String.self, forKey: .difficulty) ?? "normal"
        self.offset = try c.decodeIfPresent(Double.self, forKey: .offset) ?? 0
        self.shake = try c.decodeIfPresent(Double.self, forKey: .shake) ?? 1
        self.blood = try c.decodeIfPresent(Int.self, forKey: .blood) ?? 2
        self.quality = try c.decodeIfPresent(String.self, forKey: .quality) ?? "high"
        self.haptics = try c.decodeIfPresent(Bool.self, forKey: .haptics) ?? true
        self.flash = try c.decodeIfPresent(Bool.self, forKey: .flash) ?? true
        self.guide = try c.decodeIfPresent(Bool.self, forKey: .guide) ?? true
        self.style = try c.decodeIfPresent(String.self, forKey: .style) ?? "knight"
        self.leftHand = try c.decodeIfPresent(Bool.self, forKey: .leftHand) ?? false
        self.colorSafe = try c.decodeIfPresent(Bool.self, forKey: .colorSafe) ?? false
    }
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
    var flawless: Int = 0   // fights won without taking a hit
    var dailyStreak: Int = 0   // consecutive days with a Daily Challenge win
    var bestDailyStreak: Int = 0
    var lastDailyWin: String = ""   // yyyy-MM-dd of the last Daily Challenge win

    init() {}

    /// Tolerant decoding: a field missing from an older save falls back to its default,
    /// so adding new fields never wipes existing progress.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.gold = try c.decodeIfPresent(Int.self, forKey: .gold) ?? 0
        self.beat = try c.decodeIfPresent([String].self, forKey: .beat) ?? []
        self.bestSurvival = try c.decodeIfPresent(Int.self, forKey: .bestSurvival) ?? 0
        self.bestRush = try c.decodeIfPresent(Int.self, forKey: .bestRush) ?? 0
        self.bestDaily = try c.decodeIfPresent([String: Int].self, forKey: .bestDaily) ?? [:]
        self.unlockedDuelist = try c.decodeIfPresent(Bool.self, forKey: .unlockedDuelist) ?? false
        self.unlockedBerserker = try c.decodeIfPresent(Bool.self, forKey: .unlockedBerserker) ?? false
        self.kills = try c.decodeIfPresent(Int.self, forKey: .kills) ?? 0
        self.invHeal = try c.decodeIfPresent(Int.self, forKey: .invHeal) ?? 0
        self.invFocus = try c.decodeIfPresent(Int.self, forKey: .invFocus) ?? 0
        self.invEdge = try c.decodeIfPresent(Int.self, forKey: .invEdge) ?? 0
        self.invTough = try c.decodeIfPresent(Int.self, forKey: .invTough) ?? 0
        self.seen = try c.decodeIfPresent([String: Bool].self, forKey: .seen) ?? [:]
        self.flawless = try c.decodeIfPresent(Int.self, forKey: .flawless) ?? 0
        self.dailyStreak = try c.decodeIfPresent(Int.self, forKey: .dailyStreak) ?? 0
        self.bestDailyStreak = try c.decodeIfPresent(Int.self, forKey: .bestDailyStreak) ?? 0
        self.lastDailyWin = try c.decodeIfPresent(String.self, forKey: .lastDailyWin) ?? ""
    }
}

// MARK: - Shared enums

enum SfxKind: String {
    case clang, thud, slash, whoosh, heartbeat, bell, heavy, parry, perfect, hurt, block, miss, uiTap, uiConfirm, focus, potion, win, lose
}

enum RoundType: String { case attack, defend }

enum Grade: String { case perfect, good, miss }
