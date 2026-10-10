import Foundation
import Combine

final class GameEngine: ObservableObject {
    // MARK: - Published Properties (HUD / UI)

    @Published var hp: Double = 100.0
    @Published var maxhp: Double = 100.0
    @Published var khp: Double = 100.0
    @Published var kmax: Double = 100.0
    @Published var stamina: Double = 0.0 // focus / stamina 0..100
    @Published var special: Double = 0.0
    @Published var score: Int = 0
    @Published var combo: Int = 0
    @Published var maxCombo: Int = 0
    @Published var judgeText: String = ""
    @Published var judgeColor: String = "#ffffff"
    @Published var judgeStamp: Double = 0.0
    var hurtLevel: Double = 0.0
    var fxQueue: [FXEvent] = []
    @Published var roundType: RoundType = .defend
    @Published var paused: Bool = false
    @Published var over: Bool = false
    /// True once the finishing-blow slow-mo has played and the result screen may appear.
    @Published var resultReady: Bool = false
    var endClock: Double = 0.0
    @Published var fightResult: FightResult = FightResult()
    /// Survival boons taken this run, and the three on offer after a won wave.
    @Published var boons: [String] = []
    /// Daily Challenge twist in force (steady outside the Daily).
    var dailyMod: DailyModifier = DailyModifiers.steady
    /// True once the player has lost any health this fight (flawless tracking).
    var tookDamage: Bool = false
    /// Big centre-screen callout when the champion changes phase.
    @Published var phaseBanner: String = ""
    var phaseBannerUntil: Double = 0.0
    @Published var boonOffer: [Boon] = []
    @Published var won: Bool = false
    @Published var phaseBanner: String? = nil
    @Published var tutorialTip: String? = nil
    @Published var gold: Int = 0
    @Published var potion: Int = 0
    @Published var round: Int = 0
    @Published var wave: Int = 0
    @Published var mode: String = "duel"
    @Published var enemyName: String = ""
    @Published var enemyTitle: String = ""
    @Published var playerName: String = "KNIGHT"
    @Published var promptText: String = ""
    @Published var tauntText: String = ""
    var hitBarkCount: Int = 0
    var lowHealthBarked: Bool = false
    var musicIntensityTick: Double = 0.0
    @Published var started: Bool = false
    @Published var on: Bool = false

    // MARK: - Settings & Save

    @Published var settings: GameSettings = GameSettings() {
        didSet { InputPalette.safeMode = settings.colorSafe }
    }
    @Published var save: SaveData = SaveData()

    // MARK: - Per-frame Render Data (Plain Properties)

    var events: [NoteEvent] = []
    var playerPoseState: PoseState = PoseState(values: EnginePoses.kIdle)
    var enemyPoseState: PoseState = PoseState(values: EnginePoses.gIdle)
    var shake: Double = 0.0
    var hitStop: Double = 0.0
    var flashColor: String? = nil
    var flashOpacity: Double = 0.0

    var playerPoseRequest: PoseRequest {
        return playerPoseState.request
    }

    var enemyPoseRequest: PoseRequest {
        return enemyPoseState.request
    }

    // MARK: - Active Defs

    var enemyDef: EnemyDef?
    var styleDef: StyleDef = GameData.styles[0]

    // MARK: - Callbacks / Side Effects

    var onSfx: ((SfxKind, Double) -> Void)?
    var onHaptic: ((String) -> Void)?
    var onSpawnFX: ((FXEvent) -> Void)?

    // MARK: - Internal Engine State

    var t: Double = 0.0
    var bpm: Double = 84.0
    var roundEnd: Double = 0.0
    var roundStart: Double = 0.0
    var enemyIdx: Int = 0
    var phaseIdx: Int = 0
    var rng: MulberryRNG = MulberryRNG(seed: 1)

    // Combat flags
    var rageUntil: Double = 0.0
    var riposte: Bool = false
    var bastion: Bool = false
    var windUsed: Bool = false
    var guardBreak: Double = 0.0
    var staggerUntil: Double = 0.0
    var stunUntil: Double = 0.0
    var focusUntil: Double = 0.0
    var invulnUntil: Double = 0.0
    var counterWin: Double = 0.0
    var pStreak: Int = 0
    var nP: Int = 0
    var nG: Int = 0
    var nM: Int = 0
    var dmgScale: Double = 1.0
    var tough: Bool = false
    var edge: Bool = false
    var pendTough: Bool = false
    var pendEdge: Bool = false
    var startFocus: Double = 0.0
    var training: Bool = false
    var rushList: [Int] = []
    var startTimer: Double = 0.0
    var fReadyBit: Int = 0

    // MARK: - Initialization

    init() {
        loadAll()
        let style = GameData.styles.first(where: { $0.id == settings.style }) ?? GameData.styles[0]
        self.styleDef = style
        self.gold = save.gold
        self.onSpawnFX = { [weak self] (fx: FXEvent) in
            guard let self = self else { return }
            if self.fxQueue.count < 200 { self.fxQueue.append(fx) }
            if case .flashHurt(let o) = fx { self.hurtLevel = max(self.hurtLevel, o) }
        }
    }

    // MARK: - Main Tick Loop (External Clock Drive)

