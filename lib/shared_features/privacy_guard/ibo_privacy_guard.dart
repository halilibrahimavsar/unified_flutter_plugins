import 'dart:ui';
import 'package:flutter/material.dart';

typedef PrivacyGuardOverlayBuilder = Widget Function(
  BuildContext context,
  PrivacyGuardOverlayStyle style,
);

@immutable
class PrivacyGuardOverlayStyle {
  final double blurSigma;
  final Color scrimColor;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final String? title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const PrivacyGuardOverlayStyle({
    this.blurSigma = 18,
    this.scrimColor = const Color(0x80000000),
    this.icon = Icons.lock_outline_rounded,
    this.iconSize = 72,
    this.iconColor = const Color(0xB3FFFFFF),
    this.title = 'Hidden for privacy',
    this.subtitle = 'Return to the app to continue',
    this.titleStyle,
    this.subtitleStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });
}

class PrivacyGuard extends StatefulWidget {
  final Widget child;
  final bool enabled; // Güvenlik açık mı kontrolü
  final Set<AppLifecycleState> blurOn;
  final PrivacyGuardOverlayStyle style;
  final Duration animationDuration;
  final Curve animationCurve;
  final PrivacyGuardOverlayBuilder? overlayBuilder;

  const PrivacyGuard({
    super.key,
    required this.child,
    this.enabled = true,
    this.blurOn = const {
      AppLifecycleState.inactive,
      AppLifecycleState.paused,
    },
    this.style = const PrivacyGuardOverlayStyle(),
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOut,
    this.overlayBuilder,
  });

  @override
  State<PrivacyGuard> createState() => _PrivacyGuardState();
}

class _PrivacyGuardState extends State<PrivacyGuard>
    with WidgetsBindingObserver {
  bool _shouldBlur = false;

  @override
  void initState() {
    super.initState();
    _syncWithLifecycle();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PrivacyGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.blurOn != widget.blurOn) {
      _syncWithLifecycle();
    }
  }

  void _syncWithLifecycle() {
    final state = WidgetsBinding.instance.lifecycleState;
    final shouldBlur =
        widget.enabled && state != null && widget.blurOn.contains(state);
    if (_shouldBlur != shouldBlur) {
      setState(() {
        _shouldBlur = shouldBlur;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Eğer güvenlik kapalıysa işlem yapma
    if (!widget.enabled) return;

    // Uygulama aktif değilse (inactive veya paused) bulanıklaştır
    final shouldBlur = widget.blurOn.contains(state);

    if (_shouldBlur != shouldBlur) {
      setState(() {
        _shouldBlur = shouldBlur;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Güvenlik kapalıysa direkt içeriği göster
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        widget.child,
        if (_shouldBlur)
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: widget.animationDuration,
              switchInCurve: widget.animationCurve,
              switchOutCurve: widget.animationCurve,
              child: _PrivacyGuardOverlay(
                key: ValueKey<bool>(_shouldBlur),
                style: widget.style,
                builder: widget.overlayBuilder,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrivacyGuardOverlay extends StatelessWidget {
  final PrivacyGuardOverlayStyle style;
  final PrivacyGuardOverlayBuilder? builder;

  const _PrivacyGuardOverlay({
    super.key,
    required this.style,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = style.titleStyle ??
        theme.textTheme.titleMedium?.copyWith(
          color: style.iconColor,
          fontWeight: FontWeight.w600,
        );
    final subtitleStyle = style.subtitleStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: style.iconColor.withValues(alpha: 0.8),
        );

    return AbsorbPointer(
      absorbing: true,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: style.blurSigma,
          sigmaY: style.blurSigma,
        ),
        child: ColoredBox(
          color: style.scrimColor,
          child: Center(
            child: builder?.call(context, style) ??
                Container(
                  padding: style.padding,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.2),
                    borderRadius: style.borderRadius,
                    border: Border.all(
                      color: style.iconColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        style.icon,
                        size: style.iconSize,
                        color: style.iconColor,
                      ),
                      if (style.title != null) ...[
                        const SizedBox(height: 12),
                        Text(style.title!, style: titleStyle),
                      ],
                      if (style.subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(style.subtitle!, style: subtitleStyle),
                      ],
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
