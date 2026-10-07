import Foundation

extension GameEngine {
    // MARK: - Main Input Function

    func input(kind: String, lane: Int) {
        guard on && started && !over && !paused else { return }
        let W = currentWindows()
        let now = t + settings.offset / 1000.0

        if roundType == .attack {
            guard kind == "lane" else { return }
            var bestIndex: Int? = nil
            var bd = 9.0
            for (i, e) in events.enumerated() {
                if e.state != "live" || e.kind != "note" || e.lane != lane { continue }
                let d = abs(e.time - now)
                if d < bd {
                    bd = d
                    bestIndex = i
                }
            }

            guard let idx = bestIndex, bd <= W.miss + 0.05 else {
                combo = 0
                let poseVec = (lane == 0) ? EnginePoses.kSlash : ((lane == 1) ? EnginePoses.kThrust : EnginePoses.kOver)
                playerPoseState.setAction(poseVec, speed: 20.0, hold: 0.30)
                onSfx?(.whoosh, 1.0)
                updateHud()
                return
            }

            let grade = (bd <= W.perfect) ? "perfect" : ((bd <= W.good) ? "good" : "late")
            resolveNote(index: idx, grade: grade)
            return
        }

        // DEFEND mode
        var bestIndex: Int? = nil
        var bd = 9.0
        for (i, e) in events.enumerated() {
            if e.state != "live" { continue }
            let d = abs(e.time - now)
            if d < bd {
                bd = d
                bestIndex = i
            }
        }

        guard let idx = bestIndex, bd <= W.miss + 0.08 else {
            if training { return }
            return
        }

        let need = events[idx].input

        // Feint check
        if events[idx].feint && now < events[idx].feintAt + 0.02 && !events[idx].feintOk {
            events[idx].feintBit = 1
            say("Fooled", col: "#c9a46a")
            combo = 0
            chip(4.0)
            return
        }

        let grade = (bd <= W.perfect) ? "perfect" : ((bd <= W.good) ? "good" : "late")

        var ok = false
        if need == "parry" {
            ok = (kind == "parry")
        } else if need == "duck" {
            ok = (kind == "duck")
        } else if need == "jump" {
            ok = (kind == "jump")
        } else if need == "dodge" {
            ok = (kind == "dodge")
        } else if need == "grab" {
            events[idx].grabPresses[kind] = now
            let keys = Array(events[idx].grabPresses.keys)
            if keys.count >= 2 {
                let t0 = events[idx].grabPresses[keys[0]] ?? 0
                let t1 = events[idx].grabPresses[keys[1]] ?? 0
                ok = abs(t0 - t1) < 0.22
            }
            if !ok { return }
        }

        if !ok {
            if need == "dodge" && kind == "parry" {
                events[idx].state = "broken"
                say("Unblockable!", col: "#ff5a3a")
                hitPlayer(&events[idx], k: 1.0)
                return
            }
            if need != "parry" && kind == "parry" {
                events[idx].state = "hit-wrong"
                say("Wrong guard", col: "#c9a46a")
                hitPlayer(&events[idx], k: 0.8)
                return
            }
            return
        }

        resolveDefend(index: idx, grade: grade)
    }

    // MARK: - Defend Resolution

