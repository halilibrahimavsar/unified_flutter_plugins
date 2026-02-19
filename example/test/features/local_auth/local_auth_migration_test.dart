import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_flutter_features/features/local_auth/data/local_auth_migration.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/constants/local_auth_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final secureStorageData = <String, String>{};

  setUp(() {
    secureStorageData.clear();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final args =
          (call.arguments as Map<dynamic, dynamic>?)?.cast<String, dynamic>() ??
              <String, dynamic>{};
      final key = args['key'] as String?;

      switch (call.method) {
        case 'read':
          return key == null ? null : secureStorageData[key];
        case 'write':
          if (key != null) {
            secureStorageData[key] = (args['value'] as String?) ?? '';
          }
          return null;
        case 'delete':
          if (key != null) {
            secureStorageData.remove(key);
          }
          return null;
        case 'readAll':
          return Map<String, String>.from(secureStorageData);
        case 'deleteAll':
          secureStorageData.clear();
          return null;
        case 'containsKey':
          return key != null && secureStorageData.containsKey(key);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  test('migrates legacy pin values and removes legacy prefs', () async {
    SharedPreferences.setMockInitialValues({
      LocalAuthConstants.pinHashKey: 'legacy-hash',
      LocalAuthConstants.pinSaltKey: 'legacy-salt',
    });

    final prefs = await SharedPreferences.getInstance();

    const secureStorage = const FlutterSecureStorage();
    final migrated =
        await LocalAuthMigration.migratePinFromSharedPreferencesToSecureStorage(
      prefs: prefs,
      secureStorage: secureStorage,
      removeLegacyValues: true,
    );

    expect(migrated, isTrue);
    expect(secureStorageData[LocalAuthConstants.pinHashKey], 'legacy-hash');
    expect(secureStorageData[LocalAuthConstants.pinSaltKey], 'legacy-salt');
    expect(prefs.getString(LocalAuthConstants.pinHashKey), isNull);
    expect(prefs.getString(LocalAuthConstants.pinSaltKey), isNull);
  });

  test('does not migrate when secure storage already has pin values', () async {
    SharedPreferences.setMockInitialValues({
      LocalAuthConstants.pinHashKey: 'legacy-hash',
      LocalAuthConstants.pinSaltKey: 'legacy-salt',
    });
    secureStorageData[LocalAuthConstants.pinHashKey] = 'secure-hash';
    secureStorageData[LocalAuthConstants.pinSaltKey] = 'secure-salt';

    final prefs = await SharedPreferences.getInstance();

    const secureStorage = const FlutterSecureStorage();
    final migrated =
        await LocalAuthMigration.migratePinFromSharedPreferencesToSecureStorage(
      prefs: prefs,
      secureStorage: secureStorage,
    );

    expect(migrated, isFalse);
    expect(secureStorageData[LocalAuthConstants.pinHashKey], 'secure-hash');
    expect(secureStorageData[LocalAuthConstants.pinSaltKey], 'secure-salt');
    expect(prefs.getString(LocalAuthConstants.pinHashKey), 'legacy-hash');
    expect(prefs.getString(LocalAuthConstants.pinSaltKey), 'legacy-salt');
  });

  test('does not migrate when legacy values are missing', () async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();

    const secureStorage = const FlutterSecureStorage();
    final migrated =
        await LocalAuthMigration.migratePinFromSharedPreferencesToSecureStorage(
      prefs: prefs,
      secureStorage: secureStorage,
    );

    expect(migrated, isFalse);
    expect(secureStorageData, isEmpty);
  });
}
