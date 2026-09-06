import 'package:flutter/material.dart';

class FunctionDoc {
  final String token;
  final String label;
  final String signature;
  final String returnType;
  final String description;
  final String example;
  final Color textColor;

  const FunctionDoc({
    required this.token,
    required this.label,
    required this.signature,
    required this.returnType,
    required this.description,
    required this.example,
    required this.textColor,
  });

  static const List<FunctionDoc> allTokens = [
    FunctionDoc(
      token: 'countOn()',
      label: 'countOn()',
      signature: 'countOn() -> int',
      returnType: 'int (0..8)',
      description: 'Counts total active (1) neighbors among C1 through C8. Excludes target cell C0.',
      example: 'countOn() == 3',
      textColor: Color(0xFF4EDE83), // Emerald
    ),
    FunctionDoc(
      token: 'countOff()',
      label: 'countOff()',
      signature: 'countOff() -> int',
      returnType: 'int (0..8)',
      description: 'Counts total inactive (0) neighbors among C1 through C8. Equivalent to 8 - countOn().',
      example: 'countOff() == 5',
      textColor: Color(0xFFC2C6D6), // Slate/light
    ),
    FunctionDoc(
      token: 'rnd()',
      label: 'rnd()',
      signature: 'rnd() -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Uniform stochastic random boolean with 50% probability (P(1) = 0.5). Also accepts random().',
      example: '[C0 == 1] AND rnd()',
      textColor: Color(0xFFFFB95F), // Amber
    ),
    FunctionDoc(
      token: ' AND ',
      label: 'AND',
      signature: 'expr AND expr -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Logical conjunction. Evaluates to 1 if both left and right operands are true (>0).',
      example: 'C0 == 1 AND countOn() == 2',
      textColor: Color(0xFFADC6FF), // Electric blue
    ),
    FunctionDoc(
      token: ' OR ',
      label: 'OR',
      signature: 'expr OR expr -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Logical disjunction. Evaluates to 1 if either left or right operand is true (>0).',
      example: '[countOn() == 3] OR [C0 == 1]',
      textColor: Color(0xFFADC6FF), // Electric blue
    ),
    FunctionDoc(
      token: ' XOR ',
      label: 'XOR',
      signature: 'expr XOR expr -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Logical exclusive disjunction. Evaluates to 1 if exactly one operand is true (>0).',
      example: 'C1 XOR [C2 OR C3]',
      textColor: Color(0xFFADC6FF), // Electric blue
    ),
    FunctionDoc(
      token: 'NOT ',
      label: 'NOT',
      signature: 'NOT expr -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Logical negation. Inverts truth value: returns 1 if operand is 0; returns 0 if >0.',
      example: 'NOT(C1) or NOT C1',
      textColor: Color(0xFFFFB4AB), // Coral red
    ),
    FunctionDoc(
      token: ' <= ',
      label: '<=',
      signature: 'a <= b -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Relational operator: Less than or equal to.',
      example: 'countOn() <= 4',
      textColor: Color(0xFFDAE2FD), // On-surface
    ),
    FunctionDoc(
      token: ' >= ',
      label: '>=',
      signature: 'a >= b -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Relational operator: Greater than or equal to.',
      example: 'countOn() >= 2',
      textColor: Color(0xFFDAE2FD), // On-surface
    ),
    FunctionDoc(
      token: ' == ',
      label: '==',
      signature: 'a == b -> int (0 or 1)',
      returnType: '0 or 1',
      description: 'Relational operator: Strict numerical equality comparison.',
      example: 'countOn() == 3',
      textColor: Color(0xFFDAE2FD), // On-surface
    ),
    FunctionDoc(
      token: 'C0',
      label: 'Cn',
      signature: 'Cn (where n is 0..8) -> 0 or 1',
      returnType: '0 or 1',
      description: 'Cell reference. C0 represents center cell under evaluation. C1 through C8 represent Moore neighbors.',
      example: 'C0 == 1 AND C2 == 1',
      textColor: Color(0xFFADC6FF), // Electric blue
    ),
    FunctionDoc(
      token: '[ ]',
      label: '[...]',
      signature: '[ expression ]',
      returnType: 'sub-expression',
      description: 'Sub-expression grouping brackets. Isolates condition blocks and defines explicit precedence.',
      example: '[countOn() >= 2]',
      textColor: Color(0xFFDAE2FD), // On-surface
    ),
  ];
}
