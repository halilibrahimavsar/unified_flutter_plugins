import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_flutter_features/features/local_auth/data/secure_local_auth_repository.dart';

void main() {
  test('SecureLocalAuthRepository can be created with SharedPreferences',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final repo = SecureLocalAuthRepository(prefs: prefs);

    expect(repo, isA<SecureLocalAuthRepository>());
  });

  test('SecureLocalAuthRepository persists non-sensitive settings in prefs',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final repo = SecureLocalAuthRepository(prefs: prefs);

    await repo.setBiometricEnabled(true);
    await repo.setPrivacyGuardEnabled(false);
    await repo.setBackgroundLockTimeoutSeconds(30);

    expect(await repo.isBiometricEnabled(), isTrue);
    expect(await repo.isPrivacyGuardEnabled(), isFalse);
    expect(await repo.getBackgroundLockTimeoutSeconds(), 30);
  });
}
