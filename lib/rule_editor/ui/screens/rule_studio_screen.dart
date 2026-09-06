import 'package:flutter/material.dart';
import '../../core/theme/studio_theme.dart';
import '../../providers/rule_studio_controller.dart';
import '../widgets/app_bar/studio_app_bar.dart';
import '../widgets/cell_rule_test/cell_rule_test_panel.dart';
import '../widgets/rule_editor/rule_editor_panel.dart';

class RuleStudioScreen extends StatefulWidget {
  final RuleStudioController? controller;

  const RuleStudioScreen({super.key, this.controller});

  @override
  State<RuleStudioScreen> createState() => _RuleStudioScreenState();
}

class _RuleStudioScreenState extends State<RuleStudioScreen> {
  late final RuleStudioController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RuleStudioController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: StudioTheme.background,
          body: Column(
            children: [
              // Custom Desktop Title Bar / App Bar
              StudioAppBar(controller: _controller),

              // Main Workstation 2-Panel Viewport
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Panel: Cell Rule Test
                            CellRuleTestPanel(controller: _controller),
                            const SizedBox(width: 24),

                            // Right Panel: Rule Expression Editor
                            RuleEditorPanel(controller: _controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
