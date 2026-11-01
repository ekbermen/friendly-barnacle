import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'ayarlar/ayarlar_page.dart';
import 'aura_zihni/aura_zihni_page.dart';
import 'burclar/burclar_page.dart';
import 'fal/fal_page.dart';
import 'ritual/ritual_page.dart';
import 'uyum/uyum_page.dart';

class AuraShell extends StatefulWidget {
  const AuraShell({super.key});
  @override
  State<AuraShell> createState() => _AuraShellState();
}

class _AuraShellState extends State<AuraShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom > 0;
    final pad = MediaQuery.of(context).padding.bottom;
    return Stack(children: [
      SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: const [
          FalPage(),
          BurclarPage(),
          UyumPage(),
          AuraZihniPage(),
          RitualPage(),
          AyarlarPage(),
        ]),
      ),
      if (!kb)
        Positioned(
          left: 12,
          right: 12,
          bottom: 10 + pad,
          child: AuraBottomNav(index: index, onChanged: (i) => setState(() => index = i)),
        ),
    ]);
  }
}
