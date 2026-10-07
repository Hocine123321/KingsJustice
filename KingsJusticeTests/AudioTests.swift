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
        let drumKinds = ["kick", "snare", "hat", "tom"]
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
}
