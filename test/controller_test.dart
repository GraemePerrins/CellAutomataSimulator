import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:cell_automata/rule_editor/models/neighborhood_state.dart';
import 'package:cell_automata/rule_editor/providers/rule_studio_controller.dart';
import 'package:cell_automata/rule_editor/services/rule_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RuleStudioController controller;
  late RuleStorageService storageService;

  setUp(() {
    // Resolve rules folder relative to test location
    final testDir = Directory.current.path;
    final rulesPath = Directory(p.join(testDir, 'assets', 'rules')).existsSync()
        ? p.join(testDir, 'assets', 'rules')
        : (Directory(p.join(testDir, 'rules')).existsSync()
            ? p.join(testDir, 'rules')
            : p.join(testDir, '..', 'RuleEditor', 'rules'));

    storageService = RuleStorageService(customRulesPath: rulesPath);
    controller = RuleStudioController(storage: storageService);
  });

  tearDown(() {
    controller.dispose();
  });

  group('RuleStudioController Tests', () {
    test('Initializes with default Conway Life rule and valid status', () {
      expect(controller.ruleName, "Conway's Life");
      expect(controller.expressionText, contains("cell = [countOn() == 3]"));
      expect(controller.validationResult.isValid, isTrue);
    });

    test('newRule() auto-prepopulates with "cell = " and cursor at offset 7', () {
      controller.newRule();

      expect(controller.ruleName, "Untitled Rule");
      expect(controller.expressionText, "cell = ");
      expect(controller.expressionController.selection.baseOffset, 7);
      expect(controller.expressionController.selection.extentOffset, 7);
    });

    test('toggleCell() flips cell state without auto-evaluating', () {
      final initialC1 = controller.neighborhoodState.getCell(1);
      controller.toggleCell(1);
      expect(controller.neighborhoodState.getCell(1), initialC1 == 1 ? 0 : 1);
      expect(controller.centerCellUpdated, isFalse);
    });

    test('applyRuleToMatrix() updates C0 and flags centerCellUpdated', () {
      // Set up a Conway birth scenario: C0=0, C1=1, C2=1, C3=1, rest 0
      controller.neighborhoodState = NeighborhoodState(
        initialCells: [0, 1, 1, 1, 0, 0, 0, 0, 0],
      );
      controller.expressionController.text =
          'cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]';

      expect(controller.neighborhoodState.getCell(0), 0);
      final applied = controller.applyRuleToMatrix();

      expect(applied, isTrue);
      // C0 should now be 1 (born)
      expect(controller.neighborhoodState.getCell(0), 1);
      expect(controller.centerCellUpdated, isTrue);
    });

    test('insertToken() places token at cursor position', () {
      controller.newRule(); // expression = "cell = ", offset = 7
      controller.insertToken('countOn() == 3');

      expect(controller.expressionText, 'cell = countOn() == 3');
      expect(controller.validationResult.isValid, isTrue);
    });

    test('Loads prebuilt rules from disk successfully', () async {
      final files = storageService.listRuleFiles();
      expect(files.isNotEmpty, isTrue);

      for (final file in files) {
        final success = await controller.loadRule(file.path);
        expect(success, isTrue, reason: 'Failed to load ${file.path}');
        expect(controller.validationResult.isValid, isTrue,
            reason: 'Rule ${controller.ruleName} parsed as invalid: ${controller.validationResult.errorMessage}');
      }
    });
  });
}
