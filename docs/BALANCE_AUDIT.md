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

## Findings that need your call (nothing below was changed)

- **The music does not follow the fight's tempo.** The music plays at the arena's own tempo (70 to 92 BPM) and never changes. The notes fall on the champion's tempo (80 to 112 BPM), which also creeps up by up to 10 BPM as the champion weakens and jumps at phase changes. `AudioEngine.setMusicBPM` exists but nothing calls it. The engine also re-anchors the beat grid at the start of every round, so there is no single global beat the music could lock to. A real fix is a continuous beat clock under all note scheduling. That is timing-critical, so I would only do it with you playtesting each step.
- **Phase "pools" are flavour text.** Every phase has a pool name (enrage, frenzy, blizzard and so on) that no code reads. A phase today means a tempo bump plus a lean toward the later, denser patterns. Distinct phase behaviour per champion would need design decisions from you.
- **Maps are visual and audio, not mechanical.** Each arena has its own look, weather, music scale and (since the recent batches) ambient life and colour grade. Village and Cliff both use "ash" weather in near-identical orange. A map that changes how you fight (for example a hazard lane or a shifting light) would be a real gameplay change, so it needs your design input.
- **Teaching order is good.** The Conscript uses slash and low only, and almost every champion adds one or two new moves (double and high, ranged, feint and triple, grab and unblockable, sweep combo). Dodge and Grab first appear at the fifth champion. The Training Yard drills cover them earlier. Left as is.
