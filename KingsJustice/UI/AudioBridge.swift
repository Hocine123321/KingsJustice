import Foundation

/// Unified Audio & Haptics bridge for UI triggers.
public enum UIAudio {
    private static var hasStartedAudio: Bool = false
    
    public static func onFirstUserTap() {
        guard !hasStartedAudio else { return }
        hasStartedAudio = true
        AudioEngine.shared.start()
    }
    
    public static func playSfx(_ kind: SfxKind, intensity: Double = 1.0) {
        AudioEngine.shared.sfx(kind, intensity: intensity)
    }
    
    public static func setVolumes(music: Double, sfx: Double) {
        AudioEngine.shared.setVolumes(music: music, sfx: sfx)
    }
    
    public static func triggerHaptic(_ kind: String = "tap") {
        Haptics.play(kind)
    }
}
