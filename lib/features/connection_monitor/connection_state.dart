enum ConnectionStatus { connected, disconnected, checking }

class MyConnectionState {
  final ConnectionStatus status;
  final String? message;
  final DateTime? lastChecked;

  const MyConnectionState({
    required this.status,
    this.message,
    this.lastChecked,
  });

  MyConnectionState copyWith({
    ConnectionStatus? status,
    String? message,
    DateTime? lastChecked,
  }) {
    return MyConnectionState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyConnectionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message &&
          lastChecked == other.lastChecked;

  @override
  int get hashCode => status.hashCode ^ message.hashCode ^ lastChecked.hashCode;

  @override
  String toString() =>
      'MyConnectionState(status: $status, message: $message, lastChecked: $lastChecked)';
}
