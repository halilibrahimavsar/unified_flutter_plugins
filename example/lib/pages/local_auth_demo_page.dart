import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late final LocalAuthSecurityController _securityController;

  @override
  void initState() {
    super.initState();
    _securityController = LocalAuthSecurityController();
  }

  @override
  void dispose() {
    _securityController.dispose();
    super.dispose();
  }

  void _refreshSecurityLayer() {
    _securityController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return LocalAuthSecurityLayer(
      repository: widget.repository,
      controller: _securityController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Güvenlik Ayarları'),
          centerTitle: true,
        ),
        body: LocalAuthSettingsWidget(
          repository: widget.repository,
          onPrivacyGuardToggled: _refreshSecurityLayer,
          onBackgroundLockChanged: _refreshSecurityLayer,
          style: LocalAuthSettingsStyle(
            sectionPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            cardStyle: IboGlassStyle(
              backgroundColor: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            buttonHeight: 46,
            buttonPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            timeoutOptions: const [0, 5, 10, 15, 30, 60, 120, 300],
          ),
        ),
      ),
    );
  }
}
