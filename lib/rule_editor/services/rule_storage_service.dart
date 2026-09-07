import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../core/syntax/parser.dart';
import '../models/cell_rule.dart';

class RuleStorageService {
  final String rulesDirectoryPath;

  RuleStorageService({String? customRulesPath})
      : rulesDirectoryPath = customRulesPath ?? _resolveDefaultRulesDir();

  static String _resolveDefaultRulesDir() {
    final currentDir = Directory.current.path;

    // Check if assets/rules directory exists (primary storage for project rules)
    final assetsRules = p.join(currentDir, 'assets', 'rules');
    if (Directory(assetsRules).existsSync()) {
      return assetsRules;
    }

    // Check if parent directory contains assets/rules
    final parentAssetsRules = p.join(currentDir, '..', 'assets', 'rules');
    if (Directory(parentAssetsRules).existsSync()) {
      return parentAssetsRules;
    }

    // Check if running inside RuleEditor folder
    final directRules = p.join(currentDir, 'rules');
    if (Directory(directRules).existsSync()) {
      return directRules;
    }

    // Check if directory contains RuleEditor/rules
    final nestedRules = p.join(currentDir, 'RuleEditor', 'rules');
    if (Directory(nestedRules).existsSync()) {
      return nestedRules;
    }

    // Default fallback
    return assetsRules;
  }

  Directory get rulesDirectory {
    final dir = Directory(rulesDirectoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  List<FileSystemEntity> listRuleFiles() {
    final dir = rulesDirectory;
    final files = dir.listSync().where((f) => f.path.endsWith('.json')).toList();
    files.sort((a, b) => p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase()));
    return files;
  }

  /// Reads and parses all .json files in the rules directory.
  /// Filters out malformed files and only returns rules that are valid JSON
  /// and have syntactically valid AST expressions.
  List<CellRule> loadValidRules() {
    final dir = rulesDirectory;
    if (!dir.existsSync()) return [];

    final files = listRuleFiles();
    final List<CellRule> validRules = [];
    final Set<String> seenNames = {};

    for (final file in files) {
      if (file is! File) continue;
      try {
        final content = file.readAsStringSync();
        final json = jsonDecode(content);
        if (json is! Map<String, dynamic>) continue;

        final rawName = json['name'];
        final rawExpr = json['expression'];
        if (rawName is! String || rawName.trim().isEmpty) continue;
        if (rawExpr is! String || rawExpr.trim().isEmpty) continue;

        final name = rawName.trim();
        final expr = rawExpr.trim();

        // Validate AST syntax
        final parseResult = RuleParser.parseString(expr);
        if (!parseResult.isValid) continue;

        // Deduplicate by name if identical names exist
        if (seenNames.contains(name.toLowerCase())) continue;
        seenNames.add(name.toLowerCase());

        validRules.add(CellRule(name: name, expression: expr));
      } catch (_) {
        // Silently skip invalid or non-json files
      }
    }

    validRules.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return validRules;
  }

  String sanitizeFileName(String name) {
    var sanitized = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '-')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (sanitized.isEmpty) {
      sanitized = 'Untitled Rule';
    }
    return sanitized;
  }

  Future<File> saveRule(CellRule rule, [String? customFilePath]) async {
    final filePath = customFilePath ??
        p.join(rulesDirectory.path, '${sanitizeFileName(rule.name)}.json');

    final file = File(filePath);
    const encoder = JsonEncoder.withIndent('  ');
    final jsonStr = encoder.convert(rule.toJson());

    await file.writeAsString(jsonStr);
    return file;
  }

  Future<CellRule> loadRuleFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException("Rule file does not exist", filePath);
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return CellRule.fromJson(json);
  }
}
