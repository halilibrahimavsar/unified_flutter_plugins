import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:unified_flutter_features/features/local_auth/presentation/bloc/login/local_auth_login_bloc.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/bloc/login/local_auth_login_event.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/bloc/login/local_auth_login_state.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/widgets/local_auth_numpad.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/widgets/local_auth_pin_dots.dart';

class BiometricAuthPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onLogout;

  const BiometricAuthPage({
    super.key,
    required this.onSuccess,
    required this.onLogout,
  });

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;
  String _enteredPin = '';
  Timer? _lockoutTimer;
  int _remainingSeconds = 0;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    context.read<LocalAuthLoginBloc>().add(LoadLoginPolicyEvent());
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimer(int endTime) {
    _lockoutTimer?.cancel();
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((endTime - now) / 1000).ceil();

    if (remaining <= 0) {
      context.read<LocalAuthLoginBloc>().add(CheckLockoutEvent());
      return;
    }

    setState(() => _remainingSeconds = remaining);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
            context.read<LocalAuthLoginBloc>().add(CheckLockoutEvent());
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleKeyPress(String value, bool isLockedOut) {
    // Eğer kilitliyse veya zaten 4 hane girildiyse işlem yapma
    if (isLockedOut || _enteredPin.length >= _pinLength) return;

    HapticFeedback.selectionClick();
    setState(() {
      _enteredPin += value;
    });

    // 4. hane girildiği an doğrulama gönder
    if (_enteredPin.length == _pinLength) {
      context
          .read<LocalAuthLoginBloc>()
          .add(VerifyPinLoginEvent(pin: _enteredPin));
    }
  }

  void _handleDelete(bool isLockedOut) {
    if (isLockedOut || _enteredPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalAuthLoginBloc, LocalAuthLoginState>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.authenticated) {
          HapticFeedback.heavyImpact();
          widget.onSuccess();
        } else if (state.authStatus == AuthStatus.failure) {
          HapticFeedback.vibrate();
          // Önce salla, sallama bitince input'u temizle
          _shakeController
              .forward(from: 0.0)
              .then((_) => setState(() => _enteredPin = ''));
        } else if (state.authStatus == AuthStatus.lockedOut) {
          setState(() => _enteredPin = '');
          if (state.lockoutEndTime != null) {
            _startTimer(state.lockoutEndTime!);
          }
        }

        if (state.loadStatus == LoginLoadStatus.success &&
            state.isBiometricAvailable &&
            state.isBiometricEnabled &&
            state.authStatus == AuthStatus.initial) {
          context.read<LocalAuthLoginBloc>().add(BiometricAuthLoginEvent());
        }
      },
      builder: (context, state) {
        final isLockedOut = state.authStatus == AuthStatus.lockedOut;
        final theme = Theme.of(context);
        final isBiometricReady =
            state.isBiometricAvailable && state.isBiometricEnabled;
        final statusText = _statusText(state, isLockedOut);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Çıkış Yap'),
                style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Icon(Icons.lock_outline_rounded,
                    size: 80, color: theme.primaryColor),
                const SizedBox(height: 20),
                Text(
                  'Hoş Geldiniz',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      statusText,
                      key: ValueKey(statusText),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (isLockedOut ||
                                (state.authStatus == AuthStatus.failure &&
                                    _enteredPin.isEmpty))
                            ? theme.colorScheme.error
                            : theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                        fontWeight:
                            isLockedOut ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                LocalAuthPinDots(
                  length: _pinLength,
                  filled: _enteredPin.length,
                  isError: _isPinError(state),
                  shake: _shakeController,
                  activeColor: theme.primaryColor,
                  inactiveColor: Colors.grey.withOpacity(0.2),
                  errorColor: theme.colorScheme.error,
                ),
                const Spacer(),
                LocalAuthNumpad(
                  isLockedOut: isLockedOut,
                  showBiometric: isBiometricReady,
                  onDigit: (digit) => _handleKeyPress(digit, isLockedOut),
                  onBackspace: () => _handleDelete(isLockedOut),
                  onBiometric: () => context
                      .read<LocalAuthLoginBloc>()
                      .add(BiometricAuthLoginEvent()),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  String _statusText(LocalAuthLoginState state, bool isLockedOut) {
    if (isLockedOut) {
      return 'Çok fazla hatalı deneme. \n$_remainingSeconds saniye bekleyin.';
    }
    if (state.authStatus == AuthStatus.failure) {
      return 'Hatalı PIN, tekrar deneyin';
    }
    return state.message ?? 'Devam etmek için $_pinLength haneli PIN girin';
  }

  bool _isPinError(LocalAuthLoginState state) {
    return state.authStatus == AuthStatus.failure &&
        (_enteredPin.isEmpty || _enteredPin.length == _pinLength);
  }
}
