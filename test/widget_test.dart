import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cell_automata/main.dart';
import 'package:cell_automata/ui/header/studio_window_header.dart';

void main() {
  testWidgets('CaStudioApp smoke test and title bar render',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CaStudioApp());
    await tester.pump();

    // Verify key UI elements render
    expect(find.text('CA STUDIO'), findsOneWidget);
    expect(find.text('simulation workstation'), findsNothing);
    expect(find.text('RUN SIMULATION'), findsOneWidget);
    expect(find.text('RULES ENGINE'), findsOneWidget);
    expect(find.text('CELL GRID GEOMETRY'), findsOneWidget);

    // 1. Verify TOTALISTIC badge is removed
    expect(find.text('TOTALISTIC'), findsNothing);

    // 2. Verify simplified rule name
    expect(find.text("Conway's Life"), findsWidgets);

    // 3. Verify Cell Color controls exist
    expect(find.text('Cell Alive Color'), findsOneWidget);
    expect(find.byTooltip('Choose Custom Color'), findsOneWidget);

    // 4. Verify Total Generations controls exist
    expect(find.text('Total Generations'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('1,000'), findsOneWidget);
    expect(find.text('Unlimited (∞)'), findsOneWidget);

    // 5. Verify Grid presets with larger fonts exist
    expect(find.text('64×48'), findsOneWidget);
    expect(find.text('1200×800'), findsOneWidget);

    // 6. Verify Zoom controls exist and Center Fit is removed
    expect(find.text('Center Fit'), findsNothing);
    expect(find.byTooltip('Zoom In'), findsOneWidget);
    // Verify removed parameter badges (survive, birth, states)
    expect(find.textContaining('SURVIVE:'), findsNothing);
    expect(find.textContaining('BIRTH:'), findsNothing);
    expect(find.textContaining('STATES:'), findsNothing);

    // Verify grid dimension label swapped to Width x Height
    expect(find.text('Grid Dimensions (Width × Height in cells)'), findsOneWidget);

    // Verify step interval ms is NOT in section header line
    expect(find.text('30ms'), findsNothing);

    // Verify rule name and gen count appear in StudioWindowHeader
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.text("Conway's Life"),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.text('Gen: '),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.text('Live: '),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.text('FPS: '),
    ), findsOneWidget);
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.text('60'),
    ), findsOneWidget);

    // Verify Rule Editor button label
    expect(find.text('Rule Editor'), findsOneWidget);
    expect(find.textContaining('Configure ->'), findsNothing);

    // Verify cell count badge in Cell Grid Geometry
    expect(find.text('12288 cells'), findsOneWidget);

    // Verify hex color code is removed
    expect(find.text('#10B981'), findsNothing);

    // Verify ms/step is removed from footer
    expect(find.textContaining('ms/step'), findsNothing);

    // Verify mouse pointer cursor coordinate readout is removed from header
    expect(find.descendant(
      of: find.byType(StudioWindowHeader),
      matching: find.textContaining('('),
    ), findsNothing);
  });

  testWidgets('Interactive controls: change color, total generations, and zoom',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const CaStudioApp());
    await tester.pump();

    // Scroll to and tap "500" total generations chip
    await tester.ensureVisible(find.text('500'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('500'));
    await tester.pump();

    expect(find.text('500 max'), findsOneWidget);

    // Tap Zoom In
    await tester.tap(find.byTooltip('Zoom In'));
    await tester.pump();

    expect(find.text('125%'), findsOneWidget);
  });
}
