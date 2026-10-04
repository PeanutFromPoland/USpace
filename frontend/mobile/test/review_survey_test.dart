import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/survey_catalog.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/ui/place_details.dart';
import 'package:uspace/ui/review_survey.dart';
import 'package:uspace/ui/graphics.dart';
import 'package:uspace/ui/theme.dart';

import 'domain_test.dart' show MemoryStore;

Future<AppController> _controller(List<String> needIds) async {
  final controller = AppController(
    DemoRepository(MemoryStore()),
    autoDemoLogin: false,
  );
  await controller.load();
  await controller.saveProfile(controller.profile.copyWith(needIds: needIds));
  return controller;
}

Widget _app(AppController controller, Widget home) =>
    MaterialApp(theme: kindSpotTheme(controller.profile), home: home);

Place get _library => demoPlaces.firstWhere((p) => p.id == 'library');

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Binary answers are clear and controls have no absent option', (
    tester,
  ) async {
    final controller = await _controller([]);
    await tester.pumpWidget(
      _app(
        controller,
        ReviewSurveyScreen(
          controller: controller,
          place: _library,
          providedQuestions: [
            questionFor('guide_dog'),
            questionFor('easy_controls'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tapText(tester, 'Zaczynam');
    await _tapText(tester, 'Dalej');
    expect(find.text('Tak'), findsOneWidget);
    expect(find.text('Nie'), findsOneWidget);
    expect(find.text('Nie mogłem sprawdzić'), findsOneWidget);
    await _tapText(tester, 'Tak');
    await _tapText(tester, 'Dalej');
    expect(
      find.text(
        'Czy klamki, przyciski i terminal da się obsłużyć bez wysiłku?',
      ),
      findsOneWidget,
    );
    expect(find.text('Nie'), findsNothing);
    expect(find.text('0 – Brak funkcji'), findsNothing);
    expect(find.text('Nie mogłem sprawdzić'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Reviewed feature icon and question fit 320px at 200 percent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await _controller(['stairs']);
    await tester.pumpWidget(
      MaterialApp(
        theme: kindSpotTheme(controller.profile),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: ReviewSurveyScreen(controller: controller, place: _library),
      ),
    );
    await tester.pumpAndSettle();
    await _tapText(tester, 'Zaczynam');
    await _tapText(tester, 'Dalej');
    expect(find.text('Czy da się wejść bez schodów?'), findsOneWidget);
    expect(find.byType(KindSpotFeatureIcon), findsOneWidget);
    expect(
      tester
          .widget<KindSpotFeatureIcon>(find.byType(KindSpotFeatureIcon))
          .featureId,
      'step_free_entrance',
    );
    expect(
      KindSpotFeatureIcon.ids['elevator'],
      KindSpotFeatureIcon.ids['lift'],
    );
    expect(
      KindSpotFeatureIcon.ids['quiet_environment'],
      KindSpotFeatureIcon.ids['quiet'],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Every shown question needs an answer before moving on', (
    tester,
  ) async {
    final controller = await _controller(['stairs', 'noise']);
    await tester.pumpWidget(
      _app(
        controller,
        ReviewSurveyScreen(
          controller: controller,
          place: _library,
          today: DateTime(2026, 10, 3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Liczba pytań: 2'), findsOneWidget);
    await tester.tap(find.text('Zaczynam'));
    await tester.pumpAndSettle();
    expect(find.text('Kiedy była wizyta?'), findsOneWidget);
    expect(find.text('Nie podano'), findsOneWidget);
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();

    expect(find.text('Pytanie 1 z 2'), findsOneWidget);
    expect(find.text('Czy da się wejść bez schodów?'), findsOneWidget);
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Wybierz odpowiedź.'), findsOneWidget);
    expect(find.text('Pytanie 1 z 2'), findsOneWidget);

    await _tapText(tester, 'Nie');
    expect(find.textContaining('Wybierz odpowiedź.'), findsNothing);
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();

    expect(find.text('Jak głośno było?'), findsOneWidget);
    // Otoczenie zawsze „jest”: bez opcji braku funkcji.
    expect(find.text('Nie'), findsNothing);
    await _tapText(tester, 'Nie mogłem sprawdzić');
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();

    expect(
      find.text('Czy polecisz to miejsce osobom z podobnymi potrzebami?'),
      findsOneWidget,
    );
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    expect(find.text('Sprawdź i wyślij'), findsOneWidget);
    expect(find.text('Nie'), findsOneWidget);
    await tester.tap(find.text('Wyślij recenzję'));
    await tester.pumpAndSettle();

    expect(
      find.text('Recenzja zapisana w wersji demonstracyjnej'),
      findsOneWidget,
    );
    final answers = controller.demoSubmittedReviews.single['answers'] as List;
    expect(answers[0]['presence'], 'absent');
    expect(answers[0]['rating'], 0);
    expect(answers[1]['presence'], 'unknown');
    expect(answers[1]['rating'], isNull);
    expect(controller.reviewDraft(_library.id), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Leaving the survey keeps the draft for this place', (
    tester,
  ) async {
    final controller = await _controller(['stairs']);
    await tester.pumpWidget(
      _app(
        controller,
        PlaceDetailsScreen(
          controller: controller,
          place: _library,
          surveyBuilder: (context, place) =>
              ReviewSurveyScreen(controller: controller, place: place),
        ),
      ),
    );
    await _tapText(tester, 'Otwórz ankietę');
    expect(find.byType(ReviewSurveyScreen), findsOneWidget);
    await tester.tap(find.text('Zaczynam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    await _tapText(tester, 'Nie mogłem sprawdzić');
    // Systemowe cofnięcie prowadzi przez kolejne kroki do wyjścia.
    for (var i = 0; i < 3; i++) {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
    expect(find.byType(ReviewSurveyScreen), findsNothing);
    expect(controller.reviewDraft(_library.id)?.started, isTrue);
    await _tapText(tester, 'Otwórz ankietę');
    expect(find.textContaining('Kontynuujesz rozpoczętą'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Question screen meets Flutter accessibility guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = await _controller(['wheelchair']);
    await tester.pumpWidget(
      _app(
        controller,
        ReviewSurveyScreen(
          controller: controller,
          place: _library,
          today: DateTime(2026, 10, 3),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zaczynam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dalej'));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  for (final dark in [false, true]) {
    testWidgets('Survey question at 320 px and 200% text, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final controller = await _controller(['wheelchair']);
      await controller.saveProfile(controller.profile.copyWith(darkMode: dark));
      await tester.pumpWidget(
        _app(
          controller,
          ReviewSurveyScreen(
            controller: controller,
            place: _library,
            today: DateTime(2026, 10, 3),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zaczynam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dalej'));
      await tester.pumpAndSettle();
      expect(find.text('Pytanie 1 z 2'), findsOneWidget);
      await _tapText(tester, '4 – Małe utrudnienia');
      expect(tester.takeException(), isNull);
    });
  }
}
