import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'rule_status_badge.dart';

class RuleNameInput extends StatelessWidget {
  final RuleStudioController controller;

  const RuleNameInput({super.key, required this.controller});

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
          // Left: "RULE:" label + text field
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
                  ),
                ),
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
