import 'package:flutter/material.dart';

class AC {
  static const bg1 = Color(0xFF070314), bg2 = Color(0xFF0B0824), bg3 = Color(0xFF120A3A);
  static const navy1 = Color(0xFF0A1240), navy2 = Color(0xFF101B5C), navy3 = Color(0xFF1A2A8A);
  static const purple1 = Color(0xFF6A1BFF), purple2 = Color(0xFF8B2DFF), purple3 = Color(0xFFA855F7);
  static const neon1 = Color(0xFFC026FF), neon2 = Color(0xFFE040FB), neon3 = Color(0xFFFF2DF1);
  static const cyan = Color(0xFF00E5FF), blue = Color(0xFF3D5AFE);
  static const gold = Color(0xFFFFD86B);
  static const text = Color(0xFFF3EEFF), text2 = Color(0xFFB7A9E8), text3 = Color(0xFF7C6FB5);
}

List<Shadow> glow(Color c, [double b = 12]) => [Shadow(color: c, blurRadius: b)];

/// Uygulama ayarları (canlı değişir)
class AuraSettings extends ChangeNotifier {
  static final AuraSettings I = AuraSettings._();
  AuraSettings._();

  int accent = 0;
  double glowLevel = 0.8;
  double stars = 0.7;
  bool notif = true, vibrate = true, sound = true;

  static const names = ['Mor', 'Mavi', 'Neon Pembe'];
  static const pairs = [
    [Color(0xFF6A1BFF), Color(0xFFA855F7)],
    [Color(0xFF3D5AFE), Color(0xFF00E5FF)],
    [Color(0xFFC026FF), Color(0xFFFF2DF1)],
  ];
  Color get a1 => pairs[accent][0];
  Color get a2 => pairs[accent][1];

  void update(VoidCallback f) {
    f();
    notifyListeners();
  }
}
