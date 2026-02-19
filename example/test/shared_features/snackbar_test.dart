import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/core/constants/app_colors.dart';
import 'package:unified_flutter_features/shared_features.dart';

void main() {
  testWidgets('IboSnackbar shows and replaces messages with colors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => IboSnackbar.showSuccess(context, 'Başarılı'),
                  child: const Text('success'),
                ),
                ElevatedButton(
                  onPressed: () => IboSnackbar.showError(context, 'Hata'),
                  child: const Text('error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('success'));
    await tester.pump();

    expect(find.text('Başarılı'), findsOneWidget);
    final successSurface = tester.widget<IboGlassSurface>(
      find.byType(IboGlassSurface),
    );
    expect(successSurface.style.backgroundColor, AppColors.success);

    await tester.tap(find.text('error'));
    await tester.pump();

    expect(find.text('Hata'), findsOneWidget);
    expect(find.text('Başarılı'), findsNothing);
    final errorSurface = tester.widget<IboGlassSurface>(
      find.byType(IboGlassSurface),
    );
    expect(errorSurface.style.backgroundColor, AppColors.error);
  });
}
