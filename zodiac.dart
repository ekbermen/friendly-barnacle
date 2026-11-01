import 'package:flutter/material.dart';

class Zodiac {
  final String name, glyph, range, element, quality, planet, stone, day, strengths, weaknesses;
  final Color color;
  final int lucky;
  final List<String> compat;
  const Zodiac(this.name, this.glyph, this.range, this.element, this.quality, this.planet,
      this.stone, this.day, this.lucky, this.color, this.strengths, this.weaknesses, this.compat);

  static const all = <Zodiac>[
    Zodiac('Koç', '\u2648\uFE0E', '21.03 - 20.04', 'Ateş', 'Öncü', 'Mars', 'Elmas', 'Salı', 9, Color(0xFFFF4D4D),
        'Cesur, enerjik, lider ruhlu', 'Sabırsız, çabuk öfkelenen', ['Aslan', 'Yay', 'İkizler']),
    Zodiac('Boğa', '\u2649\uFE0E', '21.04 - 21.05', 'Toprak', 'Sabit', 'Venüs', 'Zümrüt', 'Cuma', 6, Color(0xFF3DDC84),
        'Sadık, sabırlı, güvenilir', 'İnatçı, değişime kapalı', ['Başak', 'Oğlak', 'Yengeç']),
    Zodiac('İkizler', '\u264A\uFE0E', '22.05 - 21.06', 'Hava', 'Değişken', 'Merkür', 'Akik', 'Çarşamba', 5, Color(0xFF3D8BFF),
        'Meraklı, esprili, uyumlu', 'Kararsız, dağınık', ['Terazi', 'Kova', 'Koç']),
    Zodiac('Yengeç', '\u264B\uFE0E', '22.06 - 22.07', 'Su', 'Öncü', 'Ay', 'İnci', 'Pazartesi', 2, Color(0xFF00E5FF),
        'Sezgisel, koruyucu, şefkatli', 'Alıngan, içine kapanık', ['Akrep', 'Balık', 'Boğa']),
    Zodiac('Aslan', '\u264C\uFE0E', '23.07 - 22.08', 'Ateş', 'Sabit', 'Güneş', 'Yakut', 'Pazar', 1, Color(0xFFFFC21C),
        'Cömert, karizmatik, yaratıcı', 'Gururlu, ilgi düşkünü', ['Koç', 'Yay', 'Terazi']),
    Zodiac('Başak', '\u264D\uFE0E', '23.08 - 22.09', 'Toprak', 'Değişken', 'Merkür', 'Safir', 'Çarşamba', 7, Color(0xFF4DFFB0),
        'Analitik, titiz, yardımsever', 'Eleştirel, aşırı kaygılı', ['Boğa', 'Oğlak', 'Akrep']),
    Zodiac('Terazi', '\u264E\uFE0E', '23.09 - 22.10', 'Hava', 'Öncü', 'Venüs', 'Opal', 'Cuma', 6, Color(0xFFE040FB),
        'Dengeli, nazik, estetik bakışlı', 'Kararsız, çatışmadan kaçan', ['İkizler', 'Kova', 'Aslan']),
    Zodiac('Akrep', '\u264F\uFE0E', '23.10 - 22.11', 'Su', 'Sabit', 'Plüton', 'Topaz', 'Salı', 8, Color(0xFFB44DFF),
        'Tutkulu, kararlı, derin', 'Kıskanç, kontrolcü', ['Yengeç', 'Balık', 'Başak']),
    Zodiac('Yay', '\u2650\uFE0E', '23.11 - 21.12', 'Ateş', 'Değişken', 'Jüpiter', 'Turkuaz', 'Perşembe', 3, Color(0xFFFF9A3D),
        'İyimser, özgür, felsefi', 'Patavatsız, huzursuz', ['Koç', 'Aslan', 'Kova']),
    Zodiac('Oğlak', '\u2651\uFE0E', '22.12 - 20.01', 'Toprak', 'Öncü', 'Satürn', 'Garnet', 'Cumartesi', 8, Color(0xFF2DE0C8),
        'Disiplinli, hırslı, sorumluluk sahibi', 'Katı, aşırı ciddi', ['Boğa', 'Başak', 'Akrep']),
    Zodiac('Kova', '\u2652\uFE0E', '21.01 - 19.02', 'Hava', 'Sabit', 'Uranüs', 'Ametist', 'Cumartesi', 4, Color(0xFF3DB8FF),
        'Özgün, yenilikçi, insancıl', 'Mesafeli, öngörülemez', ['İkizler', 'Terazi', 'Yay']),
    Zodiac('Balık', '\u2653\uFE0E', '20.02 - 20.03', 'Su', 'Değişken', 'Neptün', 'Aytaşı', 'Perşembe', 7, Color(0xFF8F7BFF),
        'Hayalperest, empatik, sanatsal', 'Kaçamak, fazla duygusal', ['Yengeç', 'Akrep', 'Oğlak']),
  ];

  /// Doğum tarihinden güneş burcunu bulur.
  static Zodiac fromDate(DateTime d) {
    final md = d.month * 100 + d.day;
    const cuts = [120, 220, 321, 421, 522, 622, 723, 823, 923, 1023, 1123, 1222];
    const idx = [10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    var s = 9; // Oğlak (1 Ocak - 19 Ocak)
    for (var i = 0; i < cuts.length; i++) {
      if (md >= cuts[i]) s = idx[i];
    }
    return all[s];
  }

  static Zodiac byName(String n) => all.firstWhere((z) => z.name == n);
}
