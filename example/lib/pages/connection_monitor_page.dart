import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_state.dart';
import 'package:unified_flutter_features/features/connection_monitor/widgets/connection_indicator_widget.dart';
import 'package:unified_flutter_features/features/connection_monitor/services/connection_notification_service.dart';

class ConnectionMonitorPage extends StatelessWidget {
  const ConnectionMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectionCubit(),
      child: Builder(
        builder: (context) => ConnectionNotificationHandler(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Connection Monitor'),
              actions: [
                BlocBuilder<ConnectionCubit, MyConnectionState>(
                  builder: (context, state) {
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getStatusColor(state.status),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: BlocBuilder<ConnectionCubit, MyConnectionState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bağlantı Bilgileri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                  'Durum:', _getStatusText(state.status)),
                              _buildInfoRow('Mesaj:', state.message ?? 'Yok'),
                              _buildInfoRow(
                                'Son Kontrol:',
                                state.lastChecked != null
                                    ? '${state.lastChecked!.hour.toString().padLeft(2, '0')}:'
                                        '${state.lastChecked!.minute.toString().padLeft(2, '0')}:'
                                        '${state.lastChecked!.second.toString().padLeft(2, '0')}'
                                    : 'Henüz kontrol edilmedi',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Örnek Widget Kullanımları',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ConnectionIndicatorWidget(
                            connectionState: state,
                            connectedWidget: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 4),
                                  Text(
                                    'Aktif',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                            disconnectedWidget: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text('Koptu',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                            checkingWidget: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 4),
                                  Text('Kontrol'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'check_button',
                  onPressed: () {
                    context.read<ConnectionCubit>().manualCheck();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kontrol Et'),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'clear_button',
                  onPressed: () {
                    ConnectionNotificationService().clearAllNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Tüm bildirimler temizlendi')),
                    );
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Bildirimleri Temizle'),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'permission_button',
                  onPressed: () async {
                    final granted =
                        await ConnectionNotificationService().requestPermission();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted
                              ? 'Bildirim izni verildi'
                              : 'Bildirim izni verilmedi',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('Bildirim İzni'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Bağlı';
      case ConnectionStatus.disconnected:
        return 'Bağlantı Yok';
      case ConnectionStatus.checking:
        return 'Kontrol Ediliyor';
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.disconnected:
        return Colors.red;
      case ConnectionStatus.checking:
        return Colors.orange;
    }
  }
}
