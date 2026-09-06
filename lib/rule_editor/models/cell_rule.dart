class CellRule {
  final String name;
  final String expression;

  const CellRule({
    required this.name,
    required this.expression,
  });

  CellRule copyWith({
    String? name,
    String? expression,
  }) {
    return CellRule(
      name: name ?? this.name,
      expression: expression ?? this.expression,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'expression': expression,
      };

  factory CellRule.fromJson(Map<String, dynamic> json) {
    return CellRule(
      name: json['name'] as String? ?? 'Untitled Rule',
      expression: json['expression'] as String? ?? 'cell = ',
    );
  }

  @override
  String toString() => 'CellRule(name: "$name", expression: "$expression")';
}
