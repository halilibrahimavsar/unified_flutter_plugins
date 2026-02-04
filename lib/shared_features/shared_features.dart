/// Export file for all shared UI components and feature modules.
///
/// This file exports:
/// - Shared UI components (snackbar, dialog, glass button, date pickers)
/// - Connection monitor feature with BLoC state management
/// - Amount visibility feature with obfuscation and persistence
/// - 2D Slider navigation feature with animation support
///
/// Import this file to get access to all shared components and features:
/// ```dart
/// import 'package:unified_flutter_features/shared_features.dart';
///
/// // Example usage of amount visibility feature:
/// BlocProvider(
///   create: (_) => AmountVisibilityCubit(),
///   child: Row(
///     children: [
///       AmountDisplay(amount: 1234.56, currencySymbol: '\$'),
///       AmountVisibilityButton(),
///     ],
///   ),
/// )
/// ```

// Shared UI Components
export 'snackbar/ibo_snackbar.dart';
export 'date_picker/ibo_date_picker.dart';
export 'date_range_picker/ibo_date_range_picker.dart';
export 'dialog/ibo_dialog.dart';
export 'glass_button/ibo_glass_button.dart';
export '../features/amount_visibility/ibo_amount_display.dart';
export 'common/ibo_glass_surface.dart';
export 'common/ibo_quick_menu_style.dart';

// Connection Monitor Feature
// Monitors internet connectivity using BLoC pattern with connectivity_plus
export '../features/connection_monitor/connection_cubit.dart';
export '../features/connection_monitor/connection_state.dart';
export '../features/connection_monitor/services/connection_notification_service.dart';
export '../features/connection_monitor/services/connection_snackbar_handler.dart';
export '../features/connection_monitor/widgets/connection_indicator_widget.dart';

// Amount Visibility Feature
// Manages amount visibility with BLoC pattern and shared preferences
export '../features/amount_visibility/amount_visibility_cubit.dart';

// 2D Slider Navigation Feature
// Animated slider with state transitions and mini button/sub-menu support
export '../features/slider_2d_navigation/dynamic_slider.dart';
export '../features/slider_2d_navigation/models/slider_models.dart';
export '../features/slider_2d_navigation/widgets/dynamic_slider_button.dart';
export '../features/slider_2d_navigation/widgets/mini_buttons_overlay.dart';
export '../features/slider_2d_navigation/widgets/slider_knob.dart';
export '../features/slider_2d_navigation/widgets/vertical_carousel.dart';
