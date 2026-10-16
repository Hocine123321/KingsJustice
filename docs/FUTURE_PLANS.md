# Kings Justice — Future Plans

Living roadmap. Goal: turn the prototype into a high-quality, polished game people actually want to keep playing.
Update the status boxes as work lands. Never delete an idea; move it to "Done" or "Parked" with a reason.

## Status snapshot (Oct 15, 2026)
Checklist below: 65 items done, 16 open. Latest CI build is green (lint, unit tests, IPA). Frame rate confirmed at 60 fps on the owner's device (Oct 12), before the newest ambient-life layers.

### What is still open, grouped by what it needs
**Needs an owner decision (balance and design sign-off)**
- Armoury prices (120 to 320 gold, all in `Armoury.all`): too cheap, too dear? And should style unlocks (200 and 500 gold) count gold earned instead of gold held, so buying tonics or liveries cannot delay them?
- New cosmetic silhouettes (helm, cape and weapon swaps) per style. Colour liveries are done; changing shapes needs art sign-off
- Per-champion signature mechanics (the current tells are shared by all seven)
- Dedicated Boss Rush scoring

**Needs the owner's eyes on a phone (art and feel; guessing blind risks hurting timing feel)**
- Anticipation / follow-through pass, idle variety, distinct silhouettes, hit reactions and death animations, cloth and cape motion
- 3+ parallax layers per arena, reactive environment (banners, puddles, debris), god rays for cathedral, pass and swamp
- Boss entrance signature pose and sting; screen-edge flash on Perfect parries; crowd reaction to arena events

**Needs a device or simulator**
- Layout check of every screen in phone landscape on the smallest phone (shop, style picker, settings, pause, end screen, Chronicle, which keeps growing)
- Performance profile on the heaviest scene, and an fps re-check with the newest particle layers
- Left-handed touch-zone check

**Needs an Apple capability**
- Game Center leaderboards and achievements (an unsigned build cannot use them)

**Small engineering items that need nothing from the owner**
- A distinct title-screen theme (menu screens already have a calm choir theme; the title is silent until Begin)
- Material-aware variants of the impact sounds
- Translating text built from variables (wave numbers, names, scores)

## Fixed rules (from the owner — do not drift from these)
- Two main modes: **Trial by Combat** and **Survival**. Extras: Boss Rush, Daily Challenge, Training Yard.
- Target 60 fps. A standard fight lasts about 60 seconds.
- **Focus** empowers the player. It must never make enemy AI easier.
- Mobile layout stays compact so fighters and arena are always visible.
- Every change is pushed to GitHub. CI must build the IPA and pass the tests before a download link is shared.
- Quality bar: every side of the game, not just one area.

## Working constraints
- Swift cannot be compiled locally; CI is the compiler. Ship in small batches so one error never blocks everything.
- No third-party dependencies; art is vector, audio is synthesized in code.
- Rhythm notes are synced to the music clock. Never slow game time during live fighting (slow-mo only at the finisher).
- Validated balance in `PORTING.md`: any gameplay-balance change needs owner sign-off.

## Done so far
- [x] Menu: Trial by Combat + Survival as main cards, extras as compact rows
- [x] Display link pinned to 60 fps
- [x] Spring-based fighter animation, weapon trails, dust (pre-existing updates)
- [x] Layered music, dialogue/barks, app icon (pre-existing updates)
- [x] Floating damage numbers and combo pop-ups
- [x] Kill-cam finisher: slow-mo, pivot zoom, delayed result screen
- [x] Torch flicker, drifting fog, Focus aura