    func resolveDefend(index: Int, grade: String) {
        events[index].state = "done"
        let perfect = (grade == "perfect")
        let late = (grade == "late")

        if late {
            say("Scraped", col: "#c9a46a")
            combo = 0
            chip(max(2.0, events[index].dmg * 0.35))
            onSpawnFX?(.spark(x: 660, y: 440, count: 12))
            onSfx?(.clang, 0.6)
            playerPoseState.setAction(EnginePoses.kParry, speed: 22.0, hold: 0.30)
            shake2(0.5)
        } else {
            say(perfect ? (events[index].input == "parry" ? "Perfect parry" : "Perfect") : "Good", col: perfect ? "#e8f2ff" : "#c8d4e0")
            if perfect { nP += 1 } else { nG += 1 }
            addScore2(perfect ? 300 : 150)

            let S = styleDef.special
            if S.charge == "perfect" && perfect {
                special = min(Double(S.need), special + 1.0)
                if S.id == "bastion" && Int(special) >= S.need && !bastion {
                    bastion = true
                    say("Bastion ready", col: "#ffe08a")
                }
            }

            if events[index].input == "parry" {
                onSpawnFX?(.spark(x: 650, y: 430, count: perfect ? 36 : 22))
                onSfx?(.clang, perfect ? 1.2 : 0.9)
                shake2(perfect ? 0.8 : 0.5)
                playerPoseState.setAction(EnginePoses.kParry, speed: 26.0, hold: 0.32)
                enemyPoseState.setAction(EnginePoses.gParried, speed: 26.0, hold: 0.55)
                hitStop = perfect ? 0.09 : 0.05

                let dmg = (perfect ? 2.2 : 1.2) * lenFactor() * kmax / 100.0 * (1.0 + styleDef.parryBonus)
                damageEnemy(dmg)

                if perfect {
                    pStreak += 1
                    hp = min(maxhp, hp + 1.0)
                    if pStreak >= 3 {
                        pStreak = 0
                        let B = 60.0 / bpm
                        counterWin = t + B * 10.0
                        say("Counter window", col: "#ffd070")
                        taunt(Dialogue.line(.onPlayerPerfect, enemyId: enemyDef?.id ?? "", seed: maxCombo &+ Int(t * 10.0)) ?? "You read him.")
                    }
                } else {
                    pStreak = 0
                }

                if perfect && styleDef.special.id == "riposte" {
                    riposte = true
                    say("Riposte ready", col: "#ffe08a")
                }
            } else {
                onSfx?(.whoosh, 1.0)
                let poseVec = (events[index].input == "duck") ? EnginePoses.kDuck : ((events[index].input == "jump") ? EnginePoses.kJump : EnginePoses.kDodge)
                playerPoseState.setAction(poseVec, speed: 24.0, hold: 0.45)
                if perfect {
                    onSpawnFX?(.spark(x: 560, y: 520, count: 10))
                }
                damageEnemy(1.0 * lenFactor() * kmax / 100.0)
            }

            let B = 60.0 / bpm
            if events[index].input == "dodge" || events[index].input == "grab" || events[index].kind == "triple" || events[index].kind == "sweep_combo" {
                staggerUntil = t + B * 8.0
                say("Opening!", col: "#ffd070")
            }

            if events[index].input == "dodge" || events[index].input == "grab" {
                stunUntil = t + B * 0.8
                enemyPoseState.setTarget(EnginePoses.gStun, speed: 18.0)
                damageEnemy(1.4 * kmax / 100.0)
            }
        }

        updateHud()
    }

    func hitPlayer(_ e: inout NoteEvent, k: Double = 1.0) {
        pStreak = 0
        if e.state == "live" {
            e.state = "miss"
        }

        if bastion {
            bastion = false
            special = 0
            say("Bastion holds", col: "#ffe08a")
            onSfx?(.clang, 1.2)
            onSpawnFX?(.spark(x: 600, y: 500, count: 30))
            shake2(0.6)
            updateHud()
            return
        }

        combo = 0
        let D = difficultyParams(settings.difficulty)
        let enemyDmgMul = enemyDef?.ai.aggression != nil ? 1.0 : 1.0
        let dmg = e.dmg * k * D.enemyDmg * enemyDmgMul

        hitBarkCount += 1
        if hitBarkCount % 3 == 0, let bark = Dialogue.line(.onEnemyHitsPlayer, enemyId: enemyDef?.id ?? "", seed: hitBarkCount) {
            taunt(bark)
        }

        let poseVec = (e.pose == "low") ? EnginePoses.gStrikeL : EnginePoses.gStrike
        enemyPoseState.setAction(poseVec, speed: 30.0, hold: 0.35)
        playerPoseState.setAction(EnginePoses.kHurt, speed: 26.0, hold: 0.45)

        let bloodCount = (settings.blood == 0) ? 0 : ((settings.blood == 1) ? 30 : ((settings.blood == 2) ? 60 : 90))
        onSpawnFX?(.blood(x: 600, y: 540, count: bloodCount, dir: -1.0, power: 1.0))
        if settings.blood > 0 {
            onSpawnFX?(.stain(x: 520.0 + Double.random(in: 0...80), y: 724.0, radius: 40.0))
        }

        onSfx?(.slash, 0.9)
        shake2(1.4)
        hitStop = 0.08
        onHaptic?("impact")
        onSpawnFX?(.flashHurt(opacity: 0.6))
        say("Struck", col: "#c23a2a")
        chip(dmg)
    }

    func missDefend(_ e: inout NoteEvent) {
        hitPlayer(&e, k: 1.0)
    }

    // MARK: - Attack Note Resolution

