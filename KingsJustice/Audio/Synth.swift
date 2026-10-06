import Foundation
import AVFoundation

enum Synth {
    static func scaleOffsets(for scaleName: String) -> [Int] {
        switch scaleName.lowercased() {
        case "minor", "aeolian":
            return [0, 2, 3, 5, 7, 8, 10]
        case "phrygian":
            return [0, 1, 3, 5, 7, 8, 10]
        case "locrian":
            return [0, 1, 3, 5, 6, 8, 10]
        case "dorian":
            return [0, 2, 3, 5, 7, 9, 10]
        case "major":
            return [0, 2, 4, 5, 7, 9, 11]
        case "harmonicminor":
            return [0, 2, 3, 5, 7, 8, 11]
        default:
            return [0, 2, 3, 5, 7, 8, 10]
        }
    }

    static func midiToFreq(_ midi: Int) -> Double {
        return 440.0 * pow(2.0, Double(midi - 69) / 12.0)
    }

    static func buffer(for kind: SfxKind, variant: Int = 0, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        var samples: [Float] = []

        switch kind {
        case .clang:
            samples = synthClang(variant: variant, sampleRate: sr)
        case .thud:
            samples = synthThud(variant: variant, sampleRate: sr)
        case .slash:
            samples = synthSlash(variant: variant, sampleRate: sr)
        case .whoosh:
            samples = synthWhoosh(variant: variant, sampleRate: sr)
        case .heartbeat:
            samples = synthHeartbeat(variant: variant, sampleRate: sr)
        case .bell:
            samples = synthBell(variant: variant, sampleRate: sr)
        case .heavy:
            samples = synthHeavy(variant: variant, sampleRate: sr)
        case .parry:
            samples = synthParry(variant: variant, sampleRate: sr)
        case .perfect:
            samples = synthPerfect(variant: variant, sampleRate: sr)
        case .hurt:
            samples = synthHurt(variant: variant, sampleRate: sr)
        case .block:
            samples = synthBlock(variant: variant, sampleRate: sr)
        case .miss:
            samples = synthMiss(variant: variant, sampleRate: sr)
        case .uiTap:
            samples = synthUiTap(variant: variant, sampleRate: sr)
        case .uiConfirm:
            samples = synthUiConfirm(variant: variant, sampleRate: sr)
        case .focus:
            samples = synthFocus(variant: variant, sampleRate: sr)
        case .potion:
            samples = synthPotion(variant: variant, sampleRate: sr)
        case .win:
            samples = synthWin(variant: variant, sampleRate: sr)
        case .lose:
            samples = synthLose(variant: variant, sampleRate: sr)
        }

        normalize(&samples, targetPeak: 0.95)
        return samples
    }

    static func drumBuffer(for kind: String, variant: Int = 0, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        var samples: [Float] = []

        switch kind.lowercased() {
        case "kick":
            samples = synthKick(variant: variant, sampleRate: sr)
        case "snare":
            samples = synthSnare(variant: variant, sampleRate: sr)
        case "hat", "tick":
            samples = synthHat(variant: variant, sampleRate: sr)
        case "tom":
            samples = synthTom(variant: variant, sampleRate: sr)
        default:
            samples = synthKick(variant: variant, sampleRate: sr)
        }

        normalize(&samples, targetPeak: 0.95)
        return samples
    }

    static func bassBuffer(midiNote: Int, duration: Double = 0.4, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let totalFrames = Int(sr * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))
        let freq = midiToFreq(midiNote)

        var phase1 = 0.0
        var phase2 = 0.0
        let detune = 1.005

        for i in 0..<samples.count {
            let t = Double(i) / sr
            let env = Float(exp(-t * 6.0))

            let s1 = Float(2.0 * (phase1 - floor(phase1 + 0.5)))
            let s2 = Float(2.0 * (phase2 - floor(phase2 + 0.5)))

            samples[i] = (s1 * 0.6 + s2 * 0.4) * env

            phase1 += freq / sr
            if phase1 >= 1.0 { phase1 -= 1.0 }
            phase2 += (freq * detune) / sr
            if phase2 >= 1.0 { phase2 -= 1.0 }
        }

