import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_flutter_features/shared_features/shared_features.dart';
import 'package:unified_flutter_features/features/local_auth/presentation/local_auth.dart';

/// Local Auth demo page.
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const LocalAuthDemoEntry()),
/// );
/// ```
class LocalAuthDemoEntry extends StatelessWidget {
  const LocalAuthDemoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Local Auth Demo')),
            body: const Center(
              child: Text('SharedPreferences yüklenemedi'),
            ),
          );
        }

        final repo = SharedPrefsLocalAuthRepository(prefs: snapshot.data!);
        return RepositoryProvider<LocalAuthRepository>.value(
          value: repo,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => LocalAuthSettingsBloc(repository: repo)
                  ..add(LoadSettingsEvent()),
              ),
            ],
            child: const LocalAuthDemoPage(),
          ),
        );
      },
    );
  }
}

class LocalAuthDemoPage extends StatelessWidget {
  const LocalAuthDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Local Auth Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ayarlar'),
              Tab(text: 'Akış'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LocalAuthSettingsTab(),
            LocalAuthFlowTab(),
          ],
        ),
      ),
    );
  }
}

class LocalAuthSettingsTab extends StatelessWidget {
  const LocalAuthSettingsTab({super.key});

  static const Map<int, String> _timeoutLabels = {
    0: 'Kapalı',
    30: '30 saniye',
    60: '1 dakika',
    120: '2 dakika',
    300: '5 dakika',
    600: '10 dakika',
  };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalAuthSettingsBloc, LocalAuthSettingsState>(
      listenWhen: (previous, current) =>
          current.message != null && current.message != previous.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        final isError = state.status == SettingsStatus.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                isError ? Theme.of(context).colorScheme.error : null,
          ),
        );
      },
      builder: (context, state) {
        final timeoutValue = _timeoutLabels.containsKey(
          state.backgroundLockTimeoutSeconds,
        )
            ? state.backgroundLockTimeoutSeconds
            : 0;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SettingsSection(
              title: 'PIN Yönetimi',
              subtitle: state.isPinSet
                  ? 'PIN ayarlı'
                  : 'PIN ayarlı değil. Biyometrik için PIN zorunlu.',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (!state.isPinSet)
                    ElevatedButton.icon(
                      onPressed: () => _handleSetPin(context),
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('PIN Belirle'),
                    ),
                  if (state.isPinSet)
                    OutlinedButton.icon(
                      onPressed: () => _handleChangePin(context),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('PIN Değiştir'),
                    ),
                  if (state.isPinSet)
                    TextButton.icon(
                      onPressed: () => _handleDeletePin(context),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('PIN Sil'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Biyometrik Giriş',
              subtitle: state.isBiometricAvailable
                  ? 'Cihaz biyometrik doğrulamayı destekliyor'
                  : 'Bu cihaz biyometrik doğrulamayı desteklemiyor',
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.isBiometricEnabled,
                onChanged: state.isBiometricAvailable
                    ? (value) => context
                        .read<LocalAuthSettingsBloc>()
                        .add(ToggleBiometricEvent(enable: value))
                    : null,
                title: const Text('Biyometrik giriş aktif'),
                subtitle: const Text('Etkinleştirmek için PIN gerekli'),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Privacy Guard',
              subtitle: 'Arka planda içerik bulanıklaştırma',
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.isPrivacyGuardEnabled,
                onChanged: (value) => context
                    .read<LocalAuthSettingsBloc>()
                    .add(TogglePrivacyGuardEvent(enable: value)),
                title: const Text('Privacy Guard aktif'),
              ),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Arka Plan Kilidi',
              subtitle:
                  'Uygulama arka planda beklediğinde süre aşılırsa tekrar '
                  'biyometrik doğrulama ister',
              child: DropdownButtonFormField<int>(
                value: timeoutValue,
                items: _timeoutLabels.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  context
                      .read<LocalAuthSettingsBloc>()
                      .add(UpdateBackgroundLockTimeoutEvent(seconds: value));
                },
                decoration: const InputDecoration(
                  labelText: 'Bekleme süresi',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Not: Arka plan kilidi için PIN ayarlı ve biyometrik giriş açık '
              'olmalıdır.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSetPin(BuildContext context) async {
    final pins = await _showPinDialog(
      context,
      title: 'PIN Belirle',
      labels: const ['PIN', 'PIN (Tekrar)'],
    );
    if (pins == null) return;
    final pin = pins[0];
    final confirm = pins[1];
    if (!_validatePinInputs(context, pins)) return;

    context
        .read<LocalAuthSettingsBloc>()
        .add(SavePinEvent(pin: pin, confirmPin: confirm));
  }

  Future<void> _handleChangePin(BuildContext context) async {
    final pins = await _showPinDialog(
      context,
      title: 'PIN Değiştir',
      labels: const ['Mevcut PIN', 'Yeni PIN', 'Yeni PIN (Tekrar)'],
    );
    if (pins == null) return;
    final currentPin = pins[0];
    final newPin = pins[1];
    final confirm = pins[2];
    if (!_validatePinInputs(context, pins)) return;

    context.read<LocalAuthSettingsBloc>().add(
          ChangePinEvent(
            currentPin: currentPin,
            newPin: newPin,
            confirmPin: confirm,
          ),
        );
  }

  Future<void> _handleDeletePin(BuildContext context) async {
    final pins = await _showPinDialog(
      context,
      title: 'PIN Sil',
      labels: const ['Mevcut PIN'],
    );
    if (pins == null) return;
    final currentPin = pins[0];
    if (!_validatePinInputs(context, pins)) return;

    context
        .read<LocalAuthSettingsBloc>()
        .add(DeletePinEvent(currentPin: currentPin));
  }

  bool _validatePinInputs(BuildContext context, List<String> pins) {
    final invalid = pins.any((pin) => pin.length != 4);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN 4 haneli olmalı')),
      );
      return false;
    }
    return true;
  }

  Future<List<String>?> _showPinDialog(
    BuildContext context, {
    required String title,
    required List<String> labels,
  }) {
    final controllers =
        List.generate(labels.length, (_) => TextEditingController());

    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                TextField(
                  controller: controllers[i],
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    labelText: labels[i],
                    counterText: '',
                  ),
                ),
                if (i < labels.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                final values =
                    controllers.map((controller) => controller.text.trim());
                Navigator.of(dialogContext).pop(values.toList());
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }
}

