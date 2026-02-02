import 'package:flutter/material.dart';

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
  }) async {
    if (quickOptions != null && quickOptions.isNotEmpty) {
      final action = await _showQuickMenu(
        context,
        quickOptions: quickOptions,
        title: helpText ?? 'Tarih Seç',
      );
      if (action == null) {
        return null;
      }
      if (!action.openPicker) {
        return action.date;
      }
    }

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText ?? 'Tarih Seç',
      cancelText: cancelText ?? 'İptal',
      confirmText: confirmText ?? 'Tamam',
      fieldLabelText: 'Seçilen Tarih',
      fieldHintText: 'Ay/Gün/Yıl',
    );
  }

  static Future<DateTime?> pickDateWithConstraints(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    bool Function(DateTime)? selectableDayPredicate,
    List<IboDateQuickOption>? quickOptions,
  }) async {
    if (quickOptions != null && quickOptions.isNotEmpty) {
      final action = await _showQuickMenu(
        context,
        quickOptions: quickOptions,
        title: 'Tarih Seç',
      );
      if (action == null) {
        return null;
      }
      if (!action.openPicker) {
        return action.date;
      }
    }

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: minimumDate ?? DateTime(1900),
      lastDate: maximumDate ?? DateTime(2100),
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
    );
  }

  static Future<_QuickDateAction?> _showQuickMenu(
    BuildContext context, {
    required List<IboDateQuickOption> quickOptions,
    required String title,
  }) async {
    return showModalBottomSheet<_QuickDateAction>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final option in quickOptions)
                ListTile(
                  title: Text(option.label),
                  onTap:
                      () => Navigator.of(context).pop(
                        _QuickDateAction.select(option.date),
                      ),
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Takvimden Seç'),
                onTap:
                    () =>
                        Navigator.of(context).pop(const _QuickDateAction.openPicker()),
              ),
            ],
          ),
        );
      },
    );
  }
}
