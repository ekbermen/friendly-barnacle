import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/readings.dart';
import '../../core/zodiac.dart';
import '../../widgets/widgets.dart';

class UyumPage extends StatefulWidget {
  const UyumPage({super.key});
  @override
  State<UyumPage> createState() => _UyumPageState();
}

class _UyumPageState extends State<UyumPage> {
  Zodiac? a, b;
  List<int>? scores;
  int calc = 0;

  @override
  Widget build(BuildContext context) {
    final u = AuthService.current.value;
    if (u == null) return const SizedBox();
    a ??= u.sign;
    b ??= Zodiac.all[(Zodiac.all.indexOf(u.sign) + 6) % 12];
    return Column(children: [
      PageHeader(icon: Icons.favorite_rounded, title: 'Uyum'),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 6, 18, 120), children: [
          Row(children: [
            Expanded(child: _picker(a!, (z) => setState(() { a = z; scores = null; }))),
            const SizedBox(width: 12),
            Expanded(child: _picker(b!, (z) => setState(() { b = z; scores = null; }))),
          ]),
          const SizedBox(height: 14),
          NeonButton(
            label: 'Hesapla',
            icon: Icons.auto_awesome,
            onTap: () => setState(() {
              scores = Readings.compat(a!, b!);
              calc++;
            }),
          ),
          if (scores != null) ...[
            const SizedBox(height: 22),
            Wrap(alignment: WrapAlignment.center, spacing: 18, runSpacing: 18, key: ValueKey(calc), children: [
              CircularNeonGauge(label: 'Aşk', value: scores![0], color: AC.neon3, icon: Icons.favorite),
              CircularNeonGauge(label: 'Arkadaşlık', value: scores![1], color: AC.cyan, icon: Icons.people_alt_rounded),
              CircularNeonGauge(label: 'İş', value: scores![2], color: AC.gold, icon: Icons.work_rounded),
              CircularNeonGauge(label: 'Aile', value: scores![3], color: const Color(0xFF4DFFB0), icon: Icons.home_rounded),
            ]),
            const SizedBox(height: 22),
            GlassCard(
              glowColor: AC.neon3,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Uyum Raporu', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                Text(Readings.compatReport(a!, b!, scores!, name: u.name), style: const TextStyle(height: 1.5)),
                const SizedBox(height: 10),
                const Text('Eğlence amaçlıdır.', style: TextStyle(color: AC.text3, fontSize: 12)),
              ]),
            ),
          ],
        ]),
      ),
    ]);
  }

  Widget _picker(Zodiac cur, ValueChanged<Zodiac> on) => GlassCard(
        radius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: cur.name,
            isExpanded: true,
            dropdownColor: AC.bg3,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AC.text2),
            items: Zodiac.all
                .map((z) => DropdownMenuItem(
                      value: z.name,
                      child: Row(children: [ZodiacGlyph(z, size: 22), const SizedBox(width: 8), Text(z.name)]),
                    ))
                .toList(),
            onChanged: (n) => on(Zodiac.byName(n!)),
          ),
        ),
      );
}
