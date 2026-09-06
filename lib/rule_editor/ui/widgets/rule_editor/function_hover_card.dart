import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../models/function_doc.dart';

class FunctionHoverCard extends StatelessWidget {
  final FunctionDoc doc;

  const FunctionHoverCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StudioTheme.surfaceHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.6), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Signature & Return Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doc.label,
                style: TextStyle(
                  fontFamily: StudioTheme.monoFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: doc.textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: StudioTheme.surfaceLowest,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Text(
                  doc.returnType,
                  style: const TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 9,
                    color: StudioTheme.outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Signature
          Text(
            doc.signature,
            style: const TextStyle(
              fontFamily: StudioTheme.monoFont,
              fontSize: 10,
              color: StudioTheme.primary,
            ),
          ),
          const SizedBox(height: 6),

          // Description
          Text(
            doc.description,
            style: const TextStyle(
              fontFamily: StudioTheme.bodyFont,
              fontSize: 11,
              height: 1.35,
              color: StudioTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Example
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: StudioTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: StudioTheme.outlineVariant.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text(
                  'e.g.  ',
                  style: TextStyle(
                    fontFamily: StudioTheme.monoFont,
                    fontSize: 10,
                    color: StudioTheme.outline,
                  ),
                ),
                Expanded(
                  child: Text(
                    doc.example,
                    style: const TextStyle(
                      fontFamily: StudioTheme.monoFont,
                      fontSize: 10,
                      color: StudioTheme.secondary,
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
