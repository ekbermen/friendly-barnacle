import 'dart:math';
import 'auth_service.dart';
import 'moon.dart';
import 'zodiac.dart';

/// Deterministik (seed'li) yorum üretici. Aynı gün + aynı burç = aynı yorum.
class Readings {
  static int h(String s) {
    var v = 7;
    for (final c in s.codeUnits) {
      v = (v * 31 + c) & 0x7fffffff;
    }
    return v;
  }

  static Random rng(String s) => Random(h(s));

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _fill(String t, Zodiac z, String? name, String p) {
    var s = t
        .replaceAll('{n}', name == null ? '' : '$name, ')
        .replaceAll('{p}', p)
        .replaceAll('{planet}', z.planet)
        .replaceAll('{sign}', z.name)
        .replaceAll('{element}', z.element.toLowerCase())
        .replaceAll('{stone}', z.stone)
        .replaceAll('{lucky}', '${z.lucky}');
    if (name == null) s = _cap(s);
    return s;
  }

  static const _open = [
    '{n}{p} {planet} etkisi {sign} burcunda belirgin biçimde hissediliyor.',
    '{n}{p} {element} elementinin enerjisi seni doğru yöne çekiyor.',
    '{n}{p} içsel sesin her zamankinden daha net duyuluyor.',
    '{n}{p} gökyüzü sana yeni bir kapı aralıyor.',
    '{n}{p} kozmik akış senden yana, sakin kalman yeterli.',
    '{n}{p} {sign} enerjin yükselişte ve çevren bunu fark edecek.',
  ];
  static const _mid = [
    'Aşk hayatında samimi bir konuşma bağları güçlendirebilir.',
    'Kariyerinde ertelediğin bir adımı atmak için uygun bir zaman.',
    'Maddi konularda acele karar vermemek sana kazandırır.',
    'Bedenini dinlemek ve dinlenmeye zaman ayırmak enerjini toparlar.',
    'Yakın çevrenden gelen bir haber ruh halini olumlu etkileyebilir.',
    'Yaratıcı fikirlerini paylaşmaktan çekinme, karşılık bulacaksın.',
    'Eski bir konuyu kapatmak içini hafifletecek.',
    'Yeni tanışacağın biri bakış açını genişletebilir.',
  ];
  static const _end = [
    'Şanslı sayın {lucky}; {stone} taşını yanında taşımak sana iyi gelebilir.',
    'Gün sonunda kendine küçük bir teşekkür et.',
    'Derin bir nefes al ve kalbinin yönünü izle.',
    'Küçük adımlar büyük farklar yaratır.',
    'Kendi ritmine güven; yıldızlar acele etmez.',
    'Sezgilerin pusulan olsun.',
  ];

  static String _dateKey(DateTime d, String period) {
    switch (period) {
      case 'Haftalık':
        final w = d.difference(DateTime(d.year, 1, 1)).inDays ~/ 7;
        return '${d.year}-w$w';
      case 'Aylık':
        return '${d.year}-${d.month}';
      case 'Yıllık':
        return '${d.year}';
      default:
        return '${d.year}-${d.month}-${d.day}';
    }
  }

  static String _pword(String period) =>
      {'Günlük': 'bugün', 'Haftalık': 'bu hafta', 'Aylık': 'bu ay', 'Yıllık': 'bu yıl'}[period] ?? 'bugün';

  static String reading(Zodiac z, DateTime d, String period, {String? name}) {
    final r = rng('$period-${z.name}-${_dateKey(d, period)}');
    final p = _pword(period);
    final mids = List<String>.from(_mid)..shuffle(r);
    final parts = [
      _open[r.nextInt(_open.length)],
      mids[0],
      mids[1],
      _end[r.nextInt(_end.length)],
    ];
    return parts.map((t) => _fill(t, z, name, p)).join(' ');
  }

  /// [aşk, kariyer, para, sağlık] 0-100
  static List<int> scores(Zodiac z, DateTime d) {
    final r = rng('score-${z.name}-${_dateKey(d, 'Günlük')}');
    return List.generate(4, (_) => 55 + r.nextInt(45));
  }

  // ---------- UYUM ----------
  static List<int> compat(Zodiac a, Zodiac b) {
    final names = [a.name, b.name]..sort();
    final r = rng('compat-${names.join('-')}');
    int base;
    if (a.element == b.element) {
      base = 84;
    } else if ({a.element, b.element}.containsAll({'Ateş', 'Hava'}) ||
        {a.element, b.element}.containsAll({'Toprak', 'Su'})) {
      base = 78;
    } else {
      base = 60;
    }
    if (a.compat.contains(b.name) || b.compat.contains(a.name)) base += 6;
    return List.generate(4, (_) => (base - 8 + r.nextInt(17)).clamp(35, 99));
  }

