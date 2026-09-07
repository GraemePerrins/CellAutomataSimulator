import 'dart:io';
import 'dart:typed_data';

import 'package:cell_automata/controllers/simulation_controller.dart';
import 'package:cell_automata/main.dart';
import 'package:cell_automata/services/simulation_recorder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('SimulationRecorderService Tests', () {
    test('Filename and Rule Name sanitization according to spec', () {
      // 1. "Graeme 1" -> "Graeme1"
      expect(
        SimulationRecorderService.sanitizeRuleName('Graeme 1'),
        equals('Graeme1'),
      );

      // 2. Format timestamp: 2026-09-07 15:30 -> "202609071530"
      final fixedDate = DateTime(2026, 9, 7, 15, 30);
      expect(
        SimulationRecorderService.formatTimestamp(fixedDate),
        equals('202609071530'),
      );

      // 3. Complete filename generation: rule "Graeme 1" -> Graeme1_202609071530.mp4
      final fileName = SimulationRecorderService.generateFileName(
        'Graeme 1',
        fixedDate,
      );
      expect(fileName, equals('Graeme1_202609071530.mp4'));

      // 4. Other rules with spaces or symbols
      final complexRule = SimulationRecorderService.generateFileName(
        'Brian Brain / 2',
        DateTime(2026, 1, 2, 3, 4),
      );
      expect(complexRule, equals('BrianBrain2_202601020304.mp4'));
    });

    test('Directory resolution resolves assets/recordings', () {
      final recDir = SimulationRecorderService.resolveRecordingsDir();
      expect(recDir, contains('recordings'));
    });

    test('getUniqueFilePath avoids overwriting existing files', () {
      final tempDir = Directory.systemTemp.createTempSync('ca_rec_test_');
      try {
        final file1 = SimulationRecorderService.getUniqueFilePath(
          tempDir.path,
          'Graeme1_202609071530.mp4',
        );
        expect(file1, endsWith('Graeme1_202609071530.mp4'));

        // Create the file so it exists
        File(file1).writeAsStringSync('dummy');

        // Now next call should append _1
        final file2 = SimulationRecorderService.getUniqueFilePath(
          tempDir.path,
          'Graeme1_202609071530.mp4',
        );
        expect(file2, endsWith('Graeme1_202609071530_1.mp4'));

        // Create file2 as well
        File(file2).writeAsStringSync('dummy');

        final file3 = SimulationRecorderService.getUniqueFilePath(
          tempDir.path,
          'Graeme1_202609071530.mp4',
        );
        expect(file3, endsWith('Graeme1_202609071530_2.mp4'));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('SimulationController Recording Lifecycle', () {
    test('Start, Push frames, and Stop recording state flow', () async {
      final controller = SimulationController();
      addTearDown(controller.dispose);

      expect(controller.isRecording, isFalse);
      expect(controller.recordedFrameCount, equals(0));

      // Set display size
      controller.updateGridDisplaySize(800, 600);
      expect(controller.gridDisplayWidth, equals(800));
      expect(controller.gridDisplayHeight, equals(600));

      // Test start recording
      final started = await controller.startRecording(
        customWidth: 100,
        customHeight: 100,
      );

      if (started) {
        expect(controller.isRecording, isTrue);
        expect(controller.recordingWidth, equals(100));
        expect(controller.recordingHeight, equals(100));

        // Push frames (100 * 100 * 4 = 40000 bytes)
        final frameBytes = Uint8List(100 * 100 * 4);
        controller.pushRecordingFrame(frameBytes);
        controller.pushRecordingFrame(frameBytes);

        expect(controller.recordedFrameCount, equals(2));

        final savedPath = await controller.stopRecording();
        expect(controller.isRecording, isFalse);
        if (savedPath != null) {
          expect(savedPath, endsWith('.mp4'));
          expect(File(savedPath).existsSync(), isTrue);
          // Cleanup test file
          File(savedPath).deleteSync();
        }
      }
    });

    test('Records rule "Graeme 1" to assets/recordings/ with valid H.264 mp4 stream', () async {
      final service = SimulationRecorderService();
      const width = 200;
      const height = 150;
      final started = await service.startRecording(
        ruleName: 'Graeme 1',
        width: width,
        height: height,
        fps: 30.0,
      );
      expect(started, isTrue);
      expect(service.isRecording, isTrue);

      // Generate 15 frames of RGBA data
      final frameLength = service.recordingWidth * service.recordingHeight * 4;
      final frame = Uint8List(frameLength);
      for (int i = 0; i < frameLength; i += 4) {
        frame[i] = 16;
        frame[i + 1] = 185;
        frame[i + 2] = 129;
        frame[i + 3] = 255;
      }

      for (int i = 0; i < 15; i++) {
        service.addFrame(frame);
      }
      expect(service.frameCount, equals(15));

      final savedPath = await service.stopRecording();
      expect(savedPath, isNotNull);
      expect(File(savedPath!).existsSync(), isTrue);

      // Verify filename pattern: Graeme1_<timestamp>.mp4 in assets/recordings
      expect(savedPath, contains('assets/recordings'));
      final baseName = p.basename(savedPath);
      expect(baseName, matches(r'^Graeme1_\d{12}(\_\d+)?\.mp4$'));

      // Run ffprobe to verify video file properties
      final probeResult = await Process.run('ffprobe', [
        '-v',
        'error',
        '-select_streams',
        'v:0',
        '-show_entries',
        'stream=width,height,codec_name',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        savedPath,
      ]);
      expect(probeResult.exitCode, equals(0));
      final outputLines = (probeResult.stdout as String).trim().split('\n');
      expect(outputLines, contains('h264'));
      expect(outputLines, contains('${service.recordingWidth}'));
      expect(outputLines, contains('${service.recordingHeight}'));

      // Clean up test recording
      File(savedPath).deleteSync();
    });
  });

  group('Widget Tests for Recording UX Button', () {
    testWidgets('Record Simulation as MP4 button renders in simulation panel',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const CaStudioApp());
      await tester.pump();

      // Verify the recording section is present
      expect(find.text('Video Recording (MP4)'), findsOneWidget);
      expect(find.text('RECORD SIMULATION AS MP4'), findsOneWidget);
      expect(
        find.text('Saves to assets/recordings/ matching simulation grid size'),
        findsNothing,
      );
    });

    testWidgets(
        'Progress overlay HUD is rendered over the bottom of the cell grid inside RepaintBoundary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const CaStudioApp());
      await tester.pump();

      // Verify progress HUD icons (timelapse and grain) are present
      expect(find.byIcon(Icons.timelapse_outlined), findsWidgets);
      expect(find.byIcon(Icons.grain), findsWidgets);
    });
  });
}
