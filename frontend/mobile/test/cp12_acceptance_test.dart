import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/place_details.dart';
import 'package:uspace/ui/reviews.dart';
import 'package:uspace/ui/rewards.dart';

import 'domain_test.dart' show MemoryStore;

Future<void> reach(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 100,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, Finder finder) async {
  await reach(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> section(WidgetTester tester, int index) async {
  await tester.tap(find.byKey(ValueKey('navigation-$index')));
  await tester.pumpAndSettle();
}

Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> openGarden(WidgetTester tester) async {
  await press(tester, find.text('Lista'));
  await press(tester, find.text('Ogród ciszy'));
  expect(find.byType(PlaceDetailsScreen), findsOneWidget);
}

void main() {
  testWidgets(
    'CP12 complete demo path connects list, saved details, reviews, privacy, rewards and removes routes on logout',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await openGarden(tester);
      await press(tester, find.byKey(const ValueKey('place-save')));
      expect(controller.isPlaceSaved('garden'), isTrue);
      await back(tester);
      await section(tester, 0);
      await press(tester, find.byKey(const ValueKey('saved-open-garden')));
      await press(tester, find.byKey(const ValueKey('place-reviews')));
      expect(find.byType(ReviewsScreen), findsOneWidget);
      expect(find.textContaining('fikcyjnymi przykładami'), findsOneWidget);
      final persisted = store.value;
      await back(tester);
      await section(tester, 4);
      await press(tester, find.text('Podgląd publicznego profilu'));
      expect(find.text('Potrzeby prywatne'), findsOneWidget);
      await tester.tap(find.text('Zamknij'));
      await tester.pumpAndSettle();
      await section(tester, 1);
      await press(tester, find.byKey(const ValueKey('reward-museum')));
      await press(tester, find.byKey(const ValueKey('reward-start')));
      expect(find.text('Potwierdź symulację'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reward-confirm')));
      await tester.pumpAndSettle();
      await press(tester, find.byKey(const ValueKey('reward-advance')));
      expect(find.text('TEST-NIEWAZNY'), findsOneWidget);
      expect(
        store.value,
        persisted,
        reason: 'Reading reviews and a reward simulation must not mutate stored profile or points.',
      );
      await controller.closeDemoSession();
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(RewardPreviewScreen), findsNothing);
      expect(find.byType(ReviewsScreen), findsNothing);
      expect(find.byType(PlaceDetailsScreen), findsNothing);
      expect(controller.profile.savedPlaceIds, ['garden']);
      final restarted = AppController(DemoRepository(store));
      await restarted.load();
      expect(restarted.profile.savedPlaceIds, ['garden']);
      expect(restarted.profile.publicNeeds, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'CP12 confirmed reset clears saved places and private needs across a fresh load',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      await controller.saveProfile(
        controller.profile.copyWith(
          needIds: ['wheelchair'],
          publicNeeds: true,
          savedPlaceIds: ['garden'],
        ),
      );
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await section(tester, 4);
      await press(tester, find.text('Usuń dane demonstracyjne'));
      expect(find.text('Usuń lokalne dane demo?'), findsOneWidget);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(controller.profile.savedPlaceIds, ['garden']);
      await press(tester, find.text('Usuń dane demonstracyjne'));
      await tester.tap(find.text('Usuń dane demo'));
      await tester.pumpAndSettle();
      expect(controller.profile.savedPlaceIds, isEmpty);
      expect(controller.profile.needIds, isEmpty);
      expect(controller.profile.publicNeeds, isFalse);
      final restarted = AppController(DemoRepository(store));
      await restarted.load();
      expect(restarted.profile.savedPlaceIds, isEmpty);
      expect(restarted.profile.needIds, isEmpty);
      expect(restarted.profile.publicNeeds, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'CP12 keyboard traversal on rewards cannot focus hidden map controls or change stored settings',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await section(tester, 1);
      final before = store.value;
      FocusManager.instance.primaryFocus?.unfocus();
      for (var index = 0; index < 24; index++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focusContext = FocusManager.instance.primaryFocus?.context;
        if (focusContext != null) {
          expect(
            focusContext.findAncestorWidgetOfExactType<DiscoveryScreen>(),
            isNull,
            reason: 'Tab must not visit controls of the map hidden by IndexedStack.',
          );
        }
      }
      expect(find.byType(RewardPreviewScreen), findsNothing);
      expect(store.value, before);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'CP12 landscape 800x360 at 200 percent keeps new reward confirmation and back navigation reachable',
    (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = AppController(DemoRepository(MemoryStore()));
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await section(tester, 1);
      await press(tester, find.byKey(const ValueKey('reward-museum')));
      await press(tester, find.byKey(const ValueKey('reward-start')));
      expect(find.text('Potwierdź symulację'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('reward-start')), findsOneWidget);
      await back(tester);
      expect(find.byType(RewardPreviewScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'CP12 landscape large text preserves details, reviews and privacy confirmation through the complete app',
    (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = AppController(DemoRepository(MemoryStore()));
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await openGarden(tester);
      await press(tester, find.byKey(const ValueKey('place-save')));
      await press(tester, find.byKey(const ValueKey('place-reviews')));
      expect(find.byType(ReviewsScreen), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await back(tester);
      await section(tester, 4);
      await press(
        tester,
        find.widgetWithText(
          SwitchListTile,
          'Pokaż potrzeby w publicznym profilu',
        ),
      );
      expect(find.text('Udostępnić potrzeby?'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
