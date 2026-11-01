import 'package:flutter/material.dart';
import '../../core/aura_colors.dart';
import '../../core/auth_service.dart';
import '../../core/zodiac.dart';
import '../../widgets/widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool register = true;
  final name = TextEditingController();
  final surname = TextEditingController();
  DateTime? birth;
  String? error;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    surname.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    FocusScope.of(context).unfocus();
    final d = await showDatePicker(
      context: context,
      initialDate: birth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihin',
      builder: (c, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: AC.neon2, surface: AC.bg3, onSurface: AC.text)),
        child: child!,
      ),
    );
    if (d != null) setState(() => birth = d);
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    final err = register
        ? await AuthService.register(name.text, surname.text, birth)
        : await AuthService.login(name.text, birth);
    if (mounted) setState(() {
      busy = false;
      error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sign = birth == null ? null : Zodiac.fromDate(birth!);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('AURA',
                style: TextStyle(fontSize: 52, letterSpacing: 10, fontWeight: FontWeight.w300, color: Colors.white, shadows: glow(AC.neon1, 22))),
            const SizedBox(height: 6),
            const Text('Yıldızlar konuşur, Aura dinler.', style: TextStyle(color: AC.text2)),
            const SizedBox(height: 26),
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  NeonChip(label: 'Hesap Aç', selected: register, onTap: () => setState(() { register = true; error = null; })),
                  const SizedBox(width: 10),
                  NeonChip(label: 'Giriş Yap', selected: !register, onTap: () => setState(() { register = false; error = null; })),
                ]),
                const SizedBox(height: 18),
                AuraField(controller: name, label: 'Ad', icon: Icons.person_outline),
                if (register) ...[
                  const SizedBox(height: 12),
                  AuraField(controller: surname, label: 'Soyad', icon: Icons.badge_outlined),
                ],
                const SizedBox(height: 12),
                AuraField(
                  label: birth == null ? 'Doğum Tarihi' : Fmt.date(birth!),
                  icon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: pickDate,
                ),
                if (register && sign != null) ...[
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ZodiacGlyph(sign, size: 30),
                    const SizedBox(width: 10),
                    Text('Burcun: ${sign.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ]),
                ],
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: AC.neon3)),
                ],
                const SizedBox(height: 18),
                NeonButton(
                  label: busy ? 'Bekle...' : (register ? 'Hesabı Oluştur' : 'Giriş Yap'),
                  icon: register ? Icons.auto_awesome : Icons.login_rounded,
                  onTap: busy ? null : submit,
                ),
              ]),
            ),
            const SizedBox(height: 14),
            const Text('Tüm veriler yalnızca bu cihazda saklanır.',
                style: TextStyle(color: AC.text3, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
