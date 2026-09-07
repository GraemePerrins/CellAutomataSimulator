import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../core/syntax/evaluator.dart';
import '../core/syntax/parser.dart';
import '../models/cell_rule.dart';
import '../models/neighborhood_state.dart';
import '../models/validation_result.dart';
import '../services/rule_storage_service.dart';

class RuleStudioController extends ChangeNotifier {
  final RuleStorageService storageService;

  late final TextEditingController nameController;
  late final TextEditingController expressionController;

  NeighborhoodState neighborhoodState;
  ValidationResult validationResult = const ValidationResult.invalid("Uninitialized");

  List<CellRule> availableRules = [];
  bool centerCellUpdated = false;
  int? lastEvaluatedCenterState;
  String? currentFilePath;
  String? statusMessage;

  RuleStudioController({
    RuleStorageService? storage,
    String? initialName,
    String? initialExpression,
    NeighborhoodState? initialNeighborhood,
  })  : storageService = storage ?? RuleStorageService(),
        neighborhoodState = initialNeighborhood ??
            NeighborhoodState(
              initialCells: [
                1, // C0 (Center)
                0, // C1 (NW)
                1, // C2 (N)
                0, // C3 (NE)
                0, // C4 (W)
                0, // C5 (E)
                0, // C6 (SW)
                1, // C7 (S)
                0, // C8 (SE)
              ],
            ) {
    final defaultName = initialName ?? "Conway's Life";
    final defaultExpr = initialExpression ??
        "cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]";

    nameController = TextEditingController(text: defaultName);
    expressionController = TextEditingController(text: defaultExpr);

    nameController.addListener(_onNameChanged);
    expressionController.addListener(_onExpressionChanged);

    // Initial validation and rules loading
    _validateCurrentExpression();
    refreshAvailableRules();
  }

  /// Reloads all valid JSON rules discovered in the rules directory.
  void refreshAvailableRules() {
    availableRules = storageService.loadValidRules();
    notifyListeners();
  }

  /// Switches the editor to a selected rule.
  void selectRule(CellRule rule) {
    nameController.text = rule.name;
    expressionController.text = rule.expression;
    currentFilePath = p.join(
      storageService.rulesDirectory.path,
      '${storageService.sanitizeFileName(rule.name)}.json',
    );
    centerCellUpdated = false;
    lastEvaluatedCenterState = null;
    statusMessage = "Selected rule: ${rule.name}";
    _validateCurrentExpression();
    notifyListeners();
  }

  String get ruleName => nameController.text.trim().isEmpty
      ? "Untitled Rule"
      : nameController.text.trim();

  String get expressionText => expressionController.text;

  void _onNameChanged() {
    notifyListeners();
  }

  void _onExpressionChanged() {
    _validateCurrentExpression();
    notifyListeners();
  }

  void _validateCurrentExpression() {
    final parseResult = RuleParser.parseString(expressionController.text);
    validationResult = ValidationResult.fromParseResult(parseResult);
  }

  /// Creates a new rule, auto-prepopulates with "cell = ", and positions cursor.
  void newRule() {
    nameController.text = "Untitled Rule";
    expressionController.text = "cell = ";
    expressionController.selection = const TextSelection.collapsed(offset: 7);
    currentFilePath = null;
    centerCellUpdated = false;
    lastEvaluatedCenterState = null;
    statusMessage = "Created new rule";
    _validateCurrentExpression();
    notifyListeners();
  }

  /// Toggles the state of any cell (0..8).
  /// Note: Manual toggles do NOT auto-evaluate the rule.
  void toggleCell(int index) {
    neighborhoodState.toggleCell(index);
    centerCellUpdated = false;
    notifyListeners();
  }

  /// Sets all matrix cells to 0.
  void clearMatrix() {
    neighborhoodState.clear();
    centerCellUpdated = false;
    notifyListeners();
  }

  /// Sets matrix cells to random states (0 or 1).
  void randomizeMatrix() {
    neighborhoodState.randomize();
    centerCellUpdated = false;
    notifyListeners();
  }

  /// Evaluates the current rule expression against the Moore neighborhood
  /// and updates center cell C0.
  bool applyRuleToMatrix() {
    if (!validationResult.isValid || validationResult.rootNode == null) {
      statusMessage = "Cannot apply rule: expression contains syntax errors";
      notifyListeners();
      return false;
    }

    final evaluator = RuleEvaluator(validationResult.rootNode!, neighborhoodState.rng);
    final nextState = evaluator.evaluate(neighborhoodState);

    // Update center cell C0
    neighborhoodState.setCell(0, nextState);
    centerCellUpdated = true;
    lastEvaluatedCenterState = nextState;
    statusMessage = "Applied rule: C0 next state = $nextState";
    notifyListeners();
    return true;
  }

  /// Inserts a function token into the expression at the current cursor position.
  void insertToken(String token) {
    final currentText = expressionController.text;
    final selection = expressionController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = currentText.length;
      end = currentText.length;
    }

    final newText = currentText.replaceRange(start, end, token);
    final newOffset = start + token.length;

    expressionController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Saves the current rule to rules/<name>.json.
  /// If [saveAsNew] is true, or if the rule name differs from the current file name,
  /// it automatically writes to a new file corresponding to the new rule name.
  Future<File?> saveCurrentRule({bool saveAsNew = false}) async {
    final rule = CellRule(
      name: ruleName,
      expression: expressionController.text,
    );

    String? targetPath;
    if (!saveAsNew && currentFilePath != null) {
      final currentBaseName = p.basenameWithoutExtension(currentFilePath!);
      final sanitizedCurrentName = storageService.sanitizeFileName(ruleName);
      if (currentBaseName.toLowerCase() == sanitizedCurrentName.toLowerCase()) {
        targetPath = currentFilePath;
      }
    }

    try {
      final file = await storageService.saveRule(rule, targetPath);
      currentFilePath = file.path;
      statusMessage = "Saved rule to ${file.path}";
      refreshAvailableRules();
      return file;
    } catch (e) {
      statusMessage = "Error saving rule: $e";
      notifyListeners();
      return null;
    }
  }

  /// Loads a rule from a given file path.
  Future<bool> loadRule(String filePath) async {
    try {
      final rule = await storageService.loadRuleFromPath(filePath);
      nameController.text = rule.name;
      expressionController.text = rule.expression;
      currentFilePath = filePath;
      centerCellUpdated = false;
      lastEvaluatedCenterState = null;
      statusMessage = "Loaded rule: ${rule.name}";
      _validateCurrentExpression();
      refreshAvailableRules();
      return true;
    } catch (e) {
      statusMessage = "Error loading rule: $e";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    expressionController.removeListener(_onExpressionChanged);
    nameController.dispose();
    expressionController.dispose();
    super.dispose();
  }
}
