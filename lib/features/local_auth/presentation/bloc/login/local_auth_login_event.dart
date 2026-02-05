import '../local_auth_base.dart';

abstract class LocalAuthLoginEvent extends LocalAuthEvent {
  const LocalAuthLoginEvent();
}

class LoadLoginPolicyEvent extends LocalAuthLoginEvent {}

class VerifyPinLoginEvent extends LocalAuthLoginEvent {
  final String pin;

  const VerifyPinLoginEvent({required this.pin});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyPinLoginEvent &&
          runtimeType == other.runtimeType &&
          pin == other.pin;

  @override
  int get hashCode => pin.hashCode;
}

class BiometricAuthLoginEvent extends LocalAuthLoginEvent {}

class CheckLockoutEvent extends LocalAuthLoginEvent {}
