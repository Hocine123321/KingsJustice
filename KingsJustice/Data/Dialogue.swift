import Foundation

/// Dialogue and narrative lines for Kings Justice enemies and player.
enum Dialogue {
    
    enum Event: String, CaseIterable, Equatable, Hashable {
        case intro
        case phase
        case onPlayerPerfect
        case onPlayerHit
        case onEnemyHitsPlayer
        case onLowHealth
        case onVictory
        case onDefeat
        case playerVictory
        case playerDefeat
    }
    
    // MARK: - Enemy Dialogue Pools
    
    static let enemyPools: [String: [Event: [String]]] = [
        "hollow_conscript": [
            .intro: [
                "Dust to dust. Your iron will fade.",
                "The king commands... I obey.",
                "Another soul to walk these endless halls."
            ],
            .phase: [
                "I... will not crumble!",
                "My shield still holds for the crown!"
            ],
            .onPlayerPerfect: [
                "A sharp strike. I remember that drill.",
                "My guard wavers... yet I stand."
            ],
            .onPlayerHit: [
                "Flesh cuts easily...",
                "Pain is all I have left."
            ],
            .onEnemyHitsPlayer: [
                "Yield to the kingdom's rot!",
                "You march into your grave!"
            ],
            .onLowHealth: [
                "The crown demands my life...",
                "My strength decays..."
            ],
            .onVictory: [
                "Finally... my watch ends.",
                "Forgive me... my oath is broken."
            ],
            .onDefeat: [
                "Another fallen challenger.",
                "Rest now in the cold mud."
            ]
        ],
        "pyre_marauder": [
            .intro: [
                "Burn with the ashes of your predecessors!",
                "The village cleanses in fire!",
                "Smell the cinder and soot, knight!"
            ],
            .phase: [
                "Feel the heat of the pyre!",
                "The flames consume everything!"
            ],
            .onPlayerPerfect: [
                "Your steel cannot snuff this flame!",
                "A cold parry! But fire grows!"
            ],
            .onPlayerHit: [
                "More fuel for the furnace!",
                "It only sparks my fury!"
            ],
            .onEnemyHitsPlayer: [
                "Cinder to cinder!",
                "Taste the heat!"
            ],
            .onLowHealth: [
                "The inferno rages highest before it dies!",
                "I will burn us both!"
            ],
            .onVictory: [
                "Ashes... to ashes...",
                "My fire... goes dark."
            ],
            .onDefeat: [
                "Only soot remains of you!",
                "Feed the pyre!"
            ]
        ],
        "frost_warden": [
            .intro: [
                "Winter holds no mercy for warm blood.",
                "Turn back. The ice claims all.",
                "Your breath freezes in your throat."
            ],
            .phase: [
                "The frost grows thicker!",
                "Glaciers do not yield."
            ],
            .onPlayerPerfect: [
                "Impenetrable, you think?",
                "A solid stance. Rare."
            ],
            .onPlayerHit: [
                "Cold iron bites deep.",
                "Bleed upon the snow."
            ],
            .onEnemyHitsPlayer: [
                "Freeze in place.",
                "Feel the glacial bite."
            ],
            .onLowHealth: [
                "The rime cracks...",
                "Winter remains eternal..."
            ],
            .onVictory: [
                "Cold... takes me at last.",
                "The blizzard swallows my duty."
            ],
            .onDefeat: [
                "You belong to the frost now.",
                "Ice preserves your silence."
            ]
        ],
        "marsh_hag_knight": [
            .intro: [
                "Step into the mire, noble fool.",
                "The bog remembers every sunken blade.",
                "Curse your armor, wanderer."
            ],
            .phase: [
                "Drown in the murky gloom!",
                "The swamp claims your steps!"
            ],
            .onPlayerPerfect: [
                "Clever worm, dodging my spell.",
                "You cut through the mist?"
            ],
            .onPlayerHit: [
                "A bitter prick of steel!",
                "Rot will take the wound!"
            ],
            .onEnemyHitsPlayer: [
                "Sink beneath the mud!",
                "The poison takes hold!"
            ],
            .onLowHealth: [
                "My broth grows cold...",
                "The dark water rises..."
            ],
            .onVictory: [
                "The marsh... eats all...",
                "Sinking... into the dark."
            ],
            .onDefeat: [
                "Another relic at the bottom.",
                "The bog welcomes your corpse."
            ]
        ],
        "crimson_executioner": [
            .intro: [
                "Kneel. The block awaits your neck.",
                "No mercy on this precipice.",
                "Countless heads have rolled down this rock."
            ],
            .phase: [
                "The sentence is death!",
                "No escape from the headsman!"
            ],
            .onPlayerPerfect: [
                "A sharp parry. Delaying the verdict.",
                "Your blade moves fast. Mine hits harder."
            ],
            .onPlayerHit: [
                "Blood spills on sacred stone!",
                "You dare strike the judge?"
            ],
            .onEnemyHitsPlayer: [
                "Off with your head!",
                "Justice is heavy!"
            ],
            .onLowHealth: [
                "My axe grows heavy...",
                "The executioner bleeds..."
            ],
            .onVictory: [
                "The block... receives me.",
                "My axe falls... at last."
            ],
            .onDefeat: [
                "Sentence carried out.",
                "Your head rolls into the sea."
            ]
        ],
        "bishop_of_ash": [
            .intro: [
                "Repent your heresy before this altar!",
                "The holy flame will burn away your sins!",
                "You stand in the shadows of false gods."
            ],
            .phase: [
                "Behold divine retribution!",
                "The cathedral shall be your tomb!"
            ],
            .onPlayerPerfect: [
                "Blasphemy! You turn aside holy steel!",
                "Divine grace shields me!"
            ],
            .onPlayerHit: [
                "Sacrilege! Pain is a test!",
                "The heavens judge this act!"
            ],
            .onEnemyHitsPlayer: [
                "Kneel and pray!",
                "Purification through pain!"
            ],
            .onLowHealth: [
                "Why have you forsaken me...",
                "The sacred light dims..."
            ],
            .onVictory: [
                "Forgive... my weakness...",
                "Into the ash... I go."
            ],
            .onDefeat: [
                "Your soul is condemned!",
                "Burn in eternal ash!"
            ]
        ],
        "the_king": [
            .intro: [
                "You dare challenge the crown?",
                "This kingdom was built on blood. As are you.",
                "I am the law. I am the King's Justice."
            ],
            .phase: [
                "I will not lose my throne to a beggar!",
                "Feel the absolute weight of royalty!"
            ],
            .onPlayerPerfect: [
                "Remarkable steel. But I rule this land.",
                "A peasant's blade cannot unseat me."
            ],
            .onPlayerHit: [
                "Royal blood is not so easily spilled!",
                "You strike your sovereign?"
            ],
            .onEnemyHitsPlayer: [
                "Bender of knees!",
                "Know your place, knight!"
            ],
            .onLowHealth: [
                "My crown... is so heavy...",
                "The kingdom... was already dead..."
            ],
            .onVictory: [
                "The throne... crumbles with me.",
                "Is this... justice at last?"
            ],
            .onDefeat: [
                "The crown stands eternal.",
                "Another fool crushed beneath the throne."
            ]
        ]
    ]
    
