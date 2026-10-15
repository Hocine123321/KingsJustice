import Foundation

extension GameEngine {
    // MARK: - Mode & Run Management

    func startRun(mode: String, enemyIndex: Int) {
        self.mode = mode
        self.training = (mode == "training")
        self.drill = nil
        self.phaseMusicUntil = nil
        self.guided = nil
        self.boons = []
        self.boonOffer = []

        if mode == "training" {
            self.enemyIdx = 0
            beginFight(index: 0)
        } else if mode == "survival" {
            self.wave = 0
            self.boons = []
            self.boonOffer = []
            beginFight(index: 0)
        } else if mode == "rush" {
            self.rushList = Array(0..<GameData.roster.count)
            beginFight(index: 0)
        } else if mode == "daily" {
            beginFight(index: 0)
        } else {
            // "duel"
            beginFight(index: enemyIndex)
        }
    }

    func beginFight(index: Int, keepHp: Bool = false) {
        self.enemyIdx = index
        let E = enemyFor(mode: mode, idx: index)
        self.enemyDef = E
        self.enemyName = E.name
        self.enemyTitle = E.title

        self.hitBarkCount = 0
        self.lowHealthBarked = false
        self.on = true
        self.over = false
        self.resultReady = false
        self.fightResult = FightResult()
        self.tookDamage = false
        self.arenaEventTimer = 12.0 + Double.random(in: 0.0...8.0)
        self.phaseBanner = ""
        self.endClock = 0.0
        self.paused = false
        self.started = false

        let selectedStyle = GameData.styles.first(where: { $0.id == settings.style }) ?? GameData.styles[0]
        self.styleDef = selectedStyle
        self.maxhp = 100.0 + BoonCatalog.maxHealthBonus(boons)
        if !keepHp || hp <= 0 {
            self.hp = maxhp
        }

        self.kmax = E.hp
        self.khp = E.hp
        self.special = 0.0
        self.combo = 0
        self.round = 0
        self.phaseIdx = 0
        self.events = []
        self.shake = 0.0
        self.hitStop = 0.0
        self.rageUntil = 0.0
        self.riposte = false
        self.bastion = false
        self.windUsed = false
        self.staggerUntil = 0.0
        self.guardBreak = 0.0
        self.focusUntil = 0.0
        self.fReadyBit = 0
        self.pStreak = 0
        self.counterWin = 0.0
        self.invulnUntil = 0.0
        self.stamina = startFocus

        self.tough = pendTough
        self.edge = pendEdge
        self.pendTough = false
        self.pendEdge = false

        if !keepHp {
            self.score = 0
            self.maxCombo = 0
            self.nP = 0
            self.nG = 0
            self.nM = 0
        }

        let seed: UInt32 = (mode == "daily") ? hashStr(todayDateString()) : UInt32(Int(Date().timeIntervalSince1970 * 1000) & 0xFFFFFF)
        self.rng = MulberryRNG(seed: seed)
        self.bpm = E.bpm

        prepareTonicsForFight()

        self.dailyMod = (mode == "daily") ? DailyModifiers.forDate(todayDateString()) : DailyModifiers.steady
        if dailyMod.id == "onechance" { self.windUsed = true }

        playerPoseState = PoseState(values: EnginePoses.kIdle)
        enemyPoseState = PoseState(values: EnginePoses.gIdle)

        let introLine = Dialogue.line(.intro, enemyId: E.id, seed: Int(hashStr(E.id)) &+ index) ?? E.intro
        taunt(introLine)
        if let arena = GameData.arenas[E.arena] {
            UIAudio.startArenaMusic(root: arena.music.root, scale: arena.music.scale, bpm: arena.music.tempo, theme: arena.key)
            UIAudio.startArenaAmbience(arena: arena.key)
        }
        promptText = E.name

        // Delayed fight start (handled via tick countdown)
        self.t = -0.3
        self.startTimer = 1.7

        updateHud()
    }

    /// Takes one of the offered boons and applies its instant effect.
    func chooseBoon(_ id: String) {
        guard BoonCatalog.boon(id) != nil else { return }
        boons.append(id)
        boonOffer = []
        maxhp = 100.0 + BoonCatalog.maxHealthBonus(boons)
        if id == "vigor" {
            hp = min(maxhp, hp + 12.0)
        } else if id == "mend" {
            hp = min(maxhp, hp + maxhp * 0.35)
        }
        hp = min(hp, maxhp)
    }

