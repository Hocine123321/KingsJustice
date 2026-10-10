import Foundation

extension GameEngine {
    // MARK: - Timing Windows

    func currentWindows() -> TimingWindowsCalc {
        let w = styleDef.windows
        let D = difficultyParams(settings.difficulty)
        let k = 0.8
        let f = (focusUntil > t) ? 1.5 : 1.0
        return TimingWindowsCalc(
            perfect: w.perfect * k * D.win * f,
            good: w.good * k * D.win * f,
            miss: w.miss * k * D.win * f + 0.01
        )
    }

    func difficultyParams(_ diff: String) -> DifficultyParams {
        switch diff.lowercased() {
        case "easy":
            return DifficultyParams(win: 1.3, take: 0.55, tempo: 0.88, enemyDmg: 0.65)
        case "hard":
            return DifficultyParams(win: 0.85, take: 1.2, tempo: 1.08, enemyDmg: 1.15)
        case "brutal":
            return DifficultyParams(win: 0.72, take: 1.5, tempo: 1.15, enemyDmg: 1.3)
        default:
            return DifficultyParams(win: 1.12, take: 0.8, tempo: 0.96, enemyDmg: 0.85)
        }
    }

    func lenFactor() -> Double {
        let idx = (mode == "duel" || mode == "rush") ? enemyIdx : min(5, wave)
        let table = [1.0, 0.9, 0.8, 0.7, 0.6, 0.52, 0.42]
        return table[min(6, idx)]
    }

    func earlyEase() -> Double {
        let idx = (mode == "duel" || mode == "rush") ? enemyIdx : min(4, wave)
        let table = [0.6, 0.68, 0.74, 0.8, 0.85, 0.9, 0.92]
        return table[min(6, idx)]
    }

    // MARK: - Round Building

    func buildRound() {
        guard let E = enemyDef else { return }
        let B = 60.0 / bpm
        let type: RoundType = (round % 2 == 0) ? .defend : .attack
        roundType = type

        let phN = E.phases.filter { (khp / kmax) <= $0.at }.count
        let listCount = (type == .defend) ? E.defendPatterns.count : E.attackPatterns.count
        let prog = max(0.0, min(1.0, Double(round) / 16.0 + Double(phN) * 0.2))

        let rngVal = rng.next()
        var idx = min(listCount - 1, Int(floor((rngVal * 0.5 + prog * 0.6) * Double(listCount))))
        if round < 2 {
            idx = min(idx, 1)
        }
        if round < 2 && (mode == "duel" || mode == "rush") && enemyIdx > 0 {
            idx = min(idx, 2)
        }

        let lead = (type == .attack) ? 1.0 : 0.0
        let base = ceil((t + 0.15) / B) * B + lead * B

        var evs: [NoteEvent] = []
        var gid = 0

        if type == .defend {
            let pat = E.defendPatterns[idx]
            for raw in pat {
                let b = raw.time
                let kind = raw.move
                let M = GameData.moves[kind] ?? GameData.moves["slash"]!

                let push = { (bb: Double, k: String, extraDmg: Double?, extraTell: Double?, extraInput: String?, extraPose: String?, isFeint: Bool, feintAtVal: Double) in
                    let mInput = extraInput ?? M.input
                    let mPose = extraPose ?? M.pose
                    let mDmg = extraDmg ?? M.dmg
                    let mTell = extraTell ?? (M.tellBeats * B)

                    let ev = NoteEvent(
                        id: evs.count,
                        time: base + bb * B,
                        kind: k,
                        input: mInput,
                        lane: -1,
                        flag: nil,
                        state: "live",
                        tellDone: false,
                        group: gid,
                        dmg: mDmg,
                        tell: mTell,
                        pose: mPose,
                        feint: isFeint,
                        feintAt: feintAtVal
                    )
                    evs.append(ev)
                }

                if kind == "double" {
                    push(b, "slash", M.dmg, nil, nil, nil, false, 0.0)
                    push(b + 0.5, "slash", M.dmg, B * 0.5, nil, nil, false, 0.0)
                } else if kind == "triple" {
                    push(b, "slash", nil, nil, nil, nil, false, 0.0)
                    push(b + 0.33, "slash", nil, B * 0.33, nil, nil, false, 0.0)
                    push(b + 0.66, "slash", nil, B * 0.66, nil, nil, false, 0.0)
                } else if kind == "sweep_combo" {
                    push(b, "low", nil, nil, "duck", "low", false, 0.0)
                    push(b + 1.0, "high", nil, B * 0.8, "jump", "high", false, 0.0)
                } else if kind == "feint" {
                    push(b + 0.5, "slash", nil, B * 1.1, nil, nil, true, base + b * B)
                } else if kind == "grab" {
                    push(b, "grab", nil, nil, "grab", nil, false, 0.0)
                } else {
                    push(b, kind, nil, nil, nil, nil, false, 0.0)
                }
                gid += 1
            }
        } else {
            let pat = E.attackPatterns[idx]
            for raw in pat {
                let b = raw.time
                let lane = raw.lane
                let ev = NoteEvent(
                    id: evs.count,
                    time: base + b * B,
                    kind: "note",
                    input: "lane",
                    lane: lane,
                    flag: nil,
                    state: "live",
                    group: gid,
                    armorHit: 0,
                    orig: lane
                )
                evs.append(ev)
                gid += 1
            }
        }

        evs.sort(by: { $0.time < $1.time })

        if staggerUntil > t || guardBreak > t {
            for i in 0..<evs.count {
                if evs[i].flag == "P" || evs[i].flag == "BH" || evs[i].flag == "BL" {
                    evs[i].flag = nil
                }
            }
        }

        for ev in evs {
            let key: String? = (ev.kind == "note") ? (ev.flag != nil && ev.flag != "A2" ? "note:\(ev.flag!)" : nil) : ev.kind
            if let k = key, let _ = EngineTips.tips[k], save.seen[k] != true {
                showTip(key: k)
                break
            }
        }

        events = evs
        let lastTime = evs.last?.time ?? base
        roundEnd = lastTime + B * 1.1
        roundStart = base
    }

