import 'package:flutter/material.dart';

import 'graphics.dart';

import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../app_controller.dart';
import 'components.dart';
import 'discovery.dart';
import 'preferences.dart';
import 'profile.dart';
import 'saved_places.dart';
import 'navigation.dart';
import 'theme.dart';
import 'rewards.dart';
import 'review_navigation.dart';
import 'survey_entry.dart';

// Compatibility for the existing frontend tests and integrations.
typedef USpaceApp = KindSpotApp;

class KindSpotApp extends StatefulWidget {
  const KindSpotApp({super.key, required this.controller, this.surveyBuilder});
  final AppController controller;
  final SurveyBuilder? surveyBuilder;
  @override
  State<KindSpotApp> createState() => _KindSpotAppState();
}

class _KindSpotAppState extends State<KindSpotApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final profile = widget.controller.profile;
      return MaterialApp(
        key: ValueKey(widget.controller.sessionRevision),
        title: 'KindSpot',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pl'),
        supportedLocales: const [Locale('pl')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: kindSpotTheme(profile),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                profile.reduceMotion ||
                MediaQuery.of(context).disableAnimations,
          ),
          child: KindSpotBackdrop(themeId: profile.theme, child: child!),
        ),
        home: widget.controller.loading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Odczytywanie profilu',
                  ),
                ),
              )
            : widget.controller.loadError != null
            ? Scaffold(
                body: SafeArea(
                  child: pageBody([
                    const SectionTitle('Nie możemy odczytać profilu'),
                    Text(widget.controller.loadError!),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: widget.controller.load,
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ]),
                ),
              )
            : widget.controller.isDemoSignedIn
            ? HomeShell(
                controller: widget.controller,
                surveyBuilder: widget.surveyBuilder,
              )
            : WelcomeScreen(controller: widget.controller),
      );
    },
  );
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.controller});
  final AppController controller;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? error;
  final entryFocus = FocusNode(debugLabel: 'demo-entry');
  @override
  void dispose() {
    entryFocus.dispose();
    super.dispose();
  }

  AppController get controller => widget.controller;
  Future<void> enter() async {
    setState(() => error = null);
    try {
      await controller.openDemoSession();
    } catch (_) {
      if (mounted) {
        setState(
          () => error = "Nie udało się otworzyć konta demo. Spróbuj ponownie. Twoje ustawienia nie zostały zmienione.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: pageBody([
        Row(
          children: [
            KindSpotSymbol(
              Icons.explore_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'KindSpot',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            IconButton(
              tooltip: 'Ustawienia dostępności',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AccessibilityScreen(controller: controller),
                ),
              ),
              icon: const KindSpotSymbol(Icons.accessibility_new),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(28),
          ),
          child: KindSpotSymbol(
            Icons.travel_explore,
            size: 80,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Twoje potrzeby.\nTwoje miejsca.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 16),
        const Text(
          'Znajduj miejsca, w których możesz czuć się swobodnie. Dziel się obserwacjami i pomagaj innym.',
        ),
        const SizedBox(height: 24),
        const Notice(
          'Korzystanie z KindSpot wymaga konta. Logowanie i rejestracja czekają na uzgodnienie API. Teraz możesz sprawdzić osobne konto demonstracyjne.',
        ),
        const SizedBox(height: 24),
        if (error != null) ...[
          Semantics(
            liveRegion: true,
            child: Notice(error!, icon: Icons.error_outline),
          ),
          const SizedBox(height: 16),
        ],
        FilledButton(
          key: const ValueKey('demo-enter'),
          autofocus: true,
          focusNode: entryFocus,
          onPressed: controller.saving ? null : enter,
          child: Text(
            controller.saving ? 'Otwieranie…' : 'Otwórz konto demonstracyjne',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'To lokalna sesja Test Hackaton. Nie podawaj hasła ani danych prawdziwego konta. Ustawienia demo pozostają na tym urządzeniu.',
        ),
        const SizedBox(height: 20),
      ]),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller, this.surveyBuilder});
  final AppController controller;
  final SurveyBuilder? surveyBuilder;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 2;
  bool exitDialogOpen = false;
  final discoveryKey = GlobalKey<DiscoveryScreenState>();
  void showMap() {
    discoveryKey.currentState?.showMapView();
    setState(() => index = 2);
  }

  void select(int value) {
    if (value == 3) {
      showMap();
      openFilters();
    } else if (value == 2) {
      showMap();
    } else {
      setState(() => index = value);
    }
  }

  Future<void> back() async {
    if (index != 2) {
      showMap();
      return;
    }
    if (exitDialogOpen) return;
    exitDialogOpen = true;
    final exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyjść z KindSpot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zostań'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Wyjdź'),
          ),
        ],
      ),
    );
    exitDialogOpen = false;
    if (exit == true) await SystemNavigator.pop();
  }

  void openFilters() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => FiltersScreen(controller: widget.controller),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final screens = [
      KindSpotSavedPlacesScreen(
        controller: widget.controller,
        surveyBuilder: widget.surveyBuilder,
        onOpenReviews: (context, place) =>
            openDemoReviews(context, place, widget.controller),
        onOpenSection: showMap,
      ),
      RewardsScreen(controller: widget.controller, onOpenSection: showMap),
      DiscoveryScreen(
        key: discoveryKey,
        controller: widget.controller,
        surveyBuilder: widget.surveyBuilder,
      ),
      ProfileScreen(controller: widget.controller, onOpenSection: showMap),
    ];
    final bodyIndex = switch (index) {
      0 => 0,
      1 => 1,
      2 => 2,
      _ => 3,
    };
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) back();
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: bodyIndex,
            children: [
              for (var i = 0; i < screens.length; i++)
                ExcludeFocus(
                  excluding: i != bodyIndex,
                  child: ExcludeSemantics(
                    excluding: i != bodyIndex,
                    child: screens[i],
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: KindSpotNavigation(
          selected: index,
          onSelect: select,
        ),
      ),
    );
  }
}
