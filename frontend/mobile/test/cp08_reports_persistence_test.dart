import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/data/demo_reviews.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/domain/reviews.dart';
import 'package:uspace/ui/review_navigation.dart';

import 'domain_test.dart' show MemoryStore;

class PendingReportStore extends MemoryStore {
  final completion = Completer<void>();
  int writes = 0;
  @override
  Future<void> write(String value) async {
    writes++;
    await completion.future;
    await super.write(value);
  }
}

void main() {
  test('Report persists/reloads without changing needs, aggregates, votes or moderation', () async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    await controller.saveProfile(
      controller.profile.copyWith(
        needIds: ['wheelchair'],
        savedPlaceIds: ['garden'],
      ),
    );
    final before = Map<String, dynamic>.of(controller.profile.toJson());
    final review = demoReviewsFor(demoPlaces.first).first;
    await controller.reportDemoReview(review.id, ReviewReportReason.spam);
    final reload = AppController(DemoRepository(store));
    await reload.load();
    expect(reload.profile.reviewReports, {review.id: 'spam'});
    final after = Map<String, dynamic>.of(reload.profile.toJson())
      ..remove('reviewReports');
    before.remove('reviewReports');
    expect(after, before);
    final unchanged = demoReviewsFor(demoPlaces.first).first;
    expect(unchanged.publication, ReviewPublication.visible);
    expect(unchanged.verification, review.verification);
    expect(unchanged.points, review.points);
    expect(
      unchanged.observations.first.agreements,
      review.observations.first.agreements,
    );
    expect(demoPlaces.first.aggregateRating, 4.8);
    await controller.reportDemoReview(review.id, ReviewReportReason.offensive);
    expect(controller.profile.reviewReports[review.id], 'spam');
    await controller.reset();
    expect(controller.profile.reviewReports, isEmpty);
    await reload.load();
    expect(reload.profile.reviewReports, isEmpty);
  });

  test(
    'Missing, own, held, unloaded and signed out reviews cannot be reported',
    () async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await expectLater(
        controller.reportDemoReview('garden-review-a', ReviewReportReason.spam),
        throwsStateError,
      );
      await controller.load();
      for (final id in ['missing', 'garden-review-own', 'garden-review-held']) {
        await expectLater(
          controller.reportDemoReview(id, ReviewReportReason.spam),
          throwsArgumentError,
        );
      }
      await controller.closeDemoSession();
      await expectLater(
        controller.reportDemoReview('garden-review-a', ReviewReportReason.spam),
        throwsStateError,
      );
      expect(controller.profile.reviewReports, isEmpty);
    },
  );

  test('Failed report leaves confirmed state untouched; retry and old storage remain safe', () async {
    final store = MemoryStore()..fail = true;
    final controller = AppController(DemoRepository(store));
    await controller.load();
    await expectLater(
      controller.reportDemoReview(
        'garden-review-a',
        ReviewReportReason.offensive,
      ),
      throwsStateError,
    );
    expect(controller.profile.reviewReports, isEmpty);
    expect(controller.saving, isFalse);
    store.fail = false;
    await controller.reportDemoReview(
      'garden-review-a',
      ReviewReportReason.offensive,
    );
    expect(controller.profile.reviewReports, {'garden-review-a': 'offensive'});
    final oldJson = const DemoProfile().toJson()..remove('reviewReports');
    expect(DemoProfile.fromJson(oldJson).reviewReports, isEmpty);
  });

  test(
    'Concurrent report cannot overwrite an in-flight profile write',
    () async {
      final store = PendingReportStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      final first = controller.reportDemoReview(
        'garden-review-a',
        ReviewReportReason.spam,
      );
      await expectLater(
        controller.reportDemoReview(
          'garden-review-b',
          ReviewReportReason.offensive,
        ),
        throwsStateError,
      );
      expect(store.writes, 1);
      expect(controller.profile.reviewReports, isEmpty);
      store.completion.complete();
      await first;
      expect(controller.profile.reviewReports, {'garden-review-a': 'spam'});
    },
  );

  testWidgets('Navigation adapter offers persistent local report, no voting', (
    tester,
  ) async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () =>
                  openDemoReviews(context, demoPlaces.first, controller),
              child: const Text('Recenzje'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Recenzje'));
    await tester.pumpAndSettle();
    final agree = find.byKey(const ValueKey('garden-obs-a-entrance-agree'));
    await tester.scrollUntilVisible(
      agree,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.widget<OutlinedButton>(agree).onPressed, isNull);
    final report = find.byKey(const ValueKey('report-garden-review-a'));
    await tester.scrollUntilVisible(
      report,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(report);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('review-report-confirm')));
    await tester.pumpAndSettle();
    expect(controller.profile.reviewReports, {
      'garden-review-a': 'falseInformation',
    });
    expect(tester.widget<OutlinedButton>(report).onPressed, isNull);
    final restarted = AppController(DemoRepository(store));
    await restarted.load();
    expect(restarted.profile.reviewReports, controller.profile.reviewReports);
    expect(find.byKey(const ValueKey('garden-review-a')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
