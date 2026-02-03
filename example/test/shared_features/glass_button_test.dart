import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/shared_features/shared_features.dart';

void main() {
  testWidgets('IboGlassButton uses custom child and triggers onPressed', (
    WidgetTester tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboGlassButton(
            text: 'Default',
            onPressed: () => taps++,
            child: const Text('Custom'),
          ),
        ),
      ),
    );

    expect(find.text('Custom'), findsOneWidget);
    expect(find.text('Default'), findsNothing);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('IboLoadingButton shows spinner while future completes', (
    WidgetTester tester,
  ) async {
    final completer = Completer<void>();
    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboLoadingButton(
            text: 'Yükle',
            onPressed: () {
              callCount++;
              return completer.future;
            },
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(callCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(callCount, 1);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('IboGlassButton handles null onPressed as disabled', (
    WidgetTester tester,
  ) async {
    var callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboGlassButton(
            text: 'Disabled',
            onPressed: () => callCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(callCount, 1);

    // Test with null onPressed
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboGlassButton(
            text: 'Null Callback',
            onPressed: null,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(find.text('Null Callback'), findsOneWidget);
  });

  testWidgets('IboGlassButton respects custom dimensions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboGlassButton(
            text: 'Custom Size',
            onPressed: () {},
            width: 200,
            height: 80,
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(IboGlassButton));

    expect(size.width, equals(200.0));
    expect(size.height, equals(80.0));
  });

  testWidgets('IboGlassButton respects custom colors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IboGlassButton(
            text: 'Custom Colors',
            onPressed: () {},
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );

    expect(find.text('Custom Colors'), findsOneWidget);
  });
}
