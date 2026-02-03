import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/ibo_glass_surface.dart';
import '../common/ibo_quick_menu_style.dart';

class IboDateQuickOption {
  final String label;
  final DateTime date;

  const IboDateQuickOption({
    required this.label,
    required this.date,
  });
}

class _QuickDateAction {
  final DateTime? date;
  final bool openPicker;

  const _QuickDateAction.select(this.date) : openPicker = false;
  const _QuickDateAction.openPicker()
      : date = null,
        openPicker = true;
}

class IboDatePicker {
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    List<IboDateQuickOption>? quickOptions,
    bool normalizeToStartOfDay = false,
    ThemeData? pickerTheme,
    IboQuickMenuStyle? quickMenuStyle,
    String quickMenuActionText = 'Takvimden Seç',
  }) async {
    if (quickOptions != null && quickOptions.isNotEmpty) {
      final action = await _showQuickMenu(
        context,
        quickOptions: quickOptions,
        title: helpText ?? 'Tarih Seç',
        style: quickMenuStyle,
        actionText: quickMenuActionText,
      );
      if (action == null) {
        return null;
      }
      if (!action.openPicker) {
        final selected = action.date;
        if (selected == null) {
          return null;
        }
        return normalizeToStartOfDay ? _startOfDay(selected) : selected;
      }
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText ?? 'Tarih Seç',
      cancelText: cancelText ?? 'İptal',
      confirmText: confirmText ?? 'Tamam',
      fieldLabelText: 'Seçilen Tarih',
      fieldHintText: 'Ay/Gün/Yıl',
      builder: (context, child) {
        return Theme(
          data: pickerTheme ?? _defaultPickerTheme(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (selected == null) {
      return null;
    }
    return normalizeToStartOfDay ? _startOfDay(selected) : selected;
  }

  static Future<DateTime?> pickDateWithConstraints(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    bool Function(DateTime)? selectableDayPredicate,
    List<IboDateQuickOption>? quickOptions,
    bool normalizeToStartOfDay = false,
    ThemeData? pickerTheme,
    IboQuickMenuStyle? quickMenuStyle,
    String quickMenuActionText = 'Takvimden Seç',
  }) async {
    if (quickOptions != null && quickOptions.isNotEmpty) {
      final action = await _showQuickMenu(
        context,
        quickOptions: quickOptions,
        title: 'Tarih Seç',
        style: quickMenuStyle,
        actionText: quickMenuActionText,
      );
      if (action == null) {
        return null;
      }
      if (!action.openPicker) {
        final selected = action.date;
        if (selected == null) {
          return null;
        }
        return normalizeToStartOfDay ? _startOfDay(selected) : selected;
      }
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: minimumDate ?? DateTime(1900),
      lastDate: maximumDate ?? DateTime(2100),
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
      builder: (context, child) {
        return Theme(
          data: pickerTheme ?? _defaultPickerTheme(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (selected == null) {
      return null;
    }
    return normalizeToStartOfDay ? _startOfDay(selected) : selected;
  }

  static Future<_QuickDateAction?> _showQuickMenu(
    BuildContext context, {
    required List<IboDateQuickOption> quickOptions,
    required String title,
    IboQuickMenuStyle? style,
    required String actionText,
  }) async {
    final resolvedStyle = style ?? const IboQuickMenuStyle();
    return showModalBottomSheet<_QuickDateAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: IboGlassSurface(
              style: resolvedStyle.glassStyle,
              child: Material(
                color: Colors.transparent,
                child: ListView(
                  shrinkWrap: true,
                  padding: resolvedStyle.listPadding,
                  children: [
                    ListTile(
                      title: Text(
                        title,
                        style: resolvedStyle.titleStyle ??
                            const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    for (final option in quickOptions)
                      ListTile(
                        contentPadding: resolvedStyle.itemPadding,
                        title: Text(
                          option.label,
                          style: resolvedStyle.optionStyle,
                        ),
                        onTap:
                            () => Navigator.of(context).pop(
                              _QuickDateAction.select(option.date),
                            ),
                      ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: resolvedStyle.itemPadding,
                      leading: Icon(
                        resolvedStyle.actionIcon,
                        color:
                            resolvedStyle.actionIconColor ??
                            AppColors.primary,
                      ),
                      title: Text(
                        actionText,
                        style: resolvedStyle.actionStyle ??
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap:
                          () => Navigator.of(context).pop(
                            const _QuickDateAction.openPicker(),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static ThemeData _defaultPickerTheme(BuildContext context) {
    final base = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: base.brightness,
    );
    return base.copyWith(
      colorScheme: scheme,
      dialogTheme: const DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }
}
