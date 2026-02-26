import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/constants/slider_config.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/models/slider_models.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/dynamic_slider.dart';

void main() {
  testWidgets('Submenu items are clickable and trigger callbacks', (
    WidgetTester tester,
  ) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: SliderConfig.animationDuration,
    );
    addTearDown(controller.dispose);

    String? selectedSub;

    final subMenuItems = {
      SliderState.transactions: [
        SubMenuItem(
          icon: Icons.history,
          label: 'Geçmiş',
          onTap: () => selectedSub = 'Geçmiş',
        ),
        SubMenuItem(
          icon: Icons.pending,
          label: 'Bekleyen',
          onTap: () => selectedSub = 'Bekleyen',
        ),
      ],
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: DynamicSlider(
                controller: controller,
                subMenuItems: subMenuItems,
              ),
            ),
          ),
        ),
      ),
    );

    // Navigate to transactions state (0.5 value)
    await controller.animateTo(0.5);
    await tester.pumpAndSettle();

    // Verify 'Geçmiş' is visible
    expect(find.text('Geçmiş'), findsOneWidget);

    // Tap on 'Geçmiş'
    // It should be item 1 in the carousel (item 0 is the state title)
    // The carousel is 168 high, items are 42 high.
    // Centered item (index 0) is at the knob.
    // Item 1 is below it.
    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();

    expect(selectedSub, 'Geçmiş');

    // Tap on 'Bekleyen'
    expect(find.text('Bekleyen'), findsOneWidget);
    await tester.tap(find.text('Bekleyen'));
    await tester.pumpAndSettle();

    expect(selectedSub, 'Bekleyen');
  });
}
