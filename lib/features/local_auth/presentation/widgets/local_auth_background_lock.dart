import 'package:flutter/material.dart';
import 'package:unified_flutter_features/features/local_auth/data/local_auth_repository.dart';

class LocalAuthBackgroundLock extends StatefulWidget {
  final Widget child;
  final LocalAuthRepository repository;
  final bool enabled;
  final int? timeoutSeconds;
  final String biometricReason;
  final Duration animationDuration;
  final Curve animationCurve;

  const LocalAuthBackgroundLock({
    super.key,
    required this.child,
    required this.repository,
    this.enabled = true,
    this.timeoutSeconds,
    this.biometricReason = 'Authenticate to continue',
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
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

    final isPinSet = await widget.repository.isPinSet();
    final isBioEnabled = await widget.repository.isBiometricEnabled();
    final isBioAvailable = await widget.repository.isBiometricAvailable();

    if (!isPinSet || !isBioEnabled || !isBioAvailable) {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              switchInCurve: widget.animationCurve,
              switchOutCurve: widget.animationCurve,
              child: _LockedOverlay(
                key: ValueKey<bool>(_locked),
                errorMessage: _errorMessage,
                isLoading: _authInProgress,
                onRetry: _promptBiometric,
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

  const _LockedOverlay({
    super.key,
    required this.errorMessage,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = errorMessage ??
        'Devam etmek için biyometrik doğrulama yapın';

    return Material(
      color: Colors.black.withOpacity(0.55),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
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
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : onRetry,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(isLoading ? 'Doğrulanıyor...' : 'Doğrula'),
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
