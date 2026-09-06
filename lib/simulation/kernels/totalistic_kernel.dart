import 'dart:typed_data';
import 'simulation_kernel.dart';

class TotalisticKernel implements SimulationKernel {
  @override
  final String name;

  final List<int> survive;
  final List<int> birth;
  final int surviveMask;
  final int birthMask;

  TotalisticKernel({
    required this.name,
    required this.survive,
    required this.birth,
  })  : surviveMask = _buildMask(survive),
        birthMask = _buildMask(birth);

  static int _buildMask(List<int> values) {
    int mask = 0;
    for (final v in values) {
      if (v >= 0 && v <= 8) {
        mask |= (1 << v);
      }
    }
    return mask;
  }

  factory TotalisticKernel.conway() {
    return TotalisticKernel(
      name: "Conway's Life",
      survive: const [2, 3],
      birth: const [3],
    );
  }

  factory TotalisticKernel.highLife() {
    return TotalisticKernel(
      name: "HighLife",
      survive: const [2, 3],
      birth: const [3, 6],
    );
  }

  factory TotalisticKernel.seeds() {
    return TotalisticKernel(
      name: "Seeds",
      survive: const [],
      birth: const [2],
    );
  }

  factory TotalisticKernel.dayAndNight() {
    return TotalisticKernel(
      name: "Day & Night",
      survive: const [3, 4, 6, 7, 8],
      birth: const [3, 6, 7, 8],
    );
  }

  factory TotalisticKernel.briansBrain() {
    return TotalisticKernel(
      name: "Brian's Brain",
      survive: const [],
      birth: const [2],
    );
  }

  @override
  int step(Uint8List current, Uint8List next, int width, int height) {
    int aliveCount = 0;
    final int sMask = surviveMask;
    final int bMask = birthMask;

    for (int y = 0; y < height; y++) {
      final int yUp = (y == 0 ? height - 1 : y - 1) * width;
      final int yMid = y * width;
      final int yDown = (y == height - 1 ? 0 : y + 1) * width;

      for (int x = 0; x < width; x++) {
        final int xLeft = (x == 0 ? width - 1 : x - 1);
        final int xRight = (x == width - 1 ? 0 : x + 1);

        // Moore neighborhood count
        final int neighbors = current[yUp + xLeft] +
            current[yUp + x] +
            current[yUp + xRight] +
            current[yMid + xLeft] +
            current[yMid + xRight] +
            current[yDown + xLeft] +
            current[yDown + x] +
            current[yDown + xRight];

        final int center = current[yMid + x];
        int nextState = 0;

        if (center == 1) {
          if ((sMask & (1 << neighbors)) != 0) {
            nextState = 1;
          }
        } else {
          if ((bMask & (1 << neighbors)) != 0) {
            nextState = 1;
          }
        }

        next[yMid + x] = nextState;
        if (nextState == 1) {
          aliveCount++;
        }
      }
    }

    return aliveCount;
  }
}
