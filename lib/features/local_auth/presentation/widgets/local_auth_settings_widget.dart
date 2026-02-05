import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared_features/common/ibo_glass_surface.dart';
import '../../../../shared_features/glass_button/ibo_glass_button.dart';
import '../../../../shared_features/dialog/ibo_dialog.dart';
import '../../../../shared_features/snackbar/ibo_snackbar.dart';
import '../../data/local_auth_repository.dart';
import '../bloc/settings/local_auth_settings_bloc.dart';
import '../bloc/settings/local_auth_settings_event.dart';
import '../bloc/settings/local_auth_settings_state.dart';
import '../bloc/local_auth_status.dart';
import 'local_auth_settings_style.dart';

/// A customizable settings widget for local authentication.
///
/// This widget provides a complete interface for managing:
/// - PIN creation, change, and deletion
/// - Biometric authentication toggle
/// - Privacy Guard settings
/// - Background lock timeout configuration
///
/// Example usage:
/// ```dart
/// LocalAuthSettingsWidget(
///   repository: myRepository,
///   style: LocalAuthSettingsStyle(
///     sectionTitleStyle: TextStyle(fontSize: 18),
///   ),
///   onPinChanged: () => print('PIN changed'),
/// )
/// ```
class LocalAuthSettingsWidget extends StatefulWidget {
  final LocalAuthRepository repository;
  final LocalAuthSettingsStyle style;
  final VoidCallback? onPinChanged;
  final VoidCallback? onBiometricToggled;
  final VoidCallback? onPrivacyGuardToggled;
  final VoidCallback? onBackgroundLockChanged;
  final Widget? header;
  final bool showHeader;
  final bool showPinSection;
  final bool showBiometricSection;
  final bool showPrivacyGuardSection;
  final bool showBackgroundLockSection;

  const LocalAuthSettingsWidget({
    super.key,
    required this.repository,
    this.style = const LocalAuthSettingsStyle(),
    this.onPinChanged,
    this.onBiometricToggled,
    this.onPrivacyGuardToggled,
    this.onBackgroundLockChanged,
    this.header,
    this.showHeader = true,
    this.showPinSection = true,
    this.showBiometricSection = true,
    this.showPrivacyGuardSection = true,
    this.showBackgroundLockSection = true,
  });

  @override
  State<LocalAuthSettingsWidget> createState() =>
      _LocalAuthSettingsWidgetState();
}

