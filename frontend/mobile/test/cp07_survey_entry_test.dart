import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/place_details.dart';

import 'domain_test.dart' show MemoryStore;

import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/survey_entry.dart';

void main() {
  testWidgets(
    'App injects module from list through details without session writes',
    (tester) async {
      final store = MemoryStore();
      store.value = const DemoSnapshot(
        profile: DemoProfile(
          onboarded: true,
          helper: true,
          publicNeeds: false,
          savedPlaceIds: ['museum'],
        ),
      ).encode();
      final existingSession = store.value;
      final controller = AppController(DemoRepository(store));
      Place? received;
      await tester.pumpWidget(
        USpaceApp(
          controller: controller,
          surveyBuilder: (context, place) {
            received = place;
            return Scaffold(
              appBar: AppBar(title: const Text('Przekazany moduł')),
              body: Text('Miejsce: ${place.id}'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Lista'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(PlaceCard).first,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      final selectedPlace = tester
          .widget<PlaceCard>(find.byType(PlaceCard).first)
          .hit
          .place;
      await tester.tap(find.byType(PlaceCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(PlaceDetailsScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('survey-entry')),
        350,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 80,
      );
      await tester.tap(find.byKey(const ValueKey('survey-entry')));
      await tester.pumpAndSettle();
      expect(received, same(selectedPlace));
      expect(find.text('Przekazany moduł'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(controller.isDemoSignedIn, isTrue);
      expect(store.value, existingSession);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PlaceDetailsScreen), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('survey-entry')))
            .onPressed,
        isNotNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(DiscoveryScreen), findsOneWidget);
      expect(controller.isDemoSignedIn, isTrue);
      expect(controller.profile.helper, isTrue);
      expect(controller.profile.publicNeeds, isFalse);
      expect(store.value, existingSession);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Missing questionnaire cannot open or publish a review', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SurveyEntry(place: demoPlaces.first)),
      ),
    );
    expect(find.textContaining('Ankieta w przygotowaniu'), findsOneWidget);
    final button = find.byKey(const ValueKey('survey-entry'));
    expect(tester.widget<OutlinedButton>(button).onPressed, isNull);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(SurveyEntry), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Provided module receives place and returns to same entry', (
    tester,
  ) async {
    Place? received;
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveyEntry(
            place: demoPlaces.first,
            builder: (context, place) {
              received = place;
              calls++;
              return Scaffold(
                appBar: AppBar(title: const Text('Moduł testowy')),
                body: Text(place.id),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('survey-entry')));
    await tester.pumpAndSettle();
    expect(received, same(demoPlaces.first));
    expect(calls, 1);
    expect(find.text('Moduł testowy'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SurveyEntry), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('survey-entry')))
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Unavailable status is readable at 200 percent on narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [SurveyEntry(place: demoPlaces.first)],
            ),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel(RegExp('Ankieta w przygotowaniu')),
        findsOneWidget,
      );
      expect(find.text('Otwórz ankietę'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
