import 'package:flutter_test/flutter_test.dart';
import 'package:cell_automata/rule_editor/core/syntax/evaluator.dart';
import 'package:cell_automata/rule_editor/core/syntax/lexer.dart';
import 'package:cell_automata/rule_editor/core/syntax/parser.dart';
import 'package:cell_automata/rule_editor/core/syntax/token.dart';
import 'package:cell_automata/rule_editor/models/neighborhood_state.dart';

void main() {
  group('RuleLexer Tests', () {
    test('Tokenizes basic rule statement', () {
      const src = 'cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]';
      final lexer = RuleLexer(src);
      final tokens = lexer.tokenize();

      expect(tokens.first.type, TokenType.keywordCell);
      expect(tokens[1].type, TokenType.equal);
      expect(tokens.any((t) => t.type == TokenType.fnCountOn), isTrue);
      expect(tokens.any((t) => t.type == TokenType.cellRef && t.cellIndex == 0), isTrue);
      expect(tokens.last.type, TokenType.eof);
    });

    test('Tokenizes all cell identifiers C0 through C8', () {
      for (int i = 0; i <= 8; i++) {
        final lexer = RuleLexer('C$i');
        final tokens = lexer.tokenize();
        expect(tokens.first.type, TokenType.cellRef);
        expect(tokens.first.cellIndex, i);
      }
    });

    test('Case-insensitivity on keywords', () {
      final lexer = RuleLexer('CELL = NOT c1 AND CountOn() Or Rnd() xor countoff()');
      final tokens = lexer.tokenize();
      expect(tokens[0].type, TokenType.keywordCell);
      expect(tokens[1].type, TokenType.equal);
      expect(tokens[2].type, TokenType.opNot);
      expect(tokens[3].type, TokenType.cellRef);
      expect(tokens[4].type, TokenType.opAnd);
      expect(tokens[5].type, TokenType.fnCountOn);
      expect(tokens[8].type, TokenType.opOr);
      expect(tokens[9].type, TokenType.fnRandom);
      expect(tokens[12].type, TokenType.opXor);
      expect(tokens[13].type, TokenType.fnCountOff);
    });

    test('Throws SyntaxException on unknown characters', () {
      final lexer = RuleLexer('cell = @#');
      expect(() => lexer.tokenize(), throwsA(isA<SyntaxException>()));
    });
  });

  group('RuleParser Tests', () {
    test('Rejects expressions without "cell ="', () {
      final res1 = RuleParser.parseString('countOn() == 3');
      expect(res1.isValid, isFalse);
      expect(res1.errorMessage, contains("must start with 'cell ='"));

      final res2 = RuleParser.parseString('cell countOn() == 3');
      expect(res2.isValid, isFalse);
      expect(res2.errorMessage, contains("Expected '=' after 'cell'"));
    });

    test('Parses Conway Life rule successfully', () {
      const src = 'cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]';
      final res = RuleParser.parseString(src);
      expect(res.isValid, isTrue);
      expect(res.root, isNotNull);
    });

    test('Parses prefix logic functions: OR(a, AND(b, c))', () {
      const src = 'cell = OR(countOn() == 3, AND(C0 == 1, countOn() == 2))';
      final res = RuleParser.parseString(src);
      expect(res.isValid, isTrue);
      expect(res.root, isNotNull);
    });

    test('Detects unmatched brackets', () {
      const src = 'cell = [countOn() == 3';
      final res = RuleParser.parseString(src);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains("Missing closing bracket ']'"));
    });

    test('Detects unexpected extra tokens at end', () {
      const src = 'cell = [countOn() == 3] countOn()';
      final res = RuleParser.parseString(src);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains("Unexpected token"));
    });

    test('Detects unknown identifiers', () {
      const src = 'cell = [countOn() == 3] foo';
      final res = RuleParser.parseString(src);
      expect(res.isValid, isFalse);
      expect(res.errorMessage, contains("Unknown identifier 'foo'"));
    });
  });

  group('RuleEvaluator Simulation Tests', () {
    test("Conway's Life birth and survival rules", () {
      const src = 'cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]';
      final parseRes = RuleParser.parseString(src);
      expect(parseRes.isValid, isTrue);
      final evaluator = RuleEvaluator(parseRes.root!);

      // Case 1: Dead cell with 3 live neighbors -> Birth (1)
      final state1 = NeighborhoodState(
        initialCells: [
          0, // C0 (dead)
          1, // C1
          1, // C2
          1, // C3
          0, 0, 0, 0, 0,
        ],
      );
      expect(evaluator.evaluate(state1), 1);

      // Case 2: Dead cell with 2 live neighbors -> Remains dead (0)
      final state2 = NeighborhoodState(
        initialCells: [
          0, // C0 (dead)
          1, 1, 0, 0, 0, 0, 0, 0,
        ],
      );
      expect(evaluator.evaluate(state2), 0);

      // Case 3: Live cell with 2 live neighbors -> Survives (1)
      final state3 = NeighborhoodState(
        initialCells: [
          1, // C0 (alive)
          1, 1, 0, 0, 0, 0, 0, 0,
        ],
      );
      expect(evaluator.evaluate(state3), 1);

      // Case 4: Live cell with 1 live neighbor -> Underpopulation death (0)
      final state4 = NeighborhoodState(
        initialCells: [
          1, // C0 (alive)
          1, 0, 0, 0, 0, 0, 0, 0,
        ],
      );
      expect(evaluator.evaluate(state4), 0);

      // Case 5: Live cell with 4 live neighbors -> Overpopulation death (0)
      final state5 = NeighborhoodState(
        initialCells: [
          1, // C0 (alive)
          1, 1, 1, 1, 0, 0, 0, 0,
        ],
      );
      expect(evaluator.evaluate(state5), 0);
    });

    test('Majority Vote evaluation: cell = countOn() >= 5', () {
      final parseRes = RuleParser.parseString('cell = countOn() >= 5');
      final evaluator = RuleEvaluator(parseRes.root!);

      final fourOn = NeighborhoodState(initialCells: [0, 1, 1, 1, 1, 0, 0, 0, 0]);
      expect(evaluator.evaluate(fourOn), 0);

      final fiveOn = NeighborhoodState(initialCells: [0, 1, 1, 1, 1, 1, 0, 0, 0]);
      expect(evaluator.evaluate(fiveOn), 1);
    });

    test('Wolfram Rule 30: cell = C1 XOR [C2 OR C3]', () {
      final parseRes = RuleParser.parseString('cell = C1 XOR [C2 OR C3]');
      final evaluator = RuleEvaluator(parseRes.root!);

      // If C1=1, C2=0, C3=0 -> 1 XOR 0 = 1
      final s1 = NeighborhoodState(initialCells: [0, 1, 0, 0, 0, 0, 0, 0, 0]);
      expect(evaluator.evaluate(s1), 1);

      // If C1=1, C2=1, C3=0 -> 1 XOR 1 = 0
      final s2 = NeighborhoodState(initialCells: [0, 1, 1, 0, 0, 0, 0, 0, 0]);
      expect(evaluator.evaluate(s2), 0);

      // If C1=0, C2=0, C3=1 -> 0 XOR 1 = 1
      final s3 = NeighborhoodState(initialCells: [0, 0, 0, 1, 0, 0, 0, 0, 0]);
      expect(evaluator.evaluate(s3), 1);
    });
  });
}