class _LocalAuthSettingsWidgetState extends State<LocalAuthSettingsWidget> {
  late final LocalAuthSettingsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LocalAuthSettingsBloc(repository: widget.repository);
    _bloc.add(LoadSettingsEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<LocalAuthSettingsBloc, LocalAuthSettingsState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: widget.style.sectionPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showHeader) _buildHeader(context, state),
                if (widget.showPinSection) _buildPinSection(context, state),
                if (widget.showBiometricSection) ...[
                  SizedBox(height: widget.style.sectionSpacing),
                  _buildBiometricSection(context, state),
                ],
                if (widget.showPrivacyGuardSection) ...[
                  SizedBox(height: widget.style.sectionSpacing),
                  _buildPrivacyGuardSection(context, state),
                ],
                if (widget.showBackgroundLockSection) ...[
                  SizedBox(height: widget.style.sectionSpacing),
                  _buildBackgroundLockSection(context, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleStateChanges(BuildContext context, LocalAuthSettingsState state) {
    if (state.message != null) {
      if (state.status == SettingsStatus.error) {
        IboSnackbar.showError(context, state.message!);
      } else if (state.status == SettingsStatus.success) {
        IboSnackbar.showSuccess(context, state.message!);
      }
    }

    if (state.status == SettingsStatus.success) {
      final normalized = state.message?.toLowerCase();
      if (normalized?.contains('pin') == true) {
        widget.onPinChanged?.call();
      } else if (normalized?.contains('biyometrik') == true) {
        widget.onBiometricToggled?.call();
      } else if (normalized?.contains('privacy guard') == true) {
        widget.onPrivacyGuardToggled?.call();
      } else if (normalized?.contains('arka plan') == true) {
        widget.onBackgroundLockChanged?.call();
      }
    }
  }

  Widget _buildHeader(BuildContext context, LocalAuthSettingsState state) {
    if (widget.header != null) return widget.header!;

    return Padding(
      padding: widget.style.headerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güvenlik Ayarları',
            style: widget.style.headerTitleStyle ??
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            'Uygulama güvenliğinizi yönetin',
            style: widget.style.headerSubtitleStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection(BuildContext context, LocalAuthSettingsState state) {
    return _buildSection(
      context: context,
      title: 'PIN Kilidi',
      subtitle: state.isPinSet ? 'PIN aktif' : 'PIN ayarlanmadı',
      children: [
        if (!state.isPinSet) ...[
          _buildActionButton(
            context: context,
            text: 'PIN Oluştur',
            icon: Icons.add,
            onPressed: () => _showCreatePinDialog(context),
          ),
        ] else ...[
          _buildActionButton(
            context: context,
            text: 'PIN Değiştir',
            icon: Icons.edit,
            onPressed: () => _showChangePinDialog(context),
          ),
          SizedBox(height: widget.style.buttonSpacing),
          _buildActionButton(
            context: context,
            text: 'PIN Kaldır',
            icon: Icons.delete_outline,
            isDestructive: true,
            onPressed: () => _showDeletePinDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildBiometricSection(
      BuildContext context, LocalAuthSettingsState state) {
    if (!state.isBiometricAvailable) {
      return _buildSection(
        context: context,
        title: 'Biyometrik Giriş',
        subtitle: 'Cihazınız biyometrik doğrulamayı desteklemiyor',
        children: [
          Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.grey[400],
                size: widget.style.tileIconTheme?.size ?? 24,
              ),
              SizedBox(width: widget.style.tileSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biyometrik Doğrulama',
                      style: widget.style.tileTitleStyle ??
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                    ),
                    Text(
                      'Bu cihazda kullanılamaz',
                      style: widget.style.tileSubtitleStyle ??
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.block,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ],
      );
    }

    return _buildSection(
      context: context,
      title: 'Biyometrik Giriş',
      subtitle: state.isBiometricEnabled
          ? 'Biyometrik giriş aktif'
          : 'Biyometrik giriş kapalı',
      children: [
        _buildSwitchTile(
          context: context,
          title: 'Biyometrik Doğrulama',
          subtitle: state.isBiometricEnabled
              ? 'Açık - Parmak izi veya yüz tanıma ile giriş'
              : 'Kapalı',
          value: state.isBiometricEnabled,
          icon: Icons.fingerprint,
          onChanged: (state.isPinSet || state.isBiometricEnabled)
              ? (value) => _bloc.add(ToggleBiometricEvent(enable: value))
              : null,
        ),
        if (!state.isPinSet) ...[
          SizedBox(height: widget.style.tileSpacing),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Biyometrik girişi etkinleştirmek için önce PIN oluşturmalısınız.',
                    style: widget.style.tileSubtitleStyle?.copyWith(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ) ??
                        TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyGuardSection(
      BuildContext context, LocalAuthSettingsState state) {
    return _buildSection(
      context: context,
      title: 'Privacy Guard',
      subtitle: state.isPrivacyGuardEnabled
          ? 'Ekran koruma aktif'
          : 'Ekran koruma kapalı',
      children: [
        _buildSwitchTile(
          context: context,
          title: 'Ekran Koruma',
          subtitle: state.isPrivacyGuardEnabled
              ? 'Açık - Uygulama arka plandayken içerik gizlenir'
              : 'Kapalı',
          value: state.isPrivacyGuardEnabled,
          icon: Icons.privacy_tip_outlined,
          onChanged: (value) =>
              _bloc.add(TogglePrivacyGuardEvent(enable: value)),
        ),
      ],
    );
  }

  Widget _buildBackgroundLockSection(
      BuildContext context, LocalAuthSettingsState state) {
    final currentTimeout = state.backgroundLockTimeoutSeconds;
    final canEdit = state.isPinSet &&
        state.isBiometricAvailable &&
        state.isBiometricEnabled;

    String formatDuration(int seconds) {
      if (seconds >= 60) {
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        if (remainingSeconds == 0) {
          return '$minutes dk';
        }
        return '$minutes dk $remainingSeconds sn';
      }
      return '$seconds sn';
    }

    return _buildSection(
      context: context,
      title: 'Arka Plan Kilidi',
      subtitle: currentTimeout > 0
          ? '${formatDuration(currentTimeout)} sonra kilitlenir'
          : 'Kapalı',
      children: [
        Text(
          'Uygulama arka planda belirli süre kaldığında otomatik olarak kilitlensin',
          style: widget.style.tileSubtitleStyle ??
              Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
        ),
        if (!canEdit) ...[
          SizedBox(height: widget.style.tileSpacing),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.isPinSet
                        ? (state.isBiometricAvailable
                            ? 'Arka plan kilidi için biyometrik giriş açık olmalı.'
                            : 'Biyometrik doğrulama desteklenmiyor.')
                        : 'Arka plan kilidi için önce PIN belirlemelisiniz.',
                    style: widget.style.tileSubtitleStyle?.copyWith(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ) ??
                        TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: widget.style.tileSpacing),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimeoutChip(
              context: context,
              label: 'Kapalı',
              seconds: 0,
              isSelected: currentTimeout == 0,
              enabled: canEdit || currentTimeout == 0,
            ),
            ...widget.style.timeoutOptions.where((s) => s > 0).map(
                  (seconds) => _buildTimeoutChip(
                    context: context,
                    label: formatDuration(seconds),
                    seconds: seconds,
                    isSelected: currentTimeout == seconds,
                    enabled: canEdit,
                  ),
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: widget.style.sectionTitleStyle ??
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: widget.style.sectionSubtitleStyle ??
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
              ),
            ],
          ),
        ),
        IboGlassSurface(
          style: widget.style.cardStyle,
          child: Padding(
            padding: widget.style.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool>? onChanged,
  }) {
    return InkWell(
      onTap: onChanged != null ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.style.tileSpacing / 2),
        child: Row(
          children: [
            Icon(
              icon,
              color: onChanged != null
                  ? (widget.style.tileIconTheme?.color ??
                      Theme.of(context).primaryColor)
                  : Colors.grey,
              size: widget.style.tileIconTheme?.size ?? 24,
            ),
            SizedBox(width: widget.style.tileSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: widget.style.tileTitleStyle ??
                        Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                  ),
                  Text(
                    subtitle,
                    style: widget.style.tileSubtitleStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: widget.style.switchActiveColor,
              inactiveThumbColor: widget.style.switchInactiveColor,
              activeTrackColor: widget.style.switchTrackColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    final baseTextStyle = widget.style.buttonTextStyle ??
        TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        );
    final textStyle = isDestructive
        ? baseTextStyle.copyWith(color: Colors.red)
        : baseTextStyle;
    final iconColor = isDestructive ? Colors.red : textStyle.color;

    return IboGlassButton(
      text: text,
      onPressed: onPressed,
      height: widget.style.buttonHeight,
      padding: widget.style.buttonPadding,
      foregroundColor: isDestructive ? Colors.red : null,
      borderColor: isDestructive ? Colors.red.withValues(alpha: 0.3) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoutChip({
    required BuildContext context,
    required String label,
    required int seconds,
    required bool isSelected,
    required bool enabled,
  }) {
    final baseColor = Theme.of(context).primaryColor;
    final labelColor = !enabled
        ? Colors.grey[400]
        : (isSelected ? baseColor : Colors.grey[700]);
    final weight = !enabled
        ? FontWeight.normal
        : (isSelected ? FontWeight.w600 : FontWeight.normal);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: enabled
          ? (_) => _bloc.add(UpdateBackgroundLockTimeoutEvent(seconds: seconds))
          : null,
      backgroundColor: Colors.transparent,
      selectedColor: baseColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: labelColor, fontWeight: weight),
      side: BorderSide(
        color: isSelected ? baseColor : (Colors.grey[300] ?? Colors.grey),
      ),
    );
  }

  InputDecoration _pinDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    final decoration = InputDecoration(labelText: label, hintText: hint);
    return decoration.applyDefaults(
      widget.style.pinInputDecoration ?? Theme.of(context).inputDecorationTheme,
    );
  }

  List<TextInputFormatter> _pinFormatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];
  }

  Future<void> _showCreatePinDialog(BuildContext context) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await IboDialog.showCustomDialog<bool>(
      context,
      title: 'PIN Oluştur',
      style: IboDialogStyle(
        glassStyle: widget.style.cardStyle,
        titleStyle: widget.style.pinDialogTitleStyle,
        contentStyle: widget.style.pinDialogSubtitleStyle,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: pinController,
              decoration: _pinDecoration(
                context,
                label: 'PIN (4 hane)',
                hint: '****',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: _pinFormatters(),
              validator: (value) {
                if (value?.length != 4) return '4 haneli PIN girin';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmController,
              decoration: _pinDecoration(
                context,
                label: 'PIN Tekrar',
                hint: '****',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: _pinFormatters(),
              validator: (value) {
                if (value != pinController.text) return 'PINler eşleşmiyor';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Kaydet'),
        ),
      ],
    );

    if (result == true) {
      _bloc.add(SavePinEvent(
        pin: pinController.text,
        confirmPin: confirmController.text,
      ));
    }

    pinController.dispose();
    confirmController.dispose();
  }

  Future<void> _showChangePinDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await IboDialog.showCustomDialog<bool>(
      context,
      title: 'PIN Değiştir',
      style: IboDialogStyle(
        glassStyle: widget.style.cardStyle,
        titleStyle: widget.style.pinDialogTitleStyle,
        contentStyle: widget.style.pinDialogSubtitleStyle,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentController,
              decoration: _pinDecoration(
                context,
                label: 'Mevcut PIN',
                hint: '****',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: _pinFormatters(),
              validator: (value) {
                if (value?.length != 4) return '4 haneli PIN girin';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newController,
              decoration: _pinDecoration(
                context,
                label: 'Yeni PIN',
                hint: '****',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: _pinFormatters(),
              validator: (value) {
                if (value?.length != 4) return '4 haneli PIN girin';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmController,
              decoration: _pinDecoration(
                context,
                label: 'Yeni PIN Tekrar',
                hint: '****',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              inputFormatters: _pinFormatters(),
              validator: (value) {
                if (value != newController.text) return 'PINler eşleşmiyor';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Değiştir'),
        ),
      ],
    );

    if (result == true) {
      _bloc.add(ChangePinEvent(
        currentPin: currentController.text,
        newPin: newController.text,
        confirmPin: confirmController.text,
      ));
    }

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<void> _showDeletePinDialog(BuildContext context) async {
    final confirmed = await IboDialog.showConfirmation(
      context,
      'PIN Kaldır',
      'PIN kaldırıldığında biyometrik giriş de devre dışı kalacak. Devam etmek istiyor musunuz?',
      confirmText: 'Kaldır',
      cancelText: 'İptal',
    );

    if (confirmed == true) {
      final currentPin = await IboDialog.showTextInput(
        context,
        'PIN Doğrulama',
        'Mevcut PINinizi girin',
        keyboardType: TextInputType.number,
        obscureText: true,
      );

      if (currentPin != null && currentPin.isNotEmpty) {
        _bloc.add(DeletePinEvent(currentPin: currentPin));
      }
    }
  }
}
