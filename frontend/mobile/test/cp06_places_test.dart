import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/place_details.dart';
import 'package:uspace/ui/saved_places.dart';
import 'package:uspace/ui/theme.dart';

import 'domain_test.dart' show MemoryStore;

Future<void> reach(WidgetTester tester, String key) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> show(
  WidgetTester tester,
  AppController controller,
  Widget screen, {
  bool large = false,
}) async {
  if (large) {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: uspaceTheme(controller.profile),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(large ? 2 : 1)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

class PendingStore extends MemoryStore {
  Completer<void>? pending;
  int writes = 0;
  @override
  Future<void> write(String data) async {
    writes++;
    await pending?.future;
    await super.write(data);
  }
}

void main() {
  testWidgets('Place save confirms storage and survives restart then removal', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    final place = demoPlaces.first;
    await show(
      tester,
      controller,
      PlaceDetailsScreen(controller: controller, place: place),
    );
    await reach(tester, 'place-save');
    await tester.tap(find.byKey(const ValueKey('place-save')));
    await tester.pumpAndSettle();
    expect(controller.isPlaceSaved(place.id), isTrue);
    expect(find.text('Zapisano miejsce na tym urządzeniu.'), findsOneWidget);
    final restarted = AppController(DemoRepository(store));
    await restarted.load();
    expect(restarted.profile.savedPlaceIds, [place.id]);
    await tester.tap(find.byKey(const ValueKey('place-save')));
    await tester.pumpAndSettle();
    expect(controller.isPlaceSaved(place.id), isFalse);
    expect(find.text('Usunięto miejsce z zapisanych.'), findsOneWidget);
  });

  testWidgets(
    'Failed place save retains confirmation state and persistent retry',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      await show(
        tester,
        controller,
        PlaceDetailsScreen(controller: controller, place: demoPlaces.first),
      );
      await reach(tester, 'place-save');
      store.fail = true;
      await tester.tap(find.byKey(const ValueKey('place-save')));
      await tester.pumpAndSettle();
      expect(controller.profile.savedPlaceIds, isEmpty);
      await tester.pump(const Duration(seconds: 15));
      expect(
        find.textContaining('Poprzedni stan pozostaje bez zmian.'),
        findsOneWidget,
      );
      store.fail = false;
      await reach(tester, 'place-save-retry');
      await tester.tap(find.byKey(const ValueKey('place-save-retry')));
      await tester.pumpAndSettle();
      expect(controller.isPlaceSaved(demoPlaces.first.id), isTrue);
    },
  );

  testWidgets('Place save disables repeated action until storage confirms', (
    tester,
  ) async {
    final store = PendingStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    store.pending = Completer<void>();
    await show(
      tester,
      controller,
      PlaceDetailsScreen(controller: controller, place: demoPlaces.first),
    );
    await reach(tester, 'place-save');
    await tester.tap(find.byKey(const ValueKey('place-save')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('place-save')))
          .onPressed,
      isNull,
    );
    expect(controller.profile.savedPlaceIds, isEmpty);
    expect(store.writes, 1);
    store.pending!.complete();
    await tester.pumpAndSettle();
    expect(controller.isPlaceSaved(demoPlaces.first.id), isTrue);
  });

  testWidgets(
    'Saved places include other city and excluded match; newest first',
    (tester) async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      final old = demoPlaces.first;
      final recent = demoPlaces.firstWhere((p) => p.cityId == 'warsaw');
      await controller.setPlaceSaved(old.id, true);
      await controller.setPlaceSaved(recent.id, true);
      await controller.saveProfile(
        controller.profile.copyWith(
          cityId: 'krakow',
          rules: [const FilterRule('elevator', Importance.required, 5)],
        ),
      );
      await show(
        tester,
        controller,
        KindSpotSavedPlacesScreen(controller: controller),
      );
      await reach(tester, 'saved-${recent.id}');
      expect(find.text(recent.name), findsOneWidget);
      await reach(tester, 'saved-${old.id}');
      expect(find.text(old.name), findsOneWidget);
      expect(controller.profile.savedPlaceIds, [recent.id, old.id]);
    },
  );

  testWidgets(
    'Unavailable saved item is not claimed accessible; removal failure retries',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      await controller.saveProfile(
        controller.profile.copyWith(savedPlaceIds: ['removed-id']),
      );
      await show(
        tester,
        controller,
        KindSpotSavedPlacesScreen(controller: controller),
      );
      await reach(tester, 'saved-remove-removed-id');
      expect(find.text('Miejsce niedostępne'), findsOneWidget);
      expect(find.textContaining('Nie oznacza to dostępności'), findsOneWidget);
      store.fail = true;
      await tester.tap(find.byKey(const ValueKey('saved-remove-removed-id')));
      await tester.pumpAndSettle();
      expect(controller.profile.savedPlaceIds, ['removed-id']);
      expect(find.byKey(const ValueKey('saved-remove-retry')), findsOneWidget);
      store.fail = false;
      await tester.tap(find.byKey(const ValueKey('saved-remove-retry')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nie masz zapisanych miejsc'), findsOneWidget);
    },
  );

  testWidgets('Saved detail opens and invokes map navigation callback', (
    tester,
  ) async {
    final controller = AppController(DemoRepository(MemoryStore()));
    await controller.load();
    await controller.setPlaceSaved(demoPlaces.first.id, true);
    var callbacks = 0;
    await show(
      tester,
      controller,
      Scaffold(
        body: KindSpotSavedPlacesScreen(
          controller: controller,
          onOpenSection: () => callbacks++,
        ),
      ),
    );
    await reach(tester, 'saved-open-${demoPlaces.first.id}');
    await tester.tap(find.byKey(ValueKey('saved-open-${demoPlaces.first.id}')));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailsScreen), findsOneWidget);
    expect(callbacks, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailsScreen), findsNothing);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'Details and saved remain usable at 320px and 200 percent dark=$dark',
      (tester) async {
        final controller = AppController(DemoRepository(MemoryStore()));
        await controller.load();
        await controller.saveProfile(
          controller.profile.copyWith(darkMode: dark),
        );
        final place = demoPlaces.firstWhere((p) => p.issue != null);
        await show(
          tester,
          controller,
          PlaceDetailsScreen(
            controller: controller,
            place: place,
            onOpenReviews: () {},
          ),
          large: true,
        );
        await reach(tester, 'place-save');
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('place-save')));
        await tester.pumpAndSettle();
        await reach(tester, 'place-reviews');
        expect(tester.takeException(), isNull);
        await show(
          tester,
          controller,
          KindSpotSavedPlacesScreen(controller: controller),
          large: true,
        );
        await reach(tester, 'saved-remove-${place.id}');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Unknown and absent feature remain distinct and reader labels carry context',
    (tester) async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      const place = Place(
        id: 'example',
        name: 'Przykład',
        category: 'Demo',
        cityId: 'krakow',
        address: 'Adres',
        lat: 0,
        lon: 0,
        description: 'Opis',
        observedOn: '2026-10-03',
        features: [
          FeatureFact('step_free_entrance', Presence.absent, rating: 0),
          FeatureFact('elevator', Presence.unknown),
        ],
      );
      await show(
        tester,
        controller,
        PlaceDetailsScreen(controller: controller, place: place),
      );
      await tester.scrollUntilVisible(
        find.text('Brak funkcji · ocena 0 / 5.'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Brak funkcji · ocena 0 / 5.'), findsOneWidget);
      final groups = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where(
            (s) =>
                s.properties.label?.contains('Brak funkcji · ocena 0 / 5.') ??
                false,
          );
      expect(
        groups.first.properties.label,
        contains(featureById('step_free_entrance').label),
      );
      await tester.scrollUntilVisible(
        find.text('Winda'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Brak potwierdzonej oceny liczbowej.'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