        normalize(&samples, targetPeak: 0.9)
        return samples
    }

    static func droneBuffer(root: Int, scaleName: String, duration: Double = 3.0, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let totalFrames = Int(sr * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let rootFreq = midiToFreq(root - 12)
        let fifthFreq = rootFreq * 1.498307

        var p1 = 0.0
        var p2 = 0.0
        var p3 = 0.0

        var lpState = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sr
            let lfo = 0.5 + 0.5 * sin(2.0 * .pi * 0.15 * t)
            let cutoff = 120.0 + lfo * 140.0
            let rc = 1.0 / (2.0 * .pi * cutoff)
            let alpha = (1.0 / sr) / (rc + 1.0 / sr)

            let s1 = 2.0 * (p1 - floor(p1 + 0.5))
            let s2 = 2.0 * (p2 - floor(p2 + 0.5))
            let s3 = 2.0 * (p3 - floor(p3 + 0.5))
            let noise = Double.random(in: -1.0...1.0) * 0.08

            let raw = (s1 * 0.4 + s2 * 0.35 + s3 * 0.25 + noise)

            lpState += alpha * (raw - lpState)
            samples[i] = Float(lpState)

            p1 += rootFreq / sr
            if p1 >= 1.0 { p1 -= 1.0 }
            p2 += (rootFreq * 1.008) / sr
            if p2 >= 1.0 { p2 -= 1.0 }
            p3 += fifthFreq / sr
            if p3 >= 1.0 { p3 -= 1.0 }
        }

        normalize(&samples, targetPeak: 0.85)
        return samples
    }

    static func pcmBuffer(from samples: [Float], sampleRate: Double = 44100.0) -> AVAudioPCMBuffer? {
        guard !samples.isEmpty else { return nil }
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else {
            return nil
        }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        if let channelData = buffer.floatChannelData {
            let channelPtr = channelData[0]
            for i in 0..<samples.count {
                channelPtr[i] = samples[i]
            }
        }
        return buffer
    }

    static func normalize(_ samples: inout [Float], targetPeak: Float = 0.95) {
        var maxVal: Float = 0.0
        for i in 0..<samples.count {
            let s = samples[i]
            if s.isNaN || s.isInfinite {
                samples[i] = 0.0
            } else {
                let a = abs(s)
                if a > maxVal {
                    maxVal = a
                }
            }
        }
        if maxVal > targetPeak && maxVal > 0.0 {
            let scale = targetPeak / maxVal
            for i in 0..<samples.count {
                samples[i] *= scale
            }
        }
    }

    // MARK: - Private Sound Generators

    private static func synthClang(variant: Int, sampleRate: Double) -> [Float] {
        let pitchMul = 1.0 + Double(variant - 1) * 0.07
        let freqs: [Double] = [1180.0, 1790.0, 2410.0, 3120.0, 4180.0].map { $0 * pitchMul }
        let duration = 0.9
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0

            for (idx, f) in freqs.enumerated() {
                let decay = 0.25 + Double(idx) * 0.18
                let env = exp(-t / max(0.01, decay))
                val += sin(2.0 * .pi * f * t) * 0.2 * env
            }

            if t < 0.12 {
                let noiseEnv = exp(-t / 0.03)
                let noise = Double.random(in: -1.0...1.0) * 0.3 * noiseEnv
                val += noise
            }

            samples[i] = Float(val)
        }

        applyDelay(&samples, delaySec: 0.035, feedback: 0.25, sampleRate: sampleRate)
        return samples
    }

    private static func synthThud(variant: Int, sampleRate: Double) -> [Float] {
        let pitchMul = 1.0 + Double(variant - 1) * 0.05
        let startFreq = 150.0 * pitchMul
        let endFreq = 28.0
        let duration = 0.75
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let progress = min(1.0, t / 0.6)
            let currentFreq = startFreq * pow(endFreq / startFreq, progress)
            let env = exp(-t / 0.15)

            let tri = 4.0 * abs(phase - floor(phase + 0.5)) - 1.0
            samples[i] = Float(tri * 0.95 * env)

            phase += currentFreq / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthSlash(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.5
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var lpState = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let progress = min(1.0, t / 0.4)
            let cutoff = 3500.0 * pow(260.0 / 3500.0, progress)
            let rc = 1.0 / (2.0 * .pi * cutoff)
            let alpha = (1.0 / sampleRate) / (rc + 1.0 / sampleRate)

            let noise = Double.random(in: -1.0...1.0)
            lpState += alpha * (noise - lpState)

            let env = exp(-t / 0.12)
            samples[i] = Float(lpState * 0.8 * env)
        }

        let thudSamples = synthThud(variant: variant, sampleRate: sampleRate)
        let mixCount = min(samples.count, thudSamples.count)
        for i in 0..<mixCount {
            samples[i] += thudSamples[i] * 0.6
        }

        return samples
    }

    private static func synthWhoosh(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.6
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var lpState = 0.0
        var hpState = 0.0
        var prevInput = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var freq = 400.0
            if t < 0.3 {
                freq = 400.0 + (2200.0 - 400.0) * (t / 0.3)
            } else {
                freq = 2200.0 - 1700.0 * min(1.0, (t - 0.3) / 0.28)
            }

            var env = 0.0
            if t < 0.25 {
                env = 0.3 * (t / 0.25)
            } else {
                env = 0.3 * max(0.0, 1.0 - (t - 0.25) / 0.33)
            }

            let noise = Double.random(in: -1.0...1.0)

            let rcLp = 1.0 / (2.0 * .pi * (freq * 1.4))
            let alphaLp = (1.0 / sampleRate) / (rcLp + 1.0 / sampleRate)
            lpState += alphaLp * (noise - lpState)

            let rcHp = 1.0 / (2.0 * .pi * max(50.0, freq * 0.7))
            let alphaHp = rcHp / (rcHp + 1.0 / sampleRate)
            hpState = alphaHp * (hpState + lpState - prevInput)
            prevInput = lpState

            samples[i] = Float(hpState * env * 2.0)
        }

        return samples
    }

    private static func synthHeartbeat(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.55
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let delays = [0.0, 0.22]
        let gains = [0.75, 0.50]

        for (k, dl) in delays.enumerated() {
            let startFrame = Int(dl * sampleRate)
            let pulseFrames = Int(0.25 * sampleRate)
            var phase = 0.0
            let peakGain = gains[k]

            for i in 0..<pulseFrames {
                let frameIdx = startFrame + i
                if frameIdx >= samples.count { break }
                let t = Double(i) / sampleRate
                let currentFreq = 64.0 * pow(34.0 / 64.0, min(1.0, t / 0.2))

                var env = 0.0
                if t < 0.02 {
                    env = peakGain * (t / 0.02)
                } else {
                    env = peakGain * exp(-(t - 0.02) / 0.06)
                }

                let val = sin(2.0 * .pi * phase) * env
                samples[frameIdx] += Float(val)

                phase += currentFreq / sampleRate
                if phase >= 1.0 { phase -= 1.0 }
            }
        }

        return samples
    }

    private static func synthBell(variant: Int, sampleRate: Double) -> [Float] {
        let freqs = [98.0, 147.0, 196.6, 294.5, 392.0]
        let duration = 3.5
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0

            for (idx, f) in freqs.enumerated() {
                let amp = 0.2 / Double(idx + 1)
                let env: Double
                if t < 0.03 {
                    env = amp * (t / 0.03)
                } else {
                    env = amp * exp(-(t - 0.03) / 1.0)
                }
                val += sin(2.0 * .pi * f * t) * env
            }

            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthHeavy(variant: Int, sampleRate: Double) -> [Float] {
        var samples = synthThud(variant: variant, sampleRate: sampleRate)
        let clangSamples = synthClang(variant: variant, sampleRate: sampleRate)
        let mixCount = min(samples.count, clangSamples.count)
        for i in 0..<mixCount {
            samples[i] += clangSamples[i] * 0.7
        }
        return samples
    }

    private static func synthParry(variant: Int, sampleRate: Double) -> [Float] {
        let freqs = [1400.0, 2100.0, 2800.0, 3500.0]
        let duration = 0.4
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0
            let env = exp(-t / 0.08)

            for f in freqs {
                val += sin(2.0 * .pi * f * t) * 0.25 * env
            }

            if t < 0.05 {
                val += Double.random(in: -1.0...1.0) * 0.3 * (1.0 - t / 0.05)
            }

            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthPerfect(variant: Int, sampleRate: Double) -> [Float] {
        let chord = [523.25, 659.25, 783.99, 1046.50]
        let duration = 0.6
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0

            for (idx, f) in chord.enumerated() {
                let offset = Double(idx) * 0.03
                if t >= offset {
                    let noteT = t - offset
                    let noteEnv = exp(-noteT / 0.12)
                    val += sin(2.0 * .pi * f * noteT) * 0.25 * noteEnv
                }
            }

            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthHurt(variant: Int, sampleRate: Double) -> [Float] {
        var samples = synthSlash(variant: variant, sampleRate: sampleRate)
        let thud = synthThud(variant: variant, sampleRate: sampleRate)
        let count = min(samples.count, thud.count)
        for i in 0..<count {
            samples[i] = samples[i] + thud[i] * 0.8
        }
        return samples
    }

    private static func synthBlock(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.45
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var lpState = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.08)
            let noise = Double.random(in: -1.0...1.0)

            let rc = 1.0 / (2.0 * .pi * 800.0)
            let alpha = (1.0 / sampleRate) / (rc + 1.0 / sampleRate)
            lpState += alpha * (noise - lpState)

            let val = lpState * 0.9 * env + sin(2.0 * .pi * 120.0 * t) * 0.4 * env
            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthMiss(variant: Int, sampleRate: Double) -> [Float] {
        var samples = synthWhoosh(variant: variant, sampleRate: sampleRate)
        for i in 0..<samples.count {
            samples[i] *= 0.4
        }
        return samples
    }

    private static func synthUiTap(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.04
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.008)
            let val = sin(2.0 * .pi * 1100.0 * t) * env
            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthUiConfirm(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.14
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0
            if t < 0.06 {
                let env = exp(-t / 0.02)
                val = sin(2.0 * .pi * 440.0 * t) * env
            } else {
                let t2 = t - 0.06
                let env = exp(-t2 / 0.025)
                val = sin(2.0 * .pi * 880.0 * t2) * env
            }
            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthFocus(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.5
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let freq = 220.0 + (880.0 - 220.0) * (t / duration)
            let env = sin(.pi * (t / duration))

            let val = sin(2.0 * .pi * phase) * env
            samples[i] = Float(val)

            phase += freq / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthPotion(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.35
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let pitches = [350.0, 450.0, 550.0, 700.0]
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let step = Int(t / 0.08) % pitches.count
            let stepT = t.truncatingRemainder(dividingBy: 0.08)
            let f = pitches[step]
            let env = exp(-stepT / 0.02)

            samples[i] = Float(sin(2.0 * .pi * f * stepT) * env)
        }

        return samples
    }

    private static func synthWin(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 1.5
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let chord = [261.63, 329.63, 392.00, 523.25]
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0
            let env = exp(-t / 0.5)

            for f in chord {
                val += sin(2.0 * .pi * f * t) * 0.25 * env
                val += sin(2.0 * .pi * (f * 2.0) * t) * 0.08 * env
            }

            samples[i] = Float(val)
        }

        return samples
    }

    private static func synthLose(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 1.4
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let freqs = [174.61, 155.56, 130.81, 123.47]
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let idx = min(freqs.count - 1, Int(t / 0.3))
            let stepT = t - Double(idx) * 0.3
            let f = freqs[idx]
            let env = exp(-stepT / 0.25)
            let val = (2.0 * abs((f * stepT) - floor((f * stepT) + 0.5)) - 1.0) * env

            samples[i] = Float(val * 0.7)
        }

        return samples
    }

    private static func synthKick(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.3
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let f = 110.0 * pow(38.0 / 110.0, min(1.0, t / 0.22))

            var env = 0.0
            if t < 0.008 {
                env = 0.9 * (t / 0.008)
            } else {
                env = 0.9 * exp(-(t - 0.008) / 0.08)
            }

            samples[i] = Float(sin(2.0 * .pi * phase) * env)

            phase += f / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }
        return samples
    }

    private static func synthSnare(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.22
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let f = 180.0 * pow(80.0 / 180.0, min(1.0, t / 0.15))
            let toneEnv = exp(-t / 0.05)
            let tri = 4.0 * abs(phase - floor(phase + 0.5)) - 1.0

            let noiseEnv = exp(-t / 0.08)
            let noise = Double.random(in: -1.0...1.0) * noiseEnv

            samples[i] = Float((tri * toneEnv * 0.4 + noise * 0.6) * 0.85)

            phase += f / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }
        return samples
    }

    private static func synthHat(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.05
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var hpState = 0.0
        var prevInput = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.012)
            let noise = Double.random(in: -1.0...1.0)

            let rc = 1.0 / (2.0 * .pi * 5200.0)
            let alpha = rc / (rc + 1.0 / sampleRate)
            hpState = alpha * (hpState + noise - prevInput)
            prevInput = noise

            samples[i] = Float(hpState * env * 0.4)
        }
        return samples
    }

    private static func synthTom(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.25
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let f = 190.0 * pow(90.0 / 190.0, min(1.0, t / 0.18))

            var env = 0.0
            if t < 0.008 {
                env = 0.5 * (t / 0.008)
            } else {
                env = 0.5 * exp(-(t - 0.008) / 0.07)
            }

            let tri = 4.0 * abs(phase - floor(phase + 0.5)) - 1.0
            samples[i] = Float(tri * env)

            phase += f / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }
        return samples
    }

    private static func applyDelay(_ samples: inout [Float], delaySec: Double, feedback: Double, sampleRate: Double) {
        let delayFrames = Int(sampleRate * delaySec)
        if delayFrames <= 0 || delayFrames >= samples.count { return }

        for i in delayFrames..<samples.count {
            let echo = Double(samples[i - delayFrames]) * feedback
            samples[i] = Float(Double(samples[i]) + echo)
        }
    }
}