## Next up (in order)
### 1. First impressions
- [x] Animated title screen: blood moon, parallax ridges, flickering castle, embers, staged logo reveal
- [x] Polished menu cards: spring press animation, pulsing accent glow, vector emblem per main mode (crossed blades for Trial by Combat, rising waves for Survival). Extras stay compact rows. Glow pulse is skipped under system Reduce Motion
- [x] Smooth screen transitions (fade) instead of hard cuts
- [x] Lifetime stats and records: fights won and win rate, timing accuracy, best combo and S ranks in the Chronicle, a won/lost record under every champion, a "New best combo" badge on the result screen, and two new achievements with titles (Veteran at 25 fights, Deadeye at five S ranks). The Training Yard never counts
- [x] Guided practice in the Training Yard: pick Guided practice in the Move List and it walks through Parry, Duck, Jump, Dodge and Grab, four clean (Perfect or Good) answers each, with live progress in the HUD label. A scraped late answer does not count. It builds on the drills, so enemy AI and timing windows are untouched. A fully scripted tutorial inside How to Play is still open
- [x] Weekly Gauntlet (new extra mode): three seeded champions on one health bar, new every Monday (UTC), never the King, easiest first, with a weekly twist from the Daily Challenge list (Marathon health, Tempo, and so on). The twist's score multiplier is applied once when the run ends, and your best score per week is kept and shown in the menu badge and the Chronicle's Records tab. Everyone gets the same gauntlet that week
- [x] The Armoury: six gold-bought liveries (Emberforged, Frostbound, Greenwood, Royal Violet, Ashen Ghost, Gilded Dawn, 120 to 320 gold) in the shop, worn per fighting style and drawn on your fighter. Purely cosmetic: the helm, cape, weapon and every stat are untouched, and tests prove it. A hand-edited save cannot wear a livery it does not own
- [x] Chronicle overhaul: four tabs (Deeds, Records, Champions, Titles) instead of one long scroll, so each page is short on a small phone
- [x] Hall of Records (Chronicle): your best five Survival runs, best five Boss Rush runs and top three Daily Challenge scores, plus a "Hall of Records #n" badge on the result screen when a finished run makes the list (a new personal best keeps its own label). Boss waves were already flagged in the fight intro, mode label and boon screen, so no extra banner was added
- [x] Short first-launch intro / story hook: three text cards after the title screen on the very first launch only (tap or wait, Skip any time) (the old "Watch Cinematic" button was a dead end and was removed; bring it back only with a real cinematic)

### 2. Fight presentation
- [x] Boss entrance: champion name and title card before round one (signature pose and sting still open)
- [x] Round-start "FIGHT!" beat
- [x] Phase-change banner ("PHASE II - <champion> grows desperate") with the existing shake, heartbeat and red flash. The music now holds full intensity for four seconds after a phase change, and each phase reached lifts the baseline (the Phase II+ music layer swap); a separate drum-layer swap is still open
- [x] Parry / Perfect shockwave ring (screen-edge flash still open)
- [x] Camera framing that pushes in as an enemy gets low on health

### 3. Result and reward feel
- [x] Rewards sequence: gold/score count-up, S/A/B/C/D rank stamp, personal-best callouts (real stats; the old screen showed a fake +50 gold and the current combo as "best")
- [x] "New unlock" celebration moment: a gold banner springs in on the result screen when a fight crosses the Duelist (200 gold) or Berserker (500 gold) threshold
- [x] Better defeat screen: tip tied to the fight stats (misses vs perfects vs Focus)

### 4. Arena depth (arenas currently read flat)
- [ ] 3+ parallax layers per arena (far / mid / near) with independent drift
- [ ] God rays / light shafts where the art implies windows or moon (castle done; cathedral, pass, swamp still open)
- [x] Per-arena ambient life: crows (castle, cliff), bats (cathedral), fireflies (swamp), rising embers (village), snow motes (pass). Drawn only on High quality, no blur filters, positions are a pure function of time. Second layer: falling leaves (village) and torch sparks from the real torch points (castle, cliff)
- [x] Arena events every 14-26 s, cosmetic only: swamp lightning, cliff red lightning, cathedral bell, village roof collapse, pass gust, castle torch flare (crowd reaction still open)
- [ ] Reactive environment: banners sway, puddles ripple on impact, debris on heavy hits
- [x] Per-arena colour grading (subtle screen-space tint and edge darkening per arena; off on Low quality)

### 5. Character animation and design
- [ ] Anticipation / follow-through pass on every attack and block
- [ ] Idle variety (breathing, weight shifts, taunts) so fighters never look frozen
- [ ] Distinct silhouette and attack language for each of the seven champions
- [ ] Better hit reactions, stagger, and death animations per champion
- [ ] Cloth/cape/hair secondary motion
- [ ] Armour and weapon cosmetics per fighting style

