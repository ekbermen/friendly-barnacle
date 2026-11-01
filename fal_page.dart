import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/readings.dart';
import '../../widgets/widgets.dart';

class FalEntry {
  final String title, text;
  final DateTime time;
  FalEntry(this.title, this.text, this.time);
}

final ValueNotifier<List<FalEntry>> falHistory = ValueNotifier([]);

void _openSheet(BuildContext context, String title, String text) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AC.bg3, AC.navy1]),
        border: Border.all(color: AC.neon2.withOpacity(.7)),
        boxShadow: [BoxShadow(color: AC.neon1.withOpacity(.4), blurRadius: 30)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, shadows: glow(AC.neon2))),
        const SizedBox(height: 12),
        Flexible(child: SingleChildScrollView(child: Text(text, style: const TextStyle(color: AC.text, height: 1.5, fontSize: 15)))),
        const SizedBox(height: 18),
        NeonButton(label: 'Kapat', onTap: () => Navigator.pop(context)),
      ]),
    ),
  );
}

void showFortune(BuildContext context, String title, String text) {
  falHistory.value = [FalEntry(title, text, DateTime.now()), ...falHistory.value];
  _openSheet(context, title, text);
}

class FalPage extends StatefulWidget {
  const FalPage({super.key});
  @override
  State<FalPage> createState() => _FalPageState();
}

class _FalPageState extends State<FalPage> {
  static const modes = ['Kahve Falı', 'Tarot', 'El Falı', 'Günün Kartı', 'Evet/Hayır'];
  int mode = 0;
  int nonce = 0;

  @override
  Widget build(BuildContext context) {
    final u = AuthService.current.value;
    if (u == null) return const SizedBox();
    return Column(children: [
      PageHeader(icon: Icons.auto_awesome, title: 'Fal', trailing: const Icon(Icons.workspace_premium, color: AC.gold)),
      SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: modes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => NeonChip(label: modes[i], selected: mode == i, onTap: () => setState(() => mode = i)),
        ),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 120), children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(a), child: c)),
            child: KeyedSubtree(key: ValueKey(mode), child: _body(u)),
          ),
          const SizedBox(height: 22),
          const Text('Fal Geçmişi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<FalEntry>>(
            valueListenable: falHistory,
            builder: (_, list, __) => list.isEmpty
                ? const Text('Henüz fal bakmadın.', style: TextStyle(color: AC.text3))
                : Column(
                    children: list
                        .take(8)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GlassCard(
                                onTap: () => _openSheet(context, e.title, e.text),
                                padding: const EdgeInsets.all(12),
                                child: Row(children: [
                                  const Icon(Icons.auto_awesome, color: AC.gold, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text(Fmt.time(e.time), style: const TextStyle(color: AC.text3, fontSize: 12)),
                                  ])),
                                  const Icon(Icons.chevron_right, color: AC.text2),
                                ]),
                              ),
                            ))
                        .toList()),
          ),
        ]),
      ),
    ]);
  }

  Widget _body(UserProfile u) {
    switch (mode) {
      case 0:
        return _Hero(
          icon: Icons.coffee_rounded,
          title: 'Kahve Falını Keşfet',
          sub: 'Fincanını seç, geleceğini öğren...',
          button: 'Fincanı Göster',
          onTap: () => showFortune(context, 'Kahve Falı', Readings.coffee(u, nonce++)),
        );
      case 1:
        return TarotSpread(key: const ValueKey('t3'), count: 3, user: u);
      case 2:
        return _Hero(
          icon: Icons.back_hand_rounded,
          title: 'El Falı',
          sub: 'Avucunu tara, çizgilerin ne diyor?',
          button: 'Avucumu Tara',
          onTap: () => showFortune(context, 'El Falı', Readings.palm(u)),
        );
      case 3:
        return TarotSpread(key: const ValueKey('t1'), count: 1, user: u, daily: true);
      default:
        return YesNoOrb(user: u);
    }
  }
}

class _Hero extends StatelessWidget {
  final IconData icon;
  final String title, sub, button;
  final VoidCallback onTap;
  const _Hero({required this.icon, required this.title, required this.sub, required this.button, required this.onTap});
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AC.purple2.withOpacity(.5), AC.navy1.withOpacity(.2)]),
            border: Border.all(color: AC.neon2, width: 1.5),
            boxShadow: [BoxShadow(color: AC.neon1.withOpacity(.5), blurRadius: 40, spreadRadius: 2)],
          ),
          child: Icon(icon, size: 84, color: Colors.white, shadows: glow(AC.neon2, 24)),
        ),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(color: AC.text2)),
        const SizedBox(height: 18),
        NeonButton(label: button, icon: Icons.auto_awesome, onTap: onTap),
      ]);
}

