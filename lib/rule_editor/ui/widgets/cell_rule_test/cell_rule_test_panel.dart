import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'apply_rule_button.dart';
import 'moore_grid_view.dart';

class CellRuleTestPanel extends StatelessWidget {
  final RuleStudioController controller;

  const CellRuleTestPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Row
          Row(
            children: [
              // Icon + Title
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.view_in_ar,
                      size: 18,
                      color: StudioTheme.secondary,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Cell Rule Test',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: StudioTheme.monoFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: StudioTheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Clear & Randomize Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallButton('Clear', controller.clearMatrix),
                  const SizedBox(width: 6),
                  _buildSmallButton('Randomize', controller.randomizeMatrix),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rule Name Being Tested
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: StudioTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text(
                  'Testing: ',
                  style: TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: StudioTheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.ruleName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: StudioTheme.monoFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: StudioTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3x3 Interactive Moore Grid
          MooreGridView(controller: controller),
          const SizedBox(height: 18),

          // Apply Rule Action Button
          ApplyRuleButton(controller: controller),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: StudioTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: StudioTheme.monoFont,
            fontSize: 10,
            color: StudioTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