    func tick(dt: Double) {
        guard on else { return }

        // Start countdown before fight begins
        if !started {
            if startTimer > 0 {
                startTimer -= dt
                if startTimer <= 0 {
                    started = true
                    let B = 60.0 / bpm
                    t = -B * 2.5
                    startRound2()
                }
            }
            return
        }

        if paused { return }

        // Hit-stop scaling
        var dtFrame = dt
        if hitStop > 0 {
            hitStop -= dt
            dtFrame = dt * 0.08
        }

        if !phaseBanner.isEmpty && t > phaseBannerUntil {
            phaseBanner = ""
        }

        // Finishing blow: slow-mo kill-cam on a win, a short beat on a loss, then reveal the result.
        if over {
            endClock += dt
            if won {
                dtFrame = dt * (endClock < 1.5 ? 0.25 : 0.6)
            }
            if !resultReady && endClock > (won ? 1.9 : 1.0) {
                resultReady = true
            }
        }

        t += dtFrame

        let B = 60.0 / bpm
        let W = currentWindows()

        if !over {
            // Check events
            for i in 0..<events.count {
                if events[i].state != "live" { continue }
                let dtN = events[i].time - t

                if events[i].kind != "note" {
                    // Telegraph
                    let tellWindow = (events[i].tell > 0) ? events[i].tell : B
                    if !events[i].tellDone && dtN < tellWindow {
                        events[i].tellDone = true
                        let pzKey = (events[i].pose == "low") ? "gWindL" :
                                    (events[i].pose == "high") ? "gWindH" :
                                    (events[i].pose == "lunge") ? "gLunge" :
                                    (events[i].pose == "throw") ? "gThrow" : "gWind"
                        let targetPose = getEnemyPoseVector(pzKey)
                        let speed = min(14.0, 5.0 + 1.0 / max(0.2, dtN) * 1.2)
                        enemyPoseState.setTarget(targetPose, speed: speed)

                        if events[i].kind == "unblockable" {
                            onSfx?(.heartbeat, 1.0)
                        } else {
                            onSfx?(.whoosh, 1.0)
                        }

                        if events[i].feint {
                            events[i].feintAt = events[i].time - B * 0.5
                        }
                    }

                    if events[i].feint && t > events[i].feintAt {
                        events[i].feintOk = true
                    }

                    if dtN < -W.miss {
                        missDefend(&events[i])
                    }
                } else {
                    // Attack note
                    if events[i].flag == "S+" || events[i].flag == "S-" {
                        if events[i]._sh == 0 && dtN < B * 0.35 {
                            events[i]._sh = 1
                            let shift = (events[i].flag == "S+") ? 1 : -1
                            events[i].lane = max(0, min(2, events[i].lane + shift))
                            events[i].shifted = true
                        }
                    }

                    if dtN < -W.miss {
                        if events[i].flag == "Ah" {
                            events[i].state = "done"
                        } else {
                            missNote(&events[i])
                        }
                    }
                }
            }

            // Focus expiration
            if focusUntil > 0 && t > focusUntil {
                focusUntil = 0
                stamina = 0
                fReadyBit = 0
                say("Focus fades", col: "#6a8aa8")
            }

            // Round end
            if t > roundEnd {
                if hp > 0 && khp > 0 {
                    maybePhase()
                    startRound2()
                }
            }
        }

        // Tempo ramps as enemy weakens; difficulty scales
        let D = difficultyParams(settings.difficulty)
        let frac = 1.0 - max(0.0, min(1.0, khp / kmax))
        let activePhases = enemyDef?.phases.filter { (khp / kmax) <= $0.at } ?? []
        let bpmAddSum = activePhases.reduce(0.0) { $0 + $1.bpmAdd }
        if let baseBpm = enemyDef?.bpm {
            bpm = (baseBpm + frac * 10.0 + bpmAddSum) * D.tempo
        }
        if musicIntensityTick > 0.5 {
            musicIntensityTick = 0.0
            UIAudio.setMusicIntensity(min(1.0, 0.35 + frac * 0.65))
        }
        musicIntensityTick += dt

        // Step pose physics
        playerPoseState.step(dt: dtFrame)
        enemyPoseState.step(dt: dtFrame)

        hurtLevel = max(0.0, hurtLevel - dt * 1.6)
        // Shake decay
        shake *= exp(-dt * 7.0)

        // Flash decay
        if flashOpacity > 0 {
            flashOpacity = max(0.0, flashOpacity - dt * 2.5)
            if flashOpacity == 0 {
                flashColor = nil
            }
        }
    }

    func getEnemyPoseVector(_ key: String) -> [Double] {
        switch key {
        case "gWind": return EnginePoses.gWind
        case "gWindL": return EnginePoses.gWindL
        case "gWindH": return EnginePoses.gWindH
        case "gLunge": return EnginePoses.gLunge
        case "gThrow": return EnginePoses.gThrow
        case "gStrike": return EnginePoses.gStrike
        case "gStrikeL": return EnginePoses.gStrikeL
        case "gSwing": return EnginePoses.gSwing
        case "gParried": return EnginePoses.gParried
        case "gBlockH": return EnginePoses.gBlockH
        case "gBlockL": return EnginePoses.gBlockL
        case "gHurt": return EnginePoses.gHurt
        case "gDead": return EnginePoses.gDead
        case "gStun": return EnginePoses.gStun
        case "gWin": return EnginePoses.gWin
        default: return EnginePoses.gIdle
        }
    }

    func getPlayerPoseVector(_ key: String) -> [Double] {
        switch key {
        case "kGuard": return EnginePoses.kGuard
        case "kParry": return EnginePoses.kParry
        case "kWind": return EnginePoses.kWind
        case "kSlash": return EnginePoses.kSlash
        case "kThrust": return EnginePoses.kThrust
        case "kOver": return EnginePoses.kOver
        case "kDuck": return EnginePoses.kDuck
        case "kJump": return EnginePoses.kJump
        case "kDodge": return EnginePoses.kDodge
        case "kHurt": return EnginePoses.kHurt
        case "kDead": return EnginePoses.kDead
        case "kWin": return EnginePoses.kWin
        case "kStun": return EnginePoses.kStun
        default: return EnginePoses.kIdle
        }
    }
}
