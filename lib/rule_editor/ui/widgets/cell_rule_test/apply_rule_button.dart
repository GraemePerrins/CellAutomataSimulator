import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';

class ApplyRuleButton extends StatelessWidget {
  final RuleStudioController controller;

  const ApplyRuleButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isValid = controller.validationResult.isValid;

    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? StudioTheme.primaryAccent : StudioTheme.surfaceContainer,
          foregroundColor: isValid ? Colors.white : StudioTheme.outline,
          disabledBackgroundColor: StudioTheme.surfaceContainer,
          disabledForegroundColor: StudioTheme.outline,
          elevation: isValid ? 3 : 0,
          shadowColor: StudioTheme.primaryAccent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isValid ? StudioTheme.primary : StudioTheme.outlineVariant.withOpacity(0.3),
            ),
          ),
        ),
        onPressed: isValid
            ? () {
                controller.applyRuleToMatrix();
              }
            : null,
        child: const Text(
          'Apply Rule',
          style: TextStyle(
            fontFamily: StudioTheme.monoFont,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
