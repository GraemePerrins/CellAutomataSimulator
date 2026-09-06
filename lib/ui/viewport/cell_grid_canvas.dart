import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../models/cell_shape.dart';
import '../../theme/app_theme.dart';

class CellGridCanvas extends CustomPainter {
  final ui.Image? gridImage;
  final ui.FragmentShader? shader;
  final int cols;
  final int rows;
  final CellShape cellShape;
  final double cellPadding;
  final Color aliveColor;
  final Color deadColor;
  final double activeWidth;
  final double activeHeight;

  CellGridCanvas({
    required this.gridImage,
    required this.shader,
    required this.cols,
    required this.rows,
    required this.cellShape,
    required this.cellPadding,
    this.aliveColor = AppTheme.aliveColor,
    this.deadColor = AppTheme.deadColor,
    required this.activeWidth,
    required this.activeHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (gridImage == null || cols <= 0 || rows <= 0) {
      // Draw placeholder backdrop
      final bgPaint = Paint()..color = deadColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, activeWidth, activeHeight), bgPaint);
      return;
    }

    final activeRect = Rect.fromLTWH(0, 0, activeWidth, activeHeight);

    if (shader != null) {
      // --- GPU Fragment Shader Pipeline ---
      // Uniforms layout:
      // 0, 1: u_resolution (activeWidth, activeHeight)
      // 2, 3: u_grid_size (cols, rows)
      // 4: u_shape_type (0.0 = Square, 1.0 = Circle)
      // 5: u_cell_padding
      // 6..9: u_alive_color (RGBA)
      // 10..13: u_dead_color (RGBA)
      // Sampler 0: u_grid_tex

      shader!.setFloat(0, activeWidth);
      shader!.setFloat(1, activeHeight);
      shader!.setFloat(2, cols.toDouble());
      shader!.setFloat(3, rows.toDouble());
      shader!.setFloat(4, cellShape == CellShape.square ? 0.0 : 1.0);
      shader!.setFloat(5, cellPadding);

      shader!.setFloat(6, aliveColor.red / 255.0);
      shader!.setFloat(7, aliveColor.green / 255.0);
      shader!.setFloat(8, aliveColor.blue / 255.0);
      shader!.setFloat(9, aliveColor.opacity);

      shader!.setFloat(10, deadColor.red / 255.0);
      shader!.setFloat(11, deadColor.green / 255.0);
      shader!.setFloat(12, deadColor.blue / 255.0);
      shader!.setFloat(13, deadColor.opacity);

      shader!.setImageSampler(0, gridImage!);

      final paint = Paint()..shader = shader;
      canvas.drawRect(activeRect, paint);
    } else {
      // --- Fallback Direct Canvas Pipeline (Clean & Scaled) ---
      final bgPaint = Paint()..color = deadColor;
      canvas.drawRect(activeRect, bgPaint);

      final src = Rect.fromLTWH(
        0,
        0,
        gridImage!.width.toDouble(),
        gridImage!.height.toDouble(),
      );
      final dst = activeRect;
      final paint = Paint()..filterQuality = FilterQuality.none;
      canvas.drawImageRect(gridImage!, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CellGridCanvas oldDelegate) {
    return oldDelegate.gridImage != gridImage ||
        oldDelegate.cols != cols ||
        oldDelegate.rows != rows ||
        oldDelegate.cellShape != cellShape ||
        oldDelegate.cellPadding != cellPadding ||
        oldDelegate.activeWidth != activeWidth ||
        oldDelegate.activeHeight != activeHeight ||
        oldDelegate.aliveColor != aliveColor ||
        oldDelegate.deadColor != deadColor;
  }
}
