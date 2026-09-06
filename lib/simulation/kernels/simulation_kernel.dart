import 'dart:typed_data';

abstract class SimulationKernel {
  String get name;

  /// Executes one simulation generation step from [current] into [next].
  /// Returns total number of alive cells in [next].
  int step(Uint8List current, Uint8List next, int width, int height);
}
