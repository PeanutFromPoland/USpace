import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/preferences.dart';

import 'domain_test.dart' show MemoryStore;

void main() {
  testWidgets('Fresh and saved test profiles open the map as Test Hackaton', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await tester.pumpWidget(KindSpotApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Test Hackaton'), findsOneWidget);
    expect(find.text('Zamknij konto demonstracyjne'), findsNothing);
    expect(controller.profile.publicNeeds, isFalse);
    await controller.saveProfile(
      controller.profile.copyWith(
        theme: 'pink',
        helper: true,
        onboarded: false,
      ),
    );
    final restarted = AppController(DemoRepository(store));
    await tester.pumpWidget(
      KindSpotApp(key: const ValueKey('restart'), controller: restarted),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(restarted.profile.theme, 'pink');
    expect(restarted.profile.helper, isTrue);
    expect(restarted.profile.publicNeeds, isFalse);
    await restarted.reset();
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Main navigation returns to map and asks before exit', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    await controller.saveProfile(controller.profile.copyWith(onboarded: true));
    await tester.pumpWidget(KindSpotApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('Znajdź swoje miejsce.'), findsOneWidget);
    await tester.tap(find.text('Zapisane'));
    await tester.pumpAndSettle();
    expect(find.text('Zapisane miejsca'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Znajdź swoje miejsce.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Wyjść z KindSpot?'), findsOneWidget);
    await tester.tap(find.text('Zostań'));
    await tester.pumpAndSettle();
    expect(find.text('Wyjść z KindSpot?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Accessibility available before entering demo; account is explicit',
    (tester) async {
      final controller = AppController(
        DemoRepository(MemoryStore()),
        autoDemoLogin: false,
      );
      await tester.pumpWidget(KindSpotApp(controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('Otwórz konto demonstracyjne'), findsOneWidget);
      expect(find.text('Zacznij bez personalizacji'), findsNothing);
      await tester.tap(find.byTooltip('Ustawienia dostępności'));
      await tester.pumpAndSettle();
      expect(find.text('Pastelowy pomarańczowy'), findsOneWidget);
      expect(find.text('Czarny motyw'), findsOneWidget);
      expect(controller.profile.onboarded, isFalse);
    },
  );
  for (final dark in [false, true]) {
    for (final palette in ['orange', 'pink', 'blue']) {
      testWidgets('Theme $palette dark=$dark with 200% text', (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = AppController(
          DemoRepository(MemoryStore()),
          autoDemoLogin: false,
        );
        await controller.load();
        await controller.saveProfile(
          controller.profile.copyWith(theme: palette, darkMode: dark),
        );
        await tester.pumpWidget(KindSpotApp(controller: controller));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Ustawienia dostępności'));
        await tester.pumpAndSettle();
        expect(find.byType(AccessibilityScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Filter preset can be edited and is persisted', (tester) async {
    final controller = AppController(
      DemoRepository(MemoryStore()),
      autoDemoLogin: false,
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: FiltersScreen(controller: controller)),
    );
    await tester.tap(find.text('Na wózku'));
    await tester.pump();
    expect(find.text('Warunek konieczny'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final button = find.text('Zapisz i pokaż miejsca');
    await tester.scrollUntilVisible(
      button,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(controller.profile.rules.first.minRating, 4);
  });
}