    func resolveNote(index: Int, grade: String) {
        let perfect = (grade == "perfect")
        let good = (grade == "good")

        var dmg = (perfect ? 3.7 : (good ? 2.7 : 1.3)) * kmax / 100.0 * lenFactor() * styleDef.dmgMul * dmgScale
        var msg = perfect ? "Perfect" : (good ? "Good" : "Glancing")
        var col = perfect ? "#ffe08a" : (good ? "#cdbfa6" : "#9a8f7c")

        var m = 1.0 + min(0.6, floor(Double(combo) / 8.0) * 0.1)
        if counterWin > t { m *= 1.6 }
        if staggerUntil > t { m *= 1.25 }
        if guardBreak > t { m *= 1.25 }
        if edge { m *= 1.2 }
        dmg *= min(m, 2.0)

        if riposte {
            dmg *= 2.0
            riposte = false
            msg = "Riposte!"
        }

        if rageUntil > t {
            dmg *= 2.0
        }

        events[index].state = "hit"

        if events[index].flag == "P" {
            if perfect {
                msg = "Guard broken!"
                col = "#ff9a5a"
                dmg *= 1.4
                let B = 60.0 / bpm
                guardBreak = t + B * 3.0
                say("Guard broken! Strike!", col: "#ff9a5a")
                enemyPoseState.setTarget(EnginePoses.gStun, speed: 20.0)
                onSfx?(.clang, 1.2)
                onSpawnFX?(.spark(x: 710, y: 430, count: 40))
            } else {
                msg = "Parried"
                col = "#8fb0d0"
                dmg *= 0.15
                combo = 0
                enemyPoseState.setAction(EnginePoses.gBlockH, speed: 26.0, hold: 0.35)
                onSfx?(.clang, 0.8)
                onSpawnFX?(.spark(x: 710, y: 430, count: 16))
            }
        } else if events[index].flag == "BH" && events[index].lane == 2 {
            dmg *= 0.2
            msg = "Blocked high"
            col = "#8fb0d0"
            combo = 0
            enemyPoseState.setAction(EnginePoses.gBlockH, speed: 26.0, hold: 0.35)
            onSfx?(.clang, 0.7)
        } else if events[index].flag == "BL" && events[index].lane == 0 {
            dmg *= 0.2
            msg = "Blocked low"
            col = "#8fb0d0"
            combo = 0
            enemyPoseState.setAction(EnginePoses.gBlockL, speed: 26.0, hold: 0.35)
            onSfx?(.clang, 0.7)
        } else if events[index].flag == "C" {
            msg = "Countered"
            col = "#ff7a5a"
            combo = 0
            let B = 60.0 / bpm
            let counterEv = NoteEvent(
                id: events.count,
                time: t + B * 0.9,
                kind: "slash",
                input: "parry",
                lane: -1,
                flag: nil,
                state: "live",
                group: 99,
                dmg: 10.0,
                tell: B * 0.8,
                pose: "wind",
                counter: true
            )
            events.append(counterEv)
            events.sort(by: { $0.time < $1.time })
            roundEnd = max(roundEnd, t + B * 3.0)
        }

        if events[index].flag == "A" {
            events[index].state = "live"
            events[index].flag = "Ah"
            dmg *= 0.4
            msg = "Armor cracked"
            col = "#c8d4e0"
            onSfx?(.clang, 0.8)
            onSpawnFX?(.spark(x: 700, y: 440, count: 10))
            damageEnemy(dmg)
            updateHud()
            combo += 1
            return
        }

        if events[index].flag == "A2" {
            msg = perfect ? "Armor broken!" : "Cracked"
            dmg *= 1.6
        }

        say(msg, col: col)
        if perfect { nP += 1 } else if good { nG += 1 }

        if events[index].flag != "P" || perfect {
            addScore2(perfect ? 300 : (good ? 150 : 60))
        }

        damageEnemy(dmg)

        let lanePose = (events[index].lane == 0) ? EnginePoses.kSlash : ((events[index].lane == 1) ? EnginePoses.kThrust : EnginePoses.kOver)
        playerPoseState.setAction(lanePose, speed: 28.0, hold: 0.28)

        if events[index].flag == nil || events[index].flag == "A2" || (events[index].flag == "P" && perfect) {
            enemyPoseState.setAction(EnginePoses.gHurt, speed: 24.0, hold: 0.40)
            let sparkCount = perfect ? 30 : 16
            onSpawnFX?(.spark(x: 720, y: 430, count: sparkCount))
            let bloodCount = (settings.blood == 0) ? 0 : ((settings.blood == 1) ? (perfect ? 14 : 8) : ((settings.blood == 2) ? (perfect ? 34 : 18) : (perfect ? 50 : 26)))
            onSpawnFX?(.blood(x: 760, y: 470, count: bloodCount, dir: 1.0, power: perfect ? 0.9 : 0.6))
            if perfect && settings.blood > 0 {
                onSpawnFX?(.stain(x: 800.0 + Double.random(in: 0...80), y: 722.0, radius: 34.0 + Double.random(in: 0...30)))
            }
            onSfx?(.slash, perfect ? 0.8 : 0.5)
        }

        shake2(perfect ? 1.1 : 0.6)
        hitStop = perfect ? 0.07 : 0.04
        onHaptic?(perfect ? "heavy" : "light")
        updateHud()
    }

