import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'expression_text_field.dart';
import 'functions_palette.dart';

class RuleEditorPanel extends StatelessWidget {
  final RuleStudioController controller;

  const RuleEditorPanel({super.key, required this.controller});

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
          const SizedBox(height: 14),

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
