import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/preferences.dart';

import 'domain_test.dart' show MemoryStore;

class DelayedStore extends MemoryStore {
  final completion = Completer<void>();
  int writes = 0;
  @override
  Future<void> write(String data) async {
    writes++;
    await completion.future;
    await super.write(data);
  }
}

void main() {
  test('Explicit demo logout overrides automatic entry until restart; preserves preferences', () async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    await controller.saveProfile(
      controller.profile.copyWith(needIds: ['wheelchair'], theme: 'pink'),
    );
    await controller.closeDemoSession();
    expect(controller.isDemoSignedIn, isFalse);
    expect(controller.profile.needIds, ['wheelchair']);
    await controller.saveProfile(controller.profile.copyWith(darkMode: true));
    expect(controller.isDemoSignedIn, isFalse);
    await controller.openDemoSession();
    expect(controller.isDemoSignedIn, isTrue);
    await controller.closeDemoSession();
    final manual = AppController(DemoRepository(store), autoDemoLogin: false);
    await manual.load();
    expect(manual.isDemoSignedIn, isFalse);
    final restarted = AppController(DemoRepository(store));
    await restarted.load();
    expect(restarted.isDemoSignedIn, isTrue);
    expect(restarted.profile.theme, 'pink');
  });
  test(
    'Failed logout preserves confirmed session and reports failure',
    () async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      store.fail = true;
      await controller.closeDemoSession();
      expect(controller.isDemoSignedIn, isTrue);
      expect(controller.sessionError, isNotNull);
      expect(controller.sessionRevision, 0);
      expect(controller.saving, isFalse);
      store.fail = false;
      await controller.closeDemoSession();
      expect(controller.isDemoSignedIn, isFalse);
      expect(controller.sessionError, isNull);
    },
  );
  testWidgets(
    'Closing demo removes private routes and Back does not restore them',
    (tester) async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await tester.pumpWidget(USpaceApp(controller: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('navigation-4')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('account-settings')),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('account-settings')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('demo-exit')),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('demo-exit')));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(HomeShell), findsNothing);
      expect(find.text('Test Hackaton'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HomeShell), findsNothing);
      await tester.tap(find.byTooltip('Ustawienia dostępności'));
      await tester.pumpAndSettle();
      expect(find.byType(AccessibilityScreen), findsOneWidget);
      expect(find.text('Moje potrzeby'), findsNothing);
      await controller.openDemoSession();
      await tester.pumpAndSettle();
      expect(find.byType(HomeShell), findsOneWidget);
      expect(find.byType(AccessibilityScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Failed entry stays visible and can be retried with keyboard', (
    tester,
  ) async {
    final store = MemoryStore()..fail = true;
    final controller = AppController(
      DemoRepository(store),
      autoDemoLogin: false,
    );
    await tester.pumpWidget(USpaceApp(controller: controller));
    await tester.pumpAndSettle();
    final enter = find.byKey(const ValueKey('demo-enter'));
    await tester.scrollUntilVisible(
      enter,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(enter);
    await tester.pumpAndSettle();
    final error = find.text(
      'Nie udało się otworzyć konta demo. Spróbuj ponownie. Twoje ustawienia nie zostały zmienione.',
    );
    expect(error, findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    expect(error, findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    store.fail = false;
    tester.widget<FilledButton>(enter).focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Entry during pending write cannot be submitted twice', (
    tester,
  ) async {
    final store = DelayedStore();
    final controller = AppController(
      DemoRepository(store),
      autoDemoLogin: false,
    );
    await tester.pumpWidget(USpaceApp(controller: controller));
    await tester.pumpAndSettle();
    final enter = find.byKey(const ValueKey('demo-enter'));
    await tester.scrollUntilVisible(
      enter,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(enter);
    await tester.pump();
    expect(tester.widget<FilledButton>(enter).onPressed, isNull);
    expect(find.text('Otwieranie…'), findsOneWidget);
    expect(store.writes, 1);
    store.completion.complete();
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Entry and persistent error fit 320px with 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final store = MemoryStore()..fail = true;
    final controller = AppController(
      DemoRepository(store),
      autoDemoLogin: false,
    );
    await tester.pumpWidget(USpaceApp(controller: controller));
    await tester.pumpAndSettle();
    final enter = find.byKey(const ValueKey('demo-enter'));
    await tester.scrollUntilVisible(
      enter,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(enter);
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsNothing);
    expect(
      find.textContaining('Nie udało się otworzyć konta demo.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
