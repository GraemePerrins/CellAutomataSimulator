import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../rule_editor/core/theme/studio_theme.dart';
import '../../rule_editor/providers/rule_studio_controller.dart';
import '../../rule_editor/ui/widgets/cell_rule_test/cell_rule_test_panel.dart';
import '../../rule_editor/ui/widgets/dialogs/rule_file_dialog.dart';
import '../../rule_editor/ui/widgets/rule_editor/rule_editor_panel.dart';
import '../../theme/app_theme.dart';

class RuleEditorModalDialog extends StatefulWidget {
  final SimulationController simulationController;

  const RuleEditorModalDialog({
    super.key,
    required this.simulationController,
  });

  static Future<void> show(
    BuildContext context,
    SimulationController simulationController,
  ) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => RuleEditorModalDialog(
        simulationController: simulationController,
      ),
    );
  }

  @override
  State<RuleEditorModalDialog> createState() => _RuleEditorModalDialogState();
}

class _RuleEditorModalDialogState extends State<RuleEditorModalDialog> {
  late final RuleStudioController _ruleController;

  @override
  void initState() {
    super.initState();
    _ruleController = RuleStudioController();

    // Populate with current simulation rule if available
    if (widget.simulationController.isCustomRule) {
      _ruleController.nameController.text =
          widget.simulationController.customRuleName;
      _ruleController.expressionController.text =
          widget.simulationController.customRuleExpression;
    } else {
      _ruleController.nameController.text =
          widget.simulationController.activePreset.name;
      _ruleController.expressionController.text =
          widget.simulationController.activePreset.expression;
    }
  }

  @override
  void dispose() {
    _ruleController.dispose();
    super.dispose();
  }

  void _applyToSimulation() {
    final name = _ruleController.nameController.text.trim().isEmpty
        ? 'Custom Rule'
        : _ruleController.nameController.text.trim();
    final expr = _ruleController.expressionController.text.trim();

    if (_ruleController.validationResult.isValid) {
      widget.simulationController.applyCustomRule(name, expr);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied "$name" to simulation engine'),
          backgroundColor: AppTheme.surface800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Container(
        width: 1080,
        height: 720,
        decoration: BoxDecoration(
          color: StudioTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Modal Title Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: StudioTheme.surfaceContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.terminal_rounded,
                          size: 16,
                          color: AppTheme.aliveColor,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'RULE STUDIO WORKSTATION',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'AST Grammar & 3×3 Moore Neighborhood',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // New Rule
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 15, color: AppTheme.aliveColor),
                    label: const Text(
                      'New',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      _ruleController.newRule();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Created new rule template with "cell = "'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),

                  // Load Rule
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.folder_open_rounded, size: 15, color: AppTheme.cyanAccent),
                    label: const Text(
                      'Load',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final path = await RuleFileDialog.show(context, _ruleController.storageService);
                      if (path != null) {
                        final success = await _ruleController.loadRule(path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Loaded "${_ruleController.ruleName}"' : 'Failed to load rule'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 4),

                  // Save Rule Action
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudioTheme.surfaceContainer,
                      foregroundColor: AppTheme.cyanAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                    icon: const Icon(Icons.save_outlined, size: 15, color: AppTheme.cyanAccent),
                    label: const Text(
                      'Save Rule',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      final file = await _ruleController.saveCurrentRule();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(file != null ? 'Saved rule to ${file.path}' : 'Failed to save rule'),
                            backgroundColor: AppTheme.surface800,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  // Apply to Simulation Action
                  ListenableBuilder(
                    listenable: _ruleController,
                    builder: (context, _) {
                      final isValid = _ruleController.validationResult.isValid;
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValid
                              ? AppTheme.aliveColor
                              : AppTheme.surface700,
                          foregroundColor: isValid
                              ? AppTheme.background
                              : AppTheme.textMuted,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 15),
                        label: const Text(
                          'Apply to Simulation',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: isValid ? _applyToSimulation : null,
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Close Button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppTheme.textSecondary,
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body with Rule Editor Panes
            Expanded(
              child: AnimatedBuilder(
                animation: _ruleController,
                builder: (context, _) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Cell Rule Test Panel (3x3 Moore grid C0..C8)
                            CellRuleTestPanel(controller: _ruleController),
                            const SizedBox(width: 20),

                            // Right: Rule Editor Panel (ExpressionTextField + Functions Palette)
                            RuleEditorPanel(controller: _ruleController),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
