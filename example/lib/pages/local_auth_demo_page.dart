import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_flutter_features/core/constants/app_colors.dart';
import 'package:unified_flutter_features/features/local_auth/local_auth.dart';
import 'package:unified_flutter_features/shared_features/shared_features.dart';

class LocalAuthDemoEntry extends StatefulWidget {
  const LocalAuthDemoEntry({super.key});

  @override
  State<LocalAuthDemoEntry> createState() => _LocalAuthDemoEntryState();
}

class _LocalAuthDemoEntryState extends State<LocalAuthDemoEntry> {
  late final Future<LocalAuthRepository> _repositoryFuture;

  @override
  void initState() {
    super.initState();
    _repositoryFuture = _initRepository();
  }

  Future<LocalAuthRepository> _initRepository() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsLocalAuthRepository(prefs: prefs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalAuthRepository>(
      future: _repositoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('LocalAuth repository yüklenemedi')),
          );
        }

        return LocalAuthDemoPage(repository: snapshot.data!);
      },
    );
  }
}

class LocalAuthDemoPage extends StatefulWidget {
  final LocalAuthRepository repository;

  const LocalAuthDemoPage({super.key, required this.repository});

  @override
  State<LocalAuthDemoPage> createState() => _LocalAuthDemoPageState();
}

class _LocalAuthDemoPageState extends State<LocalAuthDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik Ayarları'),
        centerTitle: true,
      ),
      body: _buildSettingsTab(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSecureArea(context),
        icon: const Icon(Icons.security),
        label: const Text('Güvenli Alan'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final style = LocalAuthSettingsStyle(
      sectionPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      cardStyle: IboGlassStyle(
        backgroundColor: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      buttonHeight: 46,
      buttonPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      timeoutOptions: const [0, 5, 10, 15, 30, 60, 120, 300],
    );

    return LocalAuthSettingsWidget(
      repository: widget.repository,
      style: style,
      showHeader: true,
    );
  }

  Future<void> _openSecureArea(BuildContext context) async {
    final isPinSet = await widget.repository.isPinSet();

    if (!isPinSet) {
      if (context.mounted) {
        IboSnackbar.showWarning(
          context,
          'Önce PIN belirlemelisiniz. Ayarlardan PIN oluşturun.',
        );
      }
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LocalAuthLoginBloc(repository: widget.repository),
          child: BiometricAuthPage(
            onSuccess: () {
              Navigator.of(context).pop();
            },
            onLogout: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
