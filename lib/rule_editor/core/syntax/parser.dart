import 'ast.dart';
import 'lexer.dart';
import 'token.dart';

class ParseException implements Exception {
  final String message;
  final int position;

  const ParseException(this.message, this.position);

  @override
  String toString() => '$message at position $position';
}

class RuleParser {
  final List<Token> tokens;
  int _current = 0;

  RuleParser(this.tokens);

  static ParseResult parseString(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return const ParseResult.error("Expression is empty", 0);
    }

    try {
      final lexer = RuleLexer(source);
      final tokenList = lexer.tokenize();
      final parser = RuleParser(tokenList);
      final ast = parser.parseRule();
      return ParseResult.success(ast);
    } on SyntaxException catch (e) {
      return ParseResult.error(e.message, e.position);
    } on ParseException catch (e) {
      return ParseResult.error(e.message, e.position);
    } catch (e) {
      return ParseResult.error(e.toString(), 0);
    }
  }

  AstNode parseRule() {
    _current = 0;

    // Must start with 'cell' '='
    if (!_check(TokenType.keywordCell)) {
      final pos = _peek().position;
      throw ParseException("Expression must start with 'cell ='", pos);
    }
    _advance();

    if (!_check(TokenType.equal)) {
      final pos = _peek().position;
      throw ParseException("Expected '=' after 'cell'", pos);
    }
    _advance();

    if (_isAtEnd()) {
      throw ParseException("Expected expression after 'cell ='", _peek().position);
    }

    final expr = _expression();

    if (!_isAtEnd()) {
      final extra = _peek();
      throw ParseException("Unexpected token '${extra.lexeme}' after expression", extra.position);
    }

    return expr;
  }

  AstNode _expression() {
    return _orExpr();
  }

  AstNode _orExpr() {
    var expr = _xorExpr();

    while (_match([TokenType.opOr])) {
      final right = _xorExpr();
      expr = BinaryOpNode(BinaryOpType.or, expr, right);
    }

    return expr;
  }

  AstNode _xorExpr() {
    var expr = _andExpr();

    while (_match([TokenType.opXor])) {
      final right = _andExpr();
      expr = BinaryOpNode(BinaryOpType.xor, expr, right);
    }

    return expr;
  }

  AstNode _andExpr() {
    var expr = _relExpr();

    while (_match([TokenType.opAnd])) {
      final right = _relExpr();
      expr = BinaryOpNode(BinaryOpType.and, expr, right);
    }

    return expr;
  }

  AstNode _relExpr() {
    var expr = _unaryExpr();

    if (_match([
      TokenType.compEqual,
      TokenType.compNotEqual,
      TokenType.compLess,
      TokenType.compLessEqual,
      TokenType.compGreater,
      TokenType.compGreaterEqual,
    ])) {
      final opToken = _previous();
      final right = _unaryExpr();

      BinaryOpType op;
      switch (opToken.type) {
        case TokenType.compEqual:
          op = BinaryOpType.equal;
          break;
        case TokenType.compNotEqual:
          op = BinaryOpType.notEqual;
          break;
        case TokenType.compLess:
          op = BinaryOpType.less;
          break;
        case TokenType.compLessEqual:
          op = BinaryOpType.lessEqual;
          break;
        case TokenType.compGreater:
          op = BinaryOpType.greater;
          break;
        case TokenType.compGreaterEqual:
          op = BinaryOpType.greaterEqual;
          break;
        default:
          throw ParseException("Unknown comparison operator", opToken.position);
      }

      expr = BinaryOpNode(op, expr, right);
    }

    return expr;
  }

  AstNode _unaryExpr() {
    if (_match([TokenType.opNot])) {
      // Check if functional NOT(...) or prefix NOT expr
      if (_check(TokenType.lParen)) {
        _advance();
        final operand = _expression();
        _consume(TokenType.rParen, "Expected ')' after 'NOT('");
        return UnaryOpNode(UnaryOpType.not, operand);
      }
      final operand = _unaryExpr();
      return UnaryOpNode(UnaryOpType.not, operand);
    }

    return _primary();
  }

  AstNode _primary() {
    if (_match([TokenType.number])) {
      return NumberNode(_previous().numberValue ?? 0);
    }

    if (_match([TokenType.cellRef])) {
      final cellIdx = _previous().cellIndex ?? 0;
      // Optional function call syntax C0()
      if (_check(TokenType.lParen)) {
        _advance();
        _consume(TokenType.rParen, "Expected ')' after C$cellIdx(");
      }
      return CellRefNode(cellIdx);
    }

    if (_match([TokenType.fnCountOn])) {
      _consume(TokenType.lParen, "Expected '(' after 'countOn'");
      _consume(TokenType.rParen, "Expected ')' after 'countOn('");
      return const CountOnNode();
    }

    if (_match([TokenType.fnCountOff])) {
      _consume(TokenType.lParen, "Expected '(' after 'countOff'");
      _consume(TokenType.rParen, "Expected ')' after 'countOff('");
      return const CountOffNode();
    }

    if (_match([TokenType.fnRandom])) {
      _consume(TokenType.lParen, "Expected '(' after '${_previous().lexeme}'");
      _consume(TokenType.rParen, "Expected ')' after '${_previous().lexeme}('");
      return const RandomNode();
    }

    // Functional logic: AND(...), OR(...), XOR(...)
    if (_match([TokenType.opAnd, TokenType.opOr, TokenType.opXor])) {
      final opToken = _previous();
      _consume(TokenType.lParen, "Expected '(' after '${opToken.lexeme}'");
      final args = <AstNode>[];
      if (!_check(TokenType.rParen)) {
        do {
          args.add(_expression());
        } while (_match([TokenType.comma]));
      }
      _consume(TokenType.rParen, "Expected ')' after arguments list");

      LogicFnType fnType;
      switch (opToken.type) {
        case TokenType.opAnd:
          fnType = LogicFnType.and;
          break;
        case TokenType.opOr:
          fnType = LogicFnType.or;
          break;
        case TokenType.opXor:
          fnType = LogicFnType.xor;
          break;
        default:
          fnType = LogicFnType.and;
      }
      return LogicFunctionNode(fnType, args);
    }

    // Bracket subexpression [...]
    if (_match([TokenType.lBracket])) {
      final startPos = _previous().position;
      final expr = _expression();
      if (!_match([TokenType.rBracket])) {
        throw ParseException("Missing closing bracket ']' corresponding to '[' at col $startPos", _peek().position);
      }
      return expr;
    }

    // Parenthesized subexpression (...)
    if (_match([TokenType.lParen])) {
      final startPos = _previous().position;
      final expr = _expression();
      if (!_match([TokenType.rParen])) {
        throw ParseException("Missing closing parenthesis ')' corresponding to '(' at col $startPos", _peek().position);
      }
      return expr;
    }

    final tok = _peek();
    if (tok.type == TokenType.eof) {
      throw ParseException("Unexpected end of expression", tok.position);
    }
    throw ParseException("Unexpected token '${tok.lexeme}'", tok.position);
  }

  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return type == TokenType.eof;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _peek() => tokens[_current];

  Token _previous() => tokens[_current - 1];

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw ParseException(message, _peek().position);
  }
}

class ParseResult {
  final bool isValid;
  final AstNode? root;
  final String? errorMessage;
  final int? errorOffset;

  const ParseResult.success(this.root)
      : isValid = true,
        errorMessage = null,
        errorOffset = null;

  const ParseResult.error(this.errorMessage, this.errorOffset)
      : isValid = false,
        root = null;
}