// ───────────── Tarot ─────────────
class TarotSpread extends StatefulWidget {
  final int count;
  final UserProfile user;
  final bool daily;
  const TarotSpread({super.key, required this.count, required this.user, this.daily = false});
  @override
  State<TarotSpread> createState() => _TarotSpreadState();
}

class _TarotSpreadState extends State<TarotSpread> {
  late List<int> cards;
  late List<bool> flipped;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final now = DateTime.now();
    final seed = widget.daily
        ? Readings.h('${widget.user.name}-${now.year}-${now.month}-${now.day}')
        : now.microsecondsSinceEpoch;
    cards = Readings.drawCards(widget.count, seed);
    flipped = List.filled(widget.count, false);
  }

  void _flip(int i) {
    if (flipped[i]) return;
    setState(() => flipped[i] = true);
    if (flipped.every((f) => f)) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          showFortune(context, widget.daily ? 'Günün Kartı' : 'Tarot • Üçlü Dizilim', Readings.tarot(cards, widget.user));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const pos = ['Geçmiş', 'Şimdi', 'Gelecek'];
    return Column(children: [
      Text(widget.daily ? 'Günün kartını çevirmek için dokun' : 'Üç kartı sırayla çevirmek için dokun',
          style: const TextStyle(color: AC.text2)),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.count, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(children: [
            FlipCard(flipped: flipped[i], name: Readings.major[cards[i]][0], onTap: () => _flip(i)),
            const SizedBox(height: 8),
            Text(widget.daily ? 'Bugün' : pos[i], style: const TextStyle(color: AC.text2, fontSize: 12)),
          ]),
        );
      })),
      if (!widget.daily) ...[
        const SizedBox(height: 18),
        NeonButton(label: 'Desteyi Karıştır', icon: Icons.shuffle_rounded, expanded: false, onTap: () => setState(_deal)),
      ],
    ]);
  }
}

class FlipCard extends StatelessWidget {
  final bool flipped;
  final String name;
  final VoidCallback onTap;
  const FlipCard({super.key, required this.flipped, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: flipped ? 1 : 0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) {
          final front = v > .5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * v),
            child: front
                ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: _face())
                : _back(),
          );
        },
      ),
    );
  }

  Widget _back() => Container(
        width: 96,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AC.purple1, AC.navy2]),
          border: Border.all(color: AC.neon2, width: 1.5),
          boxShadow: [BoxShadow(color: AC.neon1.withOpacity(.55), blurRadius: 18)],
        ),
        child: Icon(Icons.auto_awesome, color: AC.gold, size: 38, shadows: glow(AC.gold)),
      );

  Widget _face() => Container(
        width: 96,
        height: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1466), AC.navy1]),
          border: Border.all(color: AC.gold, width: 1.5),
          boxShadow: [BoxShadow(color: AC.gold.withOpacity(.5), blurRadius: 22)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.brightness_7_rounded, color: AC.gold, size: 34, shadows: glow(AC.gold)),
          const SizedBox(height: 10),
          Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ]),
      );
}

// ───────────── Evet / Hayır küresi ─────────────
class YesNoOrb extends StatefulWidget {
  final UserProfile user;
  const YesNoOrb({super.key, required this.user});
  @override
  State<YesNoOrb> createState() => _YesNoOrbState();
}

class _YesNoOrbState extends State<YesNoOrb> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  String answer = '?';

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 200,
        height: 200,
        child: Stack(alignment: Alignment.center, children: [
          RotationTransition(
            turns: c,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [AC.neon3, AC.purple1, AC.cyan, AC.neon3]),
                boxShadow: [BoxShadow(color: AC.neon1, blurRadius: 36, spreadRadius: -4)],
              ),
            ),
          ),
          Container(
            width: 184,
            height: 184,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AC.navy3, AC.bg1])),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(answer,
                  key: ValueKey(answer),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: answer.length > 10 ? 20 : 30, fontWeight: FontWeight.w800, shadows: glow(AC.cyan))),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('Aklından bir soru geçir, sonra sor.', style: TextStyle(color: AC.text2)),
      const SizedBox(height: 14),
      NeonButton(
        label: 'Soruyu Sor',
        icon: Icons.bubble_chart_rounded,
        onTap: () {
          final a = Readings.yesNo[Random().nextInt(Readings.yesNo.length)];
          setState(() => answer = a);
          falHistory.value = [FalEntry('Evet/Hayır', '${widget.user.name}, küre diyor ki: $a', DateTime.now()), ...falHistory.value];
        },
      ),
    ]);
  }
}
