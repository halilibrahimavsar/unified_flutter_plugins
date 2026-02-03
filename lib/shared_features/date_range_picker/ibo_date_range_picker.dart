import 'package:flutter/material.dart';

class IboDateRangeQuickOption {
  final String label;
  final DateTimeRange range;

  const IboDateRangeQuickOption({
    required this.label,
    required this.range,
  });
}

class _QuickRangeAction {
  final DateTimeRange? range;
  final bool openPicker;

  const _QuickRangeAction.select(this.range) : openPicker = false;
  const _QuickRangeAction.openPicker()
      : range = null,
        openPicker = true;
}

class IboDateRangePicker {
  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? saveText,
    String? cancelText,
    List<IboDateRangeQuickOption>? quickOptions,
    bool includeFullDays = false,
  }) async {
    if (quickOptions != null && quickOptions.isNotEmpty) {
      final action = await _showQuickMenu(
        context,
        quickOptions: quickOptions,
        title: helpText ?? 'Tarih Aralığı Seç',
      );
      if (action == null) {
        return null;
      }
      if (!action.openPicker) {
        final selected = action.range;
        if (selected == null) {
          return null;
        }
        return includeFullDays ? _normalizeToFullDays(selected) : selected;
      }
    }

    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText ?? 'Tarih Aralığı Seç',
      saveText: saveText ?? 'Kaydet',
      cancelText: cancelText ?? 'İptal',
    );
    if (selected == null) {
      return null;
    }
    return includeFullDays ? _normalizeToFullDays(selected) : selected;
  }

  static Future<_QuickRangeAction?> _showQuickMenu(
    BuildContext context, {
    required List<IboDateRangeQuickOption> quickOptions,
    required String title,
  }) async {
    return showModalBottomSheet<_QuickRangeAction>(
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
                        _QuickRangeAction.select(option.range),
                      ),
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Takvimden Seç'),
                onTap:
                    () =>
                        Navigator.of(context).pop(const _QuickRangeAction.openPicker()),
              ),
            ],
          ),
        );
      },
    );
  }

  static DateTimeRange _normalizeToFullDays(DateTimeRange range) {
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
      999,
    );
    return DateTimeRange(start: start, end: end);
  }
}
