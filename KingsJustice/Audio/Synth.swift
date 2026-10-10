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
        case "mixolydian":
            return [0, 2, 4, 5, 7, 9, 10]
        case "lydian":
            return [0, 2, 4, 6, 7, 9, 11]
        case "melodicminor":
            return [0, 2, 3, 5, 7, 9, 11]
        case "pentatonicminor":
            return [0, 3, 5, 7, 10]
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
            samples = stingerBuffer(win: true, sampleRate: sr)
        case .lose:
            samples = stingerBuffer(win: false, sampleRate: sr)
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
        case "openhat":
            samples = synthOpenHat(variant: variant, sampleRate: sr)
        case "ghosthat":
            samples = synthHat(variant: variant, sampleRate: sr)
            for i in 0..<samples.count { samples[i] *= 0.4 }
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
            let attackRamp = min(1.0, t / 0.002)
            let env = Float(attackRamp * exp(-t * 5.5))

            let s1 = Float(2.0 * (phase1 - floor(phase1 + 0.5)))
            let s2 = Float(2.0 * (phase2 - floor(phase2 + 0.5)))

            samples[i] = (s1 * 0.6 + s2 * 0.4) * env

            phase1 += freq / sr
            if phase1 >= 1.0 { phase1 -= 1.0 }
            phase2 += (freq * detune) / sr
            if phase2 >= 1.0 { phase2 -= 1.0 }
        }

        normalize(&samples, targetPeak: 0.90)
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

    static func padBuffer(midiNote: Int, chordType: String = "minor", duration: Double = 3.5, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let totalFrames = Int(sr * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let rootFreq = midiToFreq(midiNote)
        let thirdInterval = (chordType.lowercased() == "major") ? 4 : 3
        let fifthInterval = (chordType.lowercased() == "diminished") ? 6 : 7

        let thirdFreq = midiToFreq(midiNote + thirdInterval)
        let fifthFreq = midiToFreq(midiNote + fifthInterval)

        var phaseR1 = 0.0, phaseR2 = 0.0
        var phase3rd = 0.0
        var phase5th = 0.0
        var lpState = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sr
            let attack = min(1.0, t / 0.25)
            let release = min(1.0, (duration - t) / 0.45)
            let env = Float(max(0.0, attack * release))

            let lfo = 0.5 + 0.5 * sin(2.0 * .pi * 0.18 * t)
            let cutoff = (chordType == "choir" ? 550.0 : 220.0) + lfo * 380.0
            let rc = 1.0 / (2.0 * .pi * cutoff)
            let alpha = (1.0 / sr) / (rc + 1.0 / sr)

            let sR1 = 2.0 * (phaseR1 - floor(phaseR1 + 0.5))
            let sR2 = 4.0 * abs(phaseR2 - floor(phaseR2 + 0.5)) - 1.0
            let s3rd = 2.0 * (phase3rd - floor(phase3rd + 0.5))
            let s5th = 2.0 * (phase5th - floor(phase5th + 0.5))

            let raw = (sR1 * 0.35 + sR2 * 0.25 + s3rd * 0.22 + s5th * 0.18)

            lpState += alpha * (raw - lpState)
            samples[i] = Float(lpState) * env

            phaseR1 += rootFreq / sr
            if phaseR1 >= 1.0 { phaseR1 -= 1.0 }
            phaseR2 += (rootFreq * 1.003) / sr
            if phaseR2 >= 1.0 { phaseR2 -= 1.0 }
            phase3rd += thirdFreq / sr
            if phase3rd >= 1.0 { phase3rd -= 1.0 }
            phase5th += fifthFreq / sr
            if phase5th >= 1.0 { phase5th -= 1.0 }
        }

        applyReverb(&samples, delaySec: 0.04, feedback: 0.3, sampleRate: sr)
        normalize(&samples, targetPeak: 0.85)
        return samples
    }

    static func leadBuffer(midiNote: Int, style: String = "plucked", duration: Double = 0.6, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let totalFrames = Int(sr * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))
        let freq = midiToFreq(midiNote)

        if style == "choir" || style == "ooh" {
            var phase1 = 0.0
            var lp1 = 0.0, lp2 = 0.0

            for i in 0..<samples.count {
                let t = Double(i) / sr
                let attack = min(1.0, t / 0.05)
                let release = min(1.0, (duration - t) / 0.15)
                let env = Float(max(0.0, attack * release))

                let vibrato = 1.0 + 0.003 * sin(2.0 * .pi * 5.0 * t)
                let currentFreq = freq * vibrato

                let saw = 2.0 * (phase1 - floor(phase1 + 0.5))
                let sub = sin(2.0 * .pi * (currentFreq * 0.5) * t)

                let rc1 = 1.0 / (2.0 * .pi * 400.0)
                let alpha1 = (1.0 / sr) / (rc1 + 1.0 / sr)
                lp1 += alpha1 * (saw - lp1)

                let rc2 = 1.0 / (2.0 * .pi * 900.0)
                let alpha2 = (1.0 / sr) / (rc2 + 1.0 / sr)
                lp2 += alpha2 * (saw - lp2)

                let raw = lp1 * 0.5 + lp2 * 0.3 + sub * 0.2
                samples[i] = Float(raw) * env

                phase1 += currentFreq / sr
                if phase1 >= 1.0 { phase1 -= 1.0 }
            }
        } else {
            var phase1 = 0.0
            var phase2 = 0.0

            for i in 0..<samples.count {
                let t = Double(i) / sr
                let env = Float(exp(-t * 7.5))

                let tri = 4.0 * abs(phase1 - floor(phase1 + 0.5)) - 1.0
                let saw = 2.0 * (phase2 - floor(phase2 + 0.5))
                let pluckNoise = (t < 0.012) ? Double.random(in: -0.2...0.2) * (1.0 - t / 0.012) : 0.0

                let val = (tri * 0.65 + saw * 0.35 + pluckNoise) * Double(env)
                samples[i] = Float(val)

                phase1 += freq / sr
                if phase1 >= 1.0 { phase1 -= 1.0 }
                phase2 += (freq * 2.001) / sr
                if phase2 >= 1.0 { phase2 -= 1.0 }
            }
        }

        applyReverb(&samples, delaySec: 0.03, feedback: 0.25, sampleRate: sr)
        normalize(&samples, targetPeak: 0.90)
        return samples
    }

    /// Which ambience bed an arena uses.
    static func ambienceKind(forArena key: String) -> String {
        switch key {
        case "castle": return "crowd"
        case "village": return "fire"
        case "pass": return "wind"
        case "swamp": return "swamp"
        case "cliff": return "waves"
        case "cathedral": return "hum"
        default: return "wind"
        }
    }

    /// A seamlessly looping background bed. Kinds: wind, crowd, fire, swamp, waves, hum.
    static func ambienceBuffer(kind: String, duration: Double = 8.0, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let n = max(1, Int(sr * duration))
        let fade = min(n / 4, Int(sr * 0.6))
        let total = n + fade
        var out = [Float](repeating: 0, count: total)
        let twoPi = 2.0 * Double.pi

        var lpA = 0.0
        var lpB = 0.0
        var pop = 0.0

        for i in 0..<total {
            let t = Double(i) / sr
            let w = Double.random(in: -1.0...1.0)
            var v = 0.0
            switch kind {
            case "wind":
                lpA += 0.05 * (w - lpA)
                lpB += 0.004 * (w - lpB)
                let gust = 0.55 + 0.45 * sin(twoPi * t / duration * 2.0) * sin(twoPi * t / duration * 3.0 + 1.0)
                v = (lpA - lpB) * 3.0 * max(0.15, gust)
            case "crowd":
                lpA += 0.12 * (w - lpA)
                lpB += 0.015 * (w - lpB)
                let swell = 0.6 + 0.4 * sin(twoPi * t / duration * 3.0)
                v = (lpA - lpB) * 1.6 * swell
            case "fire":
                lpA += 0.006 * (w - lpA)
                if Double.random(in: 0.0...1.0) < 0.0007 { pop = Double.random(in: 0.4...1.0) }
                pop *= 0.994
                v = lpA * 4.0 + pop * w * 0.7
            case "swamp":
                lpA += 0.01 * (w - lpA)
                let chirpGate = sin(twoPi * 14.0 * t) > 0.35 ? 1.0 : 0.0
                let group = 0.5 + 0.5 * sin(twoPi * t / duration * 2.0)
                let cricket = sin(twoPi * 4300.0 * t) * chirpGate * group * 0.22
                v = lpA * 2.2 + cricket
            case "waves":
                lpA += 0.004 * (w - lpA)
                lpB += 0.08 * (w - lpB)
                let swell = pow(0.5 + 0.5 * sin(twoPi * t / duration * 1.0 - Double.pi / 2.0), 2.0)
                v = lpA * 7.0 * (0.25 + swell) + (lpB - lpA) * 0.5 * swell
            default: // "hum": exact integer cycles in 8 s, so it loops perfectly
                let shimmer = 0.5 + 0.5 * sin(twoPi * t / duration)
                v = 0.5 * sin(twoPi * 55.0 * t) + 0.3 * sin(twoPi * 82.5 * t) + 0.22 * sin(twoPi * 110.0 * t) + 0.18 * shimmer * sin(twoPi * 165.0 * t)
            }
            out[i] = Float(v)
        }

        // Crossfade the tail into the head so the loop point cannot click.
        var loop = Array(out[0..<n])
        if fade > 0 {
            for i in 0..<fade {
                let wgt = Float(i) / Float(fade)
                loop[i] = out[i] * wgt + out[n + i] * (1.0 - wgt)
            }
        }
        normalize(&loop, targetPeak: 0.8)
        return loop
    }

    static func stingerBuffer(win: Bool, sampleRate: Double = 44100.0) -> [Float] {
        let sr = max(8000.0, sampleRate)
        let duration = 2.0
        let totalFrames = Int(sr * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        if win {
            let chordNotes = [60, 64, 67, 72]
            for (idx, note) in chordNotes.enumerated() {
                let noteStart = Double(idx) * 0.16
                let freq = midiToFreq(note)
                var phase = 0.0

                for i in 0..<samples.count {
                    let t = Double(i) / sr
                    if t >= noteStart {
                        let noteT = t - noteStart
                        let env = exp(-noteT * 1.8)
                        let saw = 2.0 * (phase - floor(phase + 0.5))
                        let chime = sin(2.0 * .pi * (freq * 2.0) * noteT) * 0.25

                        samples[i] += Float((saw * 0.65 + chime) * env)
                        phase += freq / sr
                        if phase >= 1.0 { phase -= 1.0 }
                    }
                }
            }
        } else {
            let notes = [48, 44, 41, 36]
            for (idx, note) in notes.enumerated() {
                let noteStart = Double(idx) * 0.25
                let freq = midiToFreq(note)
                var phase = 0.0

                for i in 0..<samples.count {
                    let t = Double(i) / sr
                    if t >= noteStart {
                        let noteT = t - noteStart
                        let env = exp(-noteT * 1.3)
                        let tri = 4.0 * abs(phase - floor(phase + 0.5)) - 1.0
                        let noise = Double.random(in: -0.08...0.08) * exp(-noteT * 3.0)

                        samples[i] += Float((tri * 0.75 + noise) * env)
                        phase += freq / sr
                        if phase >= 1.0 { phase -= 1.0 }
                    }
                }
            }
        }

        applyReverb(&samples, delaySec: 0.045, feedback: 0.35, sampleRate: sr)
        normalize(&samples, targetPeak: 0.95)
        return samples
    }

    static func applyReverb(_ samples: inout [Float], delaySec: Double = 0.035, feedback: Float = 0.25, sampleRate: Double = 44100.0) {
        let delayFrames = Int(sampleRate * delaySec)
        guard delayFrames > 0, delayFrames < samples.count else { return }

        for i in delayFrames..<samples.count {
            let echo = samples[i - delayFrames] * feedback
            samples[i] += echo
        }
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
            samples[i] += thudSamples[i] * 0.4
        }

        return samples
    }

    private static func synthWhoosh(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.35
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var bpState1 = 0.0
        var bpState2 = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let envelope = sin(.pi * (t / duration))
            let centerFreq = 300.0 + 1200.0 * sin(.pi * (t / duration))

            let rc = 1.0 / (2.0 * .pi * centerFreq)
            let alpha = (1.0 / sampleRate) / (rc + 1.0 / sampleRate)

            let noise = Double.random(in: -1.0...1.0)
            bpState1 += alpha * (noise - bpState1)
            bpState2 += alpha * (bpState1 - bpState2)

            samples[i] = Float((bpState1 - bpState2) * 2.5 * envelope)
        }

        return samples
    }

    private static func synthHeartbeat(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.85
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let pulse1 = synthThud(variant: 0, sampleRate: sampleRate)
        let pulse2 = synthThud(variant: 1, sampleRate: sampleRate)

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val: Float = 0.0

            if i < pulse1.count {
                val += pulse1[i] * 0.9
            }

            let p2Offset = Int(sampleRate * 0.22)
            if i >= p2Offset && (i - p2Offset) < pulse2.count {
                val += pulse2[i - p2Offset] * 0.65
            }

            samples[i] = val
        }

        return samples
    }

    private static func synthBell(variant: Int, sampleRate: Double) -> [Float] {
        let pitchMul = 1.0 + Double(variant - 1) * 0.08
        let baseFreq = 880.0 * pitchMul
        let partials: [(Double, Double, Double)] = [
            (1.0, 1.0, 1.2),
            (2.0, 0.5, 0.8),
            (3.01, 0.3, 0.5),
            (4.15, 0.2, 0.3),
            (5.43, 0.15, 0.2)
        ]
        let duration = 1.8
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val = 0.0

            for (mult, amp, decay) in partials {
                let f = baseFreq * mult
                let env = exp(-t / max(0.01, decay))
                val += sin(2.0 * .pi * f * t) * amp * env
            }

            samples[i] = Float(val)
        }

        applyDelay(&samples, delaySec: 0.05, feedback: 0.3, sampleRate: sampleRate)
        return samples
    }

    private static func synthHeavy(variant: Int, sampleRate: Double) -> [Float] {
        let thud = synthThud(variant: variant, sampleRate: sampleRate)
        let clang = synthClang(variant: variant, sampleRate: sampleRate)

        let totalFrames = max(thud.count, clang.count)
        var samples = [Float](repeating: 0, count: totalFrames)

        for i in 0..<totalFrames {
            var val: Float = 0.0
            if i < thud.count { val += thud[i] * 0.7 }
            if i < clang.count { val += clang[i] * 0.5 }
            samples[i] = val
        }

        return samples
    }

    private static func synthParry(variant: Int, sampleRate: Double) -> [Float] {
        let clang = synthClang(variant: variant, sampleRate: sampleRate)
        let bell = synthBell(variant: variant, sampleRate: sampleRate)

        let totalFrames = max(clang.count, bell.count)
        var samples = [Float](repeating: 0, count: totalFrames)

        for i in 0..<totalFrames {
            var val: Float = 0.0
            if i < clang.count { val += clang[i] * 0.6 }
            if i < bell.count { val += bell[i] * 0.5 }
            samples[i] = val
        }

        return samples
    }

    private static func synthPerfect(variant: Int, sampleRate: Double) -> [Float] {
        let bell = synthBell(variant: 2, sampleRate: sampleRate)
        let duration = 1.2
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let shimmerFreqs = [1760.0, 2640.0, 3520.0]

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            var val: Float = 0.0

            if i < bell.count {
                val += bell[i] * 0.6
            }

            let shimmerEnv = exp(-t / 0.4)
            for f in shimmerFreqs {
                val += Float(sin(2.0 * .pi * f * t) * 0.1 * shimmerEnv)
            }

            samples[i] = val
        }

        return samples
    }

    private static func synthHurt(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.4
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let baseFreq = 90.0
        var phase = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.1)
            let pitchDrop = baseFreq * exp(-t * 8.0)

            let noise = Double.random(in: -1.0...1.0) * 0.3
            let saw = 2.0 * (phase - floor(phase + 0.5))

            samples[i] = Float((saw * 0.7 + noise) * env)

            phase += pitchDrop / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthBlock(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.35
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        let freq = 130.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.08)
            let tri = 4.0 * abs(phase - floor(phase + 0.5)) - 1.0
            let noise = Double.random(in: -0.5...0.5) * exp(-t / 0.03)

            samples[i] = Float((tri * 0.6 + noise * 0.4) * env)

            phase += freq / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthMiss(variant: Int, sampleRate: Double) -> [Float] {
        return synthWhoosh(variant: variant, sampleRate: sampleRate)
    }

    private static func synthUiTap(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.04
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let freq = 1200.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.008)
            samples[i] = Float(sin(2.0 * .pi * freq * t) * 0.5 * env)
        }

        return samples
    }

    private static func synthUiConfirm(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.25
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        let f1 = 600.0
        let f2 = 900.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env1 = exp(-t / 0.08)
            let env2 = (t > 0.06) ? exp(-(t - 0.06) / 0.1) : 0.0

            let s1 = sin(2.0 * .pi * f1 * t) * 0.4 * env1
            let s2 = sin(2.0 * .pi * f2 * t) * 0.4 * env2

            samples[i] = Float(s1 + s2)
        }

        return samples
    }

    private static func synthFocus(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.6
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let freq = 200.0 + 600.0 * (t / duration)
            let env = sin(.pi * (t / duration))

            samples[i] = Float(sin(2.0 * .pi * phase) * 0.4 * env)

            phase += freq / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthPotion(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.5
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let bubble = sin(2.0 * .pi * 25.0 * t)
            let freq = 400.0 + 300.0 * bubble
            let env = exp(-t / 0.25)

            samples[i] = Float(sin(2.0 * .pi * phase) * 0.35 * env)

            phase += freq / sampleRate
            if phase >= 1.0 { phase -= 1.0 }
        }

        return samples
    }

    private static func synthWin(variant: Int, sampleRate: Double) -> [Float] {
        return stingerBuffer(win: true, sampleRate: sampleRate)
    }

    private static func synthLose(variant: Int, sampleRate: Double) -> [Float] {
        return stingerBuffer(win: false, sampleRate: sampleRate)
    }

    private static func synthKick(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.3
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var phase = 0.0
        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let f = 120.0 * pow(35.0 / 120.0, min(1.0, t / 0.22))

            var env = 0.0
            if t < 0.008 {
                env = 0.95 * (t / 0.008)
            } else {
                env = 0.95 * exp(-(t - 0.008) / 0.08)
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

    private static func synthOpenHat(variant: Int, sampleRate: Double) -> [Float] {
        let duration = 0.18
        let totalFrames = Int(sampleRate * duration)
        var samples = [Float](repeating: 0, count: max(1, totalFrames))

        var hpState = 0.0
        var prevInput = 0.0

        for i in 0..<samples.count {
            let t = Double(i) / sampleRate
            let env = exp(-t / 0.05)
            let noise = Double.random(in: -1.0...1.0)

            let rc = 1.0 / (2.0 * .pi * 4800.0)
            let alpha = rc / (rc + 1.0 / sampleRate)
            hpState = alpha * (hpState + noise - prevInput)
            prevInput = noise

            samples[i] = Float(hpState * env * 0.45)
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
            let startF = (variant == 1) ? 220.0 : 160.0
            let endF = (variant == 1) ? 100.0 : 70.0
            let f = startF * pow(endF / startF, min(1.0, t / 0.18))

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
