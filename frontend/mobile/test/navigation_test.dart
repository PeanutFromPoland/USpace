import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/app.dart';
import 'package:uspace/ui/components.dart';
import 'package:uspace/ui/discovery.dart';
import 'package:uspace/ui/navigation.dart';
import 'package:uspace/ui/preferences.dart';
import 'package:uspace/ui/theme.dart';

import 'domain_test.dart' show MemoryStore;

double contrast(Color a, Color b) {
  final values = [a.computeLuminance(), b.computeLuminance()]..sort();
  return (values.last + .05) / (values.first + .05);
}

void main() {
  for (final dark in [false, true]) {
    for (final palette in ['orange', 'pink', 'blue']) {
      for (final high in [false, true]) {
        test('Text contrast $palette dark=$dark high=$high', () {
          final scheme = kindSpotTheme(
            DemoProfile(theme: palette, darkMode: dark, highContrast: high),
          ).colorScheme;
          for (final pair in [
            (scheme.surface, scheme.onSurface),
            (scheme.surfaceContainer, scheme.onSurfaceVariant),
            (scheme.primary, scheme.onPrimary),
            (scheme.primaryContainer, scheme.onPrimaryContainer),
            (scheme.errorContainer, scheme.onErrorContainer),
            (scheme.tertiaryContainer, scheme.onTertiaryContainer),
            (scheme.surfaceContainerHighest, scheme.onSurface),
          ]) {
            expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
          }
        });
      }
      testWidgets('Home and profile fit 320px at 200%: $palette dark=$dark', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final controller = AppController(DemoRepository(MemoryStore()));
        await controller.load();
        await controller.saveProfile(
          controller.profile.copyWith(theme: palette, darkMode: dark),
        );
        await tester.pumpWidget(KindSpotApp(controller: controller));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final semantics = tester.ensureSemantics();
        for (final item in KindSpotNavigation.items) {
          final button = find.byKey(ValueKey('navigation-${item.$1}'));
          expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
          expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
          expect(
            tester
                .getSemantics(
                  find
                      .ancestor(of: button, matching: find.byType(Semantics))
                      .first,
                )
                .label,
            item.$2,
          );
          final text = find.descendant(
            of: button,
            matching: find.text(item.$2),
          );
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
          );
        }
        semantics.dispose();
        await tester.tap(find.byKey(const ValueKey('navigation-4')));
        await tester.pumpAndSettle();
        expect(find.text('Test Hackaton'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Wygląd i dostępność'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Wygląd i dostępność'));
        await tester.pumpAndSettle();
        expect(find.byType(AccessibilityScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          tester
              .renderObject<RenderParagraph>(find.text('Dostępność interfejsu'))
              .didExceedMaxLines,
          isFalse,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Znajdź swoje miejsce.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Map button restores map; filters return to map from profile', (
    tester,
  ) async {
    final controller = AppController(DemoRepository(MemoryStore()));
    await tester.pumpWidget(KindSpotApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lista'));
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
    expect(find.byType(PlacesMap), findsNothing);
    await tester.tap(find.byKey(const ValueKey('navigation-2')));
    await tester.pumpAndSettle();
    expect(find.byType(PlacesMap), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('navigation-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-3')));
    await tester.pumpAndSettle();
    expect(find.byType(FiltersScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Znajdź swoje miejsce.'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Wyjść z KindSpot?'), findsOneWidget);
    await tester.tap(find.text('Zostań'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeShell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Statuses keep text and distinct icons in dark theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: kindSpotTheme(const DemoProfile(darkMode: true)),
        home: Scaffold(
          body: Column(
            children: [
              for (final status in MatchStatus.values) StatusTag(status),
            ],
          ),
        ),
      ),
    );
    for (final status in MatchStatus.values) {
      expect(find.text(matchLabel(status)), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
