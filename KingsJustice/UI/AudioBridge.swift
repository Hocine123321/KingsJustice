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
}
