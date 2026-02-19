import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_state.dart';
import 'package:unified_flutter_features/features/connection_monitor/services/connection_snackbar_handler.dart';
import 'package:unified_flutter_features/features/connection_monitor/widgets/connection_indicator_widget.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity({required this.controller, required this.current});

  final StreamController<List<ConnectivityResult>> controller;
  List<ConnectivityResult> current;
  int checkCount = 0;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    checkCount++;
    return current;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestConnectionCubit extends ConnectionCubit {
  TestConnectionCubit({required super.connectivity});

  int manualCheckCount = 0;

  void emitState(ConnectionMonitorState state) => emit(state);

  @override
  Future<void> checkInitialConnection() async {}

  @override
  Future<void> manualCheck() async {
    manualCheckCount++;
    emitState(
      const ConnectionMonitorState(
        status: ConnectionStatus.disconnected,
        message: 'İnternet bağlantısı yok',
      ),
    );
  }
}

void main() {
  testWidgets('ConnectionIndicatorWidget swaps widgets by status', (
    WidgetTester tester,
  ) async {
    ConnectionMonitorState current = const ConnectionMonitorState(
      status: ConnectionStatus.connected,
      message: 'Aktif',
    );
    late void Function(void Function()) setState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return ConnectionIndicatorWidget(
              connectionState: current,
              connectedWidget: const Text('connected'),
              disconnectedWidget: const Text('disconnected'),
              checkingWidget: const Text('checking'),
            );
          },
        ),
      ),
    );

    expect(find.text('connected'), findsOneWidget);

    current =
        const ConnectionMonitorState(status: ConnectionStatus.disconnected);
    setState(() {});
    await tester.pump();

    expect(find.text('disconnected'), findsOneWidget);

    current = const ConnectionMonitorState(status: ConnectionStatus.checking);
    setState(() {});
    await tester.pump();

    expect(find.text('checking'), findsOneWidget);
  });

  testWidgets('DefaultConnectionIndicator shows correct icons', (
    WidgetTester tester,
  ) async {
    ConnectionMonitorState current = const ConnectionMonitorState(
      status: ConnectionStatus.connected,
    );
    late void Function(void Function()) setState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return DefaultConnectionIndicator(connectionState: current);
          },
        ),
      ),
    );

    expect(find.byIcon(Icons.wifi), findsOneWidget);

    current =
        const ConnectionMonitorState(status: ConnectionStatus.disconnected);
    setState(() {});
    await tester.pump();

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    current = const ConnectionMonitorState(status: ConnectionStatus.checking);
    setState(() {});
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'ConnectionSnackbarHandler shows snackbars and retry triggers check', (
    WidgetTester tester,
  ) async {
    // Create a mock connectivity to track manual check calls
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.none],
    );
    final cubit = TestConnectionCubit(connectivity: fake);

    addTearDown(() {
      cubit.close();
      controller.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectionCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: ConnectionSnackbarHandler(
              child: Text('body'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    cubit.emitState(
      const ConnectionMonitorState(
        status: ConnectionStatus.disconnected,
        message: 'İnternet bağlantısı yok',
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Should show disconnected snackbar
    expect(find.textContaining('İnternet bağlantısı yok'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Test retry functionality - tap the action button
    final beforeCheck = cubit.manualCheckCount;

    // Find and tap the SnackBarAction button
    final retryButton = find.byType(SnackBarAction);
    expect(retryButton, findsOneWidget);
    final action = tester.widget<SnackBarAction>(retryButton);
    action.onPressed.call();
    await tester.pump(const Duration(milliseconds: 100));

    // Should have triggered a manual check
    expect(cubit.manualCheckCount, greaterThan(beforeCheck));
  });
}
