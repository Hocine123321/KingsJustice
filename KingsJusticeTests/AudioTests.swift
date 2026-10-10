import XCTest
import AVFoundation
@testable import KingsJustice

final class AudioTests: XCTestCase {
    func testSynthProducesValidBuffersForEverySfxKind() {
        let allKinds: [SfxKind] = [
            .clang, .thud, .slash, .whoosh, .heartbeat, .bell,
            .heavy, .parry, .perfect, .hurt, .block, .miss,
            .uiTap, .uiConfirm, .focus, .potion, .win, .lose
        ]

        for kind in allKinds {
            for variant in 0..<3 {
                let samples = Synth.buffer(for: kind, variant: variant, sampleRate: 44100.0)
                XCTAssertFalse(samples.isEmpty, "Buffer for \(kind) variant \(variant) should not be empty")

                var peak: Float = 0.0
                for sample in samples {
                    XCTAssertFalse(sample.isNaN, "Sample in \(kind) variant \(variant) should not be NaN")
                    XCTAssertFalse(sample.isInfinite, "Sample in \(kind) variant \(variant) should not be Infinite")
                    peak = max(peak, abs(sample))
                }

                XCTAssertLessThanOrEqual(peak, 1.0 + 1e-5, "Peak for \(kind) variant \(variant) should be <= 1.0, got \(peak)")
            }
        }
    }

    func testScaleTablesProduceCorrectOffsets() {
        XCTAssertEqual(Synth.scaleOffsets(for: "minor"), [0, 2, 3, 5, 7, 8, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "phrygian"), [0, 1, 3, 5, 7, 8, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "locrian"), [0, 1, 3, 5, 6, 8, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "aeolian"), [0, 2, 3, 5, 7, 8, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "dorian"), [0, 2, 3, 5, 7, 9, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "major"), [0, 2, 4, 5, 7, 9, 11])
        XCTAssertEqual(Synth.scaleOffsets(for: "mixolydian"), [0, 2, 4, 5, 7, 9, 10])
        XCTAssertEqual(Synth.scaleOffsets(for: "lydian"), [0, 2, 4, 6, 7, 9, 11])
        XCTAssertEqual(Synth.scaleOffsets(for: "melodicminor"), [0, 2, 3, 5, 7, 9, 11])
        XCTAssertEqual(Synth.scaleOffsets(for: "pentatonicminor"), [0, 3, 5, 7, 10])
    }

    func testSetVolumesClamping() {
        AudioEngine.shared.setVolumes(music: -0.5, sfx: 1.5)
        XCTAssertEqual(AudioEngine.shared.musicVolume, 0.0, accuracy: 1e-5)
        XCTAssertEqual(AudioEngine.shared.sfxVolume, 1.0, accuracy: 1e-5)

        AudioEngine.shared.setVolumes(music: 0.7, sfx: 0.3)
        XCTAssertEqual(AudioEngine.shared.musicVolume, 0.7, accuracy: 1e-5)
        XCTAssertEqual(AudioEngine.shared.sfxVolume, 0.3, accuracy: 1e-5)
    }

    func testDrumAndBassSynthesis() {
        let drumKinds = ["kick", "snare", "hat", "openhat", "ghosthat", "tom"]
        for d in drumKinds {
            let samples = Synth.drumBuffer(for: d, variant: 0, sampleRate: 44100.0)
            XCTAssertFalse(samples.isEmpty)
            for sample in samples {
                XCTAssertFalse(sample.isNaN)
                XCTAssertFalse(sample.isInfinite)
            }
        }

        let bassSamples = Synth.bassBuffer(midiNote: 45, duration: 0.3, sampleRate: 44100.0)
        XCTAssertFalse(bassSamples.isEmpty)
        for sample in bassSamples {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
        }

        let droneSamples = Synth.droneBuffer(root: 45, scaleName: "minor", duration: 1.0, sampleRate: 44100.0)
        XCTAssertFalse(droneSamples.isEmpty)
        for sample in droneSamples {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
        }
    }

    func testPadAndLeadAndStingerSynthesis() {
        let padSamples = Synth.padBuffer(midiNote: 45, chordType: "minor", duration: 1.0, sampleRate: 44100.0)
        XCTAssertFalse(padSamples.isEmpty, "Pad buffer should not be empty")

        var padPeak: Float = 0.0
        for sample in padSamples {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
            padPeak = max(padPeak, abs(sample))
        }
        XCTAssertLessThanOrEqual(padPeak, 1.0 + 1e-5, "Pad peak should be <= 1.0, got \(padPeak)")

        let leadSamples = Synth.leadBuffer(midiNote: 60, style: "choir", duration: 0.5, sampleRate: 44100.0)
        XCTAssertFalse(leadSamples.isEmpty, "Lead buffer should not be empty")

        var leadPeak: Float = 0.0
        for sample in leadSamples {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
            leadPeak = max(leadPeak, abs(sample))
        }
        XCTAssertLessThanOrEqual(leadPeak, 1.0 + 1e-5, "Lead peak should be <= 1.0, got \(leadPeak)")

        let winStinger = Synth.stingerBuffer(win: true, sampleRate: 44100.0)
        XCTAssertFalse(winStinger.isEmpty)
        for sample in winStinger {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
        }

        let loseStinger = Synth.stingerBuffer(win: false, sampleRate: 44100.0)
        XCTAssertFalse(loseStinger.isEmpty)
        for sample in loseStinger {
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
        }
    }

