import Foundation
import AVFoundation
import QuartzCore
#if canImport(UIKit)
import UIKit
#endif

final class AudioEngine {
    static let shared = AudioEngine()

    private let engine = AVAudioEngine()
    private let sfxMixer = AVAudioMixerNode()
    private let musicMixer = AVAudioMixerNode()

    private var sfxPlayerPool: [AVAudioPlayerNode] = []
    private var nextPlayerIndex = 0
    private let poolSize = 12

    private let dronePlayer = AVAudioPlayerNode()

    private let musicKickPlayer = AVAudioPlayerNode()
    private let musicSnarePlayer = AVAudioPlayerNode()
    private let musicHatPlayer = AVAudioPlayerNode()
    private let musicTomPlayer = AVAudioPlayerNode()
    private let musicBassPlayer = AVAudioPlayerNode()

    private var sfxBuffers: [SfxKind: [AVAudioPCMBuffer]] = [:]
    private var drumBuffers: [String: [AVAudioPCMBuffer]] = [:]
    private var currentDroneBuffer: AVAudioPCMBuffer?

    private(set) var isReady = false
    private var isStarted = false

    private(set) var musicVolume: Double = 0.8
    private(set) var sfxVolume: Double = 0.9
    private var outputLatencyCompensationMs: Double = 0.0

    // Music scheduler state
    private var isMusicPlaying = false
    private var musicRoot: Int = 45
    private var musicScale: String = "minor"
    private var musicBPM: Double = 80.0
    private var musicIntensity: Double = 0.5
    private var musicStartTime: Double = 0.0
    private var musicStepIndex: Int = 0
    private var nextBeatTime: Double = 0.0

    private var musicTimer: DispatchSourceTimer?
    private let musicQueue = DispatchQueue(label: "com.kingsjustice.audio.music", qos: .userInteractive)
    private let synthQueue = DispatchQueue(label: "com.kingsjustice.audio.synth", qos: .userInitiated)

    private init() {
        setupAudioSessionObservers()
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        configureAudioSession()
        setupNodes()

        synthQueue.async { [weak self] in
            self?.preloadBuffers()
        }
    }

    func stop() {
        stopMusic()
        stopDrone()

        engine.stop()
        isStarted = false
    }

    func setVolumes(music: Double, sfx: Double) {
        musicVolume = max(0.0, min(1.0, music))
        sfxVolume = max(0.0, min(1.0, sfx))

        musicMixer.outputVolume = Float(musicVolume)
        sfxMixer.outputVolume = Float(sfxVolume)
    }

    func sfx(_ kind: SfxKind, intensity: Double = 1.0) {
        guard isReady, isStarted else { return }
        guard let variants = sfxBuffers[kind], !variants.isEmpty else { return }

        let clampedIntensity = Float(max(0.0, min(1.0, intensity)))
        let variantIndex = Int.random(in: 0..<variants.count)
        let buffer = variants[variantIndex]

        let player = sfxPlayerPool[nextPlayerIndex]
        nextPlayerIndex = (nextPlayerIndex + 1) % poolSize

        player.volume = clampedIntensity
        player.stop()
        safeSchedule(player, buffer)
        player.play()
    }

    func drum(_ kind: String, intensity: Double = 1.0) {
        guard isReady, isStarted else { return }
        let k = kind.lowercased()
        guard let variants = drumBuffers[k], !variants.isEmpty else { return }

        let clampedIntensity = Float(max(0.0, min(1.0, intensity)))
        let buffer = variants[0]

        let player = sfxPlayerPool[nextPlayerIndex]
        nextPlayerIndex = (nextPlayerIndex + 1) % poolSize

        player.volume = clampedIntensity
        player.stop()
        safeSchedule(player, buffer)
        player.play()
    }

    func startDrone(root: Int, scale: String) {
        guard isStarted else { return }

        synthQueue.async { [weak self] in
            let samples = Synth.droneBuffer(root: root, scaleName: scale, duration: 3.0, sampleRate: 44100.0)
            guard let buf = Synth.pcmBuffer(from: samples, sampleRate: 44100.0) else { return }

            DispatchQueue.main.async {
                guard let self = self, self.isStarted else { return }
                self.currentDroneBuffer = buf
                self.dronePlayer.stop()
                self.dronePlayer.volume = 0.5
                self.safeSchedule(self.dronePlayer, buf, loops: true)
                self.dronePlayer.play()
            }
        }
    }

