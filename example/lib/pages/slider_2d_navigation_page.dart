import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/models/slider_models.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/dynamic_slider.dart';

class Slider2DNavigationPage extends StatefulWidget {
  const Slider2DNavigationPage({super.key});

  @override
  State<Slider2DNavigationPage> createState() => _Slider2DNavigationPageState();
}

class _Slider2DNavigationPageState extends State<Slider2DNavigationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dynamic Slider'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 50),

            // Main slider
            DynamicSlider(
              controller: _controller,
              onValueChanged: (value) => _log('Value: $value'),
              onStateTap: (state) => _log('Tapped: $state'),
              miniButtons: _getMiniButtons(),
              subMenuItems: _getSubMenuItems(),
            ),

            const SizedBox(height: 50),

            // Control buttons
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton('Birikim', 0.0),
        _buildButton('İşlemler', 0.5),
        _buildButton('Borç', 1.0),
      ],
    );
  }

  Widget _buildButton(String label, double target) {
    return ElevatedButton(
      onPressed: () => _controller.animateTo(target),
      child: Text(label),
    );
  }

  Map<SliderState, List<MiniButtonData>> _getMiniButtons() {
    return {
      SliderState.savedMoney: [
        MiniButtonData(
          icon: Icons.add,
          label: 'Ekle',
          color: Colors.green,
          onTap: () => _log('Birikim eklendi'),
        ),
        MiniButtonData(
          icon: Icons.remove,
          label: 'Çıkar',
          color: Colors.red,
          onTap: () => _log('Birikim çıkarıldı'),
        ),
        MiniButtonData(
          icon: Icons.abc_outlined,
          label: 'Güncelle',
          color: Colors.red,
          onTap: () => _log('Birikim güncellendi'),
        ),
      ],
      SliderState.transactions: [
        MiniButtonData(
          icon: Icons.send,
          label: 'Gönder',
          color: Colors.blue,
          onTap: () => _log('İşlem gönderildi'),
        ),
        MiniButtonData(
          icon: Icons.download,
          label: 'Al',
          color: Colors.purple,
          onTap: () => _log('İşlem alındı'),
        ),
      ],
      SliderState.debt: [
        MiniButtonData(
          icon: Icons.add,
          label: 'Borç Ekle',
          color: Colors.orange,
          onTap: () => _log('Borç eklendi'),
        ),
      ],
    };
  }

  Map<SliderState, List<SubMenuItem>> _getSubMenuItems() {
    return {
      SliderState.savedMoney: [
        SubMenuItem(
          icon: Icons.account_balance,
          label: 'Banka',
          onTap: () => _log('Banka seçildi'),
        ),
        SubMenuItem(
          icon: Icons.home,
          label: 'Ev',
          onTap: () => _log('Ev seçildi'),
        ),
      ],
      SliderState.transactions: [
        SubMenuItem(
          icon: Icons.history,
          label: 'Geçmiş',
          onTap: () => _log('Geçmiş seçildi'),
        ),
        SubMenuItem(
          icon: Icons.pending,
          label: 'Bekleyen',
          onTap: () => _log('Bekleyen seçildi'),
        ),
      ],
      SliderState.debt: [
        SubMenuItem(
          icon: Icons.person,
          label: 'Kişisel',
          onTap: () => _log('Kişisel borç'),
        ),
        SubMenuItem(
          icon: Icons.business,
          label: 'Kurumsal',
          onTap: () => _log('Kurumsal borç'),
        ),
      ],
    };
  }
}