    // MARK: - Player Dialogue Pools
    
    static let playerPools: [Event: [String]] = [
        .playerVictory: [
            "Justice is delivered.",
            "The realm moves closer to dawn.",
            "Rest your corrupt blade."
        ],
        .playerDefeat: [
            "My journey ends here...",
            "Forgive me... the realm remains dark.",
            "The sword falls..."
        ]
    ]
    
    // MARK: - Kingdom Pre-Fight Blurbs
    
    static let kingdomBlurbs: [String: String] = [
        "hollow_conscript": "The outer courtyard lies silent, guarded by broken men who forgot why they fight.",
        "pyre_marauder": "Ashes drift over the burnt village. Smoke chokes the air as zealots dance in fire.",
        "frost_warden": "Howling winds guard the mountain pass. Glaciers seal the path to royal lands.",
        "marsh_hag_knight": "Thick mist hangs over toxic boglands, hiding dark sorcery and drowned steel.",
        "crimson_executioner": "Sea spray hits the jagged cliffs where headsmen execute the king's dissidents.",
        "bishop_of_ash": "Stained glass filters blood-red light onto altars of fanaticism and ash.",
        "the_king": "The throne room stands in silent decay. The sovereign awaits his final judgment."
    ]
    
    // MARK: - Post-Victory Campaign Narration
    
    static let postVictoryNarrations: [String: String] = [
        "hollow_conscript": "The outer guards fall, leaving the castle gates unguarded as your blade presses onward.",
        "pyre_marauder": "The fires wane in the ruined village, leaving embers and a path clear to the peaks.",
        "frost_warden": "The icy barrier shatters, opening the high pass down into the darkened valley.",
        "marsh_hag_knight": "The witch's curse dissolves with her demise, clearing the foul fog from the marsh.",
        "crimson_executioner": "The executioner's block stands empty, ending the reign of terror along the cliffs.",
        "bishop_of_ash": "The cathedral falls silent as false prayers end, clearing the path to the royal inner keep.",
        "the_king": "The tyrant falls from his hollow throne. Peace returns to the shattered kingdom."
    ]
    
    // MARK: - API Methods
    
    /// Retrieve all lines for an event and enemy id.
    static func lines(for event: Event, enemyId: String) -> [String] {
        if event == .playerVictory || event == .playerDefeat {
            return playerPools[event] ?? []
        }
        return enemyPools[enemyId]?[event] ?? []
    }
    
    /// Select a line deterministically using a seed.
    static func line(_ event: Event, enemyId: String, seed: Int) -> String? {
        let pool = lines(for: event, enemyId: enemyId)
        guard !pool.isEmpty else { return nil }
        let index = abs(seed) % pool.count
        return pool[index]
    }
    
    /// Select a line deterministically using a seed, avoiding repeating the last line if possible.
    static func lineNotRepeating(_ event: Event, enemyId: String, seed: Int, lastLine: String?) -> String? {
        let pool = lines(for: event, enemyId: enemyId)
        guard !pool.isEmpty else { return nil }
        var index = abs(seed) % pool.count
        if let last = lastLine, pool.count > 1 && pool[index] == last {
            index = (index + 1) % pool.count
        }
        return pool[index]
    }
    
    /// Retrieve player lines for victory or defeat.
    static func playerLine(for event: Event, seed: Int) -> String? {
        guard event == .playerVictory || event == .playerDefeat else { return nil }
        return line(event, enemyId: "", seed: seed)
    }
    
    /// Pre-fight kingdom blurb per enemy/arena.
    static func kingdomBlurb(for enemyId: String) -> String {
        kingdomBlurbs[enemyId] ?? "A shadowy arena lies ahead..."
    }
    
    /// Post-victory campaign narration line per enemy.
    static func postVictoryNarration(for enemyId: String) -> String {
        postVictoryNarrations[enemyId] ?? "Victory brings the realm one step closer to justice."
    }
}
