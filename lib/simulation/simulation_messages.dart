import 'dart:isolate';

/// Messages sent from UI Thread to Simulation Worker Isolate
sealed class SimulationCommand {}

class StartSimulationMessage extends SimulationCommand {
  final int intervalMs;
  StartSimulationMessage({required this.intervalMs});
}

class PauseSimulationMessage extends SimulationCommand {}

class StepForwardMessage extends SimulationCommand {}

class StepBackwardMessage extends SimulationCommand {}

class SetSpeedMessage extends SimulationCommand {
  final int intervalMs;
  SetSpeedMessage({required this.intervalMs});
}

class ResizeGridMessage extends SimulationCommand {
  final int width;
  final int height;
  ResizeGridMessage({required this.width, required this.height});
}

class RandomizeGridMessage extends SimulationCommand {
  final double density;
  RandomizeGridMessage({this.density = 0.16});
}

class ClearGridMessage extends SimulationCommand {}

class SetCellMessage extends SimulationCommand {
  final int x;
  final int y;
  final int state;
  SetCellMessage({required this.x, required this.y, required this.state});
}

class SetRuleMessage extends SimulationCommand {
  final String ruleName;
  final String expression;
  final List<int>? survive;
  final List<int>? birth;
  final bool isTotalistic;

  SetRuleMessage({
    required this.ruleName,
    required this.expression,
    this.survive,
    this.birth,
    this.isTotalistic = false,
  });
}

/// Messages sent from Simulation Worker Isolate to UI Thread
sealed class SimulationEvent {}

class IsolateHandshakeMessage extends SimulationEvent {
  final SendPort commandPort;
  IsolateHandshakeMessage({required this.commandPort});
}

class SimulationFrameMessage extends SimulationEvent {
  final TransferableTypedData transferableData;
  final int width;
  final int height;
  final int generation;
  final int aliveCount;
  final int stepDurationUs;
  final bool canStepBack;

  SimulationFrameMessage({
    required this.transferableData,
    required this.width,
    required this.height,
    required this.generation,
    required this.aliveCount,
    required this.stepDurationUs,
    required this.canStepBack,
  });
}
