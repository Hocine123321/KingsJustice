import SwiftUI
import Combine
import UIKit

enum AppScreen: Equatable {
    case title
    case menu
    case campaign
    case style
    case shop
    case settings
    case fight
}

/// Drives `engine.tick(dt:)` once per display frame.
final class FrameClock: ObservableObject {
    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0
    var onFrame: ((Double) -> Void)?

    func start() {
        stop()
        last = CACurrentMediaTime()
        let l = CADisplayLink(target: self, selector: #selector(step))
        l.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        l.add(to: .main, forMode: .common)
        link = l
    }

    func stop() {
        link?.invalidate()
        link = nil
    }

    @objc private func step() {
        let now = CACurrentMediaTime()
        var dt = now - last
        last = now
        if dt > 0.05 { dt = 0.05 }
        if dt < 0 { dt = 0 }
        onFrame?(dt)
    }
}

struct RootView: View {
    @StateObject private var engine: GameEngine = GameEngine()
    @StateObject private var clock: FrameClock = FrameClock()
    @State private var screen: AppScreen = .title
    @State private var settingsFromPause: Bool = false
    @State private var pendingMode: String = "duel"

    init() {}

    var body: some View {
        ZStack {
            UITheme.bgNearBlack.ignoresSafeArea()
            content
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .onAppear { setupEngine() }
        .onDisappear { clock.stop() }
        .onChange(of: engine.settings) { _ in
            UIAudio.setVolumes(music: engine.settings.music, sfx: engine.settings.sfx)
            engine.saveAll()
        }
        .onChange(of: engine.started) { _ in
            if engine.on == false && screen == .fight { leaveFight() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .title:
            TitleView(onBegin: {
                UIAudio.onFirstUserTap()
                UIAudio.setVolumes(music: engine.settings.music, sfx: engine.settings.sfx)
                UIAudio.playSfx(.uiConfirm)
                screen = .menu
            })
        case .menu:
            MainMenuView(
                engine: engine,
                onSelectMode: { (mode: String) in
                    UIAudio.playSfx(.uiTap)
                    pendingMode = mode
                    if mode == "duel" {
                        screen = .campaign
                    } else {
                        startFight(mode: mode, index: 0)
                    }
                },
                onSelectStyle: { screen = .style },
                onSelectShop: { screen = .shop },
                onSelectSettings: {
                    settingsFromPause = false
                    screen = .settings
                },
                onWatchCinematic: { }
            )
        case .campaign:
            CampaignSelectView(
                engine: engine,
                onSelectOpponent: { (i: Int) in startFight(mode: "duel", index: i) },
                onBack: { screen = .menu }
            )
        case .style:
            StyleSelectView(engine: engine, onBack: { screen = .menu })
        case .shop:
            ShopView(engine: engine, onBack: { screen = .menu })
        case .settings:
            SettingsView(engine: engine, onBack: {
                screen = settingsFromPause ? .fight : .menu
            })
        case .fight:
            fightLayer
        }
    }

    private var fightLayer: some View {
        ZStack {
            GameSceneView(source: engine)
                .ignoresSafeArea()
            FightHudView(engine: engine)
            if engine.paused && !engine.over {
                PauseView(engine: engine, onSelectSettings: {
                    settingsFromPause = true
                    screen = .settings
                })
            }
            if engine.over {
                EndScreenView(
                    engine: engine,
                    onNext: { nextFight() },
                    onRetry: { startFight(mode: engine.mode, index: engine.enemyIdx) },
                    onShop: {
                        leaveFight()
                        screen = .shop
                    },
                    onMainMenu: { leaveFight() }
                )
            }
        }
    }

    // MARK: - Flow

    private func setupEngine() {
        engine.onSfx = { (kind: SfxKind, intensity: Double) in
            UIAudio.playSfx(kind, intensity: intensity)
        }
        engine.onHapticHook()
        clock.onFrame = { (dt: Double) in
            engine.tick(dt: dt)
        }
        clock.start()
        UIAudio.setVolumes(music: engine.settings.music, sfx: engine.settings.sfx)
    }

    private func startFight(mode: String, index: Int) {
        UIApplication.shared.isIdleTimerDisabled = true
        engine.startRun(mode: mode, enemyIndex: index)
        screen = .fight
    }

    private func nextFight() {
        let count = GameData.roster.count
        if engine.won && engine.mode == "duel" && engine.enemyIdx + 1 < count {
            startFight(mode: "duel", index: engine.enemyIdx + 1)
        } else if engine.won && (engine.mode == "survival" || engine.mode == "rush") {
            engine.beginFight(index: engine.enemyIdx + 1)
        } else {
            leaveFight()
        }
    }

    private func leaveFight() {
        UIApplication.shared.isIdleTimerDisabled = false
        engine.quitToMenu()
        AudioEngine.shared.stopMusic()
        AudioEngine.shared.stopDrone()
        screen = .menu
    }
}

extension GameEngine {
    /// Connects the engine's haptic callback to the device haptics.
    func onHapticHook() {
        self.onHaptic = { (name: String) in
            if self.settings.haptics { UIAudio.triggerHaptic(name) }
        }
    }
}
