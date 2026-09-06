import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../models/validation_result.dart';

class RuleStatusBadge extends StatelessWidget {
  final ValidationResult result;

  const RuleStatusBadge({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isValid = result.isValid;

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isValid
            ? StudioTheme.secondaryContainer.withOpacity(0.5)
            : StudioTheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? StudioTheme.secondary.withOpacity(0.4)
              : StudioTheme.error.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isValid ? StudioTheme.secondary : StudioTheme.errorAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isValid ? 'Valid' : 'Syntax Error',
            style: TextStyle(
              fontFamily: StudioTheme.monoFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isValid ? StudioTheme.secondary : StudioTheme.error,
            ),
          ),
        ],
      ),
    );

    if (!isValid && result.errorMessage != null) {
      return Tooltip(
        message: result.errorMessage!,
        preferBelow: false,
        child: badge,
      );
    }

    return badge;
  }
}
