abstract class LocalAuthRepository {
  Future<bool> isBiometricAvailable();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);

  Future<bool> isPinSet();
  Future<void> savePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> deletePin();

  Future<bool> authenticateWithBiometrics({String? reason});

  Future<bool> isPrivacyGuardEnabled();
  Future<void> setPrivacyGuardEnabled(bool enabled);

  Future<int> getBackgroundLockTimeoutSeconds();
  Future<void> setBackgroundLockTimeoutSeconds(int seconds);

  Future<int?> getLastBackgroundTime();
  Future<void> setLastBackgroundTime(int timestampMillis);
  Future<void> clearLastBackgroundTime();

  Future<int?> getLockoutEndTime();
  Future<int> getLockoutLevel();
  Future<void> saveLockoutState(int level, int endTime);
  Future<void> clearLockoutState();
}
