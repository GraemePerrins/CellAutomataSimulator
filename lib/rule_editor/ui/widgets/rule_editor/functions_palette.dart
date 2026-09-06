import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../models/function_doc.dart';
import '../../../providers/rule_studio_controller.dart';
import 'function_tile.dart';

class FunctionsPalette extends StatelessWidget {
  final RuleStudioController controller;

  const FunctionsPalette({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const tokens = FunctionDoc.allTokens;

    return Container(
      decoration: BoxDecoration(
        color: StudioTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: fx icon + "Functions"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: StudioTheme.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              border: Border(
                bottom: BorderSide(
                  color: StudioTheme.borderSubtle,
                  width: 1,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.functions,
                  size: 16,
                  color: StudioTheme.primary,
                ),
                SizedBox(width: 6),
                Text(
                  'Functions',
                  style: TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: StudioTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // 2x6 Grid of Function Tiles
          Padding(
            padding: const EdgeInsets.all(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 6 columns
                const columns = 6;
                const spacing = 8.0;
                final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: tokens.map((doc) {
                    return SizedBox(
                      width: itemWidth,
                      height: 36,
                      child: FunctionTile(
                        doc: doc,
                        onInsert: (token) => controller.insertToken(token),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
