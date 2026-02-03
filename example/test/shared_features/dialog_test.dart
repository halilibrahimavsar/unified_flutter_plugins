import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/shared_features/shared_features.dart';

void main() {
  testWidgets('IboDialog.showConfirmation returns true on confirm', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await IboDialog.showConfirmation(
                  context,
                  'Onay',
                  'Devam edilsin mi?',
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

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('IboDialog.showConfirmation returns false on cancel', (
    WidgetTester tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await IboDialog.showConfirmation(
                  context,
                  'Onay',
                  'Devam edilsin mi?',
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

    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('IboDialog.showTextInput returns entered text', (
    WidgetTester tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await IboDialog.showTextInput(
                  context,
                  'Metin',
                  'Adınız',
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

    await tester.enterText(find.byType(TextField), 'Ada');
    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();

    expect(result, 'Ada');
  });

  testWidgets('IboDialog.showLoadingDialog shows and dismisses', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await IboDialog.showLoadingDialog(
                  context,
                  message: 'Yükleniyor...',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Yükleniyor...'), findsOneWidget);

    final context = tester.element(find.byType(Scaffold));
    IboDialog.dismissLoadingDialog(context);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