### 6. Audio
- [x] Unique battle theme per arena: own chord progression, melody and drum feel for castle, village, pass, swamp, cliff, cathedral (before, all six used one pattern and differed only by key and speed)
- [x] Adaptive music intensity: rises with the champion wounds, your combo and your own danger; drops after the kill
- [ ] A distinct title-screen theme. The menu pages already play a calm, drum-less choir theme (starts on the menu, campaign, style and shop screens); the title screen itself is silent until you tap Begin. Victory, defeat and unlock stingers are done
- [ ] Richer impact sounds: parry/perfect/hurt/block/heavy/thud sounds are now layered onto hits (they existed but were never used). Material-aware variants and ambient beds now exist (see below). Material-aware variants still open
- [x] Haptic patterns matched to hit type (menu taps and enemy hits were silently doing nothing before; added tap, parry, impact, perfect, kill patterns)

### 7. Gameplay depth
- [x] Clearer tells: a coloured marker with the move name now appears above the champion as an attack closes in (matches the button colour). Per-champion signature mechanics still open
- [x] Survival: pick one of three boons after each wave (Keen Edge, Iron Ward, Vigor, Mending Draught, Glass Cannon risk/reward, Spoils of War). None touch enemy AI. Boss waves (the King every 5th wave, 4-boon reward) and boon chips on the HUD are in. The best-run list now exists as the Hall of Records in the Chronicle
- [x] BUG FIXED: Survival and Boss Rush reset your health to full and your score to zero after every win (the "one health bar" rule was not enforced); they now carry health and score between fights
- [x] Daily Challenge: modifier of the day (Steady Hands, Brittle, Marathon, Quickstep, One Chance, each with a score bonus) and a win streak shown on the menu
- [x] Flawless bonus (any mode): win without taking a hit for +20% gold and a result badge. Dedicated Boss Rush scoring still open
- [x] Training Yard: move list (pause menu, touch wording), beat metronome dot, and five single-input drills (Parry, Duck, Jump, Dodge, Grab) picked from the move list. Drills change only which defend input is asked, never the enemy AI or timing windows
- [x] How to Play: 3 animated pages (Strike / Defend / Focus and Heal), shown once before the first fight and from the menu. Contextual tips now use touch wording (they said Space / W / S / A). Still open: a guided, interactive practice round
- [x] Timing Assist toggle (+25% timing windows; enemy untouched)

### 8. Progression and retention
- [x] Meaningful unlocks: styles (200 and 500 gold, with a celebration) and titles. Every achievement grants a cosmetic title; pick one to wear in the Chronicle and it shows in your header and Share text. Purely cosmetic, no effect on fights. Armour and weapon cosmetics are still open
- [x] Chronicle screen: deeds, defeated champions, 12 achievements derived from the save (lifetime stats, the Hall of Records and wearable titles were added later)
- [ ] Gold sinks that matter in the shop
- [ ] Optional Game Center leaderboards and achievements

### 9. UI/UX and accessibility
- [ ] Consistent HUD style, safe-area handling on all iPhones, compact layout check on small screens
- [x] Colour-blind palette toggle (Okabe-Ito). Reduced-flash already exists; reduce-motion toggle added (no shake or camera zoom)
- [x] Left-handed layout option (Settings toggle swaps the parry and evade clusters)
- [x] Pause menu polish, clearer settings: the pause header names your mode (and drill), and every Settings toggle has a one-line plain explanation (Timing Assist says enemies are unchanged)

### 10. Technical quality
- [ ] Performance profile on the heaviest scene; keep every effect cheap (gradients over blur filters)
- [x] Fight length is now measured by simulation (CI reports it every run). Typical player (45% Perfect, 45% Good, 10% missed): 49-72 s per champion, about 57 s on average, matching the 60 s target. Perfect play: 28-45 s. The test fails if any champion drifts outside 35-90 s. More edge-case tests still welcome
- [x] Launch screen is now the game's dark colour (it was a white flash) and the app is forced to dark appearance. Fights now auto-pause when the app leaves the foreground. Unplugging headphones now pauses the fight too
- [x] CI: fight-length simulation test, plus a fast lint job (scripts/lint.sh: leaked GitHub tokens, merge-conflict markers, tabs, doubled-backslash key paths, stray print calls)
- [x] Localization-ready strings: shared components and Settings/Training text go through L10n.t, backed by Resources/en.lproj/Localizable.strings (120 keys, generated by scripts/strings.py and checked by the lint job). Add a language by copying the folder and translating the values. Text built from variables (wave numbers, names, scores) is not translated yet

