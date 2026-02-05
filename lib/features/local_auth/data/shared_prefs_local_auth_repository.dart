import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_auth_repository.dart';

class SharedPrefsLocalAuthRepository implements LocalAuthRepository {
  static const _keyPinHash = 'local_auth_pin_hash';
  static const _keyPinSalt = 'local_auth_pin_salt';
  static const _keyBiometricEnabled = 'local_auth_biometric_enabled';
  static const _keyPrivacyGuardEnabled = 'local_auth_privacy_guard_enabled';
  static const _keyBackgroundLockTimeout =
      'local_auth_background_lock_timeout';
  static const _keyLastBackgroundAt = 'local_auth_last_background_at';
  static const _keyLockoutEnd = 'local_auth_lockout_end';
  static const _keyLockoutLevel = 'local_auth_lockout_level';

  final SharedPreferences _prefs;
  final LocalAuthentication _auth;

  SharedPrefsLocalAuthRepository({
    required SharedPreferences prefs,
    LocalAuthentication? auth,
  })  : _prefs = prefs,
        _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isBiometricAvailable() async {
    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    return canCheck && supported;
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
  }

  @override
  Future<bool> isPinSet() async {
    final hash = _prefs.getString(_keyPinHash);
    final salt = _prefs.getString(_keyPinSalt);
    return hash != null && salt != null;
  }

  @override
  Future<void> savePin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _prefs.setString(_keyPinSalt, salt);
    await _prefs.setString(_keyPinHash, hash);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final salt = _prefs.getString(_keyPinSalt);
    final hash = _prefs.getString(_keyPinHash);
    if (salt == null || hash == null) return false;
    return _hashPin(pin, salt) == hash;
  }

  @override
  Future<void> deletePin() async {
    await _prefs.remove(_keyPinSalt);
    await _prefs.remove(_keyPinHash);
  }

  @override
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    final available = await isBiometricAvailable();
    if (!available) return false;
    return _auth.authenticate(
      localizedReason: reason ?? 'Authenticate to continue',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        useErrorDialogs: true,
      ),
    );
  }

  @override
  Future<bool> isPrivacyGuardEnabled() async {
    return _prefs.getBool(_keyPrivacyGuardEnabled) ?? true;
  }

  @override
  Future<void> setPrivacyGuardEnabled(bool enabled) async {
    await _prefs.setBool(_keyPrivacyGuardEnabled, enabled);
  }

  @override
  Future<int> getBackgroundLockTimeoutSeconds() async {
    return _prefs.getInt(_keyBackgroundLockTimeout) ?? 0;
  }

  @override
  Future<void> setBackgroundLockTimeoutSeconds(int seconds) async {
    await _prefs.setInt(_keyBackgroundLockTimeout, seconds);
  }

  @override
  Future<int?> getLastBackgroundTime() async {
    return _prefs.getInt(_keyLastBackgroundAt);
  }

  @override
  Future<void> setLastBackgroundTime(int timestampMillis) async {
    await _prefs.setInt(_keyLastBackgroundAt, timestampMillis);
  }

  @override
  Future<void> clearLastBackgroundTime() async {
    await _prefs.remove(_keyLastBackgroundAt);
  }

  @override
  Future<int?> getLockoutEndTime() async {
    return _prefs.getInt(_keyLockoutEnd);
  }

  @override
  Future<int> getLockoutLevel() async {
    return _prefs.getInt(_keyLockoutLevel) ?? 0;
  }

  @override
  Future<void> saveLockoutState(int level, int endTime) async {
    await _prefs.setInt(_keyLockoutLevel, level);
    await _prefs.setInt(_keyLockoutEnd, endTime);
  }

  @override
  Future<void> clearLockoutState() async {
    await _prefs.remove(_keyLockoutLevel);
    await _prefs.remove(_keyLockoutEnd);
  }

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
