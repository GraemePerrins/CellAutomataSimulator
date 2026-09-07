import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'expression_text_field.dart';
import 'functions_palette.dart';

class RuleEditorPanel extends StatelessWidget {
  final RuleStudioController controller;

  const RuleEditorPanel({super.key, required this.controller});

  String? _resolveSelectedRuleName() {
    final matches = controller.availableRules.where(
      (r) => r.name.toLowerCase() == controller.ruleName.toLowerCase(),
    );
    return matches.isNotEmpty ? matches.first.name : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudioTheme.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: </> Code Icon + "Rule Expression Editor"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 18,
                    color: StudioTheme.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Rule Expression Editor',
                    style: TextStyle(
                      fontFamily: StudioTheme.monoFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: StudioTheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (controller.availableRules.isNotEmpty)
                Text(
                  '${controller.availableRules.length} rules loaded',
                  style: const TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 10,
                    color: StudioTheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Rule Editor Selection Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: StudioTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_motion_outlined,
                  size: 15,
                  color: StudioTheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'SELECT RULE:',
                  style: TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: StudioTheme.outline,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: StudioTheme.surfaceLow,
                      value: _resolveSelectedRuleName(),
                      hint: Text(
                        controller.ruleName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: StudioTheme.monoFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: StudioTheme.primary,
                        ),
                      ),
                      items: controller.availableRules.map((rule) {
                        return DropdownMenuItem<String>(
                          value: rule.name,
                          child: Text(
                            rule.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: StudioTheme.monoFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: StudioTheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedName) {
                        if (selectedName != null) {
                          final found = controller.availableRules.firstWhere(
                            (r) => r.name == selectedName,
                          );
                          controller.selectRule(found);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Upper Section: Rule Name & Expression Text Field
          ExpressionTextField(controller: controller),
          const SizedBox(height: 14),

          // Lower Section: Functions Palette & Hover Popups
          FunctionsPalette(controller: controller),
        ],
      ),
    );
  }
}
