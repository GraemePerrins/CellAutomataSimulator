import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/simulation_controller.dart';
import '../../theme/app_theme.dart';
import '../dialogs/rule_editor_modal.dart';
import '../header/studio_window_header.dart';
import '../sidebar/control_sidebar.dart';
import '../viewport/cell_grid_viewport.dart';
import '../viewport/simulation_progress_footer.dart';

class CaStudioMainScreen extends StatefulWidget {
  const CaStudioMainScreen({super.key});

  @override
  State<CaStudioMainScreen> createState() => _CaStudioMainScreenState();
}

class _CaStudioMainScreenState extends State<CaStudioMainScreen> {
  late final SimulationController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = SimulationController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _controller.togglePlayPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _controller.stepForward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _controller.stepBackward();
      } else if (event.logicalKey == LogicalKeyboardKey.keyR &&
          HardwareKeyboard.instance.isControlPressed) {
        _controller.randomizeGrid(0.18);
      }
    }
  }

  void _openRuleEditor() {
    RuleEditorModalDialog.show(context, _controller);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            // Top Window Header Chrome
            StudioWindowHeader(controller: _controller),

            // Central Workstation: Viewport Canvas (Left/Center) + Sidebar Controls (Right)
            Expanded(
              child: Row(
                children: [
                  // Viewport and Progress Footer
                  Expanded(
                    child: Column(
                      children: [
                        // Viewport Area
                        Expanded(
                          child: CellGridViewport(controller: _controller),
                        ),

                        // Bottom Shaded Progress Timeline Footer
                        SimulationProgressFooter(controller: _controller),
                      ],
                    ),
                  ),

                  // Right Control Sidebar
                  ControlSidebar(
                    controller: _controller,
                    onOpenRuleEditor: _openRuleEditor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
