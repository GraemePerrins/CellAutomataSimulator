import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'kernels/ast_evaluator_kernel.dart';
import 'kernels/simulation_kernel.dart';
import 'kernels/totalistic_kernel.dart';
import 'simulation_messages.dart';

void simulationIsolateEntryPoint(SendPort uiSendPort) {
  final isolateWorker = SimulationIsolateWorker(uiSendPort);
  isolateWorker.initialize();
}

class SimulationIsolateWorker {
  final SendPort uiSendPort;
  final ReceivePort commandPort = ReceivePort();

  int width = 128;
  int height = 96;
  int generation = 0;
  int intervalMs = 30;
  bool isRunning = false;
  Timer? _stepTimer;

  late Uint8List currentBuffer;
  late Uint8List nextBuffer;

  // History ring buffer for rewind/step-back support (stores up to 50 states)
  static const int maxHistory = 50;
  final List<Uint8List> _history = [];

  SimulationKernel kernel = TotalisticKernel.conway();
  final Random rng = Random();

  SimulationIsolateWorker(this.uiSendPort) {
    currentBuffer = Uint8List(width * height);
    nextBuffer = Uint8List(width * height);
    _randomize(0.16);
  }

  void initialize() {
    // Complete handshake
    uiSendPort.send(IsolateHandshakeMessage(commandPort: commandPort.sendPort));

    // Emit initial frame
    _emitCurrentFrame(stepDurationUs: 0);

    // Listen for incoming UI commands
    commandPort.listen((message) {
      if (message is SimulationCommand) {
        _handleCommand(message);
      }
    });
  }

  void _handleCommand(SimulationCommand command) {
    switch (command) {
      case StartSimulationMessage(:final intervalMs):
        this.intervalMs = intervalMs;
        _start();
      case PauseSimulationMessage():
        _pause();
      case StepForwardMessage():
        _pause();
        _stepOnce();
      case StepBackwardMessage():
        _pause();
        _stepBack();
      case SetSpeedMessage(:final intervalMs):
        this.intervalMs = intervalMs;
        if (isRunning) {
          _restartTimer();
        }
      case ResizeGridMessage(:final width, :final height):
        _resize(width, height);
      case RandomizeGridMessage(:final density):
        _randomize(density);
      case ClearGridMessage():
        _clear();
      case SetCellMessage(:final x, :final y, :final state):
        _setCell(x, y, state);
      case SetRuleMessage(
          :final ruleName,
          :final expression,
          :final survive,
          :final birth,
          :final isTotalistic
        ):
        _setRule(
          ruleName: ruleName,
          expression: expression,
          survive: survive,
          birth: birth,
          isTotalistic: isTotalistic,
        );
    }
  }

  void _start() {
    isRunning = true;
    _restartTimer();
  }

  void _pause() {
    isRunning = false;
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _restartTimer() {
    _stepTimer?.cancel();
    final clampedInterval = max(10, intervalMs);
    _stepTimer = Timer.periodic(Duration(milliseconds: clampedInterval), (_) {
      _stepOnce();
    });
  }

  void _stepOnce() {
    final stopwatch = Stopwatch()..start();

    // Push current state into history ring buffer
    if (_history.length >= maxHistory) {
      _history.removeAt(0);
    }
    _history.add(Uint8List.fromList(currentBuffer));

    // Execute kernel step
    final aliveCount = kernel.step(currentBuffer, nextBuffer, width, height);

    // Swap buffers
    final temp = currentBuffer;
    currentBuffer = nextBuffer;
    nextBuffer = temp;

    generation++;
    stopwatch.stop();

    _emitCurrentFrame(
      aliveCount: aliveCount,
      stepDurationUs: stopwatch.elapsedMicroseconds,
    );
  }

  void _stepBack() {
    if (_history.isNotEmpty) {
      final prevState = _history.removeLast();
      currentBuffer.setAll(0, prevState);
      if (generation > 0) generation--;
      _emitCurrentFrame(stepDurationUs: 0);
    }
  }

  void _resize(int newWidth, int newHeight) {
    if (newWidth <= 0 || newHeight <= 0) return;
    final clampedWidth = newWidth.clamp(16, 2048);
    final clampedHeight = newHeight.clamp(16, 2048);

    final newCurrent = Uint8List(clampedWidth * clampedHeight);
    final newNext = Uint8List(clampedWidth * clampedHeight);

    // Copy overlapping region
    final minW = min(width, clampedWidth);
    final minH = min(height, clampedHeight);
    for (int y = 0; y < minH; y++) {
      for (int x = 0; x < minW; x++) {
        newCurrent[y * clampedWidth + x] = currentBuffer[y * width + x];
      }
    }

    width = clampedWidth;
    height = clampedHeight;
    currentBuffer = newCurrent;
    nextBuffer = newNext;
    _history.clear();

    _emitCurrentFrame(stepDurationUs: 0);
  }

  void _randomize(double density) {
    int count = 0;
    final total = width * height;
    final clampedDensity = density.clamp(0.01, 0.99);

    for (int i = 0; i < total; i++) {
      final val = rng.nextDouble() < clampedDensity ? 1 : 0;
      currentBuffer[i] = val;
      if (val == 1) count++;
    }

    generation = 0;
    _history.clear();
    _emitCurrentFrame(aliveCount: count, stepDurationUs: 0);
  }

  void _clear() {
    currentBuffer.fillRange(0, currentBuffer.length, 0);
    generation = 0;
    _history.clear();
    _emitCurrentFrame(aliveCount: 0, stepDurationUs: 0);
  }

  void _setCell(int x, int y, int state) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      currentBuffer[y * width + x] = state > 0 ? 1 : 0;
      _emitCurrentFrame(stepDurationUs: 0);
    }
  }

  void _setRule({
    required String ruleName,
    required String expression,
    List<int>? survive,
    List<int>? birth,
    bool isTotalistic = false,
  }) {
    if (isTotalistic && survive != null && birth != null) {
      kernel = TotalisticKernel(
        name: ruleName,
        survive: survive,
        birth: birth,
      );
    } else {
      try {
        kernel = AstEvaluatorKernel.fromExpression(ruleName, expression);
      } catch (e) {
        // Fallback to Conway's Life on expression syntax failure
        kernel = TotalisticKernel.conway();
      }
    }
  }

  void _emitCurrentFrame({int? aliveCount, int stepDurationUs = 0}) {
    int count = aliveCount ?? 0;
    if (aliveCount == null) {
      for (int i = 0; i < currentBuffer.length; i++) {
        if (currentBuffer[i] == 1) count++;
      }
    }

    // Zero-copy transfer using TransferableTypedData
    final transferable = TransferableTypedData.fromList([
      Uint8List.fromList(currentBuffer),
    ]);

    uiSendPort.send(
      SimulationFrameMessage(
        transferableData: transferable,
        width: width,
        height: height,
        generation: generation,
        aliveCount: count,
        stepDurationUs: stepDurationUs,
        canStepBack: _history.isNotEmpty,
      ),
    );
  }
}
