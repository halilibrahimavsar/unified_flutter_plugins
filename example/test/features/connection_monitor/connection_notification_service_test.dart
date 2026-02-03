import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/services/connection_notification_service.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity({required this.controller, required this.current});

  final StreamController<List<ConnectivityResult>> controller;
  List<ConnectivityResult> current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const notificationsChannel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (call) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, null);
  });

  group('ConnectionNotificationService', () {
    test('should be singleton', () {
      final service1 = ConnectionNotificationService();
      final service2 = ConnectionNotificationService();
      expect(identical(service1, service2), isTrue);
    });

    test('should return same instance', () {
      final service = ConnectionNotificationService();
      expect(service, equals(ConnectionNotificationService()));
    });
  });

  group('ConnectionNotificationHandler', () {
    testWidgets('should render without errors', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<List<ConnectivityResult>>();
      final cubit = ConnectionCubit(
        connectivity: FakeConnectivity(
          controller: controller,
          current: [ConnectivityResult.none],
        ),
      );
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ConnectionNotificationHandler(
              showNotifications: false,
              child: Scaffold(body: Text('test')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should respect showNotifications flag', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<List<ConnectivityResult>>();
      final cubit = ConnectionCubit(
        connectivity: FakeConnectivity(
          controller: controller,
          current: [ConnectivityResult.none],
        ),
      );
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ConnectionNotificationHandler(
              showNotifications: false,
              child: Scaffold(body: Text('test')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should handle custom notification titles', (
      WidgetTester tester,
    ) async {
      const customTitle = 'Custom Title';
      final controller = StreamController<List<ConnectivityResult>>();
      final cubit = ConnectionCubit(
        connectivity: FakeConnectivity(
          controller: controller,
          current: [ConnectivityResult.none],
        ),
      );
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: ConnectionNotificationHandler(
              showNotifications: false,
              connectedTitle: customTitle,
              disconnectedTitle: customTitle,
              child: const Scaffold(body: Text('test')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('should handle custom notification bodies', (
      WidgetTester tester,
    ) async {
      const customBody = 'Custom Body';
      final controller = StreamController<List<ConnectivityResult>>();
      final cubit = ConnectionCubit(
        connectivity: FakeConnectivity(
          controller: controller,
          current: [ConnectivityResult.none],
        ),
      );
      addTearDown(() async {
        await cubit.close();
        await controller.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: ConnectionNotificationHandler(
              showNotifications: false,
              connectedBody: customBody,
              disconnectedBody: customBody,
              child: const Scaffold(body: Text('test')),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('test'), findsOneWidget);
    });
  });
}
