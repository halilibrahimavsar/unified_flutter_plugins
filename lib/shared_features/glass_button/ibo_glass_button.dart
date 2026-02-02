import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class IboGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const IboGlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.child,
    this.padding,
    this.elevation,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor?.withValues(alpha: 0.3) ??
            AppColors.surface.withValues(alpha: 0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ??
            Border.all(
                color: AppColors.surface.withValues(alpha: 0.5), width: 1),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: child ??
                  Text(
                    text,
                    style: TextStyle(
                      color: foregroundColor ?? Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class IboLoadingButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const IboLoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50,
    this.borderRadius,
    this.child,
    this.padding,
  });

  @override
  State<IboLoadingButton> createState() => _IboLoadingButtonState();
}

class _IboLoadingButtonState extends State<IboLoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return IboGlassButton(
      text: widget.text,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
      padding: widget.padding,
      onPressed: _isLoading ? null : _handlePress,
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: widget.foregroundColor ?? Colors.black87,
                strokeWidth: 2,
              ),
            )
          : widget.child,
    );
  }

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
