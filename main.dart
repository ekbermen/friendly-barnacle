import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/aura_colors.dart';
import 'core/auth_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/shell.dart';
import 'widgets/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: AC.purple3, secondary: AC.cyan, surface: AC.bg2),
        scaffoldBackgroundColor: AC.bg1,
        textTheme: ThemeData.dark().textTheme.apply(bodyColor: AC.text, displayColor: AC.text),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
      ),
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool ready = false;
  @override
  void initState() {
    super.initState();
    Future.wait([AuthService.init(), Future.delayed(const Duration(milliseconds: 2200))])
        .then((_) => mounted ? setState(() => ready = true) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarfieldBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          child: !ready
              ? const _Splash(key: ValueKey('splash'))
              : ValueListenableBuilder<UserProfile?>(
                  valueListenable: AuthService.current,
                  builder: (_, u, __) => u == null
                      ? const AuthScreen(key: ValueKey('auth'))
                      : const AuraShell(key: ValueKey('shell')),
                ),
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.auto_awesome, size: 72, color: AC.neon2, shadows: glow(AC.neon2, 30)),
        const SizedBox(height: 16),
        Text('AURA',
            style: TextStyle(fontSize: 58, letterSpacing: 12, fontWeight: FontWeight.w300, color: Colors.white, shadows: glow(AC.neon1, 24))),
        const SizedBox(height: 8),
        const Text('Kozmik Dünyana Hoş Geldin', style: TextStyle(color: AC.text2, fontSize: 15)),
        const SizedBox(height: 36),
        SizedBox(
          width: 160,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 2000),
            builder: (_, v, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: v, minHeight: 4, color: AC.neon2, backgroundColor: AC.navy2),
            ),
          ),
        ),
      ]),
    );
  }
}
