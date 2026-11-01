import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/moon.dart';
import '../../widgets/widgets.dart';

class RitualPage extends StatefulWidget {
  const RitualPage({super.key});
  @override
  State<RitualPage> createState() => _RitualPageState();
}

class _RitualPageState extends State<RitualPage> {
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected = DateTime.now();
  final ctrl = TextEditingController();
  final notes = <String>[];

  static const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
  // Pazartesiden başlayarak gün yöneticisi, taş, renk
  static const rulers = [
    ['Ay', 'Ay taşı', 'gümüş'],
    ['Mars', 'Kırmızı jasper', 'kırmızı'],
    ['Merkür', 'Akik', 'sarı'],
    ['Jüpiter', 'Ametist', 'mor'],
    ['Venüs', 'Gül kuvars', 'pembe'],
    ['Satürn', 'Obsidyen', 'siyah'],
    ['Güneş', 'Sitrin', 'altın'],
  ];

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final u = AuthService.current.value;
    if (u == null) return const SizedBox();
    final first = DateTime(month.year, month.month, 1);
    final count = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1;
    final today = DateTime.now();
    final ph = Moon.phase(DateTime(selected.year, selected.month, selected.day, 12));
    final pi = Moon.index(ph);
    final r = rulers[selected.weekday - 1];

    return Column(children: [
      PageHeader(icon: Icons.nightlight_round, title: 'Ritüel', trailing: const Icon(Icons.calendar_month, color: AC.text2)),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 120), children: [
          GlassCard(
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)),
                Text('${Fmt.months[month.month - 1]} ${month.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                IconButton(onPressed: () => setState(() => month = DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right)),
              ]),
              Row(children: days.map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: AC.text3, fontSize: 11))))).toList()),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: .85,
                children: [
                  ...List.generate(lead, (_) => const SizedBox()),
                  ...List.generate(count, (i) {
                    final d = DateTime(month.year, month.month, i + 1);
                    final sel = _same(d, selected);
                    final isToday = _same(d, today);
                    return GestureDetector(
                      onTap: () => setState(() => selected = d),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: sel ? Border.all(color: AC.neon2, width: 1.5) : (isToday ? Border.all(color: AC.cyan.withOpacity(.7)) : null),
                          boxShadow: sel ? [BoxShadow(color: AC.neon2.withOpacity(.5), blurRadius: 10)] : null,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('${i + 1}', style: TextStyle(fontSize: 12, color: sel ? Colors.white : AC.text2, fontWeight: sel ? FontWeight.w800 : FontWeight.w400)),
                          const SizedBox(height: 2),
                          MoonIcon(Moon.phase(DateTime(d.year, d.month, d.day, 12)), size: 14),
                        ]),
                      ),
                    );
                  }),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 14),
          GlassCard(
            glowColor: AC.gold,
            child: Row(children: [
              MoonIcon(ph, size: 64),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(Fmt.date(selected), style: const TextStyle(color: AC.text3, fontSize: 12)),
                  Text(Moon.names[pi], style: TextStyle(color: AC.gold, fontWeight: FontWeight.w800, fontSize: 20, shadows: glow(AC.gold, 8))),
                  const SizedBox(height: 4),
                  Text(Moon.meanings[pi], style: const TextStyle(fontSize: 13, height: 1.35)),
                  const SizedBox(height: 6),
                  Text('Ritüel: ${Moon.rituals[pi]}', style: const TextStyle(color: AC.text2, fontSize: 12.5, height: 1.35)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Günlük Kozmik Rutin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Günün yöneticisi: ${r[0]}', style: const TextStyle(color: AC.text2, fontSize: 12)),
          const SizedBox(height: 10),
          Row(children: [
            _routine('Sabah', 'Niyet Et', Icons.wb_sunny_rounded, AC.gold, '${u.name}, bugün için tek bir niyet belirle.'),
            const SizedBox(width: 10),
            _routine('Öğle', 'Odaklan', Icons.self_improvement_rounded, AC.cyan, '4-4-4 nefes al; ${r[1]} taşını elinde tut.'),
            const SizedBox(width: 10),
            _routine('Akşam', 'Rahatla', Icons.bedtime_rounded, AC.neon2, 'Üç şükür yaz; ${r[2]} tonlarında bir ışık seç.'),
          ]),
          const SizedBox(height: 18),
          const Text('Astro Günlüğü', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(color: AC.text),
                  cursorColor: AC.neon2,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Bugün yaşadıklarını yaz...', hintStyle: TextStyle(color: AC.text3)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: AC.neon2),
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) return;
                  setState(() {
                    notes.insert(0, '${Fmt.date(selected)} • ${Moon.names[pi]} • ${u.sign.name} Güneşi\n${ctrl.text.trim()}');
                    ctrl.clear();
                  });
                  FocusScope.of(context).unfocus();
                },
              ),
            ]),
          ),
          ...notes.map((n) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GlassCard(child: SizedBox(width: double.infinity, child: Text(n, style: const TextStyle(height: 1.4, fontSize: 13)))),
              )),
        ]),
      ),
    ]);
  }

  Widget _routine(String t, String s, IconData ic, Color c, String detail) => Expanded(
        child: GlassCard(
          glowColor: c,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AC.bg3,
              title: Text('$t • $s', style: TextStyle(color: c)),
              content: Text(detail),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam'))],
            ),
          ),
          child: Column(children: [
            Icon(ic, color: c, shadows: glow(c)),
            const SizedBox(height: 4),
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text(s, style: const TextStyle(color: AC.text2, fontSize: 11)),
          ]),
        ),
      );
}