class LocalAuthFlowTab extends StatelessWidget {
  const LocalAuthFlowTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthSettingsBloc, LocalAuthSettingsState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SettingsSection(
              title: 'Örnek Akış',
              subtitle: 'Aşağıdaki adımları takip ederek modülü deneyin',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. PIN belirleyin'),
                  const Text('2. Biyometrik girişi açın'),
                  const Text('3. Arka plan kilidi süresini seçin'),
                  const Text(
                      '4. Güvenli alanı açıp uygulamayı arka plana alın'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChip(
                        label: state.isPinSet ? 'PIN hazır' : 'PIN yok',
                        active: state.isPinSet,
                      ),
                      _StatusChip(
                        label: state.isBiometricEnabled
                            ? 'Biyometrik açık'
                            : 'Biyometrik kapalı',
                        active: state.isBiometricEnabled,
                      ),
                      _StatusChip(
                        label: state.isPrivacyGuardEnabled
                            ? 'Privacy Guard açık'
                            : 'Privacy Guard kapalı',
                        active: state.isPrivacyGuardEnabled,
                      ),
                      _StatusChip(
                        label: state.backgroundLockTimeoutSeconds > 0
                            ? 'Arka plan kilidi açık'
                            : 'Arka plan kilidi kapalı',
                        active: state.backgroundLockTimeoutSeconds > 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openSecureArea(context),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Güvenli Alanı Aç'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'İpucu: Güvenli alanda, uygulamayı arka plana gönderip '
              'seçtiğiniz süre kadar bekleyin. Geri döndüğünüzde biyometrik '
              'doğrulama (ve isteğe bağlı PIN) istenir.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSecureArea(BuildContext context) async {
    final repo = context.read<LocalAuthRepository>();
    final settingsBloc = context.read<LocalAuthSettingsBloc>();
    final isPinSet = await repo.isPinSet();
    if (!isPinSet) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce PIN belirlemelisiniz')),
      );
      return;
    }

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) {
          return BlocProvider(
            create: (_) => LocalAuthLoginBloc(repository: repo),
            child: BiometricAuthPage(
              onSuccess: () {
                Navigator.of(routeContext).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: settingsBloc,
                      child: SecureAreaPage(repository: repo),
                    ),
                  ),
                );
              },
              onLogout: () => Navigator.of(routeContext).pop(),
            ),
          );
        },
      ),
    );
  }
}

class SecureAreaPage extends StatelessWidget {
  final LocalAuthRepository repository;

  const SecureAreaPage({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalAuthSettingsBloc, LocalAuthSettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Güvenli Alan'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Çıkış'),
              ),
            ],
          ),
          body: LocalAuthBackgroundLock(
            repository: repository,
            enabled: state.backgroundLockTimeoutSeconds > 0,
            allowPinFallback: true,
            biometricReason: 'Güvenli alana devam etmek için doğrulayın',
            child: PrivacyGuard(
              enabled: state.isPrivacyGuardEnabled,
              child: _SensitiveContent(
                timeoutSeconds: state.backgroundLockTimeoutSeconds,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SensitiveContent extends StatelessWidget {
  final int timeoutSeconds;

  const _SensitiveContent({required this.timeoutSeconds});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizli Bilgiler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                const Text('Hesap No: 1234 5678 9012 3456'),
                const Text('Bakiye: ₺12.450,75'),
                const Text('Son İşlem: 01/02/2026 - Market Harcaması'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              timeoutSeconds > 0
                  ? 'Arka plan kilidi ${timeoutSeconds}s olarak ayarlı. '
                      'Uygulamayı arka plana alın, süre dolunca geri dönün.'
                  : 'Arka plan kilidi kapalı. Süre belirlemek için ayarlar '
                      'sekmesine gidin.',
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: active
          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
          : Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor,
      ),
    );
  }
}
