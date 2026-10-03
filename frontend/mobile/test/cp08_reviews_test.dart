import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/demo_reviews.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/domain/reviews.dart';
import 'package:uspace/ui/reviews.dart';

Future<void> reach(WidgetTester tester, String key) async {
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    350,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'Unknown observation and unknown counts never become zero ratings/votes',
    () {
      final reviews = demoReviewsFor(demoPlaces.first);
      final unknown = reviews.first.observations[1];
      expect(unknown.fact.presence, Presence.unknown);
      expect(unknown.fact.rating, isNull);
      expect(displayedVoteCounts(unknown, ReviewVote.agree), (null, null));
      expect(
        displayedVoteCounts(
          reviews.first.observations.first,
          ReviewVote.disagree,
        ),
        (8, 3),
      );
      expect(
        demoReviewsFor(demoPlaces.firstWhere((p) => p.id == 'cafe')),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Own review cannot be voted on; publication, verification and points are independent',
    (tester) async {
      final place = demoPlaces.first;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewsScreen(
            place: place,
            onVote: (id, vote) async {
              calls++;
            },
          ),
        ),
      );
      await reach(tester, '${place.id}-review-own');
      expect(find.byKey(ValueKey('${place.id}-obs-own-agree')), findsNothing);
      expect(find.text('Sprawdzanie: Oczekuje na sprawdzenie'), findsWidgets);
      await reach(tester, '${place.id}-review-held');
      expect(find.text('Publikacja: Wstrzymana'), findsOneWidget);
      expect(find.text('Punkty: Nieprzyznane — przykład'), findsOneWidget);
      expect(calls, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Vote failure retains counts, persistent feedback and then retries',
    (tester) async {
      final place = demoPlaces.first;
      final id = '${place.id}-obs-a-entrance';
      var fail = true;
      final votes = <ReviewVote?>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewsScreen(
            place: place,
            allowVoteChanges: true,
            onVote: (id, vote) async {
              if (fail) throw StateError('save');
              votes.add(vote);
            },
          ),
        ),
      );
      await reach(tester, '$id-agree');
      await tester.tap(find.byKey(ValueKey('$id-agree')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Nie udało się zapisać głosu.'),
        findsOneWidget,
      );
      expect(find.text('Zgadzam się: 8 · Nie zgadzam się: 2'), findsOneWidget);
      await tester.pump(const Duration(seconds: 12));
      expect(
        find.textContaining('Nie udało się zapisać głosu.'),
        findsOneWidget,
      );
      fail = false;
      await reach(tester, '$id-agree');
      await tester.tap(find.byKey(ValueKey('$id-agree')));
      await tester.pumpAndSettle();
      expect(find.text('Zgadzam się: 9 · Nie zgadzam się: 2'), findsOneWidget);
      await reach(tester, '$id-disagree');
      await tester.tap(find.byKey(ValueKey('$id-disagree')));
      await tester.pumpAndSettle();
      expect(find.text('Zgadzam się: 8 · Nie zgadzam się: 3'), findsOneWidget);
      await reach(tester, '$id-disagree');
      await tester.tap(find.byKey(ValueKey('$id-disagree')));
      await tester.pumpAndSettle();
      expect(votes, [ReviewVote.agree, ReviewVote.disagree, null]);
      expect(find.text('Zgadzam się: 8 · Nie zgadzam się: 2'), findsOneWidget);
    },
  );

  testWidgets('Pending vote prevents repeated actions and own votes', (
    tester,
  ) async {
    final place = demoPlaces.first;
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ReviewsScreen(
          place: place,
          onVote: (id, vote) async {
            calls++;
            await pending.future;
          },
        ),
      ),
    );
    final key = '${place.id}-obs-a-entrance-agree';
    await reach(tester, key);
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pump();
    expect(
      tester.widget<OutlinedButton>(find.byKey(ValueKey(key))).onPressed,
      isNull,
    );
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Reporting is local and does not hide review; reason survives failure',
    (tester) async {
      final place = demoPlaces.first;
      var fail = true;
      ReviewReportReason? received;
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewsScreen(
            place: place,
            onReport: (id, reason) async {
              if (fail) throw StateError('save');
              received = reason;
            },
          ),
        ),
      );
      final key = 'report-${place.id}-review-a';
      await reach(tester, key);
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<ReviewReportReason>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spam').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('review-report-confirm')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Wybrany powód zachowano.'), findsOneWidget);
      fail = false;
      await reach(tester, key);
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      expect(find.text('Spam'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('review-report-confirm')));
      await tester.pumpAndSettle();
      expect(received, ReviewReportReason.spam);
      expect(find.byKey(ValueKey('${place.id}-review-a')), findsOneWidget);
      expect(
        tester.widget<OutlinedButton>(find.byKey(ValueKey(key))).onPressed,
        isNull,
      );
      expect(find.text('Zgłoszone lokalnie w demo'), findsOneWidget);
    },
  );

  testWidgets(
    '320px/200% text includes contextual semantics, vote targets and report dialog',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = tester.ensureSemantics();
      final place = demoPlaces.first;
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewsScreen(
            place: place,
            onVote: (id, vote) async {},
            onReport: (id, reason) async {},
          ),
        ),
      );
      final key = '${place.id}-obs-a-entrance-agree';
      await reach(tester, key);
      expect(
        find.bySemanticsLabel(
          RegExp('Zgadzam się: Wejście bez schodów, Wejście główne'),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byKey(ValueKey(key))).height,
        greaterThanOrEqualTo(48),
      );
      await reach(tester, 'report-${place.id}-review-a');
      await tester.tap(find.byKey(ValueKey('report-${place.id}-review-a')));
      await tester.pumpAndSettle();
      expect(find.text('Zgłoszenie demo'), findsOneWidget);
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<ReviewReportReason>),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byType(DropdownButtonFormField<ReviewReportReason>),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Spam').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
