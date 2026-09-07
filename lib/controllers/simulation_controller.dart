import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/cell_shape.dart';
import '../models/preset_rule.dart';
import '../rule_editor/services/rule_storage_service.dart';
import '../simulation/simulation_isolate_worker.dart';
import '../simulation/simulation_messages.dart';

class SimulationController extends ChangeNotifier {
  // Isolate state
  Isolate? _workerIsolate;
  ReceivePort? _uiReceivePort;
  SendPort? _workerCommandPort;

  // Grid dimensions
  int width = 128;
  int height = 96;

  // Simulation metrics
  int generation = 0;
  int aliveCount = 0;
  int stepDurationUs = 0;
  bool isRunning = false;
  bool canStepBack = false;

  // Controls
  int stepIntervalMs = 30;
  int maxGenerations = 1000;
  PresetRule activePreset = PresetRule.presets[0];
  List<PresetRule> availablePresets = [...PresetRule.presets];
  String customRuleName = "Custom";
  String customRuleExpression = "";
  bool isCustomRule = false;

  CellShape cellShape = CellShape.square;
  double cellPadding = 0.08;
  Color aliveColor = const Color(0xFF10B981);
  bool isRecording = false;

  // Texture state
  ui.Image? currentImage;
  Uint8List? rawBuffer;
  bool _isDecodingFrame = false;

  // Viewport navigation
  double zoom = 1.0;
  Offset panOffset = Offset.zero;
  int? hoveredCellX;
  int? hoveredCellY;

  // Telemetry
  double currentFps = 60.0;
  DateTime _lastFrameTime = DateTime.now();

  double get density =>
      width * height > 0 ? (aliveCount / (width * height)) * 100.0 : 0.0;

  SimulationController() {
    refreshPresets();
    _startIsolate();
  }

  /// Discovers and loads all valid JSON rules from assets/rules/ into availablePresets.
  void refreshPresets() {
    try {
      final storage = RuleStorageService();
      final validRules = storage.loadValidRules();
      if (validRules.isNotEmpty) {
        final List<PresetRule> loaded = [];
        final Set<String> ids = {};

        for (final rule in validRules) {
          final matchingPreset = PresetRule.presets.where(
            (p) => p.name.toLowerCase() == rule.name.toLowerCase(),
          );
          if (matchingPreset.isNotEmpty) {
            loaded.add(matchingPreset.first);
            ids.add(matchingPreset.first.id);
          } else {
            var baseId = rule.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
            if (baseId.isEmpty) baseId = 'rule';
            var id = baseId;
            var counter = 1;
            while (ids.contains(id)) {
              id = '${baseId}_$counter';
              counter++;
            }
            ids.add(id);
            loaded.add(
              PresetRule(
                id: id,
                name: rule.name,
                description: rule.name,
                expression: rule.expression,
                survive: const [],
                birth: const [],
                isTotalistic: false,
              ),
            );
          }
        }
        availablePresets = loaded;
        if (!isCustomRule && !availablePresets.any((p) => p.id == activePreset.id)) {
          activePreset = availablePresets.first;
        }
        notifyListeners();
      }
    } catch (_) {
      // Fallback to static presets
    }
  }

  Future<void> _startIsolate() async {
    _uiReceivePort = ReceivePort();
    _workerIsolate = await Isolate.spawn(
      simulationIsolateEntryPoint,
      _uiReceivePort!.sendPort,
    );

    _uiReceivePort!.listen((message) {
      if (message is IsolateHandshakeMessage) {
        _workerCommandPort = message.commandPort;
      } else if (message is SimulationFrameMessage) {
        _onFrameReceived(message);
      }
    });
  }

