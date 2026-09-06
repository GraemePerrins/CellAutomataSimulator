import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';

class CellTile extends StatelessWidget {
  final int index;
  final int value;
  final bool isCenter;
  final bool isUpdatedByRule;
  final VoidCallback onTap;

  const CellTile({
    super.key,
    required this.index,
    required this.value,
    required this.isCenter,
    required this.isUpdatedByRule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 80,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: _buildDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Cell ID (e.g. C0, C1)
            Text(
              'C$index',
              style: TextStyle(
                fontFamily: StudioTheme.monoFont,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getIdTextColor(),
                letterSpacing: 0.5,
              ),
            ),

            // Center: State Value (0 or 1)
            Text(
              '$value',
              style: TextStyle(
                fontFamily: StudioTheme.monoFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getValueTextColor(),
              ),
            ),

            // Bottom: Dot or CELL badge
            _buildBottomIndicator(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (isCenter) {
      if (isUpdatedByRule) {
        if (value == 1) {
          // Luminous cyan glow on rule birth/survival
          return BoxDecoration(
            color: const Color(0xFF0369A1), // Sky dark
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: StudioTheme.centerCellUpdatedAlive, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6638BDF8),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          );
        } else {
          // Quiescent / dead state transition
          return BoxDecoration(
            color: StudioTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33EF4444),
                blurRadius: 8,
              ),
            ],
          );
        }
      }

      // Standard center cell styling
      if (value == 1) {
        return BoxDecoration(
          color: StudioTheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudioTheme.primaryAccent, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x404D8EFF),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        );
      } else {
        return BoxDecoration(
          color: StudioTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudioTheme.primaryAccent.withOpacity(0.4), width: 1),
        );
      }
    } else {
      // Neighbors C1..C8
      if (value == 1) {
        return BoxDecoration(
          color: StudioTheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudioTheme.secondary.withOpacity(0.5), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2210B981),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        );
      } else {
        return BoxDecoration(
          color: StudioTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3), width: 1),
        );
      }
    }
  }

  Color _getIdTextColor() {
    if (isCenter) {
      return value == 1 ? StudioTheme.primary : StudioTheme.primary.withOpacity(0.7);
    }
    return value == 1 ? StudioTheme.secondary : StudioTheme.outline;
  }

  Color _getValueTextColor() {
    if (isCenter) {
      if (isUpdatedByRule && value == 1) return Colors.white;
      return value == 1 ? StudioTheme.primary : StudioTheme.outline;
    }
    return value == 1 ? StudioTheme.secondary : StudioTheme.outline;
  }

  Widget _buildBottomIndicator() {
    if (isCenter) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: isUpdatedByRule && value == 1
              ? StudioTheme.centerCellUpdatedAlive
              : StudioTheme.primaryAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'CELL',
          style: TextStyle(
            fontFamily: StudioTheme.monoFont,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: isUpdatedByRule && value == 1 ? Colors.black : Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: value == 1 ? StudioTheme.secondary : StudioTheme.outlineVariant.withOpacity(0.5),
        shape: BoxShape.circle,
        boxShadow: value == 1
            ? const [
                BoxShadow(
                  color: StudioTheme.secondary,
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
    );
  }
}
