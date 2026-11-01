import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/readings.dart';
import '../../widgets/widgets.dart';

class _Msg {
  final String text;
  final bool mine;
  _Msg(this.text, this.mine);
}

class AuraZihniPage extends StatefulWidget {
  const AuraZihniPage({super.key});
  @override
  State<AuraZihniPage> createState() => _AuraZihniPageState();
}

class _AuraZihniPageState extends State<AuraZihniPage> {
  final msgs = <_Msg>[];
  final ctrl = TextEditingController();
  final scroll = ScrollController();
  bool typing = false;
  bool greeted = false;

  static const quick = ['Bugün enerjim nasıl?', 'Aşk yorumu', 'Kariyer', 'Ay evresi', 'Para'];

  @override
  void dispose() {
    ctrl.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _down() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) {
          scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        }
      });

  void send(String t, UserProfile u) {
    if (t.trim().isEmpty || typing) return;
    ctrl.clear();
    setState(() {
      msgs.add(_Msg(t.trim(), true));
      typing = true;
    });
    _down();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        msgs.add(_Msg(Readings.chat(t, u, DateTime.now()), false));
        typing = false;
      });
      _down();
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.current.value;
    if (u == null) return const SizedBox();
    if (!greeted) {
      greeted = true;
      msgs.add(_Msg('Merhaba ${u.name}! Ben AURA. ${u.sign.name} burcunun ${u.sign.element.toLowerCase()} enerjisini yanımda hissediyorum. Bana aşk, kariyer, para ya da ay evresi hakkında soru sorabilirsin. ✨', false));
    }
    final kb = MediaQuery.of(context).viewInsets.bottom > 0;
    return Column(children: [
      PageHeader(icon: Icons.psychology_alt_rounded, title: 'Aura Zihni', trailing: const Icon(Icons.workspace_premium, color: AC.gold)),
      SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: quick.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => NeonChip(label: quick[i], selected: false, onTap: () => send(quick[i], u)),
        ),
      ),
      Expanded(
        child: ListView.builder(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          itemCount: msgs.length + (typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == msgs.length) return const _Bubble(child: _TypingDots(), mine: false);
            return _Bubble(mine: msgs[i].mine, child: Text(msgs[i].text, style: const TextStyle(height: 1.4, fontSize: 15)));
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(14, 4, 14, kb ? 8 : 96),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: const TextStyle(color: AC.text),
              cursorColor: AC.neon2,
              onSubmitted: (t) => send(t, u),
              decoration: InputDecoration(
                hintText: 'Mesaj yaz...',
                hintStyle: const TextStyle(color: AC.text3),
                filled: true,
                fillColor: AC.navy1.withOpacity(.6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: BorderSide(color: AC.purple3.withOpacity(.5))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(26), borderSide: const BorderSide(color: AC.neon2)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => send(ctrl.text, u),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AC.purple1, AC.neon3]),
                boxShadow: [BoxShadow(color: AC.neon2.withOpacity(.6), blurRadius: 16)],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _Bubble extends StatelessWidget {
  final Widget child;
  final bool mine;
  const _Bubble({required this.child, required this.mine});
  @override
  Widget build(BuildContext context) => Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(mine ? 20 : 4),
              bottomRight: Radius.circular(mine ? 4 : 20),
            ),
            gradient: mine
                ? const LinearGradient(colors: [AC.purple1, AC.neon3])
                : LinearGradient(colors: [AC.navy2.withOpacity(.85), AC.navy1.withOpacity(.85)]),
            border: mine ? null : Border.all(color: AC.cyan.withOpacity(.35)),
            boxShadow: [BoxShadow(color: (mine ? AC.neon2 : AC.blue).withOpacity(.35), blurRadius: 14)],
          ),
          child: child,
        ),
      );
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('AURA yazıyor', style: TextStyle(color: AC.text2)),
          const SizedBox(width: 6),
          ...List.generate(3, (i) {
            final v = ((c.value * 3 - i) % 3).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AC.cyan.withOpacity(.3 + .7 * (1 - (v - .5).abs() * 2)),
              ),
            );
          }),
        ]),
      );
}
