import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../widgets/widgets.dart';

class AyarlarPage extends StatelessWidget {
  const AyarlarPage({super.key});

  Future<void> _confirm(BuildContext context, String title, String body, VoidCallback ok) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AC.bg3,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet', style: TextStyle(color: AC.neon3))),
        ],
      ),
    );
    if (r == true) ok();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserProfile?>(
      valueListenable: AuthService.current,
      builder: (_, u, __) {
        if (u == null) return const SizedBox();
        return ListenableBuilder(
          listenable: AuraSettings.I,
          builder: (_, __) {
            final s = AuraSettings.I;
            return Column(children: [
              const PageHeader(icon: Icons.settings_rounded, title: 'Ayarlar'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 120), children: [
                  GlassCard(
                    glowColor: u.sign.color,
                    child: Row(children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: u.sign.color, width: 2),
                          boxShadow: [BoxShadow(color: u.sign.color.withOpacity(.6), blurRadius: 16)],
                        ),
                        child: ZodiacGlyph(u.sign, size: 34),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                          Text('${u.birthText} • ${u.sign.name}', style: const TextStyle(color: AC.text2, fontSize: 13)),
                          Text('${u.sign.element} • ${u.sign.planet}', style: const TextStyle(color: AC.text3, fontSize: 12)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  const Text('Tema Rengi', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(3, (i) {
                    final on = s.accent == i;
                    final p = AuraSettings.pairs[i];
                    return GestureDetector(
                      onTap: () => s.update(() => s.accent = i),
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: p),
                            border: Border.all(color: on ? Colors.white : Colors.transparent, width: 2),
                            boxShadow: [BoxShadow(color: p[1].withOpacity(on ? .8 : .3), blurRadius: on ? 18 : 8)],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(AuraSettings.names[i], style: TextStyle(fontSize: 12, color: on ? Colors.white : AC.text2)),
                      ]),
                    );
                  })),
                  const SizedBox(height: 16),
                  _slider('Glow Şiddeti', s.glowLevel, AC.neon2, (v) => s.update(() => s.glowLevel = v)),
                  _slider('Yıldız Yoğunluğu', s.stars, AC.cyan, (v) => s.update(() => s.stars = v)),
                  const SizedBox(height: 6),
                  _switch(Icons.notifications_rounded, 'Bildirimler', s.notif, (v) => s.update(() => s.notif = v)),
                  _switch(Icons.vibration_rounded, 'Titreşim', s.vibrate, (v) => s.update(() => s.vibrate = v)),
                  _switch(Icons.volume_up_rounded, 'Ses', s.sound, (v) => s.update(() => s.sound = v)),
                  const SizedBox(height: 14),
                  NeonButton(
                    label: 'Çıkış Yap',
                    icon: Icons.logout_rounded,
                    onTap: () => _confirm(context, 'Çıkış', 'Hesabından çıkış yapılsın mı?', AuthService.logout),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _confirm(context, 'Hesabı Sil', 'Hesabın bu cihazdan kalıcı olarak silinecek.', AuthService.deleteAccount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AC.neon3),
                        boxShadow: [BoxShadow(color: AC.neon3.withOpacity(.3), blurRadius: 12)],
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.delete_outline_rounded, color: AC.neon3, size: 20),
                        SizedBox(width: 8),
                        Text('Hesabı Sil', style: TextStyle(color: AC.neon3, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const GlassCard(
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, color: AC.cyan),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('AURA v1.0.0\nTüm içerik eğlence amaçlıdır. Tüm veriler yalnızca bu cihazda saklanır, hiçbir şey sunucuya gönderilmez.',
                            style: TextStyle(color: AC.text2, fontSize: 12.5, height: 1.4)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]);
          },
        );
      },
    );
  }

  Widget _slider(String t, double v, Color c, ValueChanged<double> on) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text('%${(v * 100).round()}', style: const TextStyle(color: AC.text2, fontSize: 12)),
        ]),
        Slider(value: v, onChanged: on, activeColor: c, inactiveColor: AC.navy2),
      ]);

  Widget _switch(IconData ic, String t, bool v, ValueChanged<bool> on) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(ic, color: AC.text2),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: v,
        onChanged: on,
        activeColor: AC.cyan,
        activeTrackColor: AC.blue,
      );
}
