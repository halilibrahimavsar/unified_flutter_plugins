import '../local_auth_status.dart';

class LocalAuthLoginState {
  final LoginLoadStatus loadStatus;
  final AuthStatus authStatus;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final String? message;
  final int failedAttempts;
  final int? lockoutEndTime;

  const LocalAuthLoginState({
    this.loadStatus = LoginLoadStatus.initial,
    this.authStatus = AuthStatus.initial,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.message,
    this.failedAttempts = 0,
    this.lockoutEndTime,
  });

  LocalAuthLoginState copyWith({
    LoginLoadStatus? loadStatus,
    AuthStatus? authStatus,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    String? message,
    int? failedAttempts,
    int? lockoutEndTime,
  }) {
    return LocalAuthLoginState(
      loadStatus: loadStatus ?? this.loadStatus,
      authStatus: authStatus ?? this.authStatus,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      message: message,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutEndTime: lockoutEndTime ?? this.lockoutEndTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAuthLoginState &&
          runtimeType == other.runtimeType &&
          loadStatus == other.loadStatus &&
          authStatus == other.authStatus &&
          isBiometricEnabled == other.isBiometricEnabled &&
          isBiometricAvailable == other.isBiometricAvailable &&
          message == other.message &&
          failedAttempts == other.failedAttempts &&
          lockoutEndTime == other.lockoutEndTime;

  @override
  int get hashCode =>
      loadStatus.hashCode ^
      authStatus.hashCode ^
      isBiometricEnabled.hashCode ^
      isBiometricAvailable.hashCode ^
      message.hashCode ^
      failedAttempts.hashCode ^
      lockoutEndTime.hashCode;
}
