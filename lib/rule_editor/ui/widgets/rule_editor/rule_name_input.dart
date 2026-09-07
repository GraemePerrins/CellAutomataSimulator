import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'rule_status_badge.dart';

class RuleNameInput extends StatelessWidget {
  final RuleStudioController controller;

  const RuleNameInput({super.key, required this.controller});

  Future<void> _handleSave(BuildContext context) async {
    final file = await controller.saveCurrentRule();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            file != null
                ? 'Saved "${controller.ruleName}" to ${file.path}'
                : 'Failed to save rule',
          ),
          backgroundColor: StudioTheme.surfaceHigh,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: StudioTheme.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: "RULE:" label + editable text field + quick Save button
          Expanded(
            child: Row(
              children: [
                const Text(
                  'RULE:',
                  style: TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: StudioTheme.outline,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.nameController,
                    style: const TextStyle(
                      fontFamily: StudioTheme.monoFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: StudioTheme.primary,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Enter rule name...',
                      hintStyle: TextStyle(
                        fontFamily: StudioTheme.monoFont,
                        fontSize: 12,
                        color: StudioTheme.outline,
                      ),
                    ),
                    onSubmitted: (_) => _handleSave(context),
                  ),
                ),
                const SizedBox(width: 6),
                // Quick Save button next to rule name
                Tooltip(
                  message: 'Save rule as "${controller.ruleName}.json"',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _handleSave(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: StudioTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: StudioTheme.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.save_outlined, size: 12, color: StudioTheme.primary),
                          SizedBox(width: 4),
                          Text(
                            'SAVE',
                            style: TextStyle(
                              fontFamily: StudioTheme.monoFont,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: StudioTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Right: Real-time validation badge
          RuleStatusBadge(result: controller.validationResult),
        ],
      ),
    );
  }
}
