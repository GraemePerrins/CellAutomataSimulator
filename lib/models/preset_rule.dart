class PresetRule {
  final String id;
  final String name;
  final String description;
  final String expression;
  final List<int> survive;
  final List<int> birth;
  final int states;
  final bool isTotalistic;

  const PresetRule({
    required this.id,
    required this.name,
    required this.description,
    required this.expression,
    required this.survive,
    required this.birth,
    this.states = 2,
    this.isTotalistic = true,
  });

  static const List<PresetRule> presets = [
    PresetRule(
      id: 'conway',
      name: "Conway's Life",
      description: "Standard Game of Life by John Conway",
      expression: "cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]",
      survive: [2, 3],
      birth: [3],
    ),
    PresetRule(
      id: 'highlife',
      name: "HighLife",
      description: "Similar to Conway's Life with Replicator pattern at B6",
      expression:
          "cell = [countOn() == 3] OR [countOn() == 6] OR [C0 == 1 AND countOn() == 2]",
      survive: [2, 3],
      birth: [3, 6],
    ),
    PresetRule(
      id: 'seeds',
      name: "Seeds",
      description: "All alive cells die; new cells born with 2 neighbors",
      expression: "cell = [C0 == 0] AND [countOn() == 2]",
      survive: [],
      birth: [2],
    ),
    PresetRule(
      id: 'day_and_night',
      name: "Day & Night",
      description: "Symmetric rule where patterns inverted on light background behave identically",
      expression:
          "cell = [C0 == 0 AND (countOn() == 3 OR countOn() >= 6)] OR [C0 == 1 AND (countOn() >= 3 AND countOn() != 5)]",
      survive: [3, 4, 6, 7, 8],
      birth: [3, 6, 7, 8],
    ),
    PresetRule(
      id: 'brians_brain',
      name: "Brian's Brain",
      description: "Oscillator-rich rule with moving spaceship oscillators",
      expression: "cell = [C0 == 0] AND [countOn() == 2]",
      survive: [],
      birth: [2],
      states: 3,
    ),
  ];
}