  static String compatReport(Zodiac a, Zodiac b, List<int> s, {String? name}) {
    final best = s.indexOf(s.reduce(max));
    const areas = ['aşkta', 'arkadaşlıkta', 'iş hayatında', 'ailede'];
    final who = name == null ? '' : '$name, ';
    return '$who${a.name} ve ${b.name} birlikte ${areas[best]} en güçlü uyumu yakalıyor. '
        '${a.element} ile ${b.element} elementlerinin buluşması ${a.element == b.element ? 'doğal bir anlayış' : 'tamamlayıcı bir denge'} getiriyor. '
        'Açık iletişim ve karşılıklı sabır bu bağı daha da güçlendirir.';
  }

  // ---------- FAL ----------
  static const _symbols = [
    ['Kuş', 'yakında müjdeli bir haber'],
    ['Yol', 'yeni bir yolculuk ya da değişim'],
    ['Yüzük', 'güçlü bir bağ ve söz'],
    ['Kalp', 'duygusal bir yakınlaşma'],
    ['Anahtar', 'bir meselenin çözülmesi'],
    ['Balık', 'bereket ve bolluk'],
    ['Göz', 'dikkatli olman gereken bir durum'],
    ['Ağaç', 'sağlam temeller ve büyüme'],
    ['Dağ', 'aşılacak ama seni güçlendirecek bir engel'],
    ['Yıldız', 'şanslı bir dönemin habercisi'],
  ];

  static String coffee(UserProfile u, int nonce) {
    final r = rng('coffee-${u.name}-${DateTime.now().day}-$nonce');
    final s = List<List<String>>.from(_symbols)..shuffle(r);
    return '${u.name}, fincanında ${s[0][0].toLowerCase()}, ${s[1][0].toLowerCase()} ve ${s[2][0].toLowerCase()} görünüyor.\n\n'
        '${s[0][0]}: ${s[0][1]}.\n${s[1][0]}: ${s[1][1]}.\n${s[2][0]}: ${s[2][1]}.\n\n'
        '${u.sign.name} burcunun ${u.sign.element.toLowerCase()} enerjisi bu işaretleri destekliyor. Eğlence amaçlıdır.';
  }

  static const major = [
    ['Deli', 'yeni bir başlangıç, cesaret'],
    ['Büyücü', 'irade ve yaratım gücü'],
    ['Azize', 'sezgi ve gizli bilgi'],
    ['İmparatoriçe', 'bolluk, şefkat, üretkenlik'],
    ['İmparator', 'düzen, otorite, istikrar'],
    ['Aziz', 'rehberlik ve gelenek'],
    ['Aşıklar', 'seçimler ve güçlü bağlar'],
    ['Savaş Arabası', 'kararlılık ve zafer'],
    ['Güç', 'sabırlı cesaret, içsel güç'],
    ['Ermiş', 'içe dönüş, bilgelik'],
    ['Kader Çarkı', 'döngüler ve şanslı dönüş'],
    ['Adalet', 'denge ve dürüstlük'],
    ['Asılan Adam', 'bakış açısı değiştirmek'],
    ['Ölüm', 'dönüşüm ve bir döngünün bitişi'],
    ['Denge', 'ölçülülük ve uyum'],
    ['Şeytan', 'bağımlılıkları fark etme'],
    ['Kule', 'ani değişim, yıkıp yeniden kurma'],
    ['Yıldız', 'umut ve şifa'],
    ['Ay', 'rüyalar, belirsizlik, sezgi'],
    ['Güneş', 'neşe, başarı, canlılık'],
    ['Mahkeme', 'uyanış ve yeni karar'],
    ['Dünya', 'tamamlanma ve ödül'],
  ];

  static List<int> drawCards(int count, int seed) {
    final idx = List.generate(major.length, (i) => i)..shuffle(Random(seed));
    return idx.take(count).toList();
  }

  static String tarot(List<int> cards, UserProfile u) {
    const pos = ['Geçmiş', 'Şimdi', 'Gelecek'];
    final b = StringBuffer();
    if (cards.length == 1) {
      final c = major[cards[0]];
      b.write('${c[0]}: ${c[1]}.\n\n${u.name}, bugün bu kartın temasını yanında taşı.');
    } else {
      for (var i = 0; i < cards.length; i++) {
        b.writeln('${pos[i]} • ${major[cards[i]][0]}: ${major[cards[i]][1]}.');
      }
      b.write('\n${u.name}, bu dizilim ${u.sign.name} enerjinle birlikte dönüşüm ve farkındalık vurgusu yapıyor.');
    }
    return b.toString();
  }

