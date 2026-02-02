# Unified Flutter Features

A comprehensive collection of reusable Flutter components and features organized following Clean Architecture principles. This package provides ready-to-use features that can be easily integrated into any Flutter project.

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── themes/
├── shared_features/
│   ├── snackbar/
│   │   └── ibo_snackbar.dart
│   ├── date_picker/
│   │   └── ibo_date_picker.dart
│   ├── date_range_picker/
│   │   └── ibo_date_range_picker.dart
│   ├── dialog/
│   │   └── ibo_dialog.dart
│   ├── glass_button/
│   │   └── ibo_glass_button.dart
│   └── shared_features.dart
└── features/
    ├── connection_monitor/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   ├── data/
    │   └── presentation/
    └── slider_2d_navigation/
        ├── domain/
        ├── entities/
        ├── repositories/
        └── usecases/
        ├── data/
        └── presentation/
```

## 🚀 Features

### Shared Components

#### 1. **IboSnackbar**
Beautiful and customizable snackbar notifications.

```dart
IboSnackbar.showSuccess(context, "İşlem başarılı!");
IboSnackbar.showError(context, "Hata oluştu!");
IboSnackbar.showWarning(context, "Uyarı!");
```

#### 2. **IboDatePicker**
Modern date picker with Turkish localization.

```dart
final date = await IboDatePicker.pickDate(context);
```

#### 3. **IboDialog**
Versatile dialog components.

```dart
final confirmed = await IboDialog.showConfirmation(
  context, "Onay", "Bu işlemi onaylıyor musunuz?");
  
final text = await IboDialog.showTextInput(
  context, "Metin Girişi", "Adınızı girin");
```

#### 4. **IboGlassButton**
Modern glassmorphism button with loading state.

```dart
IboGlassButton(
  text: "Tıkla",
  onPressed: () => print("Tıklandı!"),
)

IboLoadingButton(
  text: "Yükleniyor...",
  onPressed: () async {
    // Async operation
  },
)
```

### Feature Modules

#### 1. **Connection Monitor**
Real-time internet connection monitoring with BLoC pattern.

```dart
// In your widget tree
BlocProvider(
  create: (context) => ConnectionCubit(),
  child: ConnectionIndicatorWidget(),
)

// Check connection status
final connection = await connectionRepository.getCurrentConnection();
```

#### 2. **2D Slider Navigation**
Advanced slider navigation with mini buttons and carousel menu.

```dart
DynamicSlider(
  controller: _controller,
  onValueChanged: (value) => print('Value: $value'),
  onStateTap: (state) => print('Tapped: $state'),
  miniButtons: _getMiniButtons(),
  subMenuItems: _getSubMenuItems(),
)
```

## 🛠 Installation

### Requirements
- **Dart SDK**: >=2.19.0 (for null safety support)
- **Flutter**: >=3.0.0

### Add to your package's `pubspec.yaml`:

```yaml
dependencies:
  unified_flutter_features:
    path: /path/to/unified_flutter_features
    # or from pub.dev (when published)
    # unified_flutter_features: ^1.0.0
```

## 🎯 Usage

### 1. Import the package

```dart
import 'package:unified_flutter_features/unified_flutter_features.dart';
```

### 2. Use any feature directly

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Connection monitor
        BlocProvider(
          create: (_) => ConnectionCubit(),
          child: ConnectionIndicatorWidget(),
        ),
        
        // Glass button
        IboGlassButton(
          text: "Tıkla",
          onPressed: () {
            IboSnackbar.showSuccess(context, "Merhaba!");
          },
        ),
      ],
    );
  }
}
```

## 🧪 Testing

Each feature is designed to be testable independently:

```dart
testWidgets('IboSnackbar shows success message', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          IboSnackbar.showSuccess(context, "Test");
          return Container();
        },
      ),
    ),
  );

  expect(find.text("Test"), findsOneWidget);
});
```

## 🔧 Customization

### Colors
Override default colors:

```dart
class MyColors extends AppColors {
  static const primary = Color(0xFFYourColor);
}
```

### Strings
Customize messages:

```dart
class MyStrings extends AppStrings {
  static const success = 'İşlem Tamamlandı!';
}
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- BLoC pattern for state management
- Clean Architecture principles for project structure

---

Made with ❤️ for Flutter developers!