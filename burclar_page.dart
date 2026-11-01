import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/readings.dart';
import '../../core/zodiac.dart';
import '../../widgets/widgets.dart';

class BurclarPage extends StatelessWidget {
  const BurclarPage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = AuthService.current.value;
    if (u == null) return const SizedBox();
    return Column(children: [
      PageHeader(icon: Icons.auto_awesome, title: 'Burçlar', trailing: const Icon(Icons.search, color: AC.text2)),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .86),
          itemCount: 12,
          itemBuilder: (_, i) {
            final z = Zodiac.all[i];
            final mine = z.name == u.sign.name;
            return GlassCard(
              glowColor: z.color,
              padding: const EdgeInsets.all(8),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: ZodiacDetail(z: z)),
              )),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (mine)
                  const Text('SENİN', style: TextStyle(color: AC.gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                Hero(tag: 'z-${z.name}', child: Material(type: MaterialType.transparency, child: ZodiacGlyph(z, size: 42))),
                const SizedBox(height: 4),
                Text(z.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(z.range, style: const TextStyle(color: AC.text2, fontSize: 10)),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class ZodiacDetail extends StatefulWidget {
  final Zodiac z;
  const ZodiacDetail({super.key, required this.z});
  @override
  State<ZodiacDetail> createState() => _ZodiacDetailState();
}

class _ZodiacDetailState extends State<ZodiacDetail> {
  static const periods = ['Günlük', 'Haftalık', 'Aylık', 'Yıllık'];
  int p = 0;

  @override
  Widget build(BuildContext context) {
    final z = widget.z;
    final u = AuthService.current.value;
    final now = DateTime.now();
    final sc = Readings.scores(z, now);
    final info = [
      ['Element', z.element], ['Nitelik', z.quality], ['Gezegen', z.planet],
      ['Taş', z.stone], ['Şanslı Gün', z.day], ['Şanslı Sayı', '${z.lucky}'],
    ];
    return Scaffold(
      body: StarfieldBackground(
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AC.text)),
              Text(z.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ]),
            Center(child: Hero(tag: 'z-${z.name}', child: Material(type: MaterialType.transparency, child: ZodiacGlyph(z, size: 96)))),
            Center(child: Text(z.range, style: const TextStyle(color: AC.text2))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: info
                  .map((e) => GlassCard(
                        glowColor: z.color,
                        radius: 14,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(e[0], style: const TextStyle(color: AC.text3, fontSize: 10)),
                          Text(e[1], style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: NeonChip(label: periods[i], selected: p == i, onTap: () => setState(() => p = i)),
                  ))),
            ),
            const SizedBox(height: 12),
            GlassCard(
              glowColor: z.color,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(Readings.reading(z, now, periods[p], name: u?.name),
                    key: ValueKey(p), style: const TextStyle(height: 1.5, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              glowColor: z.color,
              child: Column(children: [
                NeonBar(label: 'Aşk', value: sc[0], color: AC.neon3),
                NeonBar(label: 'Kariyer', value: sc[1], color: AC.cyan),
                NeonBar(label: 'Para', value: sc[2], color: AC.gold),
                NeonBar(label: 'Sağlık', value: sc[3], color: const Color(0xFF4DFFB0)),
              ]),
            ),
            const SizedBox(height: 14),
            GlassCard(
              glowColor: z.color,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Güçlü yönler', style: TextStyle(color: z.color, fontWeight: FontWeight.w700)),
                Text(z.strengths),
                const SizedBox(height: 10),
                const Text('Zayıf yönler', style: TextStyle(color: AC.text2, fontWeight: FontWeight.w700)),
                Text(z.weaknesses),
                const SizedBox(height: 10),
                const Text('Uyumlu burçlar', style: TextStyle(color: AC.neon2, fontWeight: FontWeight.w700)),
                Text(z.compat.join(', ')),
              ]),
            ),
            const SizedBox(height: 12),
            const Center(child: Text('Eğlence amaçlıdır.', style: TextStyle(color: AC.text3, fontSize: 12))),
          ]),
        ),
      ),
    );
  }
}