    func enemyFor(mode: String, idx: Int) -> EnemyDef {
        if mode == "survival" {
            // Every fifth wave the King himself takes the field.
            let boss = (wave + 1) % 5 == 0
            let base = boss ? GameData.roster[GameData.roster.count - 1] : GameData.roster[min(GameData.roster.count - 2, wave % 6)]
            let k = 1.0 + Double(wave / 6) * 0.25
            let hpScale: Double = boss ? 0.7 : 0.55
            return EnemyDef(
                id: base.id,
                name: base.name,
                title: base.title,
                hp: floor(base.hp * hpScale * k),
                arena: base.arena,
                bpm: min(124.0, base.bpm + Double(wave) * 1.2),
                look: base.look,
                intro: base.intro,
                ai: base.ai,
                defendPatterns: base.defendPatterns,
                attackPatterns: base.attackPatterns,
                phases: base.phases,
                reward: base.reward
            )
        }

        if mode == "daily" {
            let r = MulberryRNG(seed: hashStr(todayDateString()))
            let base = GameData.roster[Int(floor(r.next() * Double(GameData.roster.count)))]
            let arenaKeys = Array(GameData.arenas.keys)
            let arenaKey = arenaKeys.isEmpty ? base.arena : arenaKeys[Int(floor(r.next() * Double(arenaKeys.count)))]
            // Roll order matters: the seeded sequence must stay the same for everyone.
            let dailyId: String = DailyModifiers.forDate(todayDateString()).id
            let hpMul: Double = (dailyId == "marathon") ? 1.4 : 1.0
            let bpmAdd: Double = (dailyId == "tempo") ? 10.0 : 0.0
            let hpRoll: Double = 0.9 + r.next() * 0.4
            let bpmRoll: Double = floor(r.next() * 10.0)
            return EnemyDef(
                id: base.id,
                name: base.name,
                title: base.title,
                hp: floor(base.hp * hpRoll * hpMul),
                arena: arenaKey,
                bpm: base.bpm + bpmRoll + bpmAdd,
                look: base.look,
                intro: base.intro,
                ai: base.ai,
                defendPatterns: base.defendPatterns,
                attackPatterns: base.attackPatterns,
                phases: base.phases,
                reward: base.reward
            )
        }

        if mode == "training" {
            let base = GameData.roster[0]
            return EnemyDef(
                id: base.id,
                name: base.name,
                title: base.title,
                hp: 9999.0,
                arena: base.arena,
                bpm: base.bpm,
                look: base.look,
                intro: base.intro,
                ai: base.ai,
                defendPatterns: base.defendPatterns,
                attackPatterns: base.attackPatterns,
                phases: base.phases,
                reward: base.reward
            )
        }

        let clampedIdx = max(0, min(GameData.roster.count - 1, idx))
        return GameData.roster[clampedIdx]
    }

