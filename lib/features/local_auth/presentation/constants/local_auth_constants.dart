class LocalAuthConstants {
  LocalAuthConstants._();

  static const int pinLength = 4;
  static const int maxFailedAttempts = 3;
  static const int hapticDelayMs = 150;
  static const int shakeAnimationDuration = 500;
  static const int pinDotSize = 20;
  static const double pinDotSpacing = 12.0;
  static const double numpadButtonSize = 75.0;
  static const double numpadSpacing = 20.0;
  static const double pinDotShadowBlurRadius = 10.0;
  static const double pinDotShadowSpreadRadius = 2.0;
  static const double backgroundLockOpacity = 0.55;
  static const int backgroundLockMaxWidth = 320;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);

  static const String pinHashKey = 'local_auth_pin_hash';
  static const String pinSaltKey = 'local_auth_pin_salt';
  static const String biometricEnabledKey = 'local_auth_biometric_enabled';
  static const String privacyGuardEnabledKey =
      'local_auth_privacy_guard_enabled';
  static const String backgroundLockTimeoutKey =
      'local_auth_background_lock_timeout';
  static const String lastBackgroundAtKey = 'local_auth_last_background_at';
  static const String lockoutEndKey = 'local_auth_lockout_end';
  static const String lockoutLevelKey = 'local_auth_lockout_level';

  static const String defaultBiometricReason = 'Authenticate to continue';
  static const String enableBiometricReason = 'Enable biometric login';
  static const String pinLabelText = 'PIN';
  static const String verifyButtonText = 'Doğrula';
  static const String cancelButtonText = 'Vazgeç';
  static const String pinDialogTitle = 'PIN Doğrulama';

  static const Map<int, int> lockoutDurations = {
    0: 30,
    1: 120,
    2: 300,
    3: 1000,
  };
}
