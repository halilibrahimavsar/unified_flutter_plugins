import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connection_state.dart';

class ConnectionCubit extends Cubit<MyConnectionState> {
  final Connectivity _connectivity;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectionCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const MyConnectionState(status: ConnectionStatus.checking)) {
    _initializeConnectionCheck();
  }

  void _initializeConnectionCheck() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _handleConnectivityChange(results);
    });

    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleConnectivityChange(results);
    } catch (e) {
      emit(
        state.copyWith(
          status: ConnectionStatus.disconnected,
          message: 'Bağlantı kontrolü yapılamadı: ${e.toString()}',
          lastChecked: DateTime.now(),
        ),
      );
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.mobile,
    );

    if (hasConnection) {
      emit(
        state.copyWith(
          status: ConnectionStatus.connected,
          message: 'İnternet bağlantısı aktif',
          lastChecked: DateTime.now(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ConnectionStatus.disconnected,
          message: 'İnternet bağlantısı yok',
          lastChecked: DateTime.now(),
        ),
      );
    }
  }

  Future<void> manualCheck() async {
    emit(state.copyWith(status: ConnectionStatus.checking));
    await checkInitialConnection();
  }

  String getConnectionTypeString(List<ConnectivityResult> results) {
    if (results.isEmpty) return 'Bilinmiyor';

    final types = <String>[];
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
          types.add('WiFi');
          break;
        case ConnectivityResult.ethernet:
          types.add('Ethernet');
          break;
        case ConnectivityResult.mobile:
          types.add('Mobil');
          break;
        case ConnectivityResult.bluetooth:
          types.add('Bluetooth');
          break;
        case ConnectivityResult.vpn:
          types.add('VPN');
          break;
        case ConnectivityResult.other:
          types.add('Diğer');
          break;
        case ConnectivityResult.none:
          types.add('Yok');
          break;
      }
    }

    return types.join(', ');
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
