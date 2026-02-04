# Unified Flutter Features

Flutter projelerinde tekrar kullanılabilir ortak bileşenler ve iki adet hazır feature modülü (Connection Monitor, 2D Slider Navigation) sunan bir paket. Amaç, “kullanımını ileride hızlıca hatırlatacak” net bir referans sağlamaktır.

**Kapsam**
- Ortak UI bileşenleri: snackbar, dialog, glass button/surface, date picker/range picker
- Feature modülleri: internet bağlantı izleme, 2D slider navigasyon
- Tek giriş noktası: `unified_flutter_features.dart` ve `shared_features.dart`

---

**Hızlı Başlangıç**

1. `pubspec.yaml` içine ekle:

```yaml
dependencies:
  unified_flutter_features:
    path: /path/to/unified_flutter_features
```

2. İçe aktar:

```dart
import 'package:unified_flutter_features/unified_flutter_features.dart';
```

---

**Proje Yapısı**

```
lib/
├── core/
│   └── constants/
│       ├── app_colors.dart
│       └── app_strings.dart
├── shared_features/
│   ├── common/
│   │   ├── ibo_glass_surface.dart
│   │   └── ibo_quick_menu_style.dart
│   ├── snackbar/ibo_snackbar.dart
│   ├── date_picker/ibo_date_picker.dart
│   ├── date_range_picker/ibo_date_range_picker.dart
│   ├── dialog/ibo_dialog.dart
│   ├── glass_button/ibo_glass_button.dart
│   └── shared_features.dart
├── features/
│   ├── connection_monitor/
│   │   ├── connection_cubit.dart
│   │   ├── connection_state.dart
│   │   ├── services/
│   │   │   ├── connection_notification_service.dart
│   │   │   └── connection_snackbar_handler.dart
│   │   └── widgets/connection_indicator_widget.dart
│   └── slider_2d_navigation/
│       ├── constants/slider_config.dart
│       ├── helpers/slider_state_helper.dart
│       ├── models/slider_models.dart
│       ├── widgets/
│       │   ├── dynamic_slider_button.dart
│       │   ├── mini_buttons_overlay.dart
│       │   ├── slider_knob.dart
│       │   └── vertical_carousel.dart
│       ├── dynamic_slider.dart
│       └── example.dart
├── unified_flutter_features.dart
└── main.dart
```

---

**Giriş Noktaları**

- Tüm export’lar: `lib/unified_flutter_features.dart`
- Sadece shared + feature export’ları: `lib/shared_features/shared_features.dart`

Önerilen kullanım:

```dart
import 'package:unified_flutter_features/unified_flutter_features.dart';
```

---

**Shared Features (Ortak Bileşenler)**

**1) IboSnackbar**

```dart
IboSnackbar.showSuccess(context, 'İşlem başarılı!');
IboSnackbar.showError(context, 'Bir hata oluştu');
IboSnackbar.showWarning(context, 'Dikkat');

IboSnackbar.show(
  context,
  'Detay mesaj',
  title: 'Başlık',
  subtitle: 'Alt açıklama',
  style: const IboSnackbarStyle(icon: Icons.info),
);
```

**2) IboDatePicker**

```dart
final date = await IboDatePicker.pickDate(
  context,
  quickOptions: [
    IboDateQuickOption(label: 'Bugün', date: DateTime.now()),
  ],
  normalizeToStartOfDay: true,
);
```

**3) IboDateRangePicker**

```dart
final range = await IboDateRangePicker.pickDateRange(
  context,
  quickOptions: [
    IboDateRangeQuickOption(
      label: 'Son 7 Gün',
      range: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    ),
  ],
  includeFullDays: true,
);
```

**4) IboDialog**

```dart
final confirmed = await IboDialog.showConfirmation(
  context,
  'Onay',
  'Bu işlemi onaylıyor musunuz?',
);

final text = await IboDialog.showTextInput(
  context,
  'Not',
  'Bir şey yazın',
);

await IboDialog.showInfo(context, 'Bilgi', 'İşlem tamamlandı');
```

**5) IboGlassButton / IboLoadingButton**

```dart
IboGlassButton(
  text: 'Tıkla',
  onPressed: () {},
);

IboLoadingButton(
  text: 'Kaydet',
  onPressed: () async {
    // async işlem
  },
);
```

**6) IboGlassSurface / IboQuickMenuStyle**

```dart
IboGlassSurface(
  style: const IboGlassStyle(),
  child: const Text('Glass içerik'),
);
```

---

**Feature: Connection Monitor**

Bu modül bağlantı durumunu BLoC ile takip eder ve isteğe bağlı olarak snackbar veya bildirim gösterir.

**Temel Kurulum**

```dart
BlocProvider(
  create: (_) => ConnectionCubit(),
  child: BlocBuilder<ConnectionCubit, MyConnectionState>(
    builder: (context, state) {
      return DefaultConnectionIndicator(connectionState: state);
    },
  ),
)
```

**Snackbar ile otomatik bildirim**

```dart
BlocProvider(
  create: (_) => ConnectionCubit(),
  child: ConnectionSnackbarHandler(
    child: YourPage(),
  ),
)
```

**Sistem bildirimi ile izleme**

```dart
BlocProvider(
  create: (_) => ConnectionCubit(),
  child: ConnectionNotificationHandler(
    child: YourPage(),
  ),
)
```

Notlar:
- `ConnectionNotificationHandler` kullanacaksanız platform izinleri gerekir.
- Bağlantı kaynağı `connectivity_plus`’tır.

---

**Feature: 2D Slider Navigation**

`DynamicSlider` bir `AnimationController` ile çalışır; state geçişleri ve mini buton/alt menü desteği sağlar.

```dart
class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicSlider(
      controller: _controller,
      onStateTap: (state) {
        // state değişince tetiklenir
      },
      miniButtons: {
        SliderState.savedMoney: [
          MiniButtonData(
            icon: Icons.add,
            label: 'Ekle',
            color: Colors.green,
            onTap: () {},
          ),
        ],
      },
      subMenuItems: {
        SliderState.transactions: [
          SubMenuItem(
            icon: Icons.list,
            label: 'Tüm İşlemler',
            onTap: () {},
            isDefault: true,
          ),
        ],
      },
    );
  }
}
```

---

**Örnek Uygulama**

`example/` altında Connection Monitor ve Slider 2D Navigation için örnek sayfalar bulunur.

---

**Testler**

Örnek projede `example/test/` altında shared feature testleri bulunur. İstersen kendi projen için benzer testleri taşıyabilirsin.

---

**Platform Notları**

- Bildirim özelliği için `flutter_local_notifications` yapılandırması ve izinleri gerekir.
- Bağlantı takibi için `connectivity_plus` platform ayarlarını kontrol et.

---

**Lisans**

MIT
