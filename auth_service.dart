import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'zodiac.dart';

class Fmt {
  static const months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];
  static String date(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';
  static String time(DateTime d) =>
      '${d.day} ${months[d.month - 1].substring(0, 3)} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Türkçe uyumlu karşılaştırma anahtarı (İ/ı dikkatli)
  static String key(String s) =>
      s.trim().replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class UserProfile {
  final String name, surname;
  final DateTime birth;
  const UserProfile(this.name, this.surname, this.birth);

  Zodiac get sign => Zodiac.fromDate(birth);
  String get fullName => '$name $surname';
  String get birthText => Fmt.date(birth);

  Map<String, dynamic> toJson() => {'n': name, 's': surname, 'b': birth.toIso8601String()};
  factory UserProfile.fromJson(Map<String, dynamic> j) =>
      UserProfile(j['n'] as String, j['s'] as String, DateTime.parse(j['b'] as String));
}

/// Cihaz içi hesap yönetimi. Hiçbir veri sunucuya gitmez.
class AuthService {
  static final ValueNotifier<UserProfile?> current = ValueNotifier(null);
  static late SharedPreferences _p;
  static List<UserProfile> _users = [];

  static String _id(UserProfile u) =>
      '${Fmt.key(u.name)}|${Fmt.key(u.surname)}|${u.birth.year}-${u.birth.month}-${u.birth.day}';
  static bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    final raw = _p.getString('users');
    if (raw != null) {
      _users = (jsonDecode(raw) as List)
          .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final s = _p.getString('session');
    if (s != null) {
      final i = _users.indexWhere((u) => _id(u) == s);
      if (i >= 0) current.value = _users[i];
    }
  }

  static Future<void> _save() => _p.setString('users', jsonEncode(_users.map((u) => u.toJson()).toList()));

  /// Hata varsa mesaj döner, başarılıysa null.
  static Future<String?> register(String name, String surname, DateTime? birth) async {
    if (name.trim().isEmpty || surname.trim().isEmpty) return 'Ad ve soyad gerekli.';
    if (birth == null) return 'Doğum tarihini seç.';
    final u = UserProfile(name.trim(), surname.trim(), birth);
    if (_users.any((x) => _id(x) == _id(u))) return 'Bu hesap zaten var, giriş yapabilirsin.';
    _users.add(u);
    await _save();
    await _p.setString('session', _id(u));
    current.value = u;
    return null;
  }

  static Future<String?> login(String name, DateTime? birth) async {
    if (name.trim().isEmpty) return 'Adını yaz.';
    if (birth == null) return 'Doğum tarihini seç.';
    final k = Fmt.key(name);
    final m = _users
        .where((u) => (Fmt.key(u.name) == k || Fmt.key(u.fullName) == k) && _sameDay(u.birth, birth))
        .toList();
    if (m.isEmpty) return 'Bu bilgilerle hesap bulunamadı. Önce hesap açmayı dene.';
    await _p.setString('session', _id(m.first));
    current.value = m.first;
    return null;
  }

  static Future<void> logout() async {
    await _p.remove('session');
    current.value = null;
  }

  static Future<void> deleteAccount() async {
    final u = current.value;
    if (u != null) {
      _users.removeWhere((x) => _id(x) == _id(u));
      await _save();
    }
    await logout();
  }
}
