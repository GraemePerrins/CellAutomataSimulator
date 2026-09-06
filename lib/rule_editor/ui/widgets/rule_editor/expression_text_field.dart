import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'rule_name_input.dart';

class ExpressionTextField extends StatelessWidget {
  final RuleStudioController controller;

  const ExpressionTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudioTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: controller.validationResult.isValid
              ? StudioTheme.outlineVariant.withOpacity(0.3)
              : StudioTheme.errorAccent.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule name and status header
          RuleNameInput(controller: controller),
          const SizedBox(height: 8),

          // Multi-line Expression Editor Text Area
          TextField(
            controller: controller.expressionController,
            maxLines: 5,
            minLines: 4,
            style: const TextStyle(
              fontFamily: StudioTheme.monoFont,
              fontSize: 12,
              height: 1.5,
              color: StudioTheme.primary,
              letterSpacing: 0.2,
            ),
            cursorColor: StudioTheme.primaryAccent,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]',
              hintStyle: TextStyle(
                fontFamily: StudioTheme.monoFont,
                fontSize: 12,
                color: StudioTheme.outline,
              ),
            ),
          ),

          // Diagnostic Error Banner if syntax is invalid
          if (!controller.validationResult.isValid &&
              controller.validationResult.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: StudioTheme.errorAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      controller.validationResult.errorMessage!,
                      style: const TextStyle(
                        fontFamily: StudioTheme.monoFont,
                        fontSize: 10,
                        color: StudioTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
