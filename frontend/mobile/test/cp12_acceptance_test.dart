import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/place_details.dart';
import 'package:uspace/ui/reviews.dart';
import 'package:uspace/ui/shop_screen.dart';

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
      await press(tester, find.byKey(const ValueKey('shop-buy-museum')));
      expect(find.text('Kup za 200 pkt?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('shop-confirm')));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 800);
      expect(controller.shop.purchases.single.redeemed, isFalse);
      expect(
        store.value,
        persisted,
        reason:
            'Test shop ledger must remain separate from persistent settings.',
      );
      await section(tester, 4);
      await press(tester, find.byKey(const ValueKey('account-settings')));
      await press(tester, find.byKey(const ValueKey('demo-exit')));
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
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
      await press(tester, find.byKey(const ValueKey('account-settings')));
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
      expect(find.byType(PointsGuideScreen), findsNothing);
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
      await press(tester, find.byKey(const ValueKey('shop-buy-museum')));
      expect(find.text('Kup za 200 pkt?'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('shop-buy-museum')), findsOneWidget);
      expect(controller.shop.balance, 1000);
      await press(tester, find.byKey(const ValueKey('points-guide')));
      expect(find.byType(PointsGuideScreen), findsOneWidget);
      await back(tester);
      expect(find.byType(PointsGuideScreen), findsNothing);
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
