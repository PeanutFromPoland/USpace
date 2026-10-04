import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/preferences.dart';

import 'domain_test.dart' show MemoryStore;

Future<void> reach(WidgetTester tester, String key) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

class PendingStore extends MemoryStore {
  final completion = Completer<void>();
  int writes = 0;
  @override
  Future<void> write(String data) async {
    writes++;
    await completion.future;
    await super.write(data);
  }
}

Future<void> confirmName(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey('filter-name')),
    'Testowy filtr',
  );
  await tester.tap(find.byKey(const ValueKey('filter-name-confirm')));
  await tester.pumpAndSettle();
}

void main() {
  for (final needs in [true, false]) {
    testWidgets(
      '${needs ? "Needs" : "Filters"} disables editing and double save while pending',
      (tester) async {
        final store = PendingStore();
        final controller = AppController(DemoRepository(store));
        await controller.load();
        await tester.pumpWidget(
          MaterialApp(
            home: needs
                ? NeedsScreen(controller: controller)
                : FiltersScreen(controller: controller),
          ),
        );
        final key = needs ? 'needs-save' : 'filters-save';
        await reach(tester, key);
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        if (!needs) await confirmName(tester);
        expect(
          tester.widget<FilledButton>(find.byKey(ValueKey(key))).onPressed,
          isNull,
        );
        expect(find.text('Zapisywanie…'), findsOneWidget);
        if (needs) {
          expect(
            tester
                .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
                .every((tile) => tile.onChanged == null),
            isTrue,
          );
          expect(find.byType(SwitchListTile), findsNothing);
        } else {
          expect(
            tester
                .widget<SwitchListTile>(find.byType(SwitchListTile))
                .onChanged,
            isNull,
          );
        }
        expect(store.writes, 1);
        store.completion.complete();
        await tester.pumpAndSettle();
        expect(controller.saving, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final needs in [true, false]) {
    testWidgets(
      '${needs ? "Needs" : "Filters"} retains draft after failure and retries with Enter',
      (tester) async {
        final store = MemoryStore();
        final controller = AppController(DemoRepository(store));
        await controller.load();
        await tester.pumpWidget(
          MaterialApp(
            home: needs
                ? NeedsScreen(controller: controller)
                : FiltersScreen(controller: controller),
          ),
        );
        if (needs) {
          await tester.tap(find.byType(CheckboxListTile).first);
        } else {
          await tester.tap(find.text('Na wózku'));
        }
        await tester.pump();
        final key = needs ? 'needs-save' : 'filters-save';
        await reach(tester, key);
        store.fail = true;
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        if (!needs) await confirmName(tester);
        final error = find.textContaining(
          'Twoje wybory pozostają w formularzu.',
        );
        expect(error, findsOneWidget);
        final regions = find.ancestor(
          of: error,
          matching: find.byType(Semantics),
        );
        expect(
          tester
              .widgetList<Semantics>(regions)
              .any((e) => e.properties.liveRegion == true),
          isTrue,
        );
        await tester.pump(const Duration(seconds: 12));
        expect(error, findsOneWidget);
        expect(controller.profile.needIds, isEmpty);
        expect(controller.profile.rules, isEmpty);
        await reach(tester, key);
        store.fail = false;
        tester
            .widget<FilledButton>(find.byKey(ValueKey(key)))
            .focusNode!
            .requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        if (!needs) await confirmName(tester);
        if (needs) {
          expect(controller.profile.needIds, isNotEmpty);
          expect(controller.profile.publicNeeds, isFalse);
        } else {
          expect(
            controller.profile.namedFilters.single.rules.first.minRating,
            4,
          );
        }
        final restart = AppController(DemoRepository(store));
        await restart.load();
        expect(restart.profile.toJson(), controller.profile.toJson());
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Clear edits draft only; Use clears active choices without changing saved rules',
    (tester) async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      await controller.saveProfile(
        controller.profile.copyWith(
          rules: [const FilterRule('quiet', Importance.required, 4)],
          includeUnknown: true,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: FiltersScreen(controller: controller)),
      );
      await tester.tap(find.byKey(const ValueKey('filters-clear')));
      await tester.pump();
      expect(controller.profile.rules.single.featureId, 'quiet');
      expect(controller.profile.includeUnknown, isTrue);
      await reach(tester, 'filters-use');
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );
      await tester.tap(find.byKey(const ValueKey('filters-use')));
      await tester.pumpAndSettle();
      expect(controller.activeRules, isEmpty);
      expect(controller.activeIncludeUnknown, isFalse);
      expect(controller.profile.rules.single.featureId, 'quiet');
    },
  );

  testWidgets('Filter dropdown semantics include feature and minimum rating', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    final controller = AppController(DemoRepository(MemoryStore()));
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: FiltersScreen(controller: controller)),
    );
    await tester.tap(find.text('Na wózku'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('step_free_entrance-required')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Znaczenie cechy:.*')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('Minimalna ocena:.*')), findsWidgets);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  for (final needs in [true, false]) {
    testWidgets(
      '${needs ? "Needs" : "Filters"} remains usable at 320 px and 200% including failure',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = AppController(
          DemoRepository(MemoryStore()..fail = true),
        );
        await controller.load();
        await tester.pumpWidget(
          MaterialApp(
            home: needs
                ? NeedsScreen(controller: controller)
                : FiltersScreen(controller: controller),
          ),
        );
        if (!needs) {
          await tester.scrollUntilVisible(
            find.text('Na wózku'),
            150,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.tap(find.text('Na wózku'));
          await tester.pump();
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('step_free_entrance-required')),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('step_free_entrance-required')),
          );
          await tester.pumpAndSettle();
          expect(find.text('Warunek konieczny'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Warunek konieczny'));
          await tester.pumpAndSettle();
        }
        final key = needs ? 'needs-save' : 'filters-save';
        await reach(tester, key);
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        if (!needs) await confirmName(tester);
        expect(
          find.textContaining('Twoje wybory pozostają w formularzu.'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
