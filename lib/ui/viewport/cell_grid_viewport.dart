import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/simulation_controller.dart';
import '../../theme/app_theme.dart';
import 'cell_grid_canvas.dart';

class CellGridViewport extends StatefulWidget {
  final SimulationController controller;

  const CellGridViewport({super.key, required this.controller});

  @override
  State<CellGridViewport> createState() => _CellGridViewportState();
}

class _CellGridViewportState extends State<CellGridViewport> {
  ui.FragmentProgram? _fragmentProgram;
  bool _isLoadingShader = true;
  int _drawMode = 1; // 1 = draw alive, 0 = erase
  bool _isPanning = false;
  Offset _lastPanPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/shaders/cell_grid.frag',
      );
      if (mounted) {
        setState(() {
          _fragmentProgram = program;
          _isLoadingShader = false;
        });
      }
    } catch (e) {
      debugPrint("Warning: Shader loading fallback to Canvas: $e");
      if (mounted) {
        setState(() {
          _isLoadingShader = false;
        });
      }
    }
  }

  void _handlePointerDown(
    PointerDownEvent event,
    double offsetX,
    double offsetY,
    double cellPixelSize,
  ) {
    final isMiddleOrRight = (event.buttons & kMiddleMouseButton != 0) ||
        (event.buttons & kSecondaryMouseButton != 0);
    final isSpaceHeld = HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.space);

    final localX = event.localPosition.dx - offsetX;
    final localY = event.localPosition.dy - offsetY;
    final isInsideGrid = cellPixelSize > 0 &&
        localX >= 0 &&
        localY >= 0 &&
        localX < widget.controller.width * cellPixelSize &&
        localY < widget.controller.height * cellPixelSize;

    if (isMiddleOrRight || isSpaceHeld || !isInsideGrid) {
      _isPanning = true;
      _lastPanPos = event.position;
      setState(() {});
      return;
    }

    if (isInsideGrid) {
      final cellX = (localX / cellPixelSize).floor();
      final cellY = (localY / cellPixelSize).floor();

      // If clicked cell is currently alive, switch to erase mode (0); else birth mode (1)
      final buffer = widget.controller.rawBuffer;
      if (buffer != null) {
        final idx = cellY * widget.controller.width + cellX;
        if (idx >= 0 && idx < buffer.length) {
          _drawMode = buffer[idx] == 1 ? 0 : 1;
        }
      }

      widget.controller.setCell(cellX, cellY, _drawMode);
    }
  }

  void _handlePointerMove(
    PointerMoveEvent event,
    double offsetX,
    double offsetY,
    double cellPixelSize,
  ) {
    if (_isPanning) {
      final delta = event.position - _lastPanPos;
      _lastPanPos = event.position;
      widget.controller.setPan(delta);
      return;
    }

    final localX = event.localPosition.dx - offsetX;
    final localY = event.localPosition.dy - offsetY;

    if (cellPixelSize > 0 &&
        localX >= 0 &&
        localY >= 0 &&
        localX < widget.controller.width * cellPixelSize &&
        localY < widget.controller.height * cellPixelSize) {
      final cellX = (localX / cellPixelSize).floor();
      final cellY = (localY / cellPixelSize).floor();

      if (event.down && (event.buttons & kPrimaryMouseButton != 0)) {
        widget.controller.setCell(cellX, cellY, _drawMode);
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_isPanning) {
      _isPanning = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth;
            final viewportHeight = constraints.maxHeight;

            final cols = widget.controller.width;
            final rows = widget.controller.height;

            if (cols <= 0 || rows <= 0 || viewportWidth <= 0 || viewportHeight <= 0) {
              return const SizedBox.shrink();
            }

            // --- STRICT 1:1 CELL ASPECT RATIO UNIFORM FITTING ---
            // S = min( W_v / cols, H_v / rows )
            final baseCellSize = min(viewportWidth / cols, viewportHeight / rows);
            final effectiveCellSize = baseCellSize * widget.controller.zoom;

            final activeWidth = cols * effectiveCellSize;
            final activeHeight = rows * effectiveCellSize;

            // Symmetrical centering with letterbox/pillarbox margins + pan offset
            final baseOffsetX = (viewportWidth - activeWidth) / 2.0;
            final baseOffsetY = (viewportHeight - activeHeight) / 2.0;

            final totalOffsetX = baseOffsetX + widget.controller.panOffset.dx;
            final totalOffsetY = baseOffsetY + widget.controller.panOffset.dy;

            final shader = _fragmentProgram?.fragmentShader();

            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
              ),
              clipBehavior: Clip.hardEdge,
              child: Listener(
                onPointerDown: (e) => _handlePointerDown(
                  e,
                  totalOffsetX,
                  totalOffsetY,
                  effectiveCellSize,
                ),
                onPointerMove: (e) => _handlePointerMove(
                  e,
                  totalOffsetX,
                  totalOffsetY,
                  effectiveCellSize,
                ),
                onPointerUp: _handlePointerUp,
                onPointerCancel: (_) {
                  if (_isPanning) {
                    _isPanning = false;
                    setState(() {});
                  }
                },
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    if (pointerSignal.scrollDelta.dy < 0) {
                      widget.controller.zoomIn();
                    } else if (pointerSignal.scrollDelta.dy > 0) {
                      widget.controller.zoomOut();
                    }
                  }
                },
                onPointerPanZoomUpdate: (event) {
                  widget.controller.setPan(event.panDelta);
                },
                child: MouseRegion(
                  cursor: _isPanning
                      ? SystemMouseCursors.grabbing
                      : (HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.space)
                          ? SystemMouseCursors.grab
                          : SystemMouseCursors.precise),
                  child: Stack(
                    children: [
                      // Centered active grid
                      Positioned(
                        left: totalOffsetX,
                        top: totalOffsetY,
                        width: activeWidth,
                        height: activeHeight,
                        child: CustomPaint(
                          size: Size(activeWidth, activeHeight),
                          painter: CellGridCanvas(
                            gridImage: widget.controller.currentImage,
                            shader: shader,
                            cols: cols,
                            rows: rows,
                            cellShape: widget.controller.cellShape,
                            cellPadding: widget.controller.cellPadding,
                            aliveColor: widget.controller.aliveColor,
                            activeWidth: activeWidth,
                            activeHeight: activeHeight,
                          ),
                        ),
                      ),

                      // Loading indicator if shader is initializing
                      if (_isLoadingShader)
                        const Positioned(
                          right: 16,
                          bottom: 16,
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.aliveColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
