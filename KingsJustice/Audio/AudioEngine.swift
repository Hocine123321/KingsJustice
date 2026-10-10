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
    private let ambiencePlayer = AVAudioPlayerNode()
    private var ambienceKind: String = ""

    // Drum players
    private let musicKickPlayer = AVAudioPlayerNode()
    private let musicSnarePlayer = AVAudioPlayerNode()
    private let musicHatPlayer = AVAudioPlayerNode()
    private let musicTomPlayer = AVAudioPlayerNode()

    // Player pools for round-robin overlapping notes (click-free)
    private var musicBassPlayers: [AVAudioPlayerNode] = []
    private var nextBassPlayerIndex = 0

    private var musicPadPlayers: [AVAudioPlayerNode] = []
    private var nextPadPlayerIndex = 0

    private var musicLeadPlayers: [AVAudioPlayerNode] = []
    private var nextLeadPlayerIndex = 0

    private let stingerPlayer = AVAudioPlayerNode()

    // Pre-rendered Buffers
    private var sfxBuffers: [SfxKind: [AVAudioPCMBuffer]] = [:]
    private var drumBuffers: [String: [AVAudioPCMBuffer]] = [:]
    private var bassBuffers: [Int: AVAudioPCMBuffer] = [:] // midiNote -> PCMBuffer
    private var padBuffers: [String: AVAudioPCMBuffer] = [:] // "midiNote_chordType" -> PCMBuffer
    private var leadBuffers: [String: AVAudioPCMBuffer] = [:] // "midiNote_style" -> PCMBuffer
    /// Guards bassBuffers / padBuffers / leadBuffers, which are written on the synth queue and read on the music queue.
    private let musicBufferLock = NSLock()
    /// Incremented on every start/stop so stale background renders can't start an old track.
    private var musicGeneration: Int = 0
    private var isMenuTrackActive = false
    private var stingerWinBuffer: AVAudioPCMBuffer?
    private var stingerLoseBuffer: AVAudioPCMBuffer?
    private var currentDroneBuffer: AVAudioPCMBuffer?

    private(set) var isReady = false
    private var isStarted = false

    private(set) var musicVolume: Double = 0.8
    private(set) var sfxVolume: Double = 0.9
    private var outputLatencyCompensationMs: Double = 0.0

    // Music scheduler state
    private var isMusicPlaying = false
    private var isMenuMusicMode = false
    private var musicRoot: Int = 45
    private var musicScale: String = "minor"
    private var musicBPM: Double = 80.0
    private var musicIntensity: Double = 0.5
    private var musicStyle: String = "default"
    private var musicStartTime: Double = 0.0
    private var musicStepIndex: Int = 0
    private var nextBeatTime: Double = 0.0

    private var musicTimer: DispatchSourceTimer?
    private var fadeTimer: DispatchSourceTimer?

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
        stopMusic(fadeDuration: 0.0)
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
        stopAmbience()
    }

    /// Starts a looping background bed (wind, crowd, fire, swamp, waves, hum). Restarting the same bed is a no-op.
    func startAmbience(kind: String, volume: Float = 0.32) {
        guard isStarted else { return }
        if kind == ambienceKind && ambiencePlayer.isPlaying { return }
        ambienceKind = kind

        synthQueue.async { [weak self] in
            let samples = Synth.ambienceBuffer(kind: kind, duration: 8.0, sampleRate: 44100.0)
            guard let buf = Synth.pcmBuffer(from: samples, sampleRate: 44100.0) else { return }

            DispatchQueue.main.async {
                guard let self = self, self.isStarted, self.ambienceKind == kind else { return }
                self.ambiencePlayer.stop()
                self.ambiencePlayer.volume = volume
                self.safeSchedule(self.ambiencePlayer, buf, loops: true)
                self.ambiencePlayer.play()
            }
        }
    }

    func stopAmbience() {
        ambienceKind = ""
        ambiencePlayer.stop()
    }

    func startMusic(root: Int, scale: String, bpm: Double) {
        startMusic(root: root, scale: scale, bpm: bpm, style: "default", isMenu: false)
    }

    func startMusic(root: Int = 45, scale: String = "minor") {
        startMusic(root: root, scale: scale, bpm: 80.0, style: "default", isMenu: false)
    }

    func startMusic(root: Int, scale: String, bpm: Double, style: String = "default", isMenu: Bool = false) {
        cancelFadeTimer()
        stopMusic(fadeDuration: 0.0)
        musicGeneration += 1
        let generation = musicGeneration

        musicRoot = root
        musicScale = scale
        musicBPM = max(30.0, min(240.0, bpm))
        musicStyle = style
        isMenuMusicMode = isMenu
        isMenuTrackActive = isMenu
        musicIntensity = isMenu ? 0.3 : 0.5
        musicMixer.outputVolume = Float(musicVolume)

        // Render only the notes this track needs, off the main thread, then start the scheduler.
        let isChoir = (scale.lowercased() == "aeolian" || style == "choir" || scale.lowercased() == "cathedral")
        let isDark = (scale.lowercased() == "phrygian" || scale.lowercased() == "locrian" || scale.lowercased() == "swamp")
        synthQueue.async { [weak self] in
            guard let self = self else { return }
            self.renderMusicBuffers(root: root, scale: scale, isChoir: isChoir, isDark: isDark, style: style)
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.musicGeneration == generation else { return }
                self.beginMusicScheduler()
            }
        }
    }

    private func beginMusicScheduler() {
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

    /// The distinct pad, bass and lead notes a track can reach. Small by design, so starting music never renders a whole library.
    static func musicNoteSets(root: Int, scale: String, style: String = "default") -> (pad: Set<Int>, bass: Set<Int>, lead: Set<Int>) {
        let offsets = Synth.scaleOffsets(for: scale)
        guard !offsets.isEmpty else { return ([], [], []) }

        var padNotes = Set<Int>()
        var bassNotes = Set<Int>()
        for degree in (MusicThemes.theme(for: style)?.chordDegrees ?? [0, 5, 2, 6]) {
            let d = min(degree, offsets.count - 1)
            let chordRoot = root + offsets[d]
            padNotes.insert(max(36, min(60, chordRoot - 12)))
            bassNotes.insert(max(24, min(55, chordRoot - 12)))
        }
        var leadNotes = Set<Int>()
        for i in 0..<offsets.count {
            leadNotes.insert(max(48, min(72, root + offsets[i])))
        }
        return (padNotes, bassNotes, leadNotes)
    }

    /// Synthesizes just the pad, bass and lead notes a track can reach. Runs on the synth queue.
    private func renderMusicBuffers(root: Int, scale: String, isChoir: Bool, isDark: Bool, style: String = "default") {
        let sr = 44100.0
        let sets = AudioEngine.musicNoteSets(root: root, scale: scale, style: style)
        let padNotes = sets.pad
        let bassNotes = sets.bass
        let leadNotes = sets.lead
        if padNotes.isEmpty { return }

        let padType = isChoir ? "choir" : (isDark ? "drone" : "minor")
        let leadStyle = isChoir ? "choir" : "plucked"

        for note in bassNotes {
            if hasMusicBuffer(bass: note) { continue }
            let samples = Synth.bassBuffer(midiNote: note, duration: 0.35, sampleRate: sr)
            if let buf = Synth.pcmBuffer(from: samples, sampleRate: sr) { storeMusicBuffer(bass: note, buf) }
        }
        for note in padNotes {
            let key = "\(note)_\(padType)"
            if hasMusicBuffer(pad: key) { continue }
            let samples = Synth.padBuffer(midiNote: note, chordType: padType, duration: 3.5, sampleRate: sr)
            if let buf = Synth.pcmBuffer(from: samples, sampleRate: sr) { storeMusicBuffer(pad: key, buf) }
        }
        for note in leadNotes {
            let key = "\(note)_\(leadStyle)"
            if hasMusicBuffer(lead: key) { continue }
            let samples = Synth.leadBuffer(midiNote: note, style: leadStyle, duration: 0.6, sampleRate: sr)
            if let buf = Synth.pcmBuffer(from: samples, sampleRate: sr) { storeMusicBuffer(lead: key, buf) }
        }
    }

    // MARK: - Thread-safe music buffer access

    private func musicBuffer(bass note: Int) -> AVAudioPCMBuffer? {
        musicBufferLock.lock(); defer { musicBufferLock.unlock() }
        return bassBuffers[note]
    }
    private func musicBuffer(pad key: String) -> AVAudioPCMBuffer? {
        musicBufferLock.lock(); defer { musicBufferLock.unlock() }
        return padBuffers[key]
    }
    private func musicBuffer(lead key: String) -> AVAudioPCMBuffer? {
        musicBufferLock.lock(); defer { musicBufferLock.unlock() }
        return leadBuffers[key]
    }
    private func hasMusicBuffer(bass note: Int) -> Bool { musicBuffer(bass: note) != nil }
    private func hasMusicBuffer(pad key: String) -> Bool { musicBuffer(pad: key) != nil }
    private func hasMusicBuffer(lead key: String) -> Bool { musicBuffer(lead: key) != nil }
    private func storeMusicBuffer(bass note: Int, _ buf: AVAudioPCMBuffer) {
        musicBufferLock.lock(); bassBuffers[note] = buf; musicBufferLock.unlock()
    }
    private func storeMusicBuffer(pad key: String, _ buf: AVAudioPCMBuffer) {
        musicBufferLock.lock(); padBuffers[key] = buf; musicBufferLock.unlock()
    }
    private func storeMusicBuffer(lead key: String, _ buf: AVAudioPCMBuffer) {
        musicBufferLock.lock(); leadBuffers[key] = buf; musicBufferLock.unlock()
    }

    /// Starts menu music only if it is not already playing, so moving between menu pages never restarts it.
    func startMenuMusic() {
        if isMenuTrackActive { return }
        startMusic(root: 45, scale: "aeolian", bpm: 60.0, style: "choir", isMenu: true)
    }

    func setMusicBPM(_ bpm: Double) {
        musicBPM = max(30.0, min(240.0, bpm))
    }

    func setMusicIntensity(_ v: Double) {
        musicIntensity = max(0.0, min(1.0, v))
    }

    func stopMusic() {
        stopMusic(fadeDuration: 0.0)
    }

    func stopMusic(fadeDuration: Double) {
        cancelFadeTimer()
        isMenuTrackActive = false
        musicGeneration += 1

        if fadeDuration <= 0.0 {
            isMusicPlaying = false
            musicTimer?.cancel()
            musicTimer = nil
            stopAllMusicPlayers()
            musicMixer.outputVolume = Float(musicVolume)
        } else {
            guard isMusicPlaying else { return }
            let startVol = musicMixer.outputVolume
            let steps = 20
            let stepInterval = max(0.01, fadeDuration / Double(steps))
            var currentStep = 0

            let fTimer = DispatchSource.makeTimerSource(queue: musicQueue)
            fTimer.schedule(deadline: .now(), repeating: .milliseconds(Int(stepInterval * 1000)))
            fTimer.setEventHandler { [weak self] in
                guard let self = self else { return }
                currentStep += 1
                let progress = Float(currentStep) / Float(steps)
                let newVol = max(0.0, startVol * (1.0 - progress))

                DispatchQueue.main.async {
                    self.musicMixer.outputVolume = newVol
                }

                if currentStep >= steps {
                    self.cancelFadeTimer()
                    self.isMusicPlaying = false
                    self.musicTimer?.cancel()
                    self.musicTimer = nil
                    self.stopAllMusicPlayers()
                    DispatchQueue.main.async {
                        self.musicMixer.outputVolume = Float(self.musicVolume)
                    }
                }
            }
            fTimer.resume()
            fadeTimer = fTimer
        }
    }

    func playStinger(win: Bool) {
        guard isReady, isStarted else { return }
        guard let buf = win ? stingerWinBuffer : stingerLoseBuffer else { return }

        stingerPlayer.volume = 1.0
        stingerPlayer.stop()
        safeSchedule(stingerPlayer, buf)
        stingerPlayer.play()
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
        if !engine.isRunning {
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
        engine.attach(ambiencePlayer)
        engine.connect(ambiencePlayer, to: sfxMixer, format: monoFormat)

        let drumPlayers = [musicKickPlayer, musicSnarePlayer, musicHatPlayer, musicTomPlayer, stingerPlayer]
        for p in drumPlayers {
            engine.attach(p)
            engine.connect(p, to: musicMixer, format: monoFormat)
        }

        // Bass round-robin pool
        for _ in 0..<4 {
            let p = AVAudioPlayerNode()
            engine.attach(p)
            engine.connect(p, to: musicMixer, format: monoFormat)
            musicBassPlayers.append(p)
        }

        // Pad round-robin pool
        for _ in 0..<4 {
            let p = AVAudioPlayerNode()
            engine.attach(p)
            engine.connect(p, to: musicMixer, format: monoFormat)
            musicPadPlayers.append(p)
        }

        // Lead round-robin pool
        for _ in 0..<4 {
            let p = AVAudioPlayerNode()
            engine.attach(p)
            engine.connect(p, to: musicMixer, format: monoFormat)
            musicLeadPlayers.append(p)
        }

        engine.prepare()
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

        let drumKinds = ["kick", "snare", "hat", "openhat", "ghosthat", "tom"]
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

        // Pre-render Stingers
        let winSamples = Synth.stingerBuffer(win: true, sampleRate: sr)
        let winBuf = Synth.pcmBuffer(from: winSamples, sampleRate: sr)

        let loseSamples = Synth.stingerBuffer(win: false, sampleRate: sr)
        let loseBuf = Synth.pcmBuffer(from: loseSamples, sampleRate: sr)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sfxBuffers = newSfxBuffers
            self.drumBuffers = newDrumBuffers
            self.stingerWinBuffer = winBuf
            self.stingerLoseBuffer = loseBuf
            self.isReady = true
        }
    }

    private func cancelFadeTimer() {
        fadeTimer?.cancel()
        fadeTimer = nil
    }

    private func stopAllMusicPlayers() {
        musicKickPlayer.stop()
        musicSnarePlayer.stop()
        musicHatPlayer.stop()
        musicTomPlayer.stop()
        for p in musicBassPlayers { p.stop() }
        for p in musicPadPlayers { p.stop() }
        for p in musicLeadPlayers { p.stop() }
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

            musicStepIndex = (musicStepIndex + 1) % 64
            nextBeatTime += stepDuration
        }
    }

    private func playMusicStep(step: Int, root: Int, scale: String, intensity: Double) {
        guard isMusicPlaying, isReady else { return }

        let scaleOffsets = Synth.scaleOffsets(for: scale)
        guard !scaleOffsets.isEmpty else { return }

        let bar = (step / 16) % 4
        let stepInBar = step % 16

        // 4-bar harmonic chord progression: bar 0 -> Root (deg 0), bar 1 -> deg 5/3, bar 2 -> deg 2/4, bar 3 -> deg 6/4
        let theme: MusicTheme? = isMenuMusicMode ? nil : MusicThemes.theme(for: musicStyle)
        let chordDegreeIndex: Int
        if let th = theme {
            chordDegreeIndex = min(th.chordDegrees[bar], scaleOffsets.count - 1)
        } else {
            switch bar {
            case 0: chordDegreeIndex = 0
            case 1: chordDegreeIndex = min(5, scaleOffsets.count - 1)
            case 2: chordDegreeIndex = min(2, scaleOffsets.count - 1)
            case 3: chordDegreeIndex = min(6, scaleOffsets.count - 1)
            default: chordDegreeIndex = 0
            }
        }
        let chordRootNote = root + scaleOffsets[chordDegreeIndex]

        let isChoirStyle = (scale.lowercased() == "aeolian" || musicStyle == "choir" || scale.lowercased() == "cathedral")
        let isDarkStyle = (scale.lowercased() == "phrygian" || scale.lowercased() == "locrian" || scale.lowercased() == "swamp")

        // 1. SUSTAINED PAD / DRONE LAYER (Bar changes)
        if stepInBar == 0 {
            let padType = isChoirStyle ? "choir" : (isDarkStyle ? "drone" : "minor")
            let padNote = max(36, min(60, chordRootNote - 12))
            let key = "\(padNote)_\(padType)"
            if let buf = musicBuffer(pad: key) ?? musicBuffer(pad: "\(padNote)_minor") {
                let p = musicPadPlayers[nextPadPlayerIndex]
                nextPadPlayerIndex = (nextPadPlayerIndex + 1) % musicPadPlayers.count
                p.volume = Float(0.35 + intensity * 0.25)
                safeSchedule(p, buf)
                p.play()
            }
        }

        // 2. BASS LAYER
        let playBass = (stepInBar % 4 == 0) || (stepInBar == 6 && intensity > 0.3) || (stepInBar == 10 && intensity > 0.5) || (stepInBar == 14)
        if playBass {
            let bassOctaveNote = max(24, min(55, chordRootNote - 12))
            if let buf = musicBuffer(bass: bassOctaveNote) {
                let p = musicBassPlayers[nextBassPlayerIndex]
                nextBassPlayerIndex = (nextBassPlayerIndex + 1) % musicBassPlayers.count
                p.volume = Float(0.5 + intensity * 0.35)
                safeSchedule(p, buf)
                p.play()
            }
        }

        // 3. LEAD / MELODY LAYER
        let playLeadNote: Bool
        var themedDegree = -1
        if isMenuMusicMode {
            playLeadNote = (stepInBar == 2 || stepInBar == 8 || stepInBar == 12)
        } else if let th = theme {
            themedDegree = th.melody[bar][stepInBar]
            playLeadNote = themedDegree >= 0
        } else {
            switch bar {
            case 0: playLeadNote = (stepInBar == 2 || stepInBar == 6 || stepInBar == 10)
            case 1: playLeadNote = (stepInBar == 2 || stepInBar == 6 || stepInBar == 9 || stepInBar == 12)
            case 2: playLeadNote = (stepInBar == 0 || stepInBar == 4 || stepInBar == 8 || stepInBar == 11 || stepInBar == 14)
            case 3: playLeadNote = (stepInBar == 2 || stepInBar == 6 || stepInBar == 10 || stepInBar == 14)
            default: playLeadNote = false
            }
        }

        if playLeadNote && (intensity > 0.2 || isMenuMusicMode) {
            let melodyDegreeIndex = themedDegree >= 0 ? (themedDegree % scaleOffsets.count) : ((stepInBar / 2) % scaleOffsets.count)
            let leadNote = max(48, min(72, root + scaleOffsets[melodyDegreeIndex]))
            let leadStyleName = isChoirStyle ? "choir" : "plucked"
            let key = "\(leadNote)_\(leadStyleName)"
            if let buf = musicBuffer(lead: key) ?? musicBuffer(lead: "\(leadNote)_plucked") {
                let p = musicLeadPlayers[nextLeadPlayerIndex]
                nextLeadPlayerIndex = (nextLeadPlayerIndex + 1) % musicLeadPlayers.count
                p.volume = Float(0.3 + intensity * 0.3)
                safeSchedule(p, buf)
                p.play()
            }
        }

        // 4. DRUMS LAYER (Muted in Menu mode)
        if !isMenuMusicMode, let th = theme {
            if th.kickSteps.contains(stepInBar) {
                playDrumPlayer(musicKickPlayer, kind: "kick", volume: 0.85)
            }
            if th.snareSteps.contains(stepInBar) {
                playDrumPlayer(musicSnarePlayer, kind: "snare", volume: 0.8)
            }
            if th.hatStride > 0 && stepInBar % th.hatStride == 0 {
                playDrumPlayer(musicHatPlayer, kind: "hat", volume: Float(0.28 + intensity * 0.25))
            }
            if th.tomFill && bar == 3 && stepInBar >= 12 {
                playDrumPlayer(musicTomPlayer, kind: "tom", volume: Float(0.5 + intensity * 0.3))
            }
        } else if !isMenuMusicMode {
            // Kick
            if stepInBar == 0 || stepInBar == 8 {
                playDrumPlayer(musicKickPlayer, kind: "kick", volume: 0.85)
            } else if (stepInBar == 4 && intensity > 0.6) || (stepInBar == 10 && intensity > 0.4) {
                playDrumPlayer(musicKickPlayer, kind: "kick", volume: 0.65)
            }

            // Snare
            if stepInBar == 4 || stepInBar == 12 {
                playDrumPlayer(musicSnarePlayer, kind: "snare", volume: 0.8)
            } else if bar == 3 && stepInBar == 15 && intensity > 0.5 {
                playDrumPlayer(musicSnarePlayer, kind: "snare", volume: 0.6)
            }

            // Hats & Ghost Hats
            if stepInBar % 2 == 0 {
                playDrumPlayer(musicHatPlayer, kind: "hat", volume: Float(0.3 + intensity * 0.25))
            } else if intensity > 0.45 {
                playDrumPlayer(musicHatPlayer, kind: "ghosthat", volume: Float(0.2 + intensity * 0.15))
            }

            // Tom Fills (4th bar or high intensity)
            if bar == 3 && (stepInBar >= 12 && stepInBar <= 15) {
                playDrumPlayer(musicTomPlayer, kind: "tom", volume: Float(0.5 + intensity * 0.3))
            } else if (stepInBar == 6 || stepInBar == 14) && intensity > 0.75 {
                playDrumPlayer(musicTomPlayer, kind: "tom", volume: 0.55)
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
