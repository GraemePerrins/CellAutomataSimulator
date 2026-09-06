import 'package:flutter/material.dart';
import '../../../core/theme/studio_theme.dart';
import '../../../providers/rule_studio_controller.dart';
import '../dialogs/rule_file_dialog.dart';

class StudioAppBar extends StatelessWidget {
  final RuleStudioController controller;

  const StudioAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: StudioTheme.surfaceLowest,
        border: Border(
          bottom: BorderSide(
            color: StudioTheme.borderSubtle,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Window controls & Title
          Row(
            children: [
              // macOS style dots
              Row(
                children: [
                  _buildWindowDot(const Color(0xFFFF5F56)),
                  const SizedBox(width: 8),
                  _buildWindowDot(const Color(0xFFFFBD2E)),
                  const SizedBox(width: 8),
                  _buildWindowDot(const Color(0xFF27C93F)),
                ],
              ),
              const SizedBox(width: 20),

              // App Icon & Title
              const Icon(
                Icons.grain,
                size: 20,
                color: StudioTheme.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Cellular Automata Rule Studio',
                style: TextStyle(
                  fontFamily: StudioTheme.monoFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: StudioTheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          // Right: Action buttons (New, Load, Save)
          Row(
            children: [
              // New Rule
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: StudioTheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.add, size: 16, color: StudioTheme.primary),
                label: const Text(
                  'New Rule',
                  style: TextStyle(fontFamily: StudioTheme.monoFont, fontSize: 11),
                ),
                onPressed: () {
                  controller.newRule();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Created new rule prepopulated with "cell = "'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              // Load Rule
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: StudioTheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.folder_open, size: 16, color: StudioTheme.primary),
                label: const Text(
                  'Load Rule',
                  style: TextStyle(fontFamily: StudioTheme.monoFont, fontSize: 11),
                ),
                onPressed: () async {
                  final path = await RuleFileDialog.show(context, controller.storageService);
                  if (path != null) {
                    final success = await controller.loadRule(path);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Loaded ${controller.ruleName}' : 'Failed to load rule'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(width: 8),

              // Save Rule
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudioTheme.surfaceContainer,
                  foregroundColor: StudioTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: StudioTheme.borderSubtle),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 16, color: StudioTheme.primary),
                label: const Text(
                  'Save Rule',
                  style: TextStyle(fontFamily: StudioTheme.monoFont, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final file = await controller.saveCurrentRule();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(file != null ? 'Saved rule to ${file.path}' : 'Failed to save rule'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindowDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
