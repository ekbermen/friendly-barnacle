import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/aura_colors.dart';
import '../core/zodiac.dart';

// ───────────── Yıldızlı arka plan ─────────────
class _Star {
  final double x, y, r, phase;
  final int k;
  final Color c;
  _Star(this.x, this.y, this.r, this.phase, this.k, this.c);
}

class StarfieldBackground extends StatefulWidget {
  final Widget child;
  const StarfieldBackground({super.key, required this.child});
  @override
  State<StarfieldBackground> createState() => _StarfieldState();
}

class _StarfieldState extends State<StarfieldBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  late final List<_Star> _stars = () {
    final r = Random(42);
    return List.generate(
        220,
        (i) => _Star(r.nextDouble(), r.nextDouble(), .4 + r.nextDouble() * 1.3, r.nextDouble() * 2 * pi,
            1 + r.nextInt(4), i % 9 == 0 ? AC.cyan : (i % 7 == 0 ? AC.neon2 : Colors.white)));
  }();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuraSettings.I,
      builder: (_, __) => Stack(fit: StackFit.expand, children: [
        RepaintBoundary(
            child: CustomPaint(painter: _SkyPainter(_c, _stars, AuraSettings.I.stars))),
        widget.child,
      ]),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final Animation<double> anim;
  final List<_Star> stars;
  final double density;
  _SkyPainter(this.anim, this.stars, this.density) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AC.bg1, AC.bg2, AC.bg3])
              .createShader(rect));
    final c1 = Offset(size.width * .9, size.height * .15);
    canvas.drawCircle(
        c1,
        size.width * .6,
        Paint()
          ..shader = RadialGradient(colors: [AC.purple2.withOpacity(.20), Colors.transparent])
              .createShader(Rect.fromCircle(center: c1, radius: size.width * .6)));
    final c2 = Offset(size.width * .05, size.height * .85);
    canvas.drawCircle(
        c2,
        size.width * .6,
        Paint()
          ..shader = RadialGradient(colors: [AC.blue.withOpacity(.16), Colors.transparent])
              .createShader(Rect.fromCircle(center: c2, radius: size.width * .6)));

    final t = anim.value * 20;
    final n = (stars.length * density).round().clamp(20, stars.length);
    for (var i = 0; i < n; i++) {
      final s = stars[i];
      final a = .25 + .75 * (.5 + .5 * sin(2 * pi * s.k * t / 20 + s.phase));
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.r,
          Paint()..color = s.c.withOpacity(a));
    }
    for (final off in [3.0, 12.0]) {
      final u = (t - off) / 1.2;
      if (u > 0 && u < 1) {
        final sx = size.width * (off == 3.0 ? .75 : .45);
        final p = Offset(sx - u * size.width * .4, size.height * .1 + u * size.height * .18);
        canvas.drawLine(
            p,
            p + const Offset(70, -32),
            Paint()
              ..color = Colors.white.withOpacity(1 - u)
              ..strokeWidth = 2
              ..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => old.density != density;
}

// ───────────── Cam kart ─────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? glowColor;
  final VoidCallback? onTap;
  const GlassCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(14),
      this.radius = 20,
      this.glowColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuraSettings.I,
      builder: (_, __) {
        final g = glowColor ?? AuraSettings.I.a2;
        final k = AuraSettings.I.glowLevel;
        final br = BorderRadius.circular(radius);
        return GestureDetector(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: Container(
            decoration: BoxDecoration(borderRadius: br, boxShadow: [
              BoxShadow(color: g.withOpacity(.28 * k), blurRadius: 24, spreadRadius: 1),
              BoxShadow(color: g.withOpacity(.16 * k), blurRadius: 8),
            ]),
            child: ClipRRect(
              borderRadius: br,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    borderRadius: br,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AC.purple2.withOpacity(.22), AC.navy2.withOpacity(.38)]),
                    border: Border.all(color: g.withOpacity(.6), width: 1),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────── Neon buton ─────────────
class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expanded;
  const NeonButton({super.key, required this.label, this.icon, this.onTap, this.expanded = true});
  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuraSettings.I,
      builder: (_, __) {
        final s = AuraSettings.I;
        return GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  widget.onTap!();
                },
          child: AnimatedScale(
            scale: _down ? .95 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: widget.expanded ? double.infinity : null,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(colors: [s.a1, s.a2]),
                boxShadow: [
                  BoxShadow(color: s.a2.withOpacity(.6 * s.glowLevel), blurRadius: 20),
                  BoxShadow(color: s.a1.withOpacity(.4 * s.glowLevel), blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                  Text(widget.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────── Neon çip ─────────────
class NeonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const NeonChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuraSettings.I,
      builder: (_, __) {
        final s = AuraSettings.I;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: selected ? LinearGradient(colors: [s.a1, s.a2]) : null,
              color: selected ? null : AC.navy1.withOpacity(.5),
              border: Border.all(color: selected ? s.a2 : AC.purple3.withOpacity(.5)),
              boxShadow: selected ? [BoxShadow(color: s.a2.withOpacity(.55 * s.glowLevel), blurRadius: 14)] : null,
            ),
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : AC.text2,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ),
        );
      },
    );
  }
}

// ───────────── Alt gezinme ─────────────
class AuraBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const AuraBottomNav({super.key, required this.index, required this.onChanged});

  static const items = [
    (Icons.coffee_rounded, 'Fal'),
    (Icons.auto_awesome, 'Burçlar'),
    (Icons.favorite_rounded, 'Uyum'),
    (Icons.psychology_alt_rounded, 'Aura Zihni'),
    (Icons.nightlight_round, 'Ritüel'),
    (Icons.settings_rounded, 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuraSettings.I,
      builder: (_, __) {
        final s = AuraSettings.I;
        return GlassCard(
          radius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final on = i == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(i);
                  },
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: on ? 42 : 30,
                      height: on ? 42 : 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: on ? LinearGradient(colors: [s.a1, s.a2]) : null,
                        boxShadow: on ? [BoxShadow(color: s.a2.withOpacity(.7 * s.glowLevel), blurRadius: 16)] : null,
                      ),
                      child: Icon(items[i].$1, size: on ? 22 : 20, color: on ? Colors.white : AC.text2),
                    ),
                    const SizedBox(height: 3),
                    Text(items[i].$2,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 9.5,
                            color: on ? Colors.white : AC.text3,
                            fontWeight: on ? FontWeight.w700 : FontWeight.w400)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 3),
                      height: 2,
                      width: on ? 18 : 0,
                      decoration: BoxDecoration(
                        color: s.a2,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(color: s.a2, blurRadius: 6)],
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ───────────── Küçük yardımcılar ─────────────
class PageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  const PageHeader({super.key, required this.icon, required this.title, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        child: Row(children: [
          Icon(icon, color: AC.neon2, shadows: glow(AC.neon2)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AC.text)),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
      );
}

class ZodiacGlyph extends StatelessWidget {
  final Zodiac z;
  final double size;
  const ZodiacGlyph(this.z, {super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => Text(z.glyph,
      style: TextStyle(fontSize: size, color: z.color, height: 1.1, shadows: glow(z.color, 16)));
}

class AuraField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  const AuraField(
      {super.key, this.controller, required this.label, required this.icon, this.readOnly = false, this.onTap});
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: AC.text),
        textCapitalization: TextCapitalization.words,
        cursorColor: AC.neon2,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AC.text2),
          prefixIcon: Icon(icon, color: AC.purple3),
          filled: true,
          fillColor: AC.navy1.withOpacity(.55),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AC.purple3.withOpacity(.5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AC.neon2, width: 1.5)),
        ),
      );
}

class NeonBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const NeonBar({super.key, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(width: 64, child: Text(label, style: const TextStyle(color: AC.text2, fontSize: 13))),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Container(
                height: 8,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(color: AC.navy1, borderRadius: BorderRadius.circular(8)),
                child: FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: color.withOpacity(.8), blurRadius: 8)]),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
              width: 44,
              child: Text('%$value', textAlign: TextAlign.right, style: const TextStyle(color: AC.text, fontSize: 12))),
        ]),
      );
}

// ───────────── Dairesel gösterge ─────────────
class CircularNeonGauge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final double size;
  const CircularNeonGauge(
      {super.key, required this.label, required this.value, required this.color, required this.icon, this.size = 118});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value / 100),
        duration: const Duration(milliseconds: 1300),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _GaugePainter(v, color),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, color: color, size: 22, shadows: glow(color)),
                Text(label, style: const TextStyle(color: AC.text, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('%${(v * 100).round()}', style: const TextStyle(color: AC.text, fontSize: 15, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      );
}

class _GaugePainter extends CustomPainter {
  final double v;
  final Color color;
  _GaugePainter(this.v, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 8);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = color.withOpacity(.18);
    canvas.drawArc(rect, 0, 2 * pi, false, base);
    final glowP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11
      ..color = color.withOpacity(.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = color;
    canvas.drawArc(rect, -pi / 2, 2 * pi * v, false, glowP);
    canvas.drawArc(rect, -pi / 2, 2 * pi * v, false, p);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter o) => o.v != v || o.color != color;
}

// ───────────── Ay evresi çizimi ─────────────
class MoonPainter extends CustomPainter {
  final double phase; // 0..1
  MoonPainter(this.phase);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2A2060));
    final k = cos(2 * pi * phase); // 1: yeni, -1: dolunay
    final waxing = phase < .5;
    canvas.save();
    if (!waxing) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final path = Path()..arcTo(Rect.fromCircle(center: c, radius: r), -pi / 2, pi, false);
    final rx = (r * k).abs();
    path.arcTo(Rect.fromCenter(center: c, width: 2 * rx, height: 2 * r), pi / 2, k > 0 ? -pi : pi, false);
    path.close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFF1C2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MoonPainter o) => o.phase != phase;
}

class MoonIcon extends StatelessWidget {
  final double phase, size;
  const MoonIcon(this.phase, {super.key, this.size = 18});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: MoonPainter(phase));
}