    func startDrone() {
        startDrone(root: 45, scale: "minor")
    }

    func stopDrone() {
        dronePlayer.stop()
    }

    func startMusic(root: Int, scale: String, bpm: Double) {
        stopMusic()

        musicRoot = root
        musicScale = scale
        musicBPM = max(30.0, min(240.0, bpm))
        musicIntensity = 0.5
        musicStartTime = CACurrentMediaTime()
        musicStepIndex = 0
        nextBeatTime = musicStartTime

        isMusicPlaying = true

        let timer = DispatchSource.makeTimerSource(queue: musicQueue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(20))
        timer.setEventHandler { [weak self] in
            self?.tickMusicScheduler()
        }
        timer.resume()
        musicTimer = timer
    }

    func startMusic(root: Int = 45, scale: String = "minor") {
        startMusic(root: root, scale: scale, bpm: 80.0)
    }

    func setMusicBPM(_ bpm: Double) {
        musicBPM = max(30.0, min(240.0, bpm))
    }

    func setMusicIntensity(_ v: Double) {
        musicIntensity = max(0.0, min(1.0, v))
    }

    func stopMusic() {
        isMusicPlaying = false
        musicTimer?.cancel()
        musicTimer = nil

        musicKickPlayer.stop()
        musicSnarePlayer.stop()
        musicHatPlayer.stop()
        musicTomPlayer.stop()
        musicBassPlayer.stop()
    }

    func beatTime() -> Double {
        guard isMusicPlaying else { return 0.0 }
        let now = CACurrentMediaTime()
        let comp = outputLatencyCompensationMs / 1000.0
        return max(0.0, now - musicStartTime - comp)
    }

    func pauseAll() {
        engine.pause()
    }

    func resumeAll() {
        if isStarted && !engine.isRunning {
            try? engine.start()
        }
    }

    func setOutputLatencyCompensationMs(_ ms: Double) {
        outputLatencyCompensationMs = max(-500.0, min(500.0, ms))
    }

    // MARK: - Private Setup

    private func configureAudioSession() {
        #if canImport(AVFoundation)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
        #endif
    }

    private func setupAudioSessionObservers() {
        #if canImport(AVFoundation)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif
        #endif
    }

