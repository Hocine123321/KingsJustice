if (typeof window === 'undefined') {
  var window = typeof globalThis !== 'undefined' ? globalThis : global;
}

window.MOVES = {
  slash: { tellBeats: 1.0, label: "Slash", color: "#e74c3c", ringStyle: "solid", input: "parry", dmg: 12, pose: "wind", sfx: "clang" },
  low: { tellBeats: 1.0, label: "Low Sweep", color: "#e67e22", ringStyle: "solid", input: "duck", dmg: 14, pose: "low", sfx: "whoosh" },
  high: { tellBeats: 1.0, label: "Overhead", color: "#f1c40f", ringStyle: "solid", input: "jump", dmg: 16, pose: "high", sfx: "heavy" },
  unblockable: { tellBeats: 1.25, label: "Unblockable", color: "#ff0044", ringStyle: "red", input: "dodge", dmg: 25, pose: "lunge", sfx: "heavy" },
  feint: { tellBeats: 1.5, label: "Feint", color: "#9b59b6", ringStyle: "dashed", input: "parry", dmg: 18, pose: "wind", sfx: "whoosh" },
  double: { tellBeats: 1.0, label: "Double Strike", color: "#3498db", ringStyle: "double", input: "parry", dmg: 20, pose: "wind", sfx: "clang" },
  triple: { tellBeats: 1.0, label: "Triple Strike", color: "#1abc9c", ringStyle: "double", input: "parry", dmg: 24, pose: "wind", sfx: "clang" },
  grab: { tellBeats: 1.25, label: "Grab Lunge", color: "#d35400", ringStyle: "red", input: "grab", dmg: 28, pose: "lunge", sfx: "heavy" },
  ranged: { tellBeats: 1.5, label: "Ranged Throw", color: "#2ecc71", ringStyle: "dashed", input: "parry", dmg: 10, pose: "throw", sfx: "whoosh" },
  sweep_combo: { tellBeats: 1.0, label: "Sweep Combo", color: "#8e44ad", ringStyle: "dashed", input: "duck", dmg: 22, pose: "low", sfx: "whoosh" }
};

window.STYLES = [
  {
    id: "knight",
    name: "Knight",
    desc: "Balanced sword and shield defender with generous parry margins.",
    weapon: "longsword",
    windows: { perfect: 0.08, good: 0.16, miss: 0.25 },
    dmgMul: 1.0,
    takeMul: 1.0,
    parryBonus: 0.10,
    special: { id: "bastion", name: "Iron Bastion", desc: "Absorbs the next incoming hit completely", charge: "perfect", need: 5 },
    look: { colors: ["#2c3e50", "#7f8c8d", "#bdc3c7"], trim: "#f1c40f", helm: "greathelm", cape: "cloak", shield: true }
  },
  {
    id: "duelist",
    name: "Duelist",
    desc: "Agile twin-blade specialist with wider precision timing and deadly counter bursts.",
    weapon: "twinblades",
    windows: { perfect: 0.11, good: 0.20, miss: 0.28 },
    dmgMul: 0.85,
    takeMul: 1.0,
    parryBonus: 0.0,
    special: { id: "riposte", name: "Riposte", desc: "After perfect parry next attack note deals x2 damage", charge: "perfect", need: 3 },
    look: { colors: ["#34495e", "#2980b9", "#ecf0f1"], trim: "#e74c3c", helm: "hood", cape: "cloakK", shield: false }
  },
  {
    id: "berserker",
    name: "Berserker",
    desc: "Relentless heavy attacker dealing massive damage with narrow parry timing.",
    weapon: "greatsword",
    windows: { perfect: 0.06, good: 0.12, miss: 0.20 },
    dmgMul: 1.5,
    takeMul: 1.2,
    parryBonus: 0.0,
    special: { id: "rage", name: "Rage", desc: "Combo of 10 triggers 6 seconds of x2 damage", charge: "combo", need: 10 },
    look: { colors: ["#4a154b", "#800000", "#c0392b"], trim: "#d35400", helm: "horned", cape: "rags", shield: false }
  }
];

