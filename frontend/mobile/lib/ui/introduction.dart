import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models.dart';
import 'components.dart';
import 'graphics.dart';
import 'theme.dart';

abstract interface class IntroductionStore {
  Future<bool> hasSeen();
  Future<void> markSeen();
}

class SecureIntroductionStore implements IntroductionStore {
  const SecureIntroductionStore();
  static const key = 'kindspot.introduction.seen.v1';
  static const storage = FlutterSecureStorage();
  @override
  Future<bool> hasSeen() async => await storage.read(key: key) == 'true';
  @override
  Future<void> markSeen() => storage.write(key: key, value: 'true');
}

/// Runs before the app connects to a server; the marker belongs to this device.
class KindSpotIntroduction extends StatefulWidget {
  const KindSpotIntroduction({
    super.key,
    required this.child,
    this.store = const SecureIntroductionStore(),
  });
  final Widget child;
  final IntroductionStore store;
  @override
  State<KindSpotIntroduction> createState() => _KindSpotIntroductionState();
}

class _KindSpotIntroductionState extends State<KindSpotIntroduction> {
  bool? seen;
  bool saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    bool value;
    try {
      value = await widget.store.hasSeen();
    } catch (_) {
      value = false;
    }
    if (mounted) setState(() => seen = value);
  }

  Future<void> finish() async {
    if (saving) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.store.markSeen();
      if (mounted) {
        setState(() => seen = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          error = 'Nie udało się zapisać ukończenia. Spróbuj ponownie lub kontynuuj bez zapisu.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (seen == true) return widget.child;
    return MaterialApp(
      title: 'KindSpot',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pl'),
      supportedLocales: const [Locale('pl')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: kindSpotTheme(const DemoProfile()),
      darkTheme: kindSpotTheme(const DemoProfile(darkMode: true)),
      home: seen == null
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Uruchamianie KindSpot',
                ),
              ),
            )
          : IntroductionSlides(
              onFinish: finish,
              saving: saving,
              error: error,
              onContinueWithoutSaving: () => setState(() => seen = true),
            ),
    );
  }
}

class IntroductionSlides extends StatefulWidget {
  const IntroductionSlides({
    super.key,
    required this.onFinish,
    this.saving = false,
    this.error,
    this.onContinueWithoutSaving,
  });
  final Future<void> Function() onFinish;
  final bool saving;
  final String? error;
  final VoidCallback? onContinueWithoutSaving;
  @override
  State<IntroductionSlides> createState() => _IntroductionSlidesState();
}

class _IntroductionSlidesState extends State<IntroductionSlides>
    with WidgetsBindingObserver {
  static const slides = [
    (
      'Znajduj miejsca dostosowane do Ciebie',
      'Wybierz swoje potrzeby i znajdź odpowiednie miejsca na mapie lub liście.',
      'onboarding_places',
    ),
    (
      'Pomagaj innym, wystawiając recenzje',
      'Opisz udogodnienia i bariery. Jeśli czegoś nie sprawdzisz, możesz to zaznaczyć.',
      'onboarding_reviews',
    ),
    (
      'Zdobywaj punkty za szczerą i rzetelną pomoc',
      'Recenzuj i sprawdzaj informacje. Punkty otrzymasz po weryfikacji Twojego wkładu.',
      'illustration_reward_received',
    ),
  ];
  int page = 0;
  bool automatic = true, quiet = false, foreground = true;
  Timer? timer;
  bool get running => automatic && !quiet && foreground && !widget.saving;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    quiet =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    schedule();
  }

  @override
  void didUpdateWidget(covariant IntroductionSlides oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != null) automatic = false;
    schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    schedule();
  }

  void schedule() {
    timer?.cancel();
    if (!running) return;
    timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (page == 2) {
        widget.onFinish();
      } else {
        setState(() => page++);
        schedule();
      }
    });
  }

  void move(int value) {
    setState(() {
      automatic = false;
      page = value;
    });
    schedule();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[page];
    return Scaffold(
      appBar: AppBar(
        title: const Text('KindSpot'),
        actions: [
          TextButton(
            onPressed: widget.saving ? null : widget.onFinish,
            child: const Text('Pomiń'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: quiet ? 0 : 300),
                  child: Column(
                    key: ValueKey(page),
                    children: [
                      KindSpotGraphic(
                        slide.$3,
                        width: 256,
                        height: 176,
                        calm: quiet,
                      ),
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        liveRegion: true,
                        child: Text(
                          slide.$1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(slide.$2, textAlign: TextAlign.center),
                      if (widget.error != null) ...[
                        const SizedBox(height: 16),
                        Notice(widget.error!, icon: Icons.error_outline),
                        TextButton(
                          onPressed: widget.onContinueWithoutSaving,
                          child: const Text('Kontynuuj bez zapisu'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Slajd ${page + 1} z 3'),
                  if (!quiet)
                    TextButton.icon(
                      onPressed: widget.saving
                          ? null
                          : () {
                              setState(() => automatic = !automatic);
                              schedule();
                            },
                      icon: KindSpotSymbol(
                        automatic ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(
                        automatic
                            ? 'Zatrzymaj przewijanie'
                            : 'Wznów przewijanie',
                      ),
                    ),
                  Row(
                    children: [
                      if (page > 0)
                        Expanded(
                          child: TextButton(
                            onPressed: widget.saving
                                ? null
                                : () => move(page - 1),
                            child: const Text('Wstecz'),
                          ),
                        ),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.saving
                              ? null
                              : page == 2
                              ? widget.onFinish
                              : () => move(page + 1),
                          child: Text(
                            widget.saving
                                ? 'Zapisywanie…'
                                : page == 2
                                ? 'Zaczynamy'
                                : 'Dalej',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
