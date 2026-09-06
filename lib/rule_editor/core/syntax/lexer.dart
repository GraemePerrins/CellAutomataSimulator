import 'token.dart';

class SyntaxException implements Exception {
  final String message;
  final int position;

  const SyntaxException(this.message, this.position);

  @override
  String toString() => '$message at column $position';
}

class RuleLexer {
  final String source;
  int _cursor = 0;

  RuleLexer(this.source);

  List<Token> tokenize() {
    final tokens = <Token>[];
    _cursor = 0;

    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;

      final startPos = _cursor;
      final char = _peek();

      // Two-character comparisons
      if (char == '=' && _peekNext() == '=') {
        _advance();
        _advance();
        tokens.add(Token(type: TokenType.compEqual, lexeme: '==', position: startPos));
        continue;
      }
      if (char == '!' && _peekNext() == '=') {
        _advance();
        _advance();
        tokens.add(Token(type: TokenType.compNotEqual, lexeme: '!=', position: startPos));
        continue;
      }
      if (char == '<' && _peekNext() == '=') {
        _advance();
        _advance();
        tokens.add(Token(type: TokenType.compLessEqual, lexeme: '<=', position: startPos));
        continue;
      }
      if (char == '>' && _peekNext() == '=') {
        _advance();
        _advance();
        tokens.add(Token(type: TokenType.compGreaterEqual, lexeme: '>=', position: startPos));
        continue;
      }

      // Single-character tokens
      if (char == '=') {
        _advance();
        tokens.add(Token(type: TokenType.equal, lexeme: '=', position: startPos));
        continue;
      }
      if (char == '<') {
        _advance();
        tokens.add(Token(type: TokenType.compLess, lexeme: '<', position: startPos));
        continue;
      }
      if (char == '>') {
        _advance();
        tokens.add(Token(type: TokenType.compGreater, lexeme: '>', position: startPos));
        continue;
      }
      if (char == '[') {
        _advance();
        tokens.add(Token(type: TokenType.lBracket, lexeme: '[', position: startPos));
        continue;
      }
      if (char == ']') {
        _advance();
        tokens.add(Token(type: TokenType.rBracket, lexeme: ']', position: startPos));
        continue;
      }
      if (char == '(') {
        _advance();
        tokens.add(Token(type: TokenType.lParen, lexeme: '(', position: startPos));
        continue;
      }
      if (char == ')') {
        _advance();
        tokens.add(Token(type: TokenType.rParen, lexeme: ')', position: startPos));
        continue;
      }
      if (char == ',') {
        _advance();
        tokens.add(Token(type: TokenType.comma, lexeme: ',', position: startPos));
        continue;
      }

      // Numbers
      if (_isDigit(char)) {
        final start = _cursor;
        while (!_isAtEnd() && _isDigit(_peek())) {
          _advance();
        }
        final numStr = source.substring(start, _cursor);
        final val = int.parse(numStr);
        tokens.add(Token(
          type: TokenType.number,
          lexeme: numStr,
          position: start,
          numberValue: val,
        ));
        continue;
      }

      // Identifiers / Keywords
      if (_isAlpha(char) || char == '_') {
        final start = _cursor;
        while (!_isAtEnd() && (_isAlphaNumeric(_peek()) || _peek() == '_')) {
          _advance();
        }
        final ident = source.substring(start, _cursor);
        final lower = ident.toLowerCase();

        // Check cell reference C0..C8
        if (lower.length == 2 && lower.startsWith('c') && _isDigit(lower[1])) {
          final cellIdx = int.parse(lower[1]);
          if (cellIdx >= 0 && cellIdx <= 8) {
            tokens.add(Token(
              type: TokenType.cellRef,
              lexeme: ident,
              position: start,
              cellIndex: cellIdx,
            ));
            continue;
          }
        }

        // Keywords & Built-ins
        if (lower == 'cell') {
          tokens.add(Token(type: TokenType.keywordCell, lexeme: ident, position: start));
        } else if (lower == 'counton') {
          tokens.add(Token(type: TokenType.fnCountOn, lexeme: ident, position: start));
        } else if (lower == 'countoff') {
          tokens.add(Token(type: TokenType.fnCountOff, lexeme: ident, position: start));
        } else if (lower == 'random' || lower == 'rnd') {
          tokens.add(Token(type: TokenType.fnRandom, lexeme: ident, position: start));
        } else if (lower == 'and') {
          tokens.add(Token(type: TokenType.opAnd, lexeme: ident, position: start));
        } else if (lower == 'or') {
          tokens.add(Token(type: TokenType.opOr, lexeme: ident, position: start));
        } else if (lower == 'xor') {
          tokens.add(Token(type: TokenType.opXor, lexeme: ident, position: start));
        } else if (lower == 'not') {
          tokens.add(Token(type: TokenType.opNot, lexeme: ident, position: start));
        } else {
          throw SyntaxException("Unknown identifier '$ident'", start);
        }
        continue;
      }

      throw SyntaxException("Unexpected character '$char'", _cursor);
    }

    tokens.add(Token(type: TokenType.eof, lexeme: '', position: _cursor));
    return tokens;
  }

  bool _isAtEnd() => _cursor >= source.length;

  String _peek() => source[_cursor];

  String _peekNext() {
    if (_cursor + 1 >= source.length) return '';
    return source[_cursor + 1];
  }

  void _advance() {
    _cursor++;
  }

  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final c = _peek();
      if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
        _advance();
      } else {
        break;
      }
    }
  }

  bool _isDigit(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  bool _isAlpha(String s) {
    if (s.isEmpty) return false;
    final code = s.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  bool _isAlphaNumeric(String s) => _isAlpha(s) || _isDigit(s);
}
