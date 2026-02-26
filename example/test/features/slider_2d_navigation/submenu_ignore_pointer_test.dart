import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/constants/slider_config.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/models/slider_models.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/dynamic_slider.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/widgets/vertical_carousel.dart';

void main() {
  testWidgets('Submenu carousel is not ignored', (
    WidgetTester tester,
  ) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: SliderConfig.animationDuration,
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: DynamicSlider(
                controller: controller,
                subMenuItems: {
                  SliderState.transactions: [
                    SubMenuItem(icon: Icons.abc, label: 'Test', onTap: () {}),
                  ],
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Navigate to state with submenu
    await controller.animateTo(0.5);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify VerticalCarousel exists
    expect(find.byType(VerticalCarousel), findsOneWidget);

    // Verify NO IgnorePointer is wrapping it in SliderKnob
    // Check if any ancestor of VerticalCarousel is IgnorePointer(ignoring: true)
    final ignored = tester
        .widgetList<IgnorePointer>(find.ancestor(
            of: find.byType(VerticalCarousel),
            matching: find.byType(IgnorePointer)))
        .any((ip) => ip.ignoring);

    expect(ignored, isFalse, reason: 'VerticalCarousel should not be ignored');
  });
}
