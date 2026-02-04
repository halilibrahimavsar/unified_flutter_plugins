// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features_example/main.dart';

void main() {
  testWidgets('Demo app renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const UnifiedFeaturesDemoApp());

    expect(find.text('Unified Features Demo'), findsOneWidget);
    expect(find.text('Shared Features'), findsOneWidget);
    expect(find.text('Buton Galerisi'), findsOneWidget);
    expect(find.text('Tarih Seç'), findsOneWidget);
    expect(find.text('Tarih Aralığı'), findsOneWidget);
    expect(find.text('Dialog'), findsOneWidget);
    expect(find.text('Metin Giriş'), findsOneWidget);
    expect(find.text('Yükle'), findsOneWidget);
    expect(find.text('Başarılı'), findsOneWidget);
    expect(find.text('Hata'), findsOneWidget);
    expect(find.text('Onay Dialog'), findsOneWidget);
    expect(find.text('Bilgi'), findsOneWidget);
  });
}
