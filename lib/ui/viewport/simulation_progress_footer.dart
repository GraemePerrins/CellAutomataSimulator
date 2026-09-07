import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../theme/app_theme.dart';

class SimulationProgressFooter extends StatelessWidget {
  final SimulationController controller;

  const SimulationProgressFooter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final currentGen = controller.generation;
        final maxGen = controller.maxGenerations;
        final progress = maxGen > 0
            ? (currentGen / maxGen).clamp(0.0, 1.0)
            : 0.0;

        final zoomPercent = (controller.zoom * 100).round();

        return Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: AppTheme.surface900,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 620;
              // Generation display (fixed width & fixed format length to avoid progress bar shifting)
              final totalStr = maxGen > 0 ? maxGen.toString() : '∞';
              final padLength = maxGen > 0 ? totalStr.length : 5;
              final genStr = currentGen.toString().padLeft(padLength, '0');

              return Row(
                children: [
                  SizedBox(
                    width: 220,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timelapse_outlined,
                          size: 15,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Gen $genStr / $totalStr',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTheme.monospaceFont,
                              fontFamilyFallback: AppTheme.monospaceFontFallback,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

              // Progress Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 6,
                    color: AppTheme.surface700,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.aliveColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.aliveColor.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Density Badge (Fixed width to prevent progress bar length from shifting)
              SizedBox(
                width: 210,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.grain,
                      size: 15,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Density: ${controller.density.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTheme.monospaceFont,
                        fontFamilyFallback: AppTheme.monospaceFontFallback,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 16),

                // Zoom Controls
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface800,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        tooltip: 'Zoom Out',
                        onPressed: controller.zoomOut,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          '$zoomPercent%',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontFamily: AppTheme.monospaceFont,
                            fontFamilyFallback: AppTheme.monospaceFontFallback,
                            fontWeight: FontWeight.bold,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 14),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        tooltip: 'Zoom In',
                        onPressed: controller.zoomIn,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  },
);
  }
}