    func end2(win: Bool) {
        guard !over else { return }
        over = true
        won = win

        guard let E = enemyDef else { return }

        if win {
            enemyPoseState.setTarget(EnginePoses.gDead, speed: 3.0)
            playerPoseState.setTarget(EnginePoses.kSlash, speed: 6.0)

            let bloodCount1 = (settings.blood == 0) ? 0 : ((settings.blood == 1) ? 60 : ((settings.blood == 2) ? 140 : 200))
            let bloodCount2 = (settings.blood == 0) ? 0 : ((settings.blood == 1) ? 24 : ((settings.blood == 2) ? 60 : 90))
            onSpawnFX?(.blood(x: 790, y: 500, count: bloodCount1, dir: 1.0, power: 1.5))
            onSpawnFX?(.blood(x: 790, y: 500, count: bloodCount2, dir: -1.0, power: 0.9))
            if settings.blood > 0 {
                onSpawnFX?(.stain(x: 860, y: 722, radius: 110))
            }

            onSfx?(.slash, 1.3)
            onSfx?(.heavy, 1.2)
            onHaptic?("kill")
            UIAudio.setMusicIntensity(0.15)   // let the music exhale after the kill
            shake2(2.2)
            flashScreen(color: "#fff", opacity: 0.25)
            onSfx?(.bell, 1.0)
            onSfx?(.win, 1.0)
            if let dying = Dialogue.line(.onVictory, enemyId: E.id, seed: Int(hashStr(E.id))) {
                taunt(dying)
            }
            UIAudio.stopMusic(fade: true)
            UIAudio.playStinger(win: true)
        } else {
            playerPoseState.setTarget(EnginePoses.kDead, speed: 2.4)
            enemyPoseState.setTarget(EnginePoses.gWin, speed: 3.0)

            let bloodCount = (settings.blood == 0) ? 0 : ((settings.blood == 1) ? 60 : ((settings.blood == 2) ? 140 : 200))
            onSpawnFX?(.blood(x: 620, y: 560, count: bloodCount, dir: -1.0, power: 1.5))
            if settings.blood > 0 {
                onSpawnFX?(.stain(x: 560, y: 725, radius: 100))
            }
            onSfx?(.slash, 1.3)
            shake2(2.2)
            onSfx?(.bell, 1.0)
            onSfx?(.lose, 1.0)
            if let gloat = Dialogue.line(.onDefeat, enemyId: E.id, seed: Int(hashStr(E.id))) {
                taunt(gloat)
            }
            UIAudio.stopMusic(fade: true)
            UIAudio.playStinger(win: false)
        }

        // Rewards logic
        let boonGold = (mode == "survival") ? BoonCatalog.goldMul(boons) : 1.0
        let flawlessWin = win && !tookDamage && !training
        let flawlessGold = flawlessWin ? 1.2 : 1.0
        let goldReward = win ? Int(floor(Double(E.reward) * (1.0 + Double(maxCombo) / 60.0) * boonGold * flawlessGold)) : 0
        if win {
            save.gold += goldReward
            save.kills += 1
            if flawlessWin { save.flawless += 1 }
            if mode == "duel" && !save.beat.contains(E.id) {
                save.beat.append(E.id)
            }
        }

        let prevBestWave = save.bestSurvival
        let prevDaily = save.bestDaily[todayDateString()] ?? 0
        let prevBestRush = save.bestRush
        let rosterCount = GameData.roster.count
        // Beating the last champion ends a Trial by Combat or a Boss Rush.
        let finalVictory = win && (mode == "duel" || mode == "rush") && (enemyIdx + 1 >= rosterCount)
        var gauntletBonus = 0
        if mode == "rush" {
            let cleared = win ? enemyIdx + 1 : enemyIdx
            if cleared > save.bestRush { save.bestRush = cleared }
            if finalVictory {
                gauntletBonus = 150
                save.gold += gauntletBonus
            }
        }

        if win && mode == "survival" {
            wave += 1
            hp = min(maxhp, hp + 22.0)
            let bossBeaten = (wave % 5 == 0)
            if bossBeaten { hp = min(maxhp, hp + 25.0) }
            boonOffer = BoonCatalog.offer(taken: boons, seed: UInt32(truncatingIfNeeded: wave &* 7919 &+ boons.count &* 31 &+ score), count: bossBeaten ? 4 : 3)
            if wave > save.bestSurvival {
                save.bestSurvival = wave
            }
        }

        if mode == "daily" {
            score = Int((Double(score) * dailyMod.scoreMul).rounded())
            if win {
                let todayWin = todayDateString()
                save.dailyStreak = DailyModifiers.nextStreak(current: save.dailyStreak, lastWin: save.lastDailyWin, today: todayWin)
                save.lastDailyWin = todayWin
                save.bestDailyStreak = max(save.bestDailyStreak, save.dailyStreak)
            }
            let today = todayDateString()
            let bestStr = save.bestDaily[today] ?? 0
            if score > bestStr {
                save.bestDaily[today] = score
            }
        }

        // Capture the result screen data once, from real fight stats
        let hpFrac = maxhp > 0 ? max(0.0, min(1.0, hp / maxhp)) : 0.0
        var res = FightResult()
        res.won = win
        res.score = score
        res.maxCombo = maxCombo
        res.perfects = nP
        res.goods = nG
        res.misses = nM
        res.gold = goldReward + gauntletBonus
        res.finalVictory = finalVictory
        res.flawless = flawlessWin
        res.hpFraction = hpFrac
        res.duration = max(0.0, t)
        res.rankLetter = FightRank.grade(perfects: nP, goods: nG, misses: nM, hpFraction: hpFrac, won: win).rawValue
        if win && mode == "survival" && wave > prevBestWave {
            res.newBest = true
            res.bestLabel = "New best: wave \(wave)"
        } else if mode == "rush" && save.bestRush > prevBestRush {
            res.newBest = true
            res.bestLabel = finalVictory ? "Gauntlet cleared +\(gauntletBonus) gold" : "New best rush: \(save.bestRush)/\(rosterCount)"
        } else if mode == "daily" && score > prevDaily {
            res.newBest = true
            res.bestLabel = "New daily best"
        }
        if !win { res.tip = FightResult.defeatTip(perfects: nP, goods: nG, misses: nM) }
        if mode == "survival" && !win {
            res.recordRank = HallOfRecords.insert(&save.topSurvival, value: wave) ?? 0
        } else if mode == "rush" && (!win || finalVictory) {
            res.recordRank = HallOfRecords.insert(&save.topRush, value: win ? enemyIdx + 1 : enemyIdx) ?? 0
        }
        res.comboRecord = LifetimeStats.record(into: &save, enemyId: E.id, won: win, maxCombo: maxCombo, perfects: nP, goods: nG, misses: nM, rank: res.rankLetter, training: training)
        res.shareText = FightResult.shareLine(won: win, enemy: E.name, rank: res.rankLetter, score: score, combo: maxCombo, mode: mode, wave: wave, title: Achievements.wornTitle(save: save, rosterIds: GameData.roster.map { $0.id }))
        res.unlocks = FightResult.newUnlocks(gold: save.gold, hasDuelist: save.unlockedDuelist, hasBerserker: save.unlockedBerserker)
        fightResult = res

        // Unlock styles if gold thresholds met
        if save.gold >= 200 { save.unlockedDuelist = true }
        if save.gold >= 500 { save.unlockedBerserker = true }

        saveAll()
        updateHud()
    }

    func pause() {
        guard on && started && !over && !paused else { return }
        paused = true
    }

    func resume() {
        paused = false
    }

    func quitToMenu() {
        UIAudio.stopMusic(fade: true)
        paused = false
        over = true
        on = false
    }

    func hashStr(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for scalar in s.unicodeScalars {
            h ^= scalar.value
            h = h &* 16777619
        }
        return h
    }

    func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: Date())
    }
}
