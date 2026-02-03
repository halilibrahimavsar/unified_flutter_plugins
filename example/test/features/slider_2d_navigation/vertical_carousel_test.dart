import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/constants/slider_config.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/widgets/vertical_carousel.dart';

void main() {
  group('VerticalCarousel', () {
    late FixedExtentScrollController controller;

    setUp(() {
      controller = FixedExtentScrollController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders with required parameters',
        (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
        Text('Item 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.byType(ListWheelScrollView), findsOneWidget);
    });

    testWidgets('calls onItemTapped when item is tapped',
        (WidgetTester tester) async {
      int? tappedIndex;
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
        Text('Item 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
              onItemTapped: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Item 2'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('animates to tapped item', (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
        Text('Item 3'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );

      // Initially at item 0
      expect(controller.selectedItem, equals(0));

      // Tap item 2
      await tester.tap(find.text('Item 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Should animate to item 1
      expect(controller.selectedItem, equals(1));
    });

    testWidgets('uses custom physics when provided',
        (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
      ];

      const customPhysics = NeverScrollableScrollPhysics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
              physics: customPhysics,
            ),
          ),
        ),
      );

      final listWheelScrollView =
          tester.widget<ListWheelScrollView>(find.byType(ListWheelScrollView));
      expect(listWheelScrollView.physics, equals(customPhysics));
    });

    testWidgets('uses default physics when not provided',
        (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
            ),
          ),
        ),
      );

      final listWheelScrollView =
          tester.widget<ListWheelScrollView>(find.byType(ListWheelScrollView));
      expect(listWheelScrollView.physics, isA<FixedExtentScrollPhysics>());
    });

    testWidgets('handles empty children list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: const [],
            ),
          ),
        ),
      );

      expect(find.byType(ListWheelScrollView), findsOneWidget);
      expect(find.text('Item'), findsNothing);
    });

    testWidgets('centers items correctly', (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
            ),
          ),
        ),
      );

      // Check that items are centered within their container
      final centerWidgets = tester.widgetList<Center>(find.byType(Center));
      expect(centerWidgets.length, equals(2));
    });

    testWidgets('has correct height from SliderConfig',
        (WidgetTester tester) async {
      const testChildren = [Text('Item 1')];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.descendant(
        of: find.byType(VerticalCarousel),
        matching: find.byType(SizedBox),
      ));
      final outerSizedBox = sizedBoxes.firstWhere(
        (box) => box.height == SliderConfig.carouselTotalHeight,
      );

      expect(outerSizedBox.height, equals(SliderConfig.carouselTotalHeight));
      expect(outerSizedBox.width, isNull); // Width should be unconstrained
    });

    testWidgets('handles onItemTapped null gracefully',
        (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
              onItemTapped: null,
            ),
          ),
        ),
      );

      // Should not crash when tapped without callback
      expect(() async {
        await tester.tap(find.text('Item 2'));
        await tester.pump();
      }, returnsNormally);
    });

    testWidgets('uses correct ListWheelScrollView configuration',
        (WidgetTester tester) async {
      const testChildren = [
        Text('Item 1'),
        Text('Item 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VerticalCarousel(
              controller: controller,
              children: testChildren,
            ),
          ),
        ),
      );

      final listWheelScrollView =
          tester.widget<ListWheelScrollView>(find.byType(ListWheelScrollView));

      expect(listWheelScrollView.itemExtent, isNotNull);
      expect(listWheelScrollView.perspective, equals(0.009));
      expect(listWheelScrollView.diameterRatio, equals(1.5));
      expect(listWheelScrollView.controller, equals(controller));
    });
  });
}
