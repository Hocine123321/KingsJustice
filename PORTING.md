# Swift port contract (The King's Justice -> native iOS, SwiftUI + Canvas)

Target: iOS 17, Swift 5.9, **no third-party deps**. No signing. We CANNOT compile Swift on this Linux box, so
write conservative, explicit Swift that compiles first time: annotate types, avoid clever generics, avoid
result builders beyond SwiftUI, avoid `any`/`some` gymnastics, no macros, no SwiftData, no `@Observable`
(use `ObservableObject` + `@Published`). Every file must compile on its own given the shared types below.
Prefer `final class`/`struct`. Mark UI types `@MainActor` only where needed. Use `Double` for time/coords
(not CGFloat) except where an API requires CGFloat. Never force-unwrap external data.

Source of truth = the original JS in /app/conversations/6ac5589fdb6e87a64d31be51/port/src/ (and
port/game.js, 2669 lines). Port **function by function, preserving numbers exactly** (timing windows,
damage, tonic effects, Second Wind, focus, damage cap x2, combo bonus, bpm, hp, rewards). Game balance was
validated; do NOT "improve" it.

## Directory ownership (each worker writes ONLY its own files)
KingsJustice/Core/      Models.swift (shared types, OWNED BY LEAD, do not edit) 
KingsJustice/Data/      Worker DATA
KingsJustice/Core/      Worker ENGINE   (GameEngine*.swift)
KingsJustice/Render/    Worker RENDER   (SVG renderer, fighter rig, scene, FX)
KingsJustice/Audio/     Worker AUDIO
KingsJustice/UI/        Worker UI       (menus, HUD, touch controls, app root)

## Shared types (already written in Core/Models.swift - import by being in the same module)
See KingsJustice/Core/Models.swift. If you need a new shared type, define it in YOUR OWN file with a
unique name prefixed by your area (e.g. `RenderPoint`), do not edit Models.swift.

## Cross-area interfaces (implement EXACTLY these signatures)
ENGINE exposes:  `final class GameEngine: ObservableObject` (see Models.swift `GameEngineAPI` doc comment)
RENDER exposes:  `struct GameSceneView: View { init(engine: GameEngine) }`  draws full scene (arena layers,
                 both fighters, fx, weather, rings/notes overlay) in a `TimelineView(.animation)` + `Canvas`.
                 Also `enum ArenaStore { static func arena(_ key: String) -> ArenaDef? }` is provided by DATA.
AUDIO exposes:   `final class AudioEngine { static let shared; func start(); func setVolumes(music:Double,sfx:Double);
                 func sfx(_ kind: SfxKind, intensity: Double); func startDrone(); func stopDrone(); func drum(...)}`
DATA exposes:    `enum GameData { static let moves: [String: MoveDef]; static let styles: [StyleDef];
                 static let roster: [EnemyDef]; static let arenas: [String: ArenaDef] }` (generated from JS).
UI exposes:      `struct RootView: View` (entry). KingsJusticeApp.swift is owned by UI worker.
