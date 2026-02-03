import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_cubit.dart';
import 'package:unified_flutter_features/features/connection_monitor/connection_state.dart';

class ConnectionSnackbarHandler extends StatefulWidget {
  final Widget child;
  final bool showSnackbar;
  final Duration? connectedDuration;
  final Duration? disconnectedDuration;
  final String? connectedMessage;
  final String? disconnectedMessage;
  final SnackBarBehavior? behavior;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const ConnectionSnackbarHandler({
    super.key,
    required this.child,
    this.showSnackbar = true,
    this.connectedDuration = const Duration(seconds: 2),
    this.disconnectedDuration = const Duration(seconds: 3),
    this.connectedMessage,
    this.disconnectedMessage,
    this.behavior,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  State<ConnectionSnackbarHandler> createState() =>
      _ConnectionSnackbarHandlerState();
}

class _ConnectionSnackbarHandlerState extends State<ConnectionSnackbarHandler> {
  MyConnectionState? lastState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionCubit, MyConnectionState>(
      listener: (context, state) {
        if (!widget.showSnackbar) return;

        if (lastState != null && lastState!.status == state.status) return;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        switch (state.status) {
          case ConnectionStatus.connected:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.wifi, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.connectedMessage ??
                            state.message ??
                            'İnternet bağlantısı aktif',
                        style: widget.textStyle ??
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: widget.backgroundColor ?? Colors.green,
                behavior: widget.behavior ?? SnackBarBehavior.floating,
                duration:
                    widget.connectedDuration ?? const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            break;

          case ConnectionStatus.disconnected:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.disconnectedMessage ??
                            state.message ??
                            'İnternet bağlantısı yok',
                        style: widget.textStyle ??
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: widget.backgroundColor ?? Colors.red,
                behavior: widget.behavior ?? SnackBarBehavior.floating,
                duration:
                    widget.disconnectedDuration ?? const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                action: SnackBarAction(
                  label: 'Yeniden Dene',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ConnectionCubit>().manualCheck();
                  },
                ),
              ),
            );
            break;

          case ConnectionStatus.checking:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message ?? 'Bağlantı kontrol ediliyor...',
                        style: widget.textStyle ??
                            const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: widget.backgroundColor ?? Colors.orange,
                behavior: widget.behavior ?? SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            break;
        }

        lastState = state;
      },
      child: widget.child,
    );
  }
}
