import Foundation

/// Unified Audio & Haptics bridge for UI triggers.
enum UIAudio {
    private static var hasStartedAudio: Bool = false

    static func onFirstUserTap() {
        guard !hasStartedAudio else { return }
        hasStartedAudio = true
        AudioEngine.shared.start()
    }

    static func playSfx(_ kind: SfxKind, intensity: Double = 1.0) {
        AudioEngine.shared.sfx(kind, intensity: intensity)
    }

    static func setVolumes(music: Double, sfx: Double) {
        AudioEngine.shared.setVolumes(music: music, sfx: sfx)
    }

    static func triggerHaptic(_ kind: String = "tap") {
        Haptics.play(kind)
    }

    // MARK: - Music & Ambience Helpers

    /// Starts arena background music with specified root MIDI pitch, scale name, and tempo BPM.
    static func startArenaMusic(root: Int, scale: String, bpm: Double, theme: String = "default") {
        onFirstUserTap()
        AudioEngine.shared.startMusic(root: root, scale: scale, bpm: bpm, style: theme, isMenu: false)
    }

    /// Starts serene, drum-less menu and idle ambience music.
    static func startMenuMusic() {
        onFirstUserTap()
        AudioEngine.shared.startMenuMusic()
    }

    /// Stops music playback with optional fade-out (default 0.5s fade).
    static func stopMusic(fade: Bool = true) {
        AudioEngine.shared.stopMusic(fadeDuration: fade ? 0.5 : 0.0)
    }

    /// Stops music playback with a specific fade-out duration in seconds.
    static func stopMusic(fadeDuration: Double) {
        AudioEngine.shared.stopMusic(fadeDuration: fadeDuration)
    }

    /// Updates dynamic music intensity (0.0 to 1.0) for combat layering.
    static func setMusicIntensity(_ intensity: Double) {
        AudioEngine.shared.setMusicIntensity(intensity)
    }

    /// Plays a rich victory (win: true) or defeat (win: false) stinger fanfare.
    static func playStinger(win: Bool) {
        AudioEngine.shared.playStinger(win: win)
    }
}
