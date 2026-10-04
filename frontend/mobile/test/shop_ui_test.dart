import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/preferences.dart';
import 'package:uspace/ui/shop_screen.dart';
import 'package:uspace/ui/theme.dart';
import 'package:uspace/domain/models.dart';

import 'domain_test.dart' show MemoryStore;

Future<void> press(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  final scroll = tester
      .state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  scroll.jumpTo(0);
  await tester.pump();
  for (var i = 0; finder.evaluate().isEmpty && i < 150; i++) {
    scroll.jumpTo((scroll.pixels + 220).clamp(0, scroll.maxScrollExtent));
    await tester.pump();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Shop cancel, buy, pending reward, redemption and history use the same ledger',
    (tester) async {
      final semantics = tester.ensureSemantics();

      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: kindSpotTheme(const DemoProfile()),
          home: Scaffold(body: ShopRewardsScreen(controller: controller)),
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await press(tester, 'shop-buy-museum');
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 1000);
      expect(controller.shop.purchases, isEmpty);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await press(tester, 'shop-buy-museum');
      await tester.tap(find.byKey(const ValueKey('shop-confirm')));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 800);
      await press(tester, 'my-rewards-tab');
      await press(tester, 'redeem-TEST-1');
      await tester.tap(find.byKey(const ValueKey('shop-redeem-confirm')));
      await tester.pumpAndSettle();
      expect(find.text('Nie masz nagród do odebrania.'), findsOneWidget);
      await press(tester, 'purchase-history-tab');
      expect(find.textContaining('Zrealizowana testowo:'), findsOneWidget);
      semantics.dispose();
      expect(controller.shop.purchases.length, 1);
      expect(controller.shop.balance, 800);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Name validation, save with failure/retry, load and use remain distinct',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(home: FiltersScreen(controller: controller)),
      );
      await tester.tap(find.text('Na wózku'));
      await press(tester, 'filters-save');
      await tester.tap(find.byKey(const ValueKey('filter-name-confirm')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Wpisz nazwę od 1'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('filter-name')),
        'Mój filtr',
      );
      store.fail = true;
      await tester.tap(find.byKey(const ValueKey('filter-name-confirm')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Twoje wybory pozostają w formularzu.'),
        findsOneWidget,
      );
      expect(controller.profile.namedFilters, isEmpty);
      await press(tester, 'filters-save');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('filter-name')))
            .controller!
            .text,
        'Mój filtr',
      );
      store.fail = false;
      await tester.tap(find.byKey(const ValueKey('filter-name-confirm')));
      await tester.pumpAndSettle();
      expect(controller.profile.namedFilters.single.name, 'Mój filtr');
      expect(controller.activeRules, isEmpty);
      await press(tester, 'filters-use');
      expect(controller.activeRules.first.minRating, 4);
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(320, 800), const Size(800, 360)]) {
    testWidgets('New shop, help and confirmation at 200 percent in $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = AppController(
        DemoRepository(MemoryStore()),
        resetAccountOnLaunch: true,
      );
      await tester.pumpWidget(KindSpotApp(controller: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('navigation-1')));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await press(tester, 'shop-buy-museum');
      await tester.ensureVisible(find.byKey(const ValueKey('shop-confirm')));
      await tester.tap(find.byKey(const ValueKey('shop-confirm')));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 800);
      await press(tester, 'points-guide');
      expect(find.byType(PointsGuideScreen), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Filter name dialog at 200 percent accepts Enter without layout errors',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(home: FiltersScreen(controller: controller)),
      );
      await press(tester, 'filters-save');
      await tester.enterText(
        find.byKey(const ValueKey('filter-name')),
        'Duży tekst',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(controller.profile.namedFilters.single.name, 'Duży tekst');
      expect(tester.takeException(), isNull);
    },
  );
}