  static String palm(UserProfile u) {
    final r = rng('palm-${u.name}-${DateTime.now().millisecondsSinceEpoch ~/ 60000}');
    const life = ['Hayat çizgin canlı ve güçlü.', 'Hayat çizgin yeni bir enerji dalgasına işaret ediyor.'];
    const heart = ['Kalp çizgin açık ve cömert bir kalbi gösteriyor.', 'Kalp çizgin yakında güzel bir yakınlaşmaya işaret ediyor.'];
    const head = ['Akıl çizgin net kararlar için hazır.', 'Akıl çizgin yaratıcı fikirlerle dolu.'];
    return '${u.name}, avucunu taradım:\n\n${life[r.nextInt(2)]}\n${heart[r.nextInt(2)]}\n${head[r.nextInt(2)]}\n\nEğlence amaçlıdır.';
  }

  static const yesNo = ['Evet', 'Hayır', 'Büyük ihtimalle', 'Şimdilik değil', 'Kesinlikle', 'Sezgin ne diyor?'];

  // ---------- AURA ZİHNİ ----------
  static bool _any(String m, List<String> k) => k.any(m.contains);

  static String chat(String msg, UserProfile u, DateTime now) {
    final m = Fmt.key(msg);
    final z = u.sign;
    final n = u.name;
    final moon = Moon.name(Moon.phase(now));

    if (_any(m, ['intihar', 'kendimi öldür', 'kendime zarar', 'yaşamak istemiyorum'])) {
      return '$n, bunu benimle paylaştığın için teşekkür ederim. Yaşadığın şey çok ağır olabilir ve yalnız kalmaman gerekiyor. '
          'Lütfen güvendiğin biriyle konuş ya da 112 acil hattını ara. Burada seni dinlemek için varım.';
    }
    if (_any(m, ['merhaba', 'selam', 'günaydın', 'iyi akşamlar'])) {
      return 'Merhaba $n! ${z.name} burcunun ${z.element.toLowerCase()} enerjisini yanımda hissediyorum. Ay şu an $moon evresinde. Ne öğrenmek istersin?';
    }
    if (_any(m, ['teşekkür', 'sağ ol', 'sağol'])) return 'Ne demek $n, yıldızlar hep yanında. ✨';
    if (_any(m, ['aşk', 'sevgi', 'ilişki', 'sevgili', 'flört'])) {
      final sc = scores(z, now)[0];
      return '$n, ${z.name} burcu için bugün aşk enerjin %$sc. ${z.planet} etkisiyle duygularını açık ifade etmek bağlarını güçlendirir. ${z.compat.first} ve ${z.compat.last} burçlarıyla uyumun yüksek.';
    }
    if (_any(m, ['kariyer', 'işim', 'iş ', 'çalış', 'terfi', 'patron'])) {
      final sc = scores(z, now)[1];
      return '$n, kariyer enerjin bugün %$sc. ${z.strengths.split(',').first} yönün öne çıkıyor; ertelediğin bir adımı atmak için uygun bir gün.';
    }
    if (_any(m, ['para', 'maddi', 'bütçe', 'yatırım'])) {
      final sc = scores(z, now)[2];
      return '$n, maddi enerjin %$sc. Acele kararlardan kaçın. Not: yıldızlar finansal tavsiye vermez, bu yorum eğlence amaçlıdır.';
    }
    if (_any(m, ['sağlık', 'enerji', 'yorgun', 'uyku'])) {
      final sc = scores(z, now)[3];
      return '$n, bugün enerjin %$sc. Dinlenmeye ve suya zaman ayır. Sağlık konularında mutlaka uzmana danış; bu yorum eğlence amaçlıdır.';
    }
    if (_any(m, ['retro'])) {
      return '$n, retro dönemlerinde iletişimi yavaşlatmak ve yeniden gözden geçirmek iyi gelir. ${z.name} için bu, ${z.planet} temalı konularda sabır demek.';
    }
    if (_any(m, ['ay evresi', 'dolunay', 'yeni ay', 'ay '])) {
      return 'Ay şu an $moon evresinde. ${Moon.meanings[Moon.index(Moon.phase(now))]} ${Moon.rituals[Moon.index(Moon.phase(now))]}';
    }
    if (_any(m, ['burç', 'burcum'])) {
      return '$n, sen ${z.name} burcusun (${z.range}). Elementin ${z.element}, yöneticin ${z.planet}. Güçlü yanların: ${z.strengths.toLowerCase()}.';
    }
    return reading(z, now, 'Günlük', name: n);
  }
}
