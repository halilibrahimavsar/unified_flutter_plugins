import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unified_flutter_features/features/local_auth/data/local_auth_repository.dart';
import '../utils/local_auth_utils.dart';
import '../constants/local_auth_constants.dart';

class LocalAuthBackgroundLock extends StatefulWidget {
  final Widget child;
  final LocalAuthRepository repository;
  final bool enabled;
  final bool allowPinFallback;
  final int? timeoutSeconds;
  final String biometricReason;
  final Duration animationDuration;

  const LocalAuthBackgroundLock({
    super.key,
    required this.child,
    required this.repository,
    this.enabled = true,
    this.allowPinFallback = true,
    this.timeoutSeconds,
    this.biometricReason = LocalAuthConstants.defaultBiometricReason,
    this.animationDuration = LocalAuthConstants.defaultAnimationDuration,
  });

  @override
  State<LocalAuthBackgroundLock> createState() =>
      _LocalAuthBackgroundLockState();
}

class _LocalAuthBackgroundLockState extends State<LocalAuthBackgroundLock>
    with WidgetsBindingObserver {
  bool _locked = false;
  bool _authInProgress = false;
  String? _errorMessage;
  bool _pinFallbackInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOnResume();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enabled) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _recordBackgroundTime();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _checkOnResume();
    }
  }

  Future<int> _resolveTimeoutSeconds() async {
    final resolved = widget.timeoutSeconds ??
        await widget.repository.getBackgroundLockTimeoutSeconds();
    return resolved < 0 ? 0 : resolved;
  }

  Future<void> _recordBackgroundTime() async {
    final timeout = await _resolveTimeoutSeconds();
    if (timeout <= 0) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await widget.repository.setLastBackgroundTime(now);
  }

  Future<void> _checkOnResume() async {
    if (_locked) return;

    if (!widget.enabled) {
      await widget.repository.clearLastBackgroundTime();
      return;
    }

    final timeout = await _resolveTimeoutSeconds();
    if (timeout <= 0) {
      await widget.repository.clearLastBackgroundTime();
      return;
    }

    final lastBackground = await widget.repository.getLastBackgroundTime();
    if (lastBackground == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = (now - lastBackground) ~/ 1000;

    if (elapsedSeconds < timeout) {
      await widget.repository.clearLastBackgroundTime();
      return;
    }

    final requirementsValid =
        await LocalAuthUtils.validateBiometricRequirements(widget.repository);
    if (!requirementsValid) {
      await widget.repository.clearLastBackgroundTime();
      return;
    }

    if (!mounted) return;
    setState(() {
      _locked = true;
      _errorMessage = null;
    });

    await _promptBiometric();
  }

  Future<void> _promptBiometric() async {
    if (_authInProgress) return;

    setState(() {
      _authInProgress = true;
      _errorMessage = null;
    });

    final success = await widget.repository.authenticateWithBiometrics(
      reason: widget.biometricReason,
    );

    if (!mounted) return;

    if (success) {
      await widget.repository.clearLastBackgroundTime();
      setState(() {
        _locked = false;
        _authInProgress = false;
      });
    } else {
      setState(() {
        _authInProgress = false;
        _errorMessage = 'Biyometrik doğrulama başarısız';
      });
    }
  }

  Future<void> _promptPinFallback() async {
    if (_pinFallbackInProgress) return;

    final isPinSet = await widget.repository.isPinSet();
    if (!isPinSet) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Önce PIN belirlemelisiniz';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _pinFallbackInProgress = true;
      _errorMessage = null;
    });

    final pin = await _showPinDialog(context);
    if (pin == null || pin.isEmpty) {
      if (!mounted) return;
      setState(() {
        _pinFallbackInProgress = false;
      });
      return;
    }

    final isValid = await widget.repository.verifyPin(pin);
    if (!mounted) return;

    if (isValid) {
      await widget.repository.clearLastBackgroundTime();
      setState(() {
        _locked = false;
        _pinFallbackInProgress = false;
      });
    } else {
      setState(() {
        _pinFallbackInProgress = false;
        _errorMessage = 'PIN doğrulama başarısız';
      });
    }
  }

  Future<String?> _showPinDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(LocalAuthConstants.pinDialogTitle),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: LocalAuthConstants.pinLength,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(LocalAuthConstants.pinLength),
            ],
            decoration: const InputDecoration(
              labelText: LocalAuthConstants.pinLabelText,
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(LocalAuthConstants.cancelButtonText),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text(LocalAuthConstants.verifyButtonText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: _LockedOverlay(
                key: ValueKey<bool>(_locked),
                errorMessage: _errorMessage,
                isLoading: _authInProgress,
                onRetry: _promptBiometric,
                showPinFallback: widget.allowPinFallback,
                onPinFallback: _promptPinFallback,
                pinFallbackBusy: _pinFallbackInProgress,
              ),
            ),
          ),
      ],
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onRetry;
  final bool showPinFallback;
  final VoidCallback onPinFallback;
  final bool pinFallbackBusy;

  const _LockedOverlay({
    super.key,
    required this.errorMessage,
    required this.isLoading,
    required this.onRetry,
    required this.showPinFallback,
    required this.onPinFallback,
    required this.pinFallbackBusy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message =
        errorMessage ?? 'Devam etmek için biyometrik doğrulama yapın';

    return Material(
      color: Colors.black
          .withValues(alpha: LocalAuthConstants.backgroundLockOpacity),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: LocalAuthConstants.backgroundLockMaxWidth.toDouble()),
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Doğrulama Gerekli',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : onRetry,
                        icon: const Icon(Icons.fingerprint_rounded),
                        label: Text(isLoading ? 'Doğrulanıyor...' : 'Doğrula'),
                      ),
                      if (showPinFallback) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: pinFallbackBusy ? null : onPinFallback,
                          child: Text(
                            pinFallbackBusy ? 'Bekleyin...' : 'PIN ile giriş',
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
