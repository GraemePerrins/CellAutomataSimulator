import 'dart:math';
import 'ast.dart';

class RuleEvaluator {
  final AstNode root;
  final Random rng;

  RuleEvaluator(this.root, [Random? rng]) : rng = rng ?? Random();

  int evaluate(EvaluationContext context) {
    final raw = root.evaluate(context);
    return raw > 0 ? 1 : 0;
  }
}
