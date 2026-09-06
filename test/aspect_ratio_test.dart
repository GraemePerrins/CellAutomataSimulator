import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cell Grid Aspect Ratio & Uniform Sizing Tests', () {
    test('Strict 1:1 cell proportion formula', () {
      const viewportWidth = 1800.0;
      const viewportHeight = 1200.0;
      const cols = 1200;
      const rows = 800;

      // Uniform cell side length S = min( W_v / cols, H_v / rows )
      final s = min(viewportWidth / cols, viewportHeight / rows);
      expect(s, equals(1.5));

      final activeWidth = cols * s;
      final activeHeight = rows * s;
      expect(activeWidth, equals(1800.0));
      expect(activeHeight, equals(1200.0));

      // Individual cell aspect ratio must be strictly 1.0 (equal width and height)
      final cellRatio = (activeWidth / cols) / (activeHeight / rows);
      expect(cellRatio, equals(1.0));
    });

    test('Widescreen viewport with square grid produces symmetrical horizontal letterbox', () {
      const viewportWidth = 1600.0;
      const viewportHeight = 900.0;
      const cols = 100;
      const rows = 100;

      final s = min(viewportWidth / cols, viewportHeight / rows);
      // min(16.0, 9.0) = 9.0
      expect(s, equals(9.0));

      final activeWidth = cols * s; // 900.0
      final activeHeight = rows * s; // 900.0
      expect(activeWidth, equals(900.0));
      expect(activeHeight, equals(900.0));

      final offsetX = (viewportWidth - activeWidth) / 2.0;
      final offsetY = (viewportHeight - activeHeight) / 2.0;

      expect(offsetX, equals(350.0)); // Symmetrical left/right pillarbox
      expect(offsetY, equals(0.0));
    });

    test('Tall grid produces symmetrical vertical letterbox', () {
      const viewportWidth = 1000.0;
      const viewportHeight = 1000.0;
      const cols = 100;
      const rows = 50;

      final s = min(viewportWidth / cols, viewportHeight / rows);
      // min(10.0, 20.0) = 10.0
      expect(s, equals(10.0));

      final activeHeight = rows * s; // 500.0
      final offsetY = (viewportHeight - activeHeight) / 2.0;

      expect(offsetY, equals(250.0)); // Symmetrical top/bottom letterbox
    });

    test('Inverse proportionality: smaller grid renders larger cells', () {
      const viewportWidth = 1200.0;
      const viewportHeight = 800.0;

      // Small grid (32x32)
      final sSmall = min(viewportWidth / 32, viewportHeight / 32);
      expect(sSmall, equals(25.0)); // Each cell is 25x25 px

      // Medium grid (128x96)
      final sMedium = min(viewportWidth / 128, viewportHeight / 96);
      expect(sMedium, closeTo(8.33, 0.01)); // Each cell is 8.33 px

      // Large grid (1200x800)
      final sLarge = min(viewportWidth / 1200, viewportHeight / 800);
      expect(sLarge, equals(1.0)); // Each cell is 1x1 px

      expect(sSmall > sMedium, isTrue);
      expect(sMedium > sLarge, isTrue);
    });

    test('Mouse coordinate translation accurately maps to grid cells', () {
      const offsetX = 100.0;
      const offsetY = 50.0;
      const s = 10.0;
      const cols = 50;
      const rows = 50;

      // Click at (155, 85) -> local relative to active grid: (55, 35) -> cell: (5, 3)
      const mouseX = 155.0;
      const mouseY = 85.0;

      const localX = mouseX - offsetX;
      const localY = mouseY - offsetY;

      final cellX = (localX / s).floor();
      final cellY = (localY / s).floor();

      expect(cellX, equals(5));
      expect(cellY, equals(3));
      expect(cellX >= 0 && cellX < cols, isTrue);
      expect(cellY >= 0 && cellY < rows, isTrue);

      // Click in letterbox margin (X = 40, before offsetX)
      const outsideX = 40.0;
      const outsideLocalX = outsideX - offsetX;
      final outsideCellX = (outsideLocalX / s).floor();
      expect(outsideCellX < 0, isTrue); // Correctly identified as outside active grid
    });
  });
}
