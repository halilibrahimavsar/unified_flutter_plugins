abstract class LocalAuthLoginEvent {
  const LocalAuthLoginEvent();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAuthLoginEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
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
