import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/bloc/local_auth_status.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/bloc/login/local_auth_login_state.dart';

void main() {
  test('LocalAuthLoginState.copyWith preserves nullable fields when omitted',
      () {
    const state = LocalAuthLoginState(
      authStatus: AuthStatus.lockedOut,
      message: 'locked',
      lockoutEndTime: 123456,
    );

    final updated = state.copyWith(authStatus: AuthStatus.initial);

    expect(updated.lockoutEndTime, 123456);
    expect(updated.message, 'locked');
  });

  test('LocalAuthLoginState.copyWith can explicitly clear nullable fields', () {
    const state = LocalAuthLoginState(
      authStatus: AuthStatus.lockedOut,
      message: 'locked',
      lockoutEndTime: 123456,
    );

    final updated = state.copyWith(
      authStatus: AuthStatus.initial,
      message: null,
      lockoutEndTime: null,
    );

    expect(updated.lockoutEndTime, isNull);
    expect(updated.message, isNull);
  });
}
