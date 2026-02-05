# unified_flutter_features_example

A new Flutter project.

## Local Auth Demo

Local authentication örneği `example/lib/pages/local_auth_demo_page.dart` dosyasında.

Kullanım:
1. Uygulamayı çalıştırın ve ana sayfada `Local Auth Demo` butonuna girin.
2. `Ayarlar` sekmesinde PIN belirleyin, biyometrik girişi açın, Privacy Guard ve arka plan kilidi süresini seçin.
3. `Akış` sekmesinden `Güvenli Alanı Aç` ile giriş yapın.
4. Uygulamayı arka plana alın ve seçtiğiniz süre kadar bekleyin. Geri döndüğünüzde biyometrik doğrulama (ve isteğe bağlı PIN) istenir.

Kısa entegrasyon örneği:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const LocalAuthDemoEntry()),
);
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
