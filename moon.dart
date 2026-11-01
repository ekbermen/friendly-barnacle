class Moon {
  static const _syn = 29.530588853;

  /// 0..1 arası ay döngüsü (0 = yeni ay, 0.5 = dolunay)
  static double phase(DateTime d) {
    final ref = DateTime.utc(2000, 1, 6, 18, 14);
    final days = d.toUtc().difference(ref).inMinutes / 1440.0;
    var p = (days / _syn) % 1.0;
    if (p < 0) p += 1;
    return p;
  }

  static int index(double p) => ((p * 8) + 0.5).floor() % 8;

  static const names = [
    'Yeni Ay', 'Büyüyen Hilal', 'İlk Dördün', 'Büyüyen Şişkin Ay',
    'Dolunay', 'Küçülen Şişkin Ay', 'Son Dördün', 'Küçülen Hilal'
  ];
  static const meanings = [
    'Yeni başlangıçlar ve niyetler zamanı.',
    'Niyetlerin filizlendiği, küçük adımların değer kazandığı dönem.',
    'Kararlılık ve eyleme geçme enerjisi yüksek.',
    'İnce ayar yapma ve sabırla beklemenin zamanı.',
    'Duyguların zirvede olduğu, niyetlerin netleştiği dönem.',
    'Şükran ve paylaşma dönemi; kazandıklarını gözden geçir.',
    'Bırakma, affetme ve hafifleme zamanı.',
    'Dinlenme, arınma ve yeni döngüye hazırlık.'
  ];
  static const rituals = [
    'Bir kâğıda üç niyet yaz ve sessizce oku.',
    'Niyetin için bugün yapabileceğin tek küçük adımı at.',
    'Ertelediğin bir işe başla; on dakika yeter.',
    'Planını gözden geçir, gereksiz olanı ele.',
    'Su iç, açık havada birkaç nefes al, minnet listesi yaz.',
    'Bir iyiliği ilet; birine teşekkür et.',
    'Seni yoran bir düşünceyi yazıp kâğıdı katla ve kenara bırak.',
    'Erken uyu, ekranı azalt, odayı havalandır.'
  ];

  static String name(double p) => names[index(p)];
}
