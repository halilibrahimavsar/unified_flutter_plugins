// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/main.dart';

void main() {
  testWidgets('Demo app renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const UnifiedFeaturesDemoApp());

    expect(find.text('Unified Features Demo'), findsOneWidget);
    expect(find.text('Shared Features'), findsOneWidget);
    expect(find.text('Bağlantı Durumu'), findsOneWidget);
    expect(find.text('Buton Galerisi'), findsOneWidget);
  });
}
