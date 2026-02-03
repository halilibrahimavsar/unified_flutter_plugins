import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../common/ibo_glass_surface.dart';

class IboDialogStyle {
  final IboGlassStyle glassStyle;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;
  final double actionsSpacing;
  final MainAxisAlignment actionsAlignment;
  final ButtonStyle? confirmButtonStyle;
  final ButtonStyle? cancelButtonStyle;
  final Duration transitionDuration;
  final Curve transitionCurve;

  const IboDialogStyle({
    this.glassStyle = const IboGlassStyle(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      padding: EdgeInsets.all(18),
    ),
    this.titleStyle,
    this.contentStyle,
    this.contentPadding = const EdgeInsets.only(top: 8),
    this.actionsPadding = const EdgeInsets.only(top: 16),
    this.actionsSpacing = 10,
    this.actionsAlignment = MainAxisAlignment.end,
    this.confirmButtonStyle,
    this.cancelButtonStyle,
    this.transitionDuration = const Duration(milliseconds: 180),
    this.transitionCurve = Curves.easeOutCubic,
  });

  IboDialogStyle copyWith({
    IboGlassStyle? glassStyle,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    double? actionsSpacing,
    MainAxisAlignment? actionsAlignment,
    ButtonStyle? confirmButtonStyle,
    ButtonStyle? cancelButtonStyle,
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return IboDialogStyle(
      glassStyle: glassStyle ?? this.glassStyle,
      titleStyle: titleStyle ?? this.titleStyle,
      contentStyle: contentStyle ?? this.contentStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      actionsPadding: actionsPadding ?? this.actionsPadding,
      actionsSpacing: actionsSpacing ?? this.actionsSpacing,
      actionsAlignment: actionsAlignment ?? this.actionsAlignment,
      confirmButtonStyle: confirmButtonStyle ?? this.confirmButtonStyle,
      cancelButtonStyle: cancelButtonStyle ?? this.cancelButtonStyle,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
    );
  }
}

class IboDialog {
  static Future<bool?> showConfirmation(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Tamam',
    String cancelText = 'İptal',
    bool barrierDismissible = true,
    IboDialogStyle? style,
    Widget? icon,
  }) async {
    final resolvedStyle = style ?? const IboDialogStyle();
    return _showGlassDialog<bool>(
      context,
      barrierDismissible: barrierDismissible,
      style: resolvedStyle,
      child: _buildDialogBody(
        title: title,
        content: Text(
          message,
          style: resolvedStyle.contentStyle ??
              TextStyle(
                color: AppColors.onSurface.withValues(alpha: 0.9),
                fontSize: 14,
              ),
        ),
        icon: icon,
        actions: [
          TextButton(
            style: resolvedStyle.cancelButtonStyle,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            style: resolvedStyle.confirmButtonStyle,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
        style: resolvedStyle,
      ),
    );
  }

  static Future<void> showInfo(
    BuildContext context,
    String title,
    String message, {
    String closeText = 'Tamam',
    bool barrierDismissible = true,
    IboDialogStyle? style,
    Widget? icon,
  }) async {
    final resolvedStyle = style ?? const IboDialogStyle();
    await _showGlassDialog<void>(
      context,
      barrierDismissible: barrierDismissible,
      style: resolvedStyle,
      child: _buildDialogBody(
        title: title,
        content: Text(
          message,
          style: resolvedStyle.contentStyle ??
              TextStyle(
                color: AppColors.onSurface.withValues(alpha: 0.9),
                fontSize: 14,
              ),
        ),
        icon: icon,
        actions: [
          TextButton(
            style: resolvedStyle.confirmButtonStyle,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(closeText),
          ),
        ],
        style: resolvedStyle,
      ),
    );
  }

  static Future<String?> showTextInput(
    BuildContext context,
    String title,
    String hintText, {
    String? initialValue,
    String confirmText = 'Tamam',
    String cancelText = 'İptal',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    IboDialogStyle? style,
    Widget? icon,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final resolvedStyle = style ?? const IboDialogStyle();

    return await _showGlassDialog<String>(
      context,
      barrierDismissible: true,
      style: resolvedStyle,
      child: _buildDialogBody(
        title: title,
        icon: icon,
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surface.withValues(alpha: 0.12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          autofocus: true,
        ),
        actions: [
          TextButton(
            style: resolvedStyle.cancelButtonStyle,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          TextButton(
            style: resolvedStyle.confirmButtonStyle,
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(confirmText),
          ),
        ],
        style: resolvedStyle,
      ),
    );
  }

  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    IboDialogStyle? style,
    String? title,
    Widget? icon,
  }) async {
    final resolvedStyle = style ?? const IboDialogStyle();
    return await _showGlassDialog<T>(
      context,
      barrierDismissible: barrierDismissible,
      style: resolvedStyle,
      child: _buildDialogBody(
        title: title,
        icon: icon,
        content: content,
        actions: actions ?? const [],
        style: resolvedStyle,
      ),
    );
  }

  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Yükleniyor...',
    bool barrierDismissible = false,
    IboDialogStyle? style,
  }) async {
    final resolvedStyle = style ?? const IboDialogStyle();
    await _showGlassDialog<void>(
      context,
      barrierDismissible: barrierDismissible,
      style: resolvedStyle,
      child: _buildDialogBody(
        title: null,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: resolvedStyle.contentStyle ??
                    TextStyle(
                      color: AppColors.onSurface.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
        actions: const [],
        style: resolvedStyle,
      ),
    );
  }

  static void dismissLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<T?> _showGlassDialog<T>(
    BuildContext context, {
    required Widget child,
    required IboDialogStyle style,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: style.transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: IboGlassSurface(
                  style: style.glassStyle,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: style.transitionCurve,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  static Widget _buildDialogBody({
    required Widget content,
    required List<Widget> actions,
    required IboDialogStyle style,
    String? title,
    Widget? icon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || icon != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: icon,
                ),
              if (title != null)
                Expanded(
                  child: Text(
                    title,
                    style: style.titleStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                  ),
                ),
            ],
          ),
        Padding(
          padding: style.contentPadding,
          child: DefaultTextStyle(
            style: style.contentStyle ??
                TextStyle(
                  color: AppColors.onSurface.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
            child: content,
          ),
        ),
        if (actions.isNotEmpty)
          Padding(
            padding: style.actionsPadding,
            child: Row(
              mainAxisAlignment: style.actionsAlignment,
              children: _withSpacing(actions, style.actionsSpacing),
            ),
          ),
      ],
    );
  }

  static List<Widget> _withSpacing(List<Widget> children, double spacing) {
    if (children.length <= 1) return children;
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(SizedBox(width: spacing));
      }
    }
    return spaced;
  }
}