    @objc private func handleInterruption(notification: Notification) {
        #if canImport(AVFoundation)
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    resumeAll()
                }
            }
        } else if type == .began {
            pauseAll()
        }
        #endif
    }

    @objc private func handleAppBackground() {
        pauseAll()
    }

    @objc private func handleAppForeground() {
        resumeAll()
    }

    /// Schedules a buffer only when it is safe to do so. Prevents the AVAudioPlayerNode
    /// channel-count assertion (and silent players) if the engine is down or formats differ.
    private func safeSchedule(_ player: AVAudioPlayerNode, _ buffer: AVAudioPCMBuffer, loops: Bool = false) {
        guard engine.isRunning else {
            do { try engine.start() } catch { return }
            if !engine.isRunning { return }
        }
        let out = player.outputFormat(forBus: 0)
        guard out.channelCount == buffer.format.channelCount else { return }
        player.scheduleBuffer(buffer, at: nil, options: loops ? .loops : [], completionHandler: nil)
        if !player.isPlaying { player.play() }
    }

    private func setupNodes() {
        engine.attach(sfxMixer)
        engine.attach(musicMixer)

        let mainMixer = engine.mainMixerNode
        engine.connect(sfxMixer, to: mainMixer, format: nil)
        engine.connect(musicMixer, to: mainMixer, format: nil)

        // All synthesized buffers are mono 44.1 kHz. Players must be connected with exactly that
        // format, otherwise scheduling a buffer asserts on channelCount mismatch.
        let monoFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)

        for _ in 0..<poolSize {
            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: sfxMixer, format: monoFormat)
            sfxPlayerPool.append(player)
        }

        engine.attach(dronePlayer)
        engine.connect(dronePlayer, to: sfxMixer, format: monoFormat)

        let musicPlayers = [musicKickPlayer, musicSnarePlayer, musicHatPlayer, musicTomPlayer, musicBassPlayer]
        for p in musicPlayers {
            engine.attach(p)
            engine.connect(p, to: musicMixer, format: monoFormat)
        }

        sfxMixer.outputVolume = Float(sfxVolume)
        musicMixer.outputVolume = Float(musicVolume)

        do {
            try engine.start()
        } catch {
            // Safe fallback when audio output is unavailable
        }
    }

    private func preloadBuffers() {
        let sr = 44100.0
        let allKinds: [SfxKind] = [
            .clang, .thud, .slash, .whoosh, .heartbeat, .bell,
            .heavy, .parry, .perfect, .hurt, .block, .miss,
            .uiTap, .uiConfirm, .focus, .potion, .win, .lose
        ]

        var newSfxBuffers: [SfxKind: [AVAudioPCMBuffer]] = [:]
        for kind in allKinds {
            var variants: [AVAudioPCMBuffer] = []
            for v in 0..<3 {
                let samples = Synth.buffer(for: kind, variant: v, sampleRate: sr)
                if let buf = Synth.pcmBuffer(from: samples, sampleRate: sr) {
                    variants.append(buf)
                }
            }
            newSfxBuffers[kind] = variants
        }

        let drumKinds = ["kick", "snare", "hat", "tom"]
        var newDrumBuffers: [String: [AVAudioPCMBuffer]] = [:]
        for dk in drumKinds {
            var variants: [AVAudioPCMBuffer] = []
            for v in 0..<2 {
                let samples = Synth.drumBuffer(for: dk, variant: v, sampleRate: sr)
                if let buf = Synth.pcmBuffer(from: samples, sampleRate: sr) {
                    variants.append(buf)
                }
            }
            newDrumBuffers[dk] = variants
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sfxBuffers = newSfxBuffers
            self.drumBuffers = newDrumBuffers
            self.isReady = true
        }
    }

    private func tickMusicScheduler() {
        guard isMusicPlaying else { return }

        let now = CACurrentMediaTime()
        let lookAhead = 0.2
        let stepDuration = (60.0 / musicBPM) / 2.0

        while nextBeatTime <= now + lookAhead {
            let delay = max(0.0, nextBeatTime - now)
            let step = musicStepIndex
            let currentRoot = musicRoot
            let currentScale = musicScale
            let currentIntensity = musicIntensity

            musicQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.playMusicStep(step: step, root: currentRoot, scale: currentScale, intensity: currentIntensity)
            }

            musicStepIndex = (musicStepIndex + 1) % 16
            nextBeatTime += stepDuration
        }
    }

    private func playMusicStep(step: Int, root: Int, scale: String, intensity: Double) {
        guard isMusicPlaying, isReady else { return }

        if step % 4 == 0 {
            playDrumPlayer(musicKickPlayer, kind: "kick", volume: 0.8)
        } else if step == 9 && intensity > 0.4 {
            playDrumPlayer(musicKickPlayer, kind: "kick", volume: 0.6)
        }

        if step == 4 || step == 12 {
            playDrumPlayer(musicSnarePlayer, kind: "snare", volume: 0.75)
        }

        if step % 2 == 0 || intensity > 0.6 {
            playDrumPlayer(musicHatPlayer, kind: "hat", volume: Float(0.3 + intensity * 0.2))
        }

        if (step == 14 && intensity > 0.3) || (step == 15 && intensity > 0.5) {
            playDrumPlayer(musicTomPlayer, kind: "tom", volume: 0.6)
        }

        if step % 3 == 0 || step == 7 || step == 11 {
            let scaleOffsets = Synth.scaleOffsets(for: scale)
            let degreeIdx: Int
            switch step {
            case 0, 6, 12: degreeIdx = 0
            case 3, 9: degreeIdx = min(2, scaleOffsets.count - 1)
            case 7, 11: degreeIdx = min(4, scaleOffsets.count - 1)
            default: degreeIdx = 0
            }

            let midiNote = root - 12 + scaleOffsets[degreeIdx]
            let bassSamples = Synth.bassBuffer(midiNote: midiNote, duration: 0.25, sampleRate: 44100.0)
            if let buf = Synth.pcmBuffer(from: bassSamples, sampleRate: 44100.0) {
                musicBassPlayer.stop()
                musicBassPlayer.volume = Float(0.5 + intensity * 0.3)
                safeSchedule(musicBassPlayer, buf)
                musicBassPlayer.play()
            }
        }
    }

    private func playDrumPlayer(_ player: AVAudioPlayerNode, kind: String, volume: Float) {
        guard let variants = drumBuffers[kind], !variants.isEmpty else { return }
        let buf = variants[0]
        player.stop()
        player.volume = volume
        safeSchedule(player, buf)
        player.play()
    }
}
