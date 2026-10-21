# Gameplay and maps audit (Oct 2026)

Method: the real engine, played by a simulated player at three skill levels, four fights per champion per level, Normal difficulty.
"Expert" misses 3% of notes and hits 80% of the rest Perfect. "Typical" misses 10% and hits 45% Perfect. "Casual" misses 22% and hits 25% Perfect.
Your rule: a standard fight lasts about 60 seconds. Typical is the target.

## Fight length in seconds (win count out of 4 in brackets)

| Champion | Typical before | Typical after | Casual before | Casual after | Expert after |
|---|---|---|---|---|---|
| Hollow Conscript | 66 | 58 | 102 | 87 | 47 |
| Pyre Marauder | 58 | 59 | 78 | 79 | 40 |
| Frost Warden | 56 | 56 | 82 | 82 | 42 |
| Marsh Hag Knight | 58 | 59 | 72 | 68 | 38 |
| Crimson Executioner | 51 | 52 | 62 | 63 | 37 |
| Bishop of Ash | 56 | 57 | 41 (0) | 48 (0) | 36 |
| The King | 54 | 54 | 54 (2) | 46 (1) | 34 |

Typical players spread 51 to 66 seconds before, and 52 to 59 after. Every typical player won every fight in both runs.
The casual win counts at the end are small samples (four fights each), so read them as "the Bishop and King stay out of reach for a casual player", not as exact odds.

## What changed

1. **First champion pacing.** Each strike on the Hollow Conscript now removes 12% more of its health (table value 1.0 to 1.12). Its slow tempo (80 BPM) made it the longest fight in the game for a typical player, in the very first fight a new player sees.
2. **Second wind.** After 75 seconds, the player's own strikes grow stronger, a little more each second, up to +50%. Typical fights never reach it. It only trims long fights for casual players. It changes only how hard you hit: enemy behaviour, enemy damage and timing windows are untouched, in line with the rule that nothing should make the enemy AI easier. To switch it off, set `PaceGovernor.maxBoost` to 0.

## Second pass: the champions' AI settings were dead data

Every champion has an AI definition (`aggression`, `parryChance`, `feintChance`, `comboLength`, and a `special` such as flame or frostbite).
**None of it was read by the engine.** The only reference was a no-op line (`value != nil ? 1.0 : 1.0`). Champions differed only by their patterns, health, tempo and move set.
Every champion's patterns also already contain that champion's signature move (for example exactly one ranged shot in every Frost Warden pattern), so steering a phase toward "signature patterns" would change almost nothing. Distinct phases need new authored patterns, which is a design job for you.

**What changed:** `aggression` now drives a "pressure" mechanic. After a defend round, a champion with aggression above 0.55 may press a second defend round straight away, skipping your strike round. You see a "No opening!" cue. The chance is 0 for the first three champions and rises to 4% (Marsh Hag), 8% (Executioner), 12% (Bishop) and 16% (King), plus 4% per active phase, and never in the first four rounds or in the Training Yard. It only makes champions more relentless.

Simulation at the three skill levels (seconds, wins out of 4, average player health left on a win):

| Champion | Typical, pacing only | Typical, with pressure | Casual, pacing only | Casual, with pressure |
|---|---|---|---|---|
| Hollow Conscript | 58 s (4) hp 93 | 57 s (4) hp 93 | 87 s (4) | 88 s (4) |
| Pyre Marauder | 59 s (4) hp 77 | 58 s (4) hp 79 | 79 s (4) | 78 s (4) |
| Frost Warden | 56 s (4) hp 96 | 56 s (4) hp 96 | 82 s (4) | 79 s (4) |
| Marsh Hag Knight | 59 s (4) hp 86 | 55 s (4) hp 77 | 68 s (2) | 70 s (3) |
| Crimson Executioner | 52 s (4) hp 80 | 50 s (4) hp 78 | 63 s (4) | 63 s (4) |
| Bishop of Ash | 57 s (4) hp 37 | 55 s (4) hp 53 | 48 s (0) | 51 s (0) |
| The King | 54 s (4) hp 42 | 55 s (3) hp 37 | 46 s (1) | 45 s (0) |

Fight length is unchanged (about 50 to 58 seconds for a typical player). The King is slightly harder, as a final boss should be (a typical player went from 4 wins to 3 in this small sample). Four fights per cell is a small sample, so treat single-cell changes as noise.
The other champion settings (`parryChance`, `feintChance`, `comboLength`, `special`) are still unused, see the roadmap.

## Third pass: authored data nobody could see

A scan of every data-definition struct for fields that no code reads found:

| Struct | Unused fields | What happened |
|---|---|---|
| AIDef | parryChance, feintChance, comboLength, special | Still unused. Each would be a new mechanic, see the roadmap |
| PhaseDef | newPatternPool | Still unused (the patterns already contain each signature move) |
| ArenaDef | sub | **Now shown**: the fight intro card names the battlefield and its one-line description, for example "Drowned Marsh: Fog, rot and whispering reeds" |
| ArenaLight | fogOp | **Now used**: each arena's mist thickness follows its authored value (marsh thickest at 0.28, castle thinnest at 0.17). Normalised so the average fog level is unchanged |
| ArenaLight | ambient, fog (colour) | Still unused. The renderer keeps its own brighter fog colours, and I did not swap them blind |

## Findings that need your call (nothing below was changed)

- **The music does not follow the fight's tempo.** The music plays at the arena's own tempo (70 to 92 BPM) and never changes. The notes fall on the champion's tempo (80 to 112 BPM), which also creeps up by up to 10 BPM as the champion weakens and jumps at phase changes. `AudioEngine.setMusicBPM` exists but nothing calls it. The engine also re-anchors the beat grid at the start of every round, so there is no single global beat the music could lock to. A real fix is a continuous beat clock under all note scheduling. That is timing-critical, so I would only do it with you playtesting each step.
- **Phase "pools" are flavour text.** Every phase has a pool name (enrage, frenzy, blizzard and so on) that no code reads. A phase today means a tempo bump plus a lean toward the later, denser patterns. Distinct phase behaviour per champion would need design decisions from you.
- **Maps are visual and audio, not mechanical.** Each arena has its own look, weather, music scale and (since the recent batches) ambient life and colour grade. Village and Cliff both use "ash" weather in near-identical orange. A map that changes how you fight (for example a hazard lane or a shifting light) would be a real gameplay change, so it needs your design input.
- **Teaching order is good.** The Conscript uses slash and low only, and almost every champion adds one or two new moves (double and high, ranged, feint and triple, grab and unblockable, sweep combo). Dodge and Grab first appear at the fifth champion. The Training Yard drills cover them earlier. Left as is.
