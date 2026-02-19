import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/shared_features.dart';

void main() {
  testWidgets('IboDateRangePicker returns quick range and expands to full days',
      (
    WidgetTester tester,
  ) async {
    final selectedRange = DateTimeRange(
      start: DateTime(2024, 3, 1, 9, 30),
      end: DateTime(2024, 3, 5, 14, 10),
    );
    DateTimeRange? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await IboDateRangePicker.pickDateRange(
                  context,
                  helpText: 'Tarih Aralığı Seç',
                  quickOptions: [
                    IboDateRangeQuickOption(
                      label: 'Hafta',
                      range: selectedRange,
                    ),
                  ],
                  includeFullDays: true,
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

    expect(find.text('Hafta'), findsOneWidget);
    await tester.tap(find.text('Hafta'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.start, DateTime(2024, 3, 1));
    expect(
      result!.end,
      DateTime(2024, 3, 5, 23, 59, 59, 999),
    );
  });
}
