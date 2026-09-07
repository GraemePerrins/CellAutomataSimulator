import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../theme/app_theme.dart';

class CanvasHudOverlay extends StatelessWidget {
  final SimulationController controller;

  const CanvasHudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final ruleName = controller.isCustomRule
            ? controller.customRuleName
            : controller.activePreset.name;

        return Positioned(
          left: 14,
          top: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surface900.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulse dot
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isRunning
                        ? AppTheme.aliveColor
                        : AppTheme.amberAccent,
                    boxShadow: controller.isRunning
                        ? [
                            BoxShadow(
                              color: AppTheme.aliveColor.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),

                // Rule Name
                Text(
                  ruleName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
                const SizedBox(width: 8),

                // Gen count
                Text(
                  'Gen: ${controller.generation}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontFamily: AppTheme.monospaceFont,
                    fontFamilyFallback: AppTheme.monospaceFontFallback,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                ),
                const SizedBox(width: 8),

                // Live Cells
                Text(
                  '${controller.aliveCount} Live',
                  style: const TextStyle(
                    color: AppTheme.aliveGlow,
                    fontSize: 11,
                    fontFamily: AppTheme.monospaceFont,
                    fontFamilyFallback: AppTheme.monospaceFontFallback,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