window.ROSTER_HELPERS = {
  getEnemyById: function(id) { return window.ROSTER.find(function(e) { return e.id === id; }); },
  getStyleById: function(id) { return window.STYLES.find(function(s) { return s.id === id; }); },
  getDefendMove: function(kind) { return window.MOVES[kind]; }
};

window.ROSTER = [
  {
    id: "hollow_conscript",
    name: "Hollow Conscript",
    title: "Broken Foot-Soldier",
    hp: 90,
    arena: "castle",
    bpm: 80,
    look: {
      colors: ["#2b2b2b", "#4a4a4a", "#7a7a7a"],
      trim: "#666666",
      eye: "#888888",
      helm: "bare",
      cape: "rags",
      weapon: "longsword",
      size: 0.95,
      shield: false
    },
    intro: "Dust to dust... your iron will fade.",
    ai: { aggression: 0.3, parryChance: 0.0, feintChance: 0.0, comboLength: 3, special: "none" },
    defendPatterns: [
      [[1.5, "slash"], [3.0, "slash"], [4.5, "low"]],
      [[1.5, "low"], [3.0, "slash"], [4.5, "slash"]],
      [[2.0, "slash"], [3.5, "slash"], [5.0, "low"]],
      [[1.5, "slash"], [2.5, "low"], [4.0, "slash"]],
      [[2.0, "low"], [3.5, "low"], [5.0, "slash"]],
      [[1.5, "slash"], [3.0, "low"], [4.5, "low"]]
    ],
    attackPatterns: [
      [[1.0, 0], [2.5, 1], [4.0, 2]],
      [[1.0, 1], [2.5, 0], [4.0, 1]],
      [[1.5, 0], [3.0, 2], [4.5, 1]],
      [[1.0, 2], [2.5, 2], [4.0, 0]],
      [[1.5, 1], [3.0, 0], [4.5, 2]],
      [[1.0, 0], [2.5, 0], [4.0, 1]]
    ],
    phases: [
      { at: 0.4, bpmAdd: 2, newPatternPool: "enrage", line: "I... will not crumble!" }
    ],
    reward: 50
  },
  {
    id: "pyre_marauder",
    name: "Pyre Marauder",
    title: "Ashen Berserker",
    hp: 110,
    arena: "village",
    bpm: 84,
    look: {
      colors: ["#3d1400", "#7a2d00", "#b84700"],
      trim: "#f39c12",
      eye: "#ff4500",
      helm: "hood",
      cape: "cloak",
      weapon: "axe",
      size: 1.05,
      shield: false
    },
    intro: "Burn with the ashes of your predecessors!",
    ai: { aggression: 0.45, parryChance: 0.05, feintChance: 0.0, comboLength: 4, special: "flame" },
    defendPatterns: [
      [[1.5, "slash"], [2.5, "high"], [3.5, "low"], [4.5, "slash"]],
      [[1.5, "high"], [2.5, "double"], [4.0, "slash"]],
      [[2.0, "slash"], [3.0, "low"], [4.0, "double"]],
      [[1.5, "double"], [3.0, "high"], [4.0, "low"]],
      [[2.0, "high"], [3.0, "slash"], [4.0, "high"], [5.0, "slash"]],
      [[1.5, "low"], [2.5, "double"], [4.0, "high"]],
      [[2.0, "slash"], [3.0, "double"], [4.5, "low"]]
    ],
    attackPatterns: [
      [[1.0, 0], [2.0, 1], [3.0, 2], [4.0, 0]],
      [[1.0, 2, "BL"], [2.0, 0], [3.0, 1], [4.0, 2]],
      [[1.5, 1], [2.5, 0], [3.5, 1], [4.5, 2]],
      [[1.0, 0], [2.0, 2, "BL"], [3.0, 1], [4.0, 0]],
      [[1.5, 2], [2.5, 1], [3.5, 0], [4.5, 1]],
      [[1.0, 1], [2.0, 0], [3.0, 2], [4.0, 1]],
      [[1.5, 0], [2.5, 2, "P"], [3.5, 1], [4.5, 0]]
    ],
    phases: [
      { at: 0.5, bpmAdd: 3, newPatternPool: "frenzy", line: "Feel the heat of the pyre!" }
    ],
    reward: 110
  },
  {
    id: "frost_warden",
    name: "Frost Warden",
    title: "Glacial Guardian",
    hp: 135,
    arena: "pass",
    bpm: 90,
    look: {
      colors: ["#17202a", "#2c3e50", "#566573"],
      trim: "#85c1e9",
      eye: "#5dade2",
      helm: "greathelm",
      cape: "cloakK",
      weapon: "spear",
      size: 1.1,
      shield: true
    },
    intro: "Winter holds no mercy for warm blood.",
    ai: { aggression: 0.55, parryChance: 0.12, feintChance: 0.0, comboLength: 4, special: "frostbite" },
    defendPatterns: [
      [[1.5, "ranged"], [3.5, "slash"], [4.5, "high"]],
      [[1.5, "slash"], [2.5, "low"], [3.5, "ranged"]],
      [[2.0, "ranged"], [4.0, "double"], [5.0, "low"]],
      [[1.5, "high"], [2.5, "slash"], [3.5, "ranged"], [5.0, "double"]],
      [[2.0, "slash"], [3.0, "double"], [4.5, "ranged"]],
      [[1.5, "low"], [2.5, "high"], [3.5, "slash"], [4.5, "ranged"]],
      [[2.0, "ranged"], [3.5, "high"], [4.5, "double"]]
    ],
    attackPatterns: [
      [[1.0, 2, "BH"], [2.0, 0, "BL"], [3.0, 1], [4.0, 2, "BH"]],
      [[1.0, 0, "BL"], [2.0, 2, "BH"], [3.0, 0, "P"], [4.0, 1]],
      [[1.5, 2, "BH"], [2.5, 1], [3.5, 0, "BL"], [4.5, 2, "BH"]],
      [[1.0, 1], [2.0, 2, "BH"], [3.0, 0, "BL"], [4.0, 1]],
      [[1.5, 0, "BL"], [2.5, 2, "BH"], [3.5, 1, "P"], [4.5, 0, "BL"]],
      [[1.0, 2, "BH"], [2.0, 1], [3.0, 0, "BL"], [4.0, 2, "BH"]],
      [[1.5, 1], [2.5, 2, "BH"], [3.5, 0, "BL"], [4.5, 1]]
    ],
    phases: [
      { at: 0.5, bpmAdd: 3, newPatternPool: "blizzard", line: "The chill turns to ice!" }
    ],
    reward: 180
  },
  {
    id: "marsh_hag_knight",
    name: "Marsh Hag-Knight",
    title: "Bog Sorcerer",
    hp: 155,
    arena: "swamp",
    bpm: 95,
    look: {
      colors: ["#0e1a0e", "#1c331c", "#335c33"],
      trim: "#82e0aa",
      eye: "#2ecc71",
      helm: "cowl",
      cape: "rags",
      weapon: "twinblades",
      size: 1.0,
      shield: false,
      glow: "#2ecc71"
    },
    intro: "Step into the mire... and sink forever.",
    ai: { aggression: 0.65, parryChance: 0.20, feintChance: 0.30, comboLength: 5, special: "miasma" },
    defendPatterns: [
      [[1.5, "feint"], [3.0, "triple"], [4.5, "slash"]],
      [[1.5, "slash"], [2.5, "feint"], [4.0, "low"], [5.0, "triple"]],
      [[2.0, "ranged"], [3.5, "feint"], [5.0, "slash"]],
      [[1.5, "triple"], [3.0, "feint"], [4.5, "low"]],
      [[1.5, "low"], [2.5, "ranged"], [4.0, "feint"], [5.5, "slash"]],
      [[2.0, "feint"], [3.5, "triple"], [5.0, "low"]],
      [[1.5, "slash"], [2.5, "triple"], [4.0, "feint"]],
      [[2.0, "ranged"], [3.5, "triple"], [5.0, "feint"]]
    ],
    attackPatterns: [
      [[1.0, 0, "S+"], [1.8, 1], [2.6, 2, "S-"], [3.4, 0]],
      [[1.0, 1], [1.8, 0, "S+"], [2.6, 2, "P"], [3.4, 1]],
      [[1.5, 2, "S-"], [2.3, 1, "S+"], [3.1, 0], [3.9, 2]],
      [[1.0, 0], [1.8, 2, "S+"], [2.6, 1, "P"], [3.4, 0, "S-"]],
      [[1.5, 1, "S+"], [2.3, 0], [3.1, 2, "S-"], [3.9, 1]],
      [[1.0, 2, "P"], [1.8, 0, "S+"], [2.6, 1, "S-"], [3.4, 2]],
      [[1.5, 0, "S-"], [2.3, 2, "S+"], [3.1, 1], [3.9, 0, "P"]],
      [[1.0, 1, "S+"], [1.8, 2, "S-"], [2.6, 0], [3.4, 1, "S+"]]
    ],
    phases: [
      { at: 0.45, bpmAdd: 4, newPatternPool: "quicksand", line: "The swamp claims your soul!" }
    ],
    reward: 260
  },
  {
    id: "crimson_executioner",
    name: "Crimson Executioner",
    title: "Scourge of the Cliff",
    hp: 175,
    arena: "cliff",
    bpm: 101,
    look: {
      colors: ["#230505", "#4a0a0a", "#781010"],
      trim: "#e74c3c",
      eye: "#ff2222",
      helm: "skull",
      cape: "cloak",
      weapon: "greatsword",
      size: 1.25,
      shield: false,
      glow: "#900c3f"
    },
    intro: "Off with your head! The block awaits.",
    ai: { aggression: 0.75, parryChance: 0.28, feintChance: 0.10, comboLength: 5, special: "decapitate" },
    defendPatterns: [
      [[1.5, "unblockable"], [3.0, "high"], [4.0, "grab"], [5.0, "slash"]],
      [[1.5, "high"], [2.5, "grab"], [3.5, "unblockable"], [4.5, "double"]],
      [[2.0, "grab"], [3.0, "slash"], [4.0, "unblockable"]],
      [[1.5, "double"], [2.5, "unblockable"], [3.5, "grab"]],
      [[2.0, "unblockable"], [3.0, "double"], [4.0, "grab"], [5.0, "high"]],
      [[1.5, "slash"], [2.5, "unblockable"], [3.5, "high"], [4.5, "grab"]],
      [[2.0, "grab"], [3.0, "unblockable"], [4.0, "double"]],
      [[1.5, "high"], [2.5, "double"], [3.5, "unblockable"], [4.5, "grab"]]
    ],
    attackPatterns: [
      [[1.0, 0, "A"], [1.6, 1], [2.2, 2, "BH"], [2.8, 0, "A"]],
      [[1.0, 2, "A"], [1.6, 0, "P"], [2.2, 1, "A"], [2.8, 2]],
      [[1.5, 1, "A"], [2.1, 2, "BH"], [2.7, 0, "A"], [3.3, 1]],
      [[1.0, 0], [1.6, 1, "A"], [2.2, 2, "A"], [2.8, 0, "P"]],
      [[1.5, 2, "A"], [2.1, 0, "BL"], [2.7, 1, "A"], [3.3, 2]],
      [[1.0, 1, "A"], [1.6, 2, "A"], [2.2, 0, "P"], [2.8, 1, "A"]],
      [[1.5, 0, "A"], [2.1, 1, "A"], [2.7, 2, "BH"], [3.3, 0]],
      [[1.0, 2, "A"], [1.6, 0, "A"], [2.2, 1, "P"], [2.8, 2, "A"]]
    ],
    phases: [
      { at: 0.4, bpmAdd: 4, newPatternPool: "execution", line: "Guilty as charged!" }
    ],
    reward: 380
  },
  {
    id: "bishop_of_ash",
    name: "The Bishop of Ash",
    title: "High Hierophant",
    hp: 195,
    arena: "cathedral",
    bpm: 107,
    look: {
      colors: ["#140d24", "#2b1b4d", "#4c3080"],
      trim: "#f1c40f",
      eye: "#f39c12",
      helm: "cowl",
      cape: "cloakK",
      weapon: "scythe",
      size: 1.2,
      shield: false,
      glow: "#9b59b6"
    },
    intro: "Repent! Your sins shall burn in holy ember!",
    ai: { aggression: 0.85, parryChance: 0.38, feintChance: 0.20, comboLength: 6, special: "smite" },
    defendPatterns: [
      [[1.5, "sweep_combo"], [3.0, "feint"], [4.5, "triple"]],
      [[1.5, "feint"], [2.5, "sweep_combo"], [4.0, "double"], [5.0, "high"]],
      [[2.0, "triple"], [3.0, "sweep_combo"], [4.5, "feint"]],
      [[1.5, "high"], [2.5, "sweep_combo"], [4.0, "triple"], [5.0, "feint"]],
      [[2.0, "sweep_combo"], [3.5, "feint"], [4.5, "double"], [5.5, "high"]],
      [[1.5, "triple"], [2.5, "feint"], [3.5, "sweep_combo"]],
      [[2.0, "feint"], [3.0, "double"], [4.0, "sweep_combo"], [5.5, "triple"]],
      [[1.5, "sweep_combo"], [3.0, "triple"], [4.0, "feint"], [5.0, "high"]],
      [[2.0, "double"], [3.0, "sweep_combo"], [4.5, "triple"], [5.5, "feint"]]
    ],
    attackPatterns: [
      [[1.0, 0, "C"], [1.5, 1, "P"], [2.0, 2, "C"], [2.5, 0, "P"], [3.0, 1]],
      [[1.0, 2, "P"], [1.5, 0, "C"], [2.0, 1, "P"], [2.5, 2, "C"], [3.0, 0]],
      [[1.5, 1, "C"], [2.0, 2, "P"], [2.5, 0, "C"], [3.0, 1, "P"], [3.5, 2]],
      [[1.0, 0, "P"], [1.5, 1, "C"], [2.0, 2, "P"], [2.5, 0, "C"], [3.0, 1, "P"]],
      [[1.5, 2, "C"], [2.0, 0, "P"], [2.5, 1, "C"], [3.0, 2, "P"], [3.5, 0]],
      [[1.0, 1, "P"], [1.5, 2, "C"], [2.0, 0, "P"], [2.5, 1, "C"], [3.0, 2, "P"]],
      [[1.5, 0, "C"], [2.0, 1, "P"], [2.5, 2, "C"], [3.0, 0, "P"], [3.5, 1]],
      [[1.0, 2, "P"], [1.5, 1, "C"], [2.0, 0, "P"], [2.5, 2, "C"], [3.0, 1]],
      [[1.5, 1, "C"], [2.0, 0, "P"], [2.5, 2, "C"], [3.0, 1, "P"], [3.5, 0, "C"]]
    ],
    phases: [
      { at: 0.5, bpmAdd: 4, newPatternPool: "wrath", line: "Burn in holy fire!" }
    ],
    reward: 520
  },
  {
    id: "the_king",
    name: "The King",
    title: "Sovereign of Ruin",
    hp: 215,
    arena: "castle",
    bpm: 112,
    look: {
      colors: ["#12121a", "#242436", "#40405c"],
      trim: "#ffd700",
      eye: "#ffffff",
      helm: "crown",
      cape: "cloakK",
      weapon: "longsword",
      size: 1.35,
      shield: true,
      glow: "#f1c40f"
    },
    intro: "Kneel before the crown, or bleed upon the throne.",
    ai: { aggression: 0.95, parryChance: 0.50, feintChance: 0.30, comboLength: 7, special: "monarch" },
    defendPatterns: [
      [[1.5, "unblockable"], [2.5, "feint"], [3.5, "grab"], [4.5, "triple"]],
      [[1.5, "sweep_combo"], [3.0, "ranged"], [4.0, "unblockable"], [5.0, "double"]],
      [[2.0, "grab"], [3.0, "triple"], [4.0, "feint"], [5.0, "sweep_combo"]],
      [[1.5, "high"], [2.5, "unblockable"], [3.5, "grab"], [4.5, "triple"], [5.5, "feint"]],
      [[2.0, "feint"], [3.0, "sweep_combo"], [4.5, "grab"], [5.5, "unblockable"]],
      [[1.5, "ranged"], [2.5, "triple"], [3.5, "unblockable"], [4.5, "grab"]],
      [[2.0, "sweep_combo"], [3.5, "feint"], [4.5, "triple"], [5.5, "double"]],
      [[1.5, "grab"], [2.5, "unblockable"], [3.5, "sweep_combo"], [5.0, "feint"]],
      [[2.0, "triple"], [3.0, "grab"], [4.0, "unblockable"], [5.0, "sweep_combo"]],
      [[1.5, "feint"], [2.5, "unblockable"], [3.5, "grab"], [4.5, "triple"], [5.5, "sweep_combo"]]
    ],
    attackPatterns: [
      [[1.0, 0, "P"], [1.5, 1, "C"], [2.0, 2, "A"], [2.5, 0, "S+"], [3.0, 1, "P"], [3.5, 2, "C"]],
      [[1.0, 2, "C"], [1.5, 0, "P"], [2.0, 1, "S-"], [2.5, 2, "A"], [3.0, 0, "P"], [3.5, 1, "C"]],
      [[1.5, 1, "P"], [2.0, 2, "A"], [2.5, 0, "C"], [3.0, 1, "S+"], [3.5, 2, "P"], [4.0, 0, "A"]],
      [[1.0, 0, "A"], [1.5, 2, "P"], [2.0, 1, "C"], [2.5, 0, "S-"], [3.0, 2, "P"], [3.5, 1, "A"]],
      [[1.5, 2, "P"], [2.0, 0, "S+"], [2.5, 1, "A"], [3.0, 2, "C"], [3.5, 0, "P"], [4.0, 1, "C"]],
      [[1.0, 1, "C"], [1.5, 2, "P"], [2.0, 0, "A"], [2.5, 1, "S-"], [3.0, 2, "C"], [3.5, 0, "P"]],
      [[1.5, 0, "S+"], [2.0, 1, "P"], [2.5, 2, "C"], [3.0, 0, "A"], [3.5, 1, "P"], [4.0, 2, "C"]],
      [[1.0, 2, "P"], [1.5, 0, "A"], [2.0, 1, "C"], [2.5, 2, "S+"], [3.0, 0, "P"], [3.5, 1, "A"]],
      [[1.5, 1, "A"], [2.0, 2, "C"], [2.5, 0, "P"], [3.0, 1, "S-"], [3.5, 2, "A"], [4.0, 0, "P"]],
      [[1.0, 0, "C"], [1.5, 1, "P"], [2.0, 2, "S+"], [2.5, 0, "A"], [3.0, 1, "C"], [3.5, 2, "P"], [4.0, 0, "A"]]
    ],
    phases: [
      { at: 0.65, bpmAdd: 3, newPatternPool: "enrage", line: "You dare strike royalty?!" },
      { at: 0.30, bpmAdd: 3, newPatternPool: "desperation", line: "I AM THE KING! I SHALL NOT FALL!" }
    ],
    reward: 750
  }
];
