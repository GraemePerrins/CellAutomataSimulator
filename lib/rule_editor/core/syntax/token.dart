/// Lexical Token Types and Token model for Cellular Automata Rule Expressions.
library;

enum TokenType {
  keywordCell, // 'cell'
  equal, // '='

  cellRef, // 'C0'..'C8'
  fnCountOn, // 'countOn'
  fnCountOff, // 'countOff'
  fnRandom, // 'random' or 'rnd'

  opAnd, // 'AND'
  opOr, // 'OR'
  opXor, // 'XOR'
  opNot, // 'NOT'

  compEqual, // '=='
  compNotEqual, // '!='
  compLess, // '<'
  compLessEqual, // '<='
  compGreater, // '>'
  compGreaterEqual, // '>='

  lBracket, // '['
  rBracket, // ']'
  lParen, // '('
  rParen, // ')'
  comma, // ','

  number, // [0-9]+
  eof, // end of input
}

class Token {
  final TokenType type;
  final String lexeme;
  final int position;
  final int? numberValue;
  final int? cellIndex;

  const Token({
    required this.type,
    required this.lexeme,
    required this.position,
    this.numberValue,
    this.cellIndex,
  });

  @override
  String toString() => 'Token($type, "$lexeme", pos: $position)';
}
