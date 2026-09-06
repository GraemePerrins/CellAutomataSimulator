import 'dart:typed_data';
import '../../rule_editor/core/syntax/ast.dart';
import '../../rule_editor/core/syntax/evaluator.dart';
import '../../rule_editor/core/syntax/parser.dart';
import '../../rule_editor/models/neighborhood_state.dart';
import 'simulation_kernel.dart';

class AstEvaluatorKernel implements SimulationKernel {
  @override
  final String name;

  final String expression;
  final AstNode rootNode;
  final RuleEvaluator evaluator;

  AstEvaluatorKernel({
    required this.name,
    required this.expression,
    required this.rootNode,
  }) : evaluator = RuleEvaluator(rootNode);

  factory AstEvaluatorKernel.fromExpression(String name, String expression) {
    final result = RuleParser.parseString(expression);
    if (!result.isValid || result.root == null) {
      throw FormatException(result.errorMessage ?? 'Invalid rule expression');
    }
    return AstEvaluatorKernel(
      name: name,
      expression: expression,
      rootNode: result.root!,
    );
  }

  @override
  int step(Uint8List current, Uint8List next, int width, int height) {
    int aliveCount = 0;
    // Pre-allocate a single NeighborhoodState and reuse across all cell evaluations
    final context = NeighborhoodState();

    for (int y = 0; y < height; y++) {
      final int yUp = (y == 0 ? height - 1 : y - 1) * width;
      final int yMid = y * width;
      final int yDown = (y == height - 1 ? 0 : y + 1) * width;

      for (int x = 0; x < width; x++) {
        final int xLeft = (x == 0 ? width - 1 : x - 1);
        final int xRight = (x == width - 1 ? 0 : x + 1);

        // Map 3x3 Moore neighborhood:
        // C1 C2 C3
        // C8 C0 C4
        // C7 C6 C5
        context.setCell(0, current[yMid + x]);
        context.setCell(1, current[yUp + xLeft]);
        context.setCell(2, current[yUp + x]);
        context.setCell(3, current[yUp + xRight]);
        context.setCell(4, current[yMid + xRight]);
        context.setCell(5, current[yDown + xRight]);
        context.setCell(6, current[yDown + x]);
        context.setCell(7, current[yDown + xLeft]);
        context.setCell(8, current[yMid + xLeft]);

        final int nextState = evaluator.evaluate(context);
        next[yMid + x] = nextState;
        if (nextState == 1) {
          aliveCount++;
        }
      }
    }

    return aliveCount;
  }
}
