// =====================================================
// FLOW GAME - 9x9 VERIFIED LEVELS (SAFE & SOLVABLE)
// RULES: no diagonal, no crossing, full connectivity
// =====================================================

// ----------------- LEVELS -----------------
final level1 = [
  ["red", null, "green", null, "yellow"],
  [null, null, "blue", null, "orange"],
  [null, null, null, null, null],
  [null, "green", null, "yellow", null],
  [null, "red", "blue", "orange", null],
];

final level2 = [
  ["yellow", null, null, null, null],
  [null, null, null, null, null],
  [null, null, "green", null, null],
  ["blue", "green", "red", null, "yellow"],
  ["red", null, null, null, "blue"],
];


final level3 = [
  [null, "yellow", "blue", "green", null],
  [null, null, null, "red", null],
  [null, null, "red", null, null],
  ["yellow", null, null, "orange", null],
  ["blue", null, "orange", "green", null],
];

final level4 = [
  ["green", "yellow", "cyan", null, "red", "blue"],
  [null, null, null, null, "orange", null],
  [null, null, "cyan", null, null, null],
  [null, null, "red", null, null, null],
  ["green", null, "orange", null, null, null],
  ["yellow", null, "blue", null, null, null],
];

final level5 = [
  [null, null, null, null, null, "yellow"],
  [null, null, null, "red", "blue", "green"],
  [null, null, "blue", null, null, null],
  [null, null, "green", null, null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, "yellow", "red"],
];


final level6 = [
  ["green", null, "yellow", null, null, null],
  ["red", null, null, "blue", null, null],
  [null, "red", "green", "orange", null, null],
  [null, null, null, null, null, null],
  [null, null, null, null, null, null],
  ["orange", "blue", "yellow", null, null, null],
];


final level7 = [
  [null, null, null, "red", "cyan", "orange"],
  [null, "yellow", null, null, null, null],
  ["red", null, "cyan", null, "green", null],
  ["yellow", null, "green", null, null, null],
  ["orange", null, null, null, null, "blue"],
  ["blue", null, null, null, null, null],
];


final level8 = [
  [null, null, null, "red", "cyan", "orange"],
  [null, "yellow", null, null, null, null],
  ["red", null, "cyan", null, "green", null],
  ["yellow", null, "green", null, null, null],
  ["orange", null, null, null, null, "blue"],
  ["blue", null, null, null, null, null],
];


final level9 = [
  [null, null, null, null, null, "red"],
  [null, null, null, null, null, null],
  ["red", null, null, null, null, null],
  [null, null, null, "blue", null, null],
  [null, "blue", "green", null, null, null],
  ["yellow", null, null, null, "green", "yellow"],
];


final level10 = [
  ["pink", null, "green", null, null, "green"],
  ["red", null, "yellow", null, null, null],
  [null, null, null, null, "pink", null],
  [null, "orange", "cyan", null, "blue", "yellow"],
  [null, null, null, null, null, "blue"],
  [null, "red", "orange", null, null, "cyan"],
];


final level11 = [
  ["blue", null, "red", null, null, null],
  ["yellow", null, null, null, "green", null],
  [null, null, "orange", "blue", null, null],
  [null, null, "red", null, "green", null],
  [null, null, null, null, null, null],
  [null, "yellow", null, null, null, "orange"],
];
final level12 = [
  ["red", null, null, null, null, null, null, null, "blue"],
  [null, null, null, null, null, null, null, null, null],
  [null, "green", null, null, null, null, null, null, null],
  [null, "yellow", null, null, "yellow", null, null, null, null],
  [null, null, null, null, null, null, null, null, null],
  [null, "purple", null, null, null, null, "purple", null, null],
  [null, null, null, null, null, null, "green", null, null],
  [null, null, "orange", null, null, null, "orange", null, null],
  ["red", null, null, null, null, null, null, null, "blue"],
];
final level13 = [
  ["red", null, null, null, null, null, null, null, "blue"],
  [null, null, null, null, null, null, null, null, null],
  [null, null, null, null, null, null, null, null, null], // ← removed green block
  [null, "yellow", null, null, null, null, null, "yellow", null],
  [null, null, null, null, null, null, null, null, null],
  [null, "purple", null, null, null, null, null, "purple", null],
  [null, "green", null, null, null, null, null, "green", null], // moved green
  [null, null, "orange", null, null, null, "orange", null, null],
  ["red", null, null, null, null, null, null, null, "blue"],
];

final level14 = [
  ["blue", null, "red", null, null, null],
  ["yellow", null, null, null, "green", null],
  [null, null, "orange", "blue", null, null],
  [null, null, "red", null, "green", null],
  [null, null, null, null, null, null],
  [null, "yellow", null, null, null, "orange"],
];

final level15 = [
  ["red", null, null, null, "blue", null, null, null, null],
  ["green", null, null, null, null, null, "yellow", null, null],
  [null, "purple", null, null, null, null, null, null, null],
  [null, null, null, null, null, null, null, null, null],
  [null, null, null, null, null, null, null, null, null],
  ["orange", null, null, null, null, null, null, null, null],
  [null, null, null, null, null, null, null, null, null],
  ["cyan", null, null, null, "purple", "green", null, null, null],
  [null, null, "cyan", null, null, "orange", "red", "yellow", "blue"],
];





// ----------------- ALL LEVELS -----------------

final allLevels = [
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
  level8,
  level9,
];

// ----------------- REWARDS -----------------

final levelRewards = {
  1: {'xp': 100, 'rp': 20},
  2: {'xp': 150, 'rp': 30},
  3: {'xp': 200, 'rp': 40},
  4: {'xp': 300, 'rp': 60},
  5: {'xp': 400, 'rp': 80},
  6: {'xp': 500, 'rp': 100},
  7: {'xp': 650, 'rp': 130},
  8: {'xp': 800, 'rp': 160},
  9: {'xp': 1000, 'rp': 200},
  10: {'xp': 1200, 'rp': 240},
  11: {'xp': 1400, 'rp': 280},
  12: {'xp': 1700, 'rp': 340},
  13: {'xp': 2000, 'rp': 400},
  14: {'xp': 2400, 'rp': 480},
  15: {'xp': 2800, 'rp': 560},
};