# The King's Justice

<p align="center"><strong>A medieval rhythm duel for iPhone and iPad.</strong><br>
Read the beat. Parry the blade. Break the king.</p>

The King's Justice is a rhythm fighting game. Every enemy attack arrives as a note on the beat of the arena's music, and you survive by parrying, dodging, ducking and jumping in time. When the enemy's guard drops you turn the tables and strike back to the same rhythm. It is a duel built on timing, not button mashing.

It started life as a browser game (HTML and JavaScript) and is being rebuilt as a **fully native iOS app** in Swift. Everything you see and hear, including the SVG-style art, the particle effects and the music, is drawn and synthesised in code. There are no image or audio files to download.

## What it is

### How a fight works

Each fight alternates between two kinds of rounds:

- **Defend rounds.** The enemy attacks in time with the music. Match each incoming strike with the right response (parry, dodge, duck or jump) inside its timing window.
- **Attack rounds.** Your turn. Land your own strikes on the beat to wear the enemy down.

Every hit is graded **Perfect**, **Good** or **Miss**. Perfect parries build your combo and charge your style's special move. Misses cost you health. Enemies speed up and change tactics as they weaken, so the last stretch of a fight is the hardest.

A standard encounter is tuned to last about a minute.

**Focus** is a meter you build up and spend for a short burst of empowerment. It makes you stronger without making the enemy any easier.

### Game modes

| Mode | What it is |
| --- | --- |
| **Trial by Combat** | The campaign. Fight seven champions across six battlefields. The King waits at the end. |
| **Survival** | Endless waves. Every kill restores a little health. How long can you stand? |
| **Boss Rush** | Every champion back to back on one health bar. |
| **Daily Challenge** | One seeded fight per day, the same for everyone. Beat your best. |
| **Training Yard** | No damage dealt or taken. Practise every move. |

### The champions

1. **Hollow Conscript**, the Broken Foot-Soldier (Castle Courtyard)
2. **Pyre Marauder**, the Ashen Berserker (Burning Village)
3. **Frost Warden**, the Glacial Guardian (Frozen Pass)
4. **Marsh Hag-Knight**, the Bog Sorcerer (Drowned Marsh)
5. **Crimson Executioner**, Scourge of the Cliff (Blood Moon Crag)
6. **The Bishop of Ash**, the High Hierophant (Ruined Basilica)
7. **The King**, Sovereign of Ruin (back in the Castle Courtyard)

Each champion has their own look, tempo, attack patterns, boss phases, taunts and arena. Each arena has its own weather, lighting and music.

### Fighting styles

| Style | Cost | Feel | Special |
| --- | --- | --- | --- |
| **Knight** | Free | Balanced sword and shield with generous parry margins | **Iron Bastion**: absorbs the next incoming hit completely |
| **Duelist** | 250 gold | Agile twin blades, wider precision timing, deadly counters | **Riposte**: after a perfect parry, your next attack does double damage |
| **Berserker** | 500 gold | Heavy greatsword, huge damage, narrow timing, takes more damage | **Rage**: a 10 combo gives 6 seconds of double damage |

### Progression and the shop

Win fights to earn gold and spend it on new styles and one-fight tonics:

- **Healing Draught**: restore 35% health mid-fight (once per fight)
- **Battle Focus**: start the next fight with the Focus meter half full
- **Whetstone**: +25% damage for the next fight
- **Iron Gambeson**: 20% less damage taken for the next fight

Your gold, champions slain, unlocked styles and best scores for Survival, Boss Rush and the Daily Challenge are saved on the device.

### Built for touch

- Compact mobile layout that keeps both fighters and the arena in view
- On-screen pads for the three lanes plus jump, dodge, duck and parry
- Left-handed layout
- Haptic feedback
- Settings for music and effects volume, difficulty (easy, normal, hard, brutal), audio/visual latency offset, screen shake, blood level, graphics quality, screen flashes, timing guide and fighting style

## How it is built

- **Swift 5.9, SwiftUI and Canvas.** No third-party dependencies.
- **Custom renderer.** SVG art is parsed and drawn directly into a SwiftUI `Canvas`: parallax arenas, a posed fighter rig with spring-smoothed animation, weapon trails, weather, blood, sparks and dust.
- **Procedural audio.** Sound effects and adaptive music (per-arena key, scale and tempo, with intensity that rises as a fight heats up) are synthesised at runtime with `AVAudioEngine`.
- **Deterministic engine.** The game logic runs on a fixed beat clock driven by the display link, targeting 60 fps. The Daily Challenge uses a date-seeded random generator.
- **Tested.** Unit tests cover the engine, audio, rendering and dialogue, and run on every push.

```
KingsJustice/
  Core/     game engine, rounds, input, modes, save data
  Data/     champions, styles, arenas, dialogue
  Render/   SVG parser, fighter rig, scene, particles
  Audio/    synth, audio engine, haptics
  UI/       menus, HUD, touch controls, settings, shop
tools/      make_icon.py (draws the app icon in code)
```

## Where it is going

**Goals**

- **Full parity with the original browser game**, with the native version matching or beating it on feel, content and balance.
- **A steady 60 fps** on any hardware that can manage it, with animation that stays smooth during the busiest fights.
- **Fights that stay fair and readable.** About a minute per standard fight, with difficulty coming from sharper patterns and tempo, never from hidden rules.
- **A compact, comfortable mobile layout** on every iPhone and iPad size.

**Ideas on the table** (not promises)

- More champions, arenas and fighting styles
- More music and dialogue variety per arena
- Online leaderboards for the Daily Challenge
- Game Center achievements
- Controller support
- Accessibility options such as larger timing windows and colour-blind-friendly note colours
- A signed build on TestFlight

## Build

Every push to `main` runs the **Build IPA** GitHub Action. Open the **Actions** tab, pick the latest run and download the `KingsJustice-unsigned-ipa` artifact.

The IPA is unsigned. Sign and install it with your usual tool (AltStore, Sideloadly, TrollStore).

Build locally:

```sh
brew install xcodegen
xcodegen generate
open KingsJustice.xcodeproj
```

Requires Xcode with the iOS 17 SDK or later.

To redraw the app icon: `python3 tools/make_icon.py` (needs Pillow).
