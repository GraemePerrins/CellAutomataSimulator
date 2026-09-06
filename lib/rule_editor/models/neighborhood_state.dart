import 'dart:math';
import '../core/syntax/ast.dart';

class NeighborhoodState implements EvaluationContext {
  final List<int> _cells;
  @override
  final Random rng;

  NeighborhoodState({List<int>? initialCells, Random? random})
      : _cells = initialCells != null
            ? List<int>.from(initialCells)
            : List<int>.filled(9, 0),
        rng = random ?? Random() {
    assert(_cells.length == 9, 'NeighborhoodState must have exactly 9 cells');
  }

  @override
  int getCell(int index) {
    if (index < 0 || index >= 9) return 0;
    return _cells[index] > 0 ? 1 : 0;
  }

  void setCell(int index, int value) {
    if (index >= 0 && index < 9) {
      _cells[index] = value > 0 ? 1 : 0;
    }
  }

  void toggleCell(int index) {
    if (index >= 0 && index < 9) {
      _cells[index] = _cells[index] == 1 ? 0 : 1;
    }
  }

  @override
  int countOn() {
    int onCount = 0;
    for (int i = 1; i <= 8; i++) {
      if (_cells[i] == 1) onCount++;
    }
    return onCount;
  }

  @override
  int countOff() {
    return 8 - countOn();
  }

  void clear() {
    for (int i = 0; i < 9; i++) {
      _cells[i] = 0;
    }
  }

  void randomize() {
    for (int i = 0; i < 9; i++) {
      _cells[i] = rng.nextBool() ? 1 : 0;
    }
  }

  NeighborhoodState clone() {
    return NeighborhoodState(
      initialCells: List<int>.from(_cells),
      random: rng,
    );
  }

  List<int> toList() => List<int>.unmodifiable(_cells);
}
