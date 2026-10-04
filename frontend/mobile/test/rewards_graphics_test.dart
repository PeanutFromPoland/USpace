import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/graphics.dart';
import 'package:uspace/ui/theme.dart';

void main() {
  test('Both reward themes retain readable surface and button text', () {
    for (final id in ['explorer', 'gardener']) {
      for (final dark in [false, true]) {
        for (final contrast in [false, true]) {
          final s = kindSpotTheme(
            DemoProfile(theme: id, darkMode: dark, highContrast: contrast),
          ).colorScheme;
          for (final pair in [
            (s.surface, s.onSurface),
            (s.primary, s.onPrimary),
            (s.primaryContainer, s.onPrimaryContainer),
          ]) {
            final a = pair.$1.computeLuminance(),
                b = pair.$2.computeLuminance();
            final ratio =
                (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$id dark=$dark contrast=$contrast',
            );
          }
        }
      }
    }
  });
  testWidgets(
    'Bow overlays avatar without intercepting controls; accessible mode suppresses patterns',
    (tester) async {
      var tapped = false;
      Future<void> show(bool quiet) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: kindSpotTheme(
              DemoProfile(theme: 'explorer', highContrast: quiet),
            ),
            builder: (context, child) =>
                KindSpotBackdrop(themeId: 'explorer', child: child!),
            home: Scaffold(
              body: Column(
                children: [
                  const KindSpotAvatar(
                    'avatar_lemur',
                    frameId: 'frame_bow',
                    label: 'Awatar: Lemur',
                  ),
                  const KindSpotAvatar(
                    'avatar_cat',
                    size: 64,
                    label: 'Awatar: Kot',
                  ),
                  FilledButton(
                    onPressed: () => tapped = true,
                    child: const Text('Wybierz'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(false);
      expect(find.byType(GridView), findsOneWidget);
      await tester.tap(find.text('Wybierz'));
      expect(tapped, isTrue);
      await show(true);
      expect(find.byType(GridView), findsNothing);
      expect(find.bySemanticsLabel('Awatar: Lemur'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