## Findings from the owner's gameplay recording (Oct 2026)
Fixed in the "recording fixes" batch:
- [x] Focus aura / kill-cam vignette showed a hard 16:9 edge on wide phones (my bug) - now drawn in screen space
- [x] Arena left dark side bars on wide phones - landscape now fills the screen (top/bottom edge trimmed instead)
- [x] Arenas looked blurry - layers were baked at 1.0x, now 1.6x
- [x] Touch-zone boxes covered most of the arena - borders and labels are now much quieter until pressed
- [x] "Struck" / "Scraped" judge text was low-contrast and sat on top of the fighters - now outlined and raised
- [x] Damage numbers were small, grey and always "37" - now bigger, outlined, over the champion's head, 10x scale
- [x] Landscape menu: skyline fought with the list rows - dimmed in landscape
- [x] Frame rate: the recording suggests roughly 45-48 fps in the red arena and 30-36 fps in the castle. Per-frame blur layers (note glow, fighter shadow/aura, weapon trail, sparks, dust, ring glow, impact flash) were replaced with cheap gradients/strokes
- [x] Result screen overflowed in landscape (title and buttons cut off; owner screenshot) - now a two-column landscape layout, scrollable in portrait
Still open:
- [ ] Check EVERY screen in phone landscape for overflow (shop, style picker, settings, pause, end screen) with a layout test or screenshot pass
- [x] Re-measure fps: owner confirmed 60 fps on device (Oct 12, 2026). Re-check after the ambient life layer
- [x] Weapons look oversized: all weapons scaled to 86% (grip anchored, trail tip matched). Revisit after a new recording
- [x] Fighters are small on screen: landscape camera 5% tighter, centred lower on the fighters
- [x] Castle arena: real block masonry (highlights, shadows, chips, damp streaks), moonlit windows and light shafts. Cathedral also reworked (complete rose window + halo, stars, coloured light pools, broken pews). Swamp also reworked (two-layer cypress forest with hanging moss, glowing eyes, mud/puddle detail, rotting log). Village also reworked (it only had mountains before; now a burning village skyline with houses, rooftop fires and a church tower). Pass also reworked (aurora, stars, pine forest, snow sparkle, banner). Cliff also reworked (execution scaffold with gallows and axe block, crows over the blood moon, sea stacks, wave crests, rubble and bones). All six arenas now have a depth pass; keep tuning after real-device feedback
- [x] Touch zones: clearer outlines for new players (first 3 wins), then they fade. Left-handed check still open
- [x] Top HUD: removed the confusing wallet gold from the enemy side; player bar turns red when low

## Controls (owner feedback)
- [x] Button colours did not match the circles (the Jump button was green but its circle was yellow; circles were coloured by attack type, not by the button to press). One shared palette now drives both: Parry blue, Duck yellow, Jump green, Dodge red-orange, Grab violet. The target circle takes the same colour; double strikes show a second ring.

## Engineering fixes
- [x] Saves and settings used auto-generated decoding, so adding any field would have silently reset players' progress. Now tolerant (missing fields fall back to defaults), with tests
- [x] Ambient beds: wind (pass), crowd (castle), crackling fire (village), crickets (swamp), waves (cliff), choir hum (cathedral). Seamless 8 s loops, synthesized in code

- [x] The Graphics Quality setting did nothing before. Now High keeps everything, Medium drops weapon trails and mist, Low also drops weather and dust (for slower phones)

- [x] Boss Rush was unfinished: best run was never saved, and winning the last champion tried to start a non-existent fight. Now it records your best, ends at the King with a +150 gold gauntlet bonus and a "Return to the Hall" result, and unlocks the Gauntlet achievement
- [x] HUD shows where you are (Survival wave, Rush 2/7, Daily twist, Training Yard); result screen recaps the boons you took; Settings Reset no longer changes your fighting style

## Stretch ideas (parked until the core is polished)
- Photo mode / replay of the final blow
- Ghost data for Daily Challenge
- Story cinematics between champions
- Seasonal arenas and limited events
- Local pass-and-play duel

## Process for every batch
1. Pick the next unchecked item above. 2. Implement small. 3. Add or update tests. 4. Push. 5. Confirm CI (tests + IPA) is green. 6. Share the download link and what to look at. 7. Tick the box here. Batches bundle several changes (owner request, Oct 12 2026).
