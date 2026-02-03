import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_state.dart';

class ConnectionNotificationService {
  static final ConnectionNotificationService _instance =
      ConnectionNotificationService._internal();
  factory ConnectionNotificationService() => _instance;
  ConnectionNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermissionsIfNeeded();

    _initialized = true;
  }

  Future<void> _requestPermissionsIfNeeded() async {
    final androidNotifications =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidNotifications?.requestNotificationsPermission();

    final iosNotifications =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosNotifications?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macosNotifications =
        _notifications.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    await macosNotifications?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Bildirime tıklandı: ${response.payload}');
  }

  Future<void> showConnectedNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'connection_monitor',
      'Bağlantı Bildirimleri',
      channelDescription: 'İnternet bağlantı durumu bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      color: Colors.green,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      1,
      title ?? 'İnternet Bağlantısı Aktif',
      body ?? 'Cihazınız internete bağlı',
      platformDetails,
      payload: payload,
    );
  }

  Future<void> showDisconnectedNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'connection_monitor',
      'Bağlantı Bildirimleri',
      channelDescription: 'İnternet bağlantı durumu bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.red,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      2,
      title ?? 'İnternet Bağlantısı Kesildi',
      body ?? 'Cihazınız internete bağlı değil',
      platformDetails,
      payload: payload,
    );
  }

  Future<void> clearConnectedNotification() async {
    await _notifications.cancel(1);
  }

  Future<void> clearDisconnectedNotification() async {
    await _notifications.cancel(2);
  }

  Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }
}

class ConnectionNotificationHandler extends StatefulWidget {
  final Widget child;
  final bool showNotifications;
  final String? connectedTitle;
  final String? connectedBody;
  final String? disconnectedTitle;
  final String? disconnectedBody;

  const ConnectionNotificationHandler({
    super.key,
    required this.child,
    this.showNotifications = true,
    this.connectedTitle,
    this.connectedBody,
    this.disconnectedTitle,
    this.disconnectedBody,
  });

  @override
  State<ConnectionNotificationHandler> createState() =>
      _ConnectionNotificationHandlerState();
}

class _ConnectionNotificationHandlerState
    extends State<ConnectionNotificationHandler> {
  final ConnectionNotificationService _notificationService =
      ConnectionNotificationService();
  MyConnectionState? lastState;

  @override
  void initState() {
    super.initState();
    if (widget.showNotifications) {
      _notificationService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionCubit, MyConnectionState>(
      listener: (context, state) {
        if (!widget.showNotifications) return;

        if (lastState != null && lastState!.status == state.status) return;

        switch (state.status) {
          case ConnectionStatus.connected:
            _notificationService.clearDisconnectedNotification();
            _notificationService.showConnectedNotification(
              title: widget.connectedTitle,
              body: widget.connectedBody,
            );
            break;

          case ConnectionStatus.disconnected:
            _notificationService.clearConnectedNotification();
            _notificationService.showDisconnectedNotification(
              title: widget.disconnectedTitle,
              body: widget.disconnectedBody,
            );
            break;

          case ConnectionStatus.checking:
            break;
        }

        lastState = state;
      },
      child: widget.child,
    );
  }
}
