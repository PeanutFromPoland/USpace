import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/city_locator.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/place_details.dart';

import 'domain_test.dart' show MemoryStore;

class FakeCityLocator implements CityLocator {
  FakeCityLocator(this.request);
  final Future<String> Function() request;
  int calls = 0;
  @override
  Future<String> locateCity() {
    calls++;
    return request();
  }
}

class PermissionPlatform extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.denied;
  LocationPermission requested = LocationPermission.denied;
  int requests = 0, positions = 0;
  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return requested;
  }

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    positions++;
    throw TimeoutException('fake timeout');
  }
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  final position = tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  position.jumpTo(0);
  await tester.pump();
  for (var step = 0; step < 80; step++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      return;
    }
    position.jumpTo((position.pixels + 180).clamp(0, position.maxScrollExtent));
    await tester.pump();
  }
  fail('Control not reachable: $finder');
}

Future<AppController> open(
  WidgetTester tester,
  FakeCityLocator locator, {
  MemoryStore? store,
}) async {
  final controller = AppController(
    DemoRepository(store ?? MemoryStore()),
    cityLocator: locator,
  );
  await controller.load();
  await tester.pumpWidget(USpaceApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  test(
    'City lookup never guesses another country, district or unsupported city',
    () {
      expect(
        supportedDemoCity(countryCode: 'PL', locality: ' Kraków '),
        'krakow',
      );
      expect(
        supportedDemoCity(countryCode: 'PL', locality: 'Warszawa'),
        'warsaw',
      );
      expect(supportedDemoCity(countryCode: 'US', locality: 'Warsaw'), isNull);
      expect(
        supportedDemoCity(countryCode: 'PL', locality: 'Podgórze'),
        isNull,
      );
      expect(supportedDemoCity(countryCode: 'PL', locality: 'Gdańsk'), isNull);
      expect(supportedDemoCity(countryCode: 'PL'), isNull);
    },
  );

  for (final problem in [
    CityLocationProblem.denied,
    CityLocationProblem.deniedForever,
    CityLocationProblem.serviceDisabled,
    CityLocationProblem.timedOut,
  ]) {
    test(
      'Device locator reports $problem without reading after refusal',
      () async {
        final previous = GeolocatorPlatform.instance;
        final platform = PermissionPlatform();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        GeolocatorPlatform.instance = platform;
        addTearDown(() {
          GeolocatorPlatform.instance = previous;
          debugDefaultTargetPlatformOverride = null;
        });
        if (problem == CityLocationProblem.deniedForever) {
          platform.permission = LocationPermission.deniedForever;
        }
        if (problem == CityLocationProblem.serviceDisabled) {
          platform.enabled = false;
        }
        if (problem == CityLocationProblem.timedOut) {
          platform.permission = LocationPermission.whileInUse;
        }
        await expectLater(
          DeviceCityLocator().locateCity(),
          throwsA(
            isA<CityLocationException>().having(
              (e) => e.problem,
              'problem',
              problem,
            ),
          ),
        );
        expect(
          platform.positions,
          problem == CityLocationProblem.timedOut ? 1 : 0,
        );
        expect(
          platform.requests,
          problem == CityLocationProblem.denied ? 1 : 0,
        );
      },
    );
  }

  testWidgets(
    'Location only on request; refusal keeps manual city and persistent notice',
    (tester) async {
      final locator = FakeCityLocator(
        () async =>
            throw const CityLocationException(CityLocationProblem.denied),
      );
      final controller = await open(tester, locator);
      expect(locator.calls, 0);
      final button = find.byKey(const ValueKey('locate-city'));
      await reveal(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(locator.calls, 1);
      expect(controller.profile.cityId, 'krakow');
      expect(find.textContaining('Nie udzielono zgody'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      expect(find.textContaining('Nie udzielono zgody'), findsOneWidget);
      final city = find.byType(DropdownButtonFormField<String>);
      await reveal(tester, city);
      await tester.tap(city);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warszawa').last);
      await tester.pumpAndSettle();
      expect(controller.profile.cityId, 'warsaw');
      expect(find.textContaining('Nie udzielono zgody'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'GPS save failure retains proposed city; retry saves without another request',
    (tester) async {
      final store = MemoryStore()..fail = true;
      final locator = FakeCityLocator(() async => 'warsaw');
      final controller = await open(tester, locator, store: store);
      final button = find.byKey(const ValueKey('locate-city'));
      await reveal(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(controller.profile.cityId, 'krakow');
      expect(
        find.textContaining('Nie udało się zapisać miasta'),
        findsOneWidget,
      );
      await reveal(tester, find.byType(DropdownButtonFormField<String>));
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .initialValue,
        'warsaw',
      );
      store.fail = false;
      final retry = find.byKey(const ValueKey('city-retry'));
      await reveal(tester, retry);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(controller.profile.cityId, 'warsaw');
      expect(locator.calls, 1);
      final restart = AppController(DemoRepository(store));
      await restart.load();
      expect(restart.profile.cityId, 'warsaw');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Manual choice supersedes late GPS and repeated requests are disabled',
    (tester) async {
      final pending = Completer<String>();
      final locator = FakeCityLocator(() => pending.future);
      final controller = await open(tester, locator);
      final button = find.byKey(const ValueKey('locate-city'));
      await reveal(tester, button);
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
      final city = find.byType(DropdownButtonFormField<String>);
      await reveal(tester, city);
      await tester.tap(city);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Warszawa').last);
      await tester.pumpAndSettle();
      pending.complete('krakow');
      await tester.pumpAndSettle();
      expect(controller.profile.cityId, 'warsaw');
      expect(locator.calls, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Map and list share filtered search results; clear restores focus',
    (tester) async {
      final controller = await open(
        tester,
        FakeCityLocator(() async => 'krakow'),
      );
      final search = find.byKey(const ValueKey('place-search'));
      await reveal(tester, search);
      await tester.enterText(search, 'biblioteka');
      await tester.pumpAndSettle();
      await reveal(tester, find.byType(PlacesMap));
      final map = tester.widget<PlacesMap>(find.byType(PlacesMap));
      expect(
        map.hits.map((h) => h.place.id),
        controller.search('biblioteka').map((h) => h.place.id),
      );
      expect(
        tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers.length,
        map.hits.length,
      );
      await reveal(tester, find.text('Lista'));
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      await reveal(tester, find.byType(PlaceCard));
      expect(
        tester.widget<PlaceCard>(find.byType(PlaceCard).first).hit.place.id,
        map.hits.single.place.id,
      );
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceDetailsScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await reveal(tester, search);
      await tester.enterText(search, 'nieistniejące miejsce xyz');
      await tester.pumpAndSettle();
      await reveal(tester, find.text('Brak pasujących miejsc'));
      expect(controller.search('nieistniejące miejsce xyz'), isEmpty);
      await reveal(tester, find.byTooltip('Wyczyść wyszukiwanie'));
      await tester.tap(find.byTooltip('Wyczyść wyszukiwanie'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(search).focusNode!.hasFocus, isTrue);
      expect(tester.widget<TextField>(search).controller!.text, isEmpty);
      expect(controller.search(''), isNotEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Sort persists, failure does not reorder; proposed places cover entire city',
    (tester) async {
      final store = MemoryStore();
      final controller = await open(
        tester,
        FakeCityLocator(() async => 'krakow'),
        store: store,
      );
      final sort = find.byType(DropdownButtonFormField<PlaceSort>);
      await reveal(tester, sort);
      store.fail = true;
      await tester.tap(sort);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Najwięcej recenzji').last);
      await tester.pumpAndSettle();
      expect(controller.profile.placeSort, PlaceSort.bestRated);
      expect(controller.search('').first.place.id, 'library');
      store.fail = false;
      await reveal(tester, find.byKey(const ValueKey('sort-retry')));
      await tester.tap(find.byKey(const ValueKey('sort-retry')));
      await tester.pumpAndSettle();
      expect(controller.profile.placeSort, PlaceSort.reviewCount);
      expect(controller.search('').first.place.id, 'museum');
      await reveal(tester, find.text('Proponowane miejsca'));
      await tester.tap(find.text('Proponowane miejsca'));
      await tester.pumpAndSettle();
      expect(find.byType(ProposedPlacesScreen), findsOneWidget);
      expect(find.textContaining('całe wybrane miasto'), findsOneWidget);
      await reveal(tester, find.byType(PlaceCard));
      expect(
        tester.widget<PlaceCard>(find.byType(PlaceCard).first).hit.place.id,
        'museum',
      );
      final restart = AppController(DemoRepository(store));
      await restart.load();
      expect(restart.profile.placeSort, PlaceSort.reviewCount);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Result announcement waits for typing pause', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: ResultsSummary(count: 5, cityId: 'krakow', query: ''),
      ),
    );
    expect(
      tester.getSemantics(find.byType(ResultsSummary)).label,
      contains('Wyniki: 5'),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultsSummary(count: 1, cityId: 'krakow', query: 'b'),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.getSemantics(find.byType(ResultsSummary)).label,
      contains('Wyniki: 5'),
    );
    await tester.pump(const Duration(milliseconds: 301));
    expect(
      tester.getSemantics(find.byType(ResultsSummary)).label,
      contains('Wyniki: 1'),
    );
    semantics.dispose();
  });

  testWidgets('Discovery controls and list remain usable at 320 px / 200%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(
      tester,
      FakeCityLocator(
        () async =>
            throw const CityLocationException(CityLocationProblem.denied),
      ),
    );
    await reveal(tester, find.byKey(const ValueKey('locate-city')));
    await tester.tap(find.byKey(const ValueKey('locate-city')));
    await tester.pumpAndSettle();
    final sort = find.byType(DropdownButtonFormField<PlaceSort>);
    await reveal(tester, sort);
    await tester.tap(sort);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Najwięcej recenzji').last);
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Lista'));
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    await reveal(tester, find.byType(PlaceCard));
    expect(tester.takeException(), isNull);
  });
}