  void _onFrameReceived(SimulationFrameMessage frame) {
    // Backpressure: drop intermediate frame decode if UI is still decoding previous frame
    if (_isDecodingFrame) return;
    _isDecodingFrame = true;

    final rawBytes = frame.transferableData.materialize().asUint8List();
    rawBuffer = rawBytes;
    width = frame.width;
    height = frame.height;
    generation = frame.generation;
    aliveCount = frame.aliveCount;
    stepDurationUs = frame.stepDurationUs;
    canStepBack = frame.canStepBack;

    // Check max generations stop condition
    if (maxGenerations > 0 && generation >= maxGenerations && isRunning) {
      pause();
    }

    // Measure FPS
    final now = DateTime.now();
    final elapsedMs = now.difference(_lastFrameTime).inMilliseconds;
    if (elapsedMs > 0) {
      final instantFps = 1000.0 / elapsedMs;
      currentFps = (currentFps * 0.85) + (instantFps * 0.15); // Smooth FPS
    }
    _lastFrameTime = now;

    // Convert flat state buffer into 32-bit RGBA pixel array
    final totalCells = width * height;
    final rgba = Uint8List(totalCells * 4);
    for (int i = 0; i < totalCells && i < rawBytes.length; i++) {
      final val = rawBytes[i];
      final offset = i * 4;
      if (val > 0) {
        rgba[offset] = 255;
        rgba[offset + 1] = 255;
        rgba[offset + 2] = 255;
        rgba[offset + 3] = 255;
      } else {
        rgba[offset] = 0;
        rgba[offset + 1] = 0;
        rgba[offset + 2] = 0;
        rgba[offset + 3] = 255;
      }
    }

    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (image) {
        final oldImage = currentImage;
        currentImage = image;
        oldImage?.dispose();
        _isDecodingFrame = false;
        notifyListeners();
      },
    );
  }

  // Playback actions
  void play() {
    isRunning = true;
    _workerCommandPort?.send(StartSimulationMessage(intervalMs: stepIntervalMs));
    notifyListeners();
  }

  void pause() {
    isRunning = false;
    _workerCommandPort?.send(PauseSimulationMessage());
    notifyListeners();
  }

  void togglePlayPause() {
    if (isRunning) {
      pause();
    } else {
      play();
    }
  }

  void stepForward() {
    pause();
    _workerCommandPort?.send(StepForwardMessage());
  }

  void stepBackward() {
    pause();
    _workerCommandPort?.send(StepBackwardMessage());
  }

  void setSpeed(int intervalMs) {
    stepIntervalMs = intervalMs.clamp(10, 500);
    _workerCommandPort?.send(SetSpeedMessage(intervalMs: stepIntervalMs));
    notifyListeners();
  }

  void setMaxGenerations(int maxGen) {
    maxGenerations = maxGen;
    notifyListeners();
  }

  void resizeGrid(int newWidth, int newHeight) {
    if (newWidth <= 0 || newHeight <= 0) return;
    width = newWidth.clamp(16, 2048);
    height = newHeight.clamp(16, 2048);
    _workerCommandPort?.send(ResizeGridMessage(width: width, height: height));
    resetZoomAndPan();
    notifyListeners();
  }

  void randomizeGrid([double density = 0.16]) {
    _workerCommandPort?.send(RandomizeGridMessage(density: density));
  }

  void resetGrid() {
    _workerCommandPort?.send(ClearGridMessage());
  }

  void setCell(int x, int y, int state) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      if (rawBuffer != null && (y * width + x) < rawBuffer!.length) {
        rawBuffer![y * width + x] = state;
      }
      _workerCommandPort?.send(SetCellMessage(x: x, y: y, state: state));
    }
  }

  void selectPreset(PresetRule preset) {
    activePreset = preset;
    isCustomRule = false;
    _workerCommandPort?.send(
      SetRuleMessage(
        ruleName: preset.name,
        expression: preset.expression,
        survive: preset.survive,
        birth: preset.birth,
        isTotalistic: preset.isTotalistic,
      ),
    );
    notifyListeners();
  }

  void applyCustomRule(String name, String expression) {
    customRuleName = name;
    customRuleExpression = expression;
    isCustomRule = true;
    _workerCommandPort?.send(
      SetRuleMessage(
        ruleName: name,
        expression: expression,
        isTotalistic: false,
      ),
    );
    refreshPresets();
    notifyListeners();
  }

  void setCellShape(CellShape shape) {
    cellShape = shape;
    notifyListeners();
  }

  void setCellPadding(double padding) {
    cellPadding = padding.clamp(0.0, 0.45);
    notifyListeners();
  }

  void setAliveColor(Color color) {
    aliveColor = color;
    notifyListeners();
  }

  void toggleRecording() {
    isRecording = !isRecording;
    notifyListeners();
  }

  // Viewport interactions
  void setZoom(double newZoom) {
    zoom = newZoom.clamp(0.2, 20.0);
    notifyListeners();
  }

  void zoomIn() => setZoom(zoom * 1.25);
  void zoomOut() => setZoom(zoom / 1.25);

  void setPan(Offset delta) {
    panOffset += delta;
    notifyListeners();
  }

  void resetZoomAndPan() {
    zoom = 1.0;
    panOffset = Offset.zero;
    notifyListeners();
  }

  void updateHoverCoord(int? x, int? y) {
    if (hoveredCellX != x || hoveredCellY != y) {
      hoveredCellX = x;
      hoveredCellY = y;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _workerCommandPort?.send(PauseSimulationMessage());
    _workerIsolate?.kill(priority: Isolate.immediate);
    _uiReceivePort?.close();
    currentImage?.dispose();
    super.dispose();
  }
}