    func startRound2() {
        buildRound()
        promptText = (roundType == .defend ? "Defend" : "Strike")
        if roundType == .attack {
            playerPoseState.setTarget(EnginePoses.kWind, speed: 6.0)
            let enemyBlock = (enemyDef?.look.shield == true) ? EnginePoses.gBlockH : EnginePoses.gIdle
            enemyPoseState.setTarget(enemyBlock, speed: 8.0)
            playerPoseState.rest = EnginePoses.kWind
            enemyPoseState.rest = enemyBlock
        } else {
            playerPoseState.setTarget(EnginePoses.kGuard, speed: 8.0)
            enemyPoseState.setTarget(EnginePoses.gIdle, speed: 8.0)
            playerPoseState.rest = EnginePoses.kGuard
            enemyPoseState.rest = EnginePoses.gIdle
        }
        updateHud()
        round += 1
    }

    func maybePhase() {
        guard let E = enemyDef else { return }
        for i in 0..<E.phases.count {
            let p = E.phases[i]
            if (khp / kmax) <= p.at && phaseIdx <= i {
                phaseIdx = i + 1
                if !p.line.isEmpty {
                    taunt(p.line)
                }
                shake2(1.2)
                onSfx?(.heartbeat, 1.0)
                flashScreen(color: "#a00", opacity: 0.35)
                let numerals = ["I", "II", "III", "IV", "V"]
                phaseBanner = "Phase \(numerals[min(i + 1, numerals.count - 1)])"
                phaseBannerUntil = t + 2.0
            }
        }
    }

    func showTip(key: String) {
        guard save.seen[key] != true, let tip = EngineTips.tips[key] else { return }
        save.seen[key] = true
        tutorialTip = "\(tip.title): \(tip.description)"
        saveAll()
    }
}
