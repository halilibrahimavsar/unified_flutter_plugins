import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/constants/slider_config.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/models/slider_models.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/widgets/dynamic_slider_button.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/widgets/slider_knob.dart';

void main() {
  testWidgets('DynamicSlider taps update controller and state callback', (
    WidgetTester tester,
  ) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: SliderConfig.animationDuration,
    );
    addTearDown(controller.dispose);

    SliderState? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: DynamicSlider(
              controller: controller,
              onStateTap: (state) => tapped = state,
            ),
          ),
        ),
      ),
    );

    expect(controller.value, 0.0);

    await tester.tap(find.text('İŞLEMLER'));
    await tester.pump();
    await tester.pump(SliderConfig.animationDuration);
    await tester.pumpAndSettle();

    expect(controller.value, closeTo(0.5, 0.05));

    await tester.tap(find.byType(SliderKnob));
    await tester.pump();

    expect(tapped, SliderState.transactions);

    controller.stop();
  });

  testWidgets('DynamicSlider shows mini buttons overlay and triggers action', (
    WidgetTester tester,
  ) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: SliderConfig.animationDuration,
    );
    addTearDown(controller.dispose);

    var miniTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: DynamicSlider(
                controller: controller,
                miniButtons: {
                  SliderState.savedMoney: [
                    MiniButtonData(
                      icon: Icons.add,
                      label: 'Ekle',
                      color: Colors.green,
                      onTap: () => miniTapped = true,
                    ),
                  ],
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(SliderKnob));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('Ekle'), findsOneWidget);

    await tester.tap(find.text('Ekle'));
    await tester.pumpAndSettle();

    expect(miniTapped, isTrue);
    expect(find.text('Ekle'), findsNothing);
  });
}
