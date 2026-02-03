import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/shared_features/shared_features.dart';

void main() {
  testWidgets('IboDatePicker returns quick option and normalizes date', (
    WidgetTester tester,
  ) async {
    final selected = DateTime(2024, 4, 20, 15, 45);
    DateTime? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await IboDatePicker.pickDate(
                  context,
                  helpText: 'Tarih Seç',
                  quickOptions: [
                    IboDateQuickOption(label: 'Bugün', date: selected),
                  ],
                  normalizeToStartOfDay: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Bugün'), findsOneWidget);
    await tester.tap(find.text('Bugün'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.year, 2024);
    expect(result!.month, 4);
    expect(result!.day, 20);
    expect(result!.hour, 0);
    expect(result!.minute, 0);
  });
}
