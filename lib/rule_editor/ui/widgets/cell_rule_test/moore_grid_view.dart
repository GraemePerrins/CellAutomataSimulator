import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import 'cell_tile.dart';

class MooreGridView extends StatelessWidget {
  final RuleStudioController controller;

  const MooreGridView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // 3x3 grid layout mapping:
    // [C1, C2, C3]
    // [C4, C0, C5]
    // [C6, C7, C8]
    final gridIndices = [
      [1, 2, 3],
      [4, 0, 5],
      [6, 7, 8],
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StudioTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: gridIndices.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: row.map((index) {
                final isCenter = index == 0;
                final value = controller.neighborhoodState.getCell(index);
                final isUpdated = isCenter && controller.centerCellUpdated;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CellTile(
                    index: index,
                    value: value,
                    isCenter: isCenter,
                    isUpdatedByRule: isUpdated,
                    onTap: () => controller.toggleCell(index),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