    /// Regression: scheduling a mono synth buffer on a player connected to a stereo mixer
    /// asserted "_outputFormat.channelCount == buffer.format.channelCount" and crashed the game.
    func testMonoBufferSchedulesOnMonoConnectedPlayer() throws {
        let engine = AVAudioEngine()
        let mixer = AVAudioMixerNode()
        let player = AVAudioPlayerNode()
        engine.attach(mixer)
        engine.attach(player)

        let mono = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
        engine.connect(player, to: mixer, format: mono)

        let stereo = AVAudioFormat(standardFormatWithSampleRate: 48000.0, channels: 2)!
        try engine.enableManualRenderingMode(.offline, format: stereo, maximumFrameCount: 4096)
        try engine.start()

        let samples = Synth.buffer(for: .clang, variant: 0, sampleRate: 44100.0)
        let buffer = try XCTUnwrap(Synth.pcmBuffer(from: samples))
        XCTAssertEqual(player.outputFormat(forBus: 0).channelCount, buffer.format.channelCount)

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()

        let out = AVAudioPCMBuffer(pcmFormat: stereo, frameCapacity: 4096)!
        let status = try engine.renderOffline(1024, to: out)
        XCTAssertNotEqual(status, .error)
        engine.stop()
    }

    func testUIAudioHelpersAndAudioEngineMusicAPIs() {
        UIAudio.startArenaMusic(root: 48, scale: "minor", bpm: 92.0)
        UIAudio.setMusicIntensity(0.8)
        UIAudio.playStinger(win: true)
        UIAudio.stopMusic(fade: false)

        UIAudio.startMenuMusic()
        UIAudio.stopMusic(fadeDuration: 0.1)
    }

    func testMusicNoteSetsStaySmallForEveryArena() {
        // Starting a track must only render a handful of notes, never the whole library (this caused a freeze at fight start).
        for (_, arena) in GameData.arenas {
            let sets = AudioEngine.musicNoteSets(root: arena.music.root, scale: arena.music.scale)
            XCTAssertFalse(sets.pad.isEmpty, "\(arena.key) needs pad notes")
            XCTAssertLessThanOrEqual(sets.pad.count, 4)
            XCTAssertLessThanOrEqual(sets.bass.count, 4)
            XCTAssertLessThanOrEqual(sets.lead.count, 8)
        }
        let menu = AudioEngine.musicNoteSets(root: 45, scale: "aeolian")
        XCTAssertFalse(menu.lead.isEmpty)
    }

    func testRepeatedMenuMusicStartsDoNotCrash() {
        for _ in 0..<5 { AudioEngine.shared.startMenuMusic() }
        AudioEngine.shared.stopMusic(fadeDuration: 0.0)
    }
}

final class MusicThemeTests: XCTestCase {
    func testEveryArenaHasAWellFormedTheme() {
        for key in GameData.arenas.keys {
            guard let theme = MusicThemes.theme(for: key) else {
                XCTFail("Missing music theme for \(key)")
                continue
            }
            XCTAssertEqual(theme.chordDegrees.count, 4, key)
            XCTAssertEqual(theme.melody.count, 4, key)
            for bar in theme.melody { XCTAssertEqual(bar.count, 16, key) }
            for d in theme.chordDegrees { XCTAssertTrue(d >= 0 && d < 7, key) }
            for s in theme.kickSteps.union(theme.snareSteps) { XCTAssertTrue(s >= 0 && s < 16, key) }
            XCTAssertTrue(theme.melody.flatMap { $0 }.contains { $0 >= 0 }, "\(key) melody is silent")
        }
    }

    func testThemesAreDistinct() {
        let progressions = GameData.arenas.keys.compactMap { MusicThemes.theme(for: $0)?.chordDegrees }
        XCTAssertEqual(Set(progressions.map { $0.map(String.init).joined(separator: ",") }).count, progressions.count)
    }

    func testThemedNoteSetsCoverEveryChord() {
        for (key, arena) in GameData.arenas {
            guard let theme = MusicThemes.theme(for: key) else { continue }
            let offsets = Synth.scaleOffsets(for: arena.music.scale)
            let sets = AudioEngine.musicNoteSets(root: arena.music.root, scale: arena.music.scale, style: key)
            for d in theme.chordDegrees {
                let chordRoot = arena.music.root + offsets[min(d, offsets.count - 1)]
                XCTAssertTrue(sets.bass.contains(max(24, min(55, chordRoot - 12))), "\(key) bass missing")
                XCTAssertTrue(sets.pad.contains(max(36, min(60, chordRoot - 12))), "\(key) pad missing")
            }
        }
    }

    func testUnknownStyleKeepsGenericPattern() {
        XCTAssertNil(MusicThemes.theme(for: "default"))
    }
}
