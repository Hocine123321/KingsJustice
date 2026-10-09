# Kings Justice — Future Plans

Living roadmap. Goal: turn the prototype into a high-quality, polished game people actually want to keep playing.
Update the status boxes as work lands. Never delete an idea; move it to "Done" or "Parked" with a reason.

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
- [ ] Polished menu cards with press animation, subtle glow, mode art (staggered entrance + skyline backdrop done; card art still open)
- [x] Smooth screen transitions (fade) instead of hard cuts
- [ ] Short first-launch intro / story hook (the old "Watch Cinematic" button was a dead end and was removed; bring it back only with a real cinematic)

### 2. Fight presentation
- [x] Boss entrance: champion name and title card before round one (signature pose and sting still open)
- [x] Round-start "FIGHT!" beat
- [ ] Phase-change moments (enemy shifts stance, music layer swaps, banner)
- [x] Parry / Perfect shockwave ring (screen-edge flash still open)
- [x] Camera framing that pushes in as an enemy gets low on health

### 3. Result and reward feel
- [x] Rewards sequence: gold/score count-up, S/A/B/C/D rank stamp, personal-best callouts (real stats; the old screen showed a fake +50 gold and the current combo as "best")
- [ ] "New unlock" celebration moment
- [x] Better defeat screen: tip tied to the fight stats (misses vs perfects vs Focus)

### 4. Arena depth (arenas currently read flat)
- [ ] 3+ parallax layers per arena (far / mid / near) with independent drift
- [ ] God rays / light shafts where the art implies windows or moon (castle done; cathedral, pass, swamp still open)
- [ ] Per-arena ambient life: crows, bats, fireflies, falling leaves, torch sparks
- [ ] Arena-specific events mid-fight: lightning flash, wind gust, crowd reaction
- [ ] Reactive environment: banners sway, puddles ripple on impact, debris on heavy hits
- [ ] Per-arena colour grading

### 5. Character animation and design
- [ ] Anticipation / follow-through pass on every attack and block
- [ ] Idle variety (breathing, weight shifts, taunts) so fighters never look frozen
- [ ] Distinct silhouette and attack language for each of the seven champions
- [ ] Better hit reactions, stagger, and death animations per champion
- [ ] Cloth/cape/hair secondary motion
- [ ] Armour and weapon cosmetics per fighting style

### 6. Audio
- [ ] Unique looping battle theme per arena, tied to champion identity
- [ ] Adaptive intensity: layers escalate with combo and low health, resolve after the kill
- [ ] Title and menu themes, victory / defeat / unlock stingers
- [ ] Richer impact sounds (material-aware: steel, shield, flesh), ambient beds (wind, crowd, swamp)
- [ ] Haptic patterns matched to hit type

### 7. Gameplay depth
- [ ] Clearer, more varied enemy tells; per-champion signature mechanic
- [ ] Survival: modifiers between waves, risk/reward picks, boss waves, leaderboard-style best runs
- [ ] Daily Challenge: seeded modifier of the day, streak counter
- [ ] Boss Rush: score multiplier for no-damage clears
- [ ] Training Yard: guided drills, a move list, a metronome to practise timing
- [ ] Interactive tutorial for the rhythm mechanic (first fight)
- [ ] Difficulty assist options that never touch Focus-vs-AI rules

### 8. Progression and retention
- [ ] Meaningful unlocks: styles, cosmetics, titles
- [ ] Achievements and a "chronicle" of defeated champions
- [ ] Gold sinks that matter in the shop
- [ ] Optional Game Center leaderboards and achievements

### 9. UI/UX and accessibility
- [ ] Consistent HUD style, safe-area handling on all iPhones, compact layout check on small screens
- [ ] Colour-blind friendly note colours, reduced-motion and reduced-flash options (settings already exist for some)
- [ ] Left-handed layout option
- [ ] Pause menu polish, clearer settings

### 10. Technical quality
- [ ] Performance profile on the heaviest scene; keep every effect cheap (gradients over blur filters)
- [ ] More unit tests around engine edge cases and fight length (~60 s)
- [ ] Crash/edge-case pass: interruptions, backgrounding, audio route changes
- [ ] CI: add a lint step and a simple fight-length simulation test
- [ ] Localization-ready strings

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
- [ ] Re-measure fps from a new recording; if still under 60, profile fighter rig layer count and SVG per-frame fallback
- [x] Weapons look oversized: all weapons scaled to 86% (grip anchored, trail tip matched). Revisit after a new recording
- [x] Fighters are small on screen: landscape camera 5% tighter, centred lower on the fighters
- [x] Castle arena: real block masonry (highlights, shadows, chips, damp streaks), moonlit windows and light shafts. Cathedral also reworked (complete rose window + halo, stars, coloured light pools, broken pews). Village, pass, swamp and cliff still to get the same treatment
- [ ] Touch zones: consider a first-run hint then auto-fade, and a left-handed check
- [x] Top HUD: removed the confusing wallet gold from the enemy side; player bar turns red when low

## Stretch ideas (parked until the core is polished)
- Photo mode / replay of the final blow
- Ghost data for Daily Challenge
- Story cinematics between champions
- Seasonal arenas and limited events
- Local pass-and-play duel

## Process for every batch
1. Pick the next unchecked item above. 2. Implement small. 3. Add or update tests. 4. Push. 5. Confirm CI (tests + IPA) is green. 6. Share the download link and what to look at. 7. Tick the box here.
