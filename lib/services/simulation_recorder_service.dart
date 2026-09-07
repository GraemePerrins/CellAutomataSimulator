import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class SimulationRecorderService {
  Process? _ffmpegProcess;
  IOSink? _ffmpegStdin;
  String? _currentOutputPath;
  int _width = 0;
  int _height = 0;
  int _frameCount = 0;
  bool _isRecording = false;
  Completer<int>? _processExitCompleter;

  bool get isRecording => _isRecording;
  int get frameCount => _frameCount;
  int get recordingWidth => _width;
  int get recordingHeight => _height;
  String? get currentOutputPath => _currentOutputPath;

  /// Sanitizes rule name by removing all whitespace and unsafe filesystem characters.
  /// Example: "Graeme 1" -> "Graeme1"
  static String sanitizeRuleName(String ruleName) {
    var clean = ruleName.replaceAll(RegExp(r'\s+'), '');
    clean = clean.replaceAll(RegExp(r'[/\\:*?"<>|]'), '');
    if (clean.isEmpty) clean = 'Simulation';
    return clean;
  }

  /// Formats date and time as YYYYMMDDHHmm (e.g. 202609071530).
  static String formatTimestamp([DateTime? time]) {
    final now = time ?? DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$y$m$d$h$min';
  }

  /// Generates the target MP4 filename: <RuleNameClean>_<YYYYMMDDHHmm>.mp4
  /// Example: "Graeme 1" -> "Graeme1_202609071530.mp4"
  static String generateFileName(String ruleName, [DateTime? time]) {
    final cleanRule = sanitizeRuleName(ruleName);
    final timestamp = formatTimestamp(time);
    return '${cleanRule}_$timestamp.mp4';
  }

  /// Resolves the assets/recordings directory path.
  static String resolveRecordingsDir({String? customDir}) {
    if (customDir != null) return customDir;
    final currentDir = Directory.current.path;

    // Check if inside CellAutomata root with assets/
    final assetsRec = p.join(currentDir, 'assets', 'recordings');
    if (Directory(p.join(currentDir, 'assets')).existsSync()) {
      return assetsRec;
    }

    // Check if in parent repo directory containing CellAutomata/assets
    final cellAutomataAssetsRec =
        p.join(currentDir, 'CellAutomata', 'assets', 'recordings');
    if (Directory(p.join(currentDir, 'CellAutomata', 'assets')).existsSync()) {
      return cellAutomataAssetsRec;
    }

    // Check parent directory containing assets/
    final parentAssetsRec = p.join(currentDir, '..', 'assets', 'recordings');
    if (Directory(p.join(currentDir, '..', 'assets')).existsSync()) {
      return parentAssetsRec;
    }

    return assetsRec;
  }

  /// Generates a unique file path in targetDir, appending _1, _2 if file exists.
  static String getUniqueFilePath(String targetDir, String baseFileName) {
    var targetFile = File(p.join(targetDir, baseFileName));
    if (!targetFile.existsSync()) {
      return targetFile.path;
    }

    final nameWithoutExt = p.basenameWithoutExtension(baseFileName);
    final ext = p.extension(baseFileName);
    int counter = 1;
    while (targetFile.existsSync()) {
      targetFile = File(p.join(targetDir, '${nameWithoutExt}_$counter$ext'));
      counter++;
    }
    return targetFile.path;
  }

  /// Checks if ffmpeg command is available on the system.
  static Future<bool> isFfmpegAvailable() async {
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Starts recording an MP4 video at width x height with given fps.
  Future<bool> startRecording({
    required String ruleName,
    required int width,
    required int height,
    double fps = 30.0,
    String? outputDirectory,
  }) async {
    if (_isRecording) {
      await stopRecording();
    }

    // Align to even dimensions required for H.264 / yuv420p
    _width = (width ~/ 2) * 2;
    _height = (height ~/ 2) * 2;
    if (_width <= 0 || _height <= 0) {
      throw ArgumentError('Width and height must be positive integers.');
    }

    final targetDir = resolveRecordingsDir(customDir: outputDirectory);
    final dir = Directory(targetDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final baseFileName = generateFileName(ruleName);
    final fullOutputPath = getUniqueFilePath(targetDir, baseFileName);
    _currentOutputPath = fullOutputPath;
    _frameCount = 0;

    final roundedFps = fps.clamp(1.0, 60.0).round();

    final args = [
      '-y',
      '-f',
      'rawvideo',
      '-pix_fmt',
      'rgba',
      '-s',
      '${_width}x$_height',
      '-r',
      '$roundedFps',
      '-i',
      '-',
      '-c:v',
      'libx264',
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      '+faststart',
      fullOutputPath,
    ];

    try {
      final process = await Process.start('ffmpeg', args);
      _ffmpegProcess = process;
      _ffmpegStdin = process.stdin;
      _isRecording = true;
      _processExitCompleter = Completer<int>();

      process.exitCode.then((code) {
        if (!_processExitCompleter!.isCompleted) {
          _processExitCompleter!.complete(code);
        }
      }).catchError((error) {
        if (!_processExitCompleter!.isCompleted) {
          _processExitCompleter!.completeError(error);
        }
      });

      // Capture stderr for diagnostics if process fails
      final stderrBuffer = StringBuffer();
      process.stderr.transform(utf8.decoder).listen((data) {
        stderrBuffer.write(data);
      });

      return true;
    } catch (e) {
      _isRecording = false;
      _currentOutputPath = null;
      rethrow;
    }
  }

  /// Appends an RGBA frame buffer to the recording stream.
  void addFrame(Uint8List rgbaBytes) {
    if (!_isRecording || _ffmpegStdin == null) return;
    final expectedLength = _width * _height * 4;
    if (rgbaBytes.length != expectedLength) {
      debugPrint(
        'Warning: Recording frame dropped due to size mismatch: '
        'expected $expectedLength, got ${rgbaBytes.length}',
      );
      return;
    }

    try {
      _ffmpegStdin!.add(rgbaBytes);
      _frameCount++;
    } catch (e) {
      debugPrint('Error writing frame to ffmpeg stdin: $e');
    }
  }

  /// Stops recording, closes stdin, waits for ffmpeg to finalize the MP4 file,
  /// and returns the saved file path if successful.
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _isRecording = false;

    final outputPath = _currentOutputPath;
    try {
      if (_ffmpegStdin != null) {
        await _ffmpegStdin!.flush();
        await _ffmpegStdin!.close();
        _ffmpegStdin = null;
      }

      if (_processExitCompleter != null) {
        final exitCode = await _processExitCompleter!.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            _ffmpegProcess?.kill(ProcessSignal.sigkill);
            return -1;
          },
        );

        if (exitCode == 0 &&
            outputPath != null &&
            File(outputPath).existsSync()) {
          return outputPath;
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    } finally {
      _ffmpegProcess = null;
      _ffmpegStdin = null;
      _processExitCompleter = null;
    }

    return null;
  }

  /// Cancels recording and deletes any partial output file.
  void cancelRecording() {
    if (!_isRecording) return;
    _isRecording = false;

    try {
      _ffmpegStdin?.close();
      _ffmpegProcess?.kill(ProcessSignal.sigkill);
      if (_currentOutputPath != null) {
        final file = File(_currentOutputPath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    } finally {
      _ffmpegProcess = null;
      _ffmpegStdin = null;
      _currentOutputPath = null;
      _processExitCompleter = null;
    }
  }
}
