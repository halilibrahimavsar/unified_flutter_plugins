import 'package:bloc/bloc.dart';
import 'package:unified_flutter_features/features/local_auth/data/local_auth_repository.dart';
import 'local_auth_login_event.dart';
import 'local_auth_login_state.dart';

class LocalAuthLoginBloc
    extends Bloc<LocalAuthLoginEvent, LocalAuthLoginState> {
  final LocalAuthRepository _repository;

  LocalAuthLoginBloc({required LocalAuthRepository repository})
      : _repository = repository,
        super(const LocalAuthLoginState()) {
    on<LoadLoginPolicyEvent>(_onLoadPolicy);
    on<VerifyPinLoginEvent>(_onVerifyPinLogin);
    on<BiometricAuthLoginEvent>(_onBiometricAuthLogin);
    on<CheckLockoutEvent>(_onCheckLockout);
  }

  Future<void> _onLoadPolicy(
    LoadLoginPolicyEvent event,
    Emitter<LocalAuthLoginState> emit,
  ) async {
    emit(state.copyWith(loadStatus: LoginLoadStatus.loading));
    try {
      final isPinSet = await _repository.isPinSet();
      var isBioEnabled = await _repository.isBiometricEnabled();
      final isAvailable = await _repository.isBiometricAvailable();

      if (!isPinSet && isBioEnabled) {
        await _repository.setBiometricEnabled(false);
        isBioEnabled = false;
      }

      // Also check lockout status on load
      add(CheckLockoutEvent());

      emit(state.copyWith(
        loadStatus: LoginLoadStatus.success,
        isBiometricEnabled: isBioEnabled,
        isBiometricAvailable: isAvailable,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadStatus: LoginLoadStatus.error,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onCheckLockout(
    CheckLockoutEvent event,
    Emitter<LocalAuthLoginState> emit,
  ) async {
    final int? endTime = await _repository.getLockoutEndTime();
    if (endTime == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (endTime > now) {
      emit(state.copyWith(
        authStatus: AuthStatus.lockedOut,
        lockoutEndTime: endTime,
      ));
    } else {
      emit(state.copyWith(
        authStatus: AuthStatus.initial,
        lockoutEndTime: null,
        failedAttempts: 0,
      ));
    }
  }

  Future<void> _onVerifyPinLogin(
    VerifyPinLoginEvent event,
    Emitter<LocalAuthLoginState> emit,
  ) async {
    if (state.authStatus == AuthStatus.lockedOut) return;

    emit(state.copyWith(authStatus: AuthStatus.loading));
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      final isCorrect = await _repository.verifyPin(event.pin);

      if (isCorrect) {
        await _repository.clearLockoutState();
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          failedAttempts: 0,
          lockoutEndTime: null,
        ));
      } else {
        final newAttempts = state.failedAttempts + 1;
        if (newAttempts >= 3) {
          // Calculate lockout
          final level = await _repository.getLockoutLevel();
          final duration = _lockoutDurationSeconds(level);
          final endTime =
              DateTime.now().millisecondsSinceEpoch + (duration * 1000);

          await _repository.saveLockoutState(level + 1, endTime);
          emit(state.copyWith(
            authStatus: AuthStatus.lockedOut,
            lockoutEndTime: endTime,
            failedAttempts: 0,
          ));
        } else {
          emit(state.copyWith(
            authStatus: AuthStatus.failure,
            failedAttempts: newAttempts,
            message: 'Hatalı PIN. Kalan hak: ${3 - newAttempts}',
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
          authStatus: AuthStatus.failure, message: e.toString()));
    }
  }

  Future<void> _onBiometricAuthLogin(
    BiometricAuthLoginEvent event,
    Emitter<LocalAuthLoginState> emit,
  ) async {
    if (state.authStatus == AuthStatus.lockedOut) return;

    final success = await _repository.authenticateWithBiometrics(
      reason: 'Authenticate to continue',
    );
    if (success) {
      await _repository.clearLockoutState();
      emit(state.copyWith(
        authStatus: AuthStatus.authenticated,
        failedAttempts: 0,
        lockoutEndTime: null,
      ));
    }
  }

  int _lockoutDurationSeconds(int level) {
    if (level <= 0) return 30;
    if (level == 1) return 120;
    if (level == 2) return 300;
    return 1000;
  }
}
