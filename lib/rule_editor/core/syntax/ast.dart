import 'dart:math';

abstract class EvaluationContext {
  int getCell(int index);
  int countOn();
  int countOff();
  Random get rng;
}

abstract class AstNode {
  const AstNode();
  int evaluate(EvaluationContext context);
}

class NumberNode extends AstNode {
  final int value;
  const NumberNode(this.value);

  @override
  int evaluate(EvaluationContext context) => value;

  @override
  String toString() => '$value';
}

class CellRefNode extends AstNode {
  final int index;
  const CellRefNode(this.index);

  @override
  int evaluate(EvaluationContext context) {
    final val = context.getCell(index);
    return val > 0 ? 1 : 0;
  }

  @override
  String toString() => 'C$index';
}

class CountOnNode extends AstNode {
  const CountOnNode();

  @override
  int evaluate(EvaluationContext context) => context.countOn();

  @override
  String toString() => 'countOn()';
}

class CountOffNode extends AstNode {
  const CountOffNode();

  @override
  int evaluate(EvaluationContext context) => context.countOff();

  @override
  String toString() => 'countOff()';
}

class RandomNode extends AstNode {
  const RandomNode();

  @override
  int evaluate(EvaluationContext context) => context.rng.nextBool() ? 1 : 0;

  @override
  String toString() => 'random()';
}

enum UnaryOpType { not }

class UnaryOpNode extends AstNode {
  final UnaryOpType op;
  final AstNode operand;

  const UnaryOpNode(this.op, this.operand);

  @override
  int evaluate(EvaluationContext context) {
    final val = operand.evaluate(context);
    switch (op) {
      case UnaryOpType.not:
        return val == 0 ? 1 : 0;
    }
  }

  @override
  String toString() => 'NOT $operand';
}

enum BinaryOpType {
  and,
  or,
  xor,
  equal,
  notEqual,
  less,
  lessEqual,
  greater,
  greaterEqual,
}

class BinaryOpNode extends AstNode {
  final BinaryOpType op;
  final AstNode left;
  final AstNode right;

  const BinaryOpNode(this.op, this.left, this.right);

  @override
  int evaluate(EvaluationContext context) {
    final l = left.evaluate(context);
    final r = right.evaluate(context);

    switch (op) {
      case BinaryOpType.and:
        return (l > 0 && r > 0) ? 1 : 0;
      case BinaryOpType.or:
        return (l > 0 || r > 0) ? 1 : 0;
      case BinaryOpType.xor:
        return ((l > 0) ^ (r > 0)) ? 1 : 0;
      case BinaryOpType.equal:
        return l == r ? 1 : 0;
      case BinaryOpType.notEqual:
        return l != r ? 1 : 0;
      case BinaryOpType.less:
        return l < r ? 1 : 0;
      case BinaryOpType.lessEqual:
        return l <= r ? 1 : 0;
      case BinaryOpType.greater:
        return l > r ? 1 : 0;
      case BinaryOpType.greaterEqual:
        return l >= r ? 1 : 0;
    }
  }

  @override
  String toString() => '($left ${op.name.toUpperCase()} $right)';
}

enum LogicFnType { and, or, xor, not }

class LogicFunctionNode extends AstNode {
  final LogicFnType fn;
  final List<AstNode> arguments;

  const LogicFunctionNode(this.fn, this.arguments);

  @override
  int evaluate(EvaluationContext context) {
    if (fn == LogicFnType.not) {
      if (arguments.isEmpty) return 1;
      return arguments.first.evaluate(context) == 0 ? 1 : 0;
    }

    if (fn == LogicFnType.and) {
      if (arguments.isEmpty) return 1;
      for (final arg in arguments) {
        if (arg.evaluate(context) == 0) return 0;
      }
      return 1;
    }

    if (fn == LogicFnType.or) {
      for (final arg in arguments) {
        if (arg.evaluate(context) > 0) return 1;
      }
      return 0;
    }

    if (fn == LogicFnType.xor) {
      int countTrue = 0;
      for (final arg in arguments) {
        if (arg.evaluate(context) > 0) countTrue++;
      }
      return (countTrue % 2 == 1) ? 1 : 0;
    }

    return 0;
  }

  @override
  String toString() => '${fn.name.toUpperCase()}(${arguments.join(", ")})';
}
