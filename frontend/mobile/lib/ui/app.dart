import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../app_controller.dart';
import 'components.dart';
import 'discovery.dart';
import 'preferences.dart';
import 'profile.dart';
import 'navigation.dart';
import 'theme.dart';

class USpaceApp extends StatefulWidget {
  const USpaceApp({super.key, required this.controller});
  final AppController controller;
  @override
  State<USpaceApp> createState() => _USpaceAppState();
}

class _USpaceAppState extends State<USpaceApp> {
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
        title: 'KindSpot',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pl'),
        supportedLocales: const [Locale('pl')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: uspaceTheme(profile),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                profile.reduceMotion ||
                MediaQuery.of(context).disableAnimations,
          ),
          child: child!,
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
            ? HomeShell(controller: widget.controller)
            : WelcomeScreen(controller: widget.controller),
      );
    },
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: pageBody([
        Row(
          children: [
            Icon(
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
              icon: const Icon(Icons.accessibility_new),
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
          child: Icon(
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
        FilledButton(
          onPressed: controller.saving
              ? null
              : () => perform(
                  context,
                  () => controller.saveProfile(
                    controller.profile.copyWith(onboarded: true),
                  ),
                ),
          child: const Text('Otwórz konto demonstracyjne'),
        ),
        const SizedBox(height: 20),
        demoNotice(),
      ]),
    ),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final AppController controller;
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
      const SavedPlacesScreen(),
      RewardsScreen(controller: widget.controller),
      DiscoveryScreen(key: discoveryKey, controller: widget.controller),
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
          child: IndexedStack(index: bodyIndex, children: screens),
        ),
        bottomNavigationBar: USpaceNavigation(
          selected: index,
          onSelect: select,
        ),
      ),
    );
  }
}
