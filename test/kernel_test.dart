import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:cell_automata/simulation/kernels/ast_evaluator_kernel.dart';
import 'package:cell_automata/simulation/kernels/totalistic_kernel.dart';

void main() {
  group('TotalisticKernel Tests', () {
    test('Blinker oscillator in Conway Life', () {
      final kernel = TotalisticKernel.conway();
      const width = 5;
      const height = 5;

      // Create a horizontal 3-cell blinker at row 2: (1,2), (2,2), (3,2)
      final current = Uint8List(width * height);
      final next = Uint8List(width * height);
      current[2 * width + 1] = 1;
      current[2 * width + 2] = 1;
      current[2 * width + 3] = 1;

      final count1 = kernel.step(current, next, width, height);
      expect(count1, equals(3));

      // After 1 step, should be vertical blinker at col 2: (2,1), (2,2), (2,3)
      expect(next[1 * width + 2], equals(1));
      expect(next[2 * width + 2], equals(1));
      expect(next[3 * width + 2], equals(1));
      expect(next[2 * width + 1], equals(0));
      expect(next[2 * width + 3], equals(0));

      // After 2nd step, should oscillate back to horizontal
      final next2 = Uint8List(width * height);
      final count2 = kernel.step(next, next2, width, height);
      expect(count2, equals(3));
      expect(next2[2 * width + 1], equals(1));
      expect(next2[2 * width + 2], equals(1));
      expect(next2[2 * width + 3], equals(1));
    });

    test('2x2 Block still life remains static', () {
      final kernel = TotalisticKernel.conway();
      const width = 4;
      const height = 4;

      final current = Uint8List(width * height);
      final next = Uint8List(width * height);
      current[1 * width + 1] = 1;
      current[1 * width + 2] = 1;
      current[2 * width + 1] = 1;
      current[2 * width + 2] = 1;

      final count = kernel.step(current, next, width, height);
      expect(count, equals(4));
      expect(next[1 * width + 1], equals(1));
      expect(next[1 * width + 2], equals(1));
      expect(next[2 * width + 1], equals(1));
      expect(next[2 * width + 2], equals(1));
    });
  });

  group('AstEvaluatorKernel Tests', () {
    test('Evaluates Conway Life AST expression identically to TotalisticKernel', () {
      final astKernel = AstEvaluatorKernel.fromExpression(
        "Conway AST",
        "cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]",
      );
      const width = 5;
      const height = 5;

      final current = Uint8List(width * height);
      final next = Uint8List(width * height);
      current[2 * width + 1] = 1;
      current[2 * width + 2] = 1;
      current[2 * width + 3] = 1;

      final count = astKernel.step(current, next, width, height);
      expect(count, equals(3));
      expect(next[1 * width + 2], equals(1));
      expect(next[2 * width + 2], equals(1));
      expect(next[3 * width + 2], equals(1));
    });

    test('Evaluates Seeds rule expression', () {
      final seedsKernel = AstEvaluatorKernel.fromExpression(
        "Seeds",
        "cell = [C0 == 0] AND [countOn() == 2]",
      );
      const width = 5;
      const height = 5;

      final current = Uint8List(width * height);
      final next = Uint8List(width * height);
      // Two diagonal alive cells
      current[1 * width + 1] = 1;
      current[1 * width + 3] = 1;

      final count = seedsKernel.step(current, next, width, height);
      // Original cells must die (C0 == 0 required for life)
      expect(next[1 * width + 1], equals(0));
      expect(next[1 * width + 3], equals(0));
      // Cell between them at (2,1) has 2 neighbors, so it is born
      expect(next[1 * width + 2], equals(1));
      expect(count >= 1, isTrue);
    });
  });
}
