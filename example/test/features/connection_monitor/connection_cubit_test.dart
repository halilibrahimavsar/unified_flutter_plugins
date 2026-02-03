import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_state.dart';

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

void main() {
  test('ConnectionCubit maps connectivity types to labels', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.wifi, ConnectivityResult.mobile],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(
      cubit.getConnectionTypeString([
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
        ConnectivityResult.vpn,
      ]),
      'WiFi, Mobil, VPN',
    );

    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit reacts to connectivity changes', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.none],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.status, ConnectionStatus.disconnected);

    fake.current = [ConnectivityResult.wifi];
    controller.add(fake.current);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.status, ConnectionStatus.connected);

    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit manualCheck emits checking then final state', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.none],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final statuses = <ConnectionStatus>[];
    final sub = cubit.stream.listen((state) {
      statuses.add(state.status);
    });

    await Future<void>.delayed(const Duration(milliseconds: 1));
    statuses.clear();

    fake.current = [ConnectivityResult.wifi];
    await cubit.manualCheck();
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(statuses.first, ConnectionStatus.checking);
    expect(statuses.last, ConnectionStatus.connected);
    expect(fake.checkCount, greaterThanOrEqualTo(2));

    await sub.cancel();
    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit handles ethernet connectivity', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.ethernet],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.status, ConnectionStatus.connected);
    expect(
      cubit.getConnectionTypeString([ConnectivityResult.ethernet]),
      'Ethernet',
    );

    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit handles multiple connectivity types', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
        ConnectivityResult.mobile
      ],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.status, ConnectionStatus.connected);
    expect(
      cubit.getConnectionTypeString([
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
        ConnectivityResult.mobile,
        ConnectivityResult.bluetooth,
      ]),
      'WiFi, Ethernet, Mobil, Bluetooth',
    );

    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit handles connection check errors', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.none],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.status, ConnectionStatus.disconnected);
    expect(cubit.state.message, isNotNull);

    await cubit.close();
    await controller.close();
  });

  test('ConnectionCubit maintains last checked timestamp', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    final fake = FakeConnectivity(
      controller: controller,
      current: [ConnectivityResult.wifi],
    );

    final cubit = ConnectionCubit(connectivity: fake);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state.lastChecked, isNotNull);
    expect(
        cubit.state.lastChecked!
            .isBefore(DateTime.now().add(const Duration(seconds: 1))),
        isTrue);

    await cubit.close();
    await controller.close();
  });
}