    func missNote(_ n: inout NoteEvent) {
        n.state = "miss"
        combo = 0
        nM += 1
        say("Missed", col: "#8a7f6a")
        updateHud()
    }

    // MARK: - Combat Helpers

    func chip(_ n: Double) {
        if invulnUntil > t { return }
        let D = difficultyParams(settings.difficulty)
        let toughMul = tough ? 0.8 : 1.0
        hp -= n * D.take * styleDef.takeMul * earlyEase() * toughMul

        if hp <= 0 {
            if !windUsed {
                windUsed = true
                hp = Double(Int(maxhp * 0.25))
                let B = 60.0 / bpm
                invulnUntil = t + B * 2.0
                stamina = 100.0
                fReadyBit = 1
                say("SECOND WIND", col: "#ffe08a")
                taunt("Not yet.")
                flashScreen(color: "#ffd070", opacity: 0.35)
                shake2(1.0)
            } else {
                updateHud()
                end2(win: false)
                return
            }
        }
        updateHud()
    }

    func useFocus() {
        guard on && started && !over && !paused else { return }
        guard stamina >= 100.0 || focusUntil <= t else { return }
        guard stamina >= 100.0 else { return }
        focusUntil = t + 3.5
        fReadyBit = 0
        say("FOCUS", col: "#9fd0ff")
        flashScreen(color: "#6fa8ff", opacity: 0.22)
        onSfx?(.focus, 1.0)
    }

    func gainFocus(_ n: Double) {
        if focusUntil > t { return }
        stamina = min(100.0, stamina + n)
        if stamina >= 100.0 && fReadyBit == 0 {
            fReadyBit = 1
            say("Focus ready", col: "#9fd0ff")
        }
    }

    func addScore2(_ p: Int) {
        combo += 1
        gainFocus(p >= 300 ? 5.0 : 3.0)
        maxCombo = max(maxCombo, combo)

        let comboMul = 1.0 + min(Double(combo), 40.0) * 0.08
        let rageMul = (rageUntil > t) ? 2.0 : 1.0
        score += Int(floor(Double(p) * comboMul * rageMul))

        let S = styleDef.special
        if S.charge == "combo" {
            special = min(Double(S.need), Double(combo))
        }

        if S.id == "rage" && Int(special) >= S.need && rageUntil < t {
            rageUntil = t + 6.0
            special = 0.0
            say("RAGE", col: "#ff4a3a")
            shake2(1.2)
        }
    }

    func damageEnemy(_ d: Double) {
        if training { return }
        khp -= d
        if khp <= 0 {
            end2(win: true)
        } else if !lowHealthBarked && kmax > 0 && (khp / kmax) < 0.25 {
            lowHealthBarked = true
            if let bark = Dialogue.line(.onLowHealth, enemyId: enemyDef?.id ?? "", seed: hitBarkCount &+ 7) {
                taunt(bark)
            }
        }
    }

    func say(_ txt: String, col: String) {
        judgeText = txt
        judgeColor = col
        judgeStamp += 1.0
    }

    func taunt(_ line: String) {
        tauntText = "“\(line)”"
    }

    func shake2(_ n: Double) {
        shake = max(shake, n * settings.shake)
    }

    func flashScreen(color: String, opacity: Double) {
        guard settings.flash else { return }
        flashColor = color
        flashOpacity = opacity
        onSpawnFX?(.flashScreen(color: color, opacity: opacity))
    }

    func updateHud() {
        gold = save.gold
    }
}
