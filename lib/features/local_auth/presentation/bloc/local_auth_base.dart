abstract class LocalAuthEvent {
  const LocalAuthEvent();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAuthEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class LocalAuthState {
  const LocalAuthState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAuthState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
