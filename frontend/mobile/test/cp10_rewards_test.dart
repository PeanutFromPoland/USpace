import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/rewards_demo.dart';
import 'package:uspace/ui/rewards.dart';

import 'domain_test.dart' show MemoryStore;

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: content!,
  ),
  home: Scaffold(body: child),
);
Future<void> press(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> start(WidgetTester tester) async {
  await press(tester, 'reward-start');
  await tester.tap(find.byKey(const ValueKey('reward-confirm')));
  await tester.pumpAndSettle();
}

void main() {
  test('Unknown result resolves the existing fixture, not a new operation', () {
    final initial = RewardPreview(
      rewardExamples[1],
      RewardScenario.unknownResult,
      RewardPreviewStatus.processing,
    );
    final unknown = initial.advance();
    expect(unknown.status, RewardPreviewStatus.unknown);
    final ready = unknown.advance();
    expect(ready.status, RewardPreviewStatus.ready);
    expect(ready.operationId, initial.operationId);
    expect(ready.advance().status, RewardPreviewStatus.ready);
  });
  test(
    'Failure does not claim returned points until the separate confirmation',
    () {
      final pending = RewardPreview(
        rewardExamples[0],
        RewardScenario.failed,
        RewardPreviewStatus.processing,
      );
      final failure = pending.advance();
      expect(failure.status, RewardPreviewStatus.failed);
      expect(failure.statusText, contains('nie jest jeszcze potwierdzony'));
      expect(failure.advance().status, RewardPreviewStatus.released);
      expect(failure.advance().operationId, failure.operationId);
    },
  );
  testWidgets(
    'Catalog opens a theoretical reward; cancellation produces no operation or stored purchase',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      final before = store.value;
      await tester.pumpWidget(host(RewardsScreen(controller: controller)));
      await press(tester, 'shop-buy-museum');
      expect(find.text('Kup za 200 pkt?'), findsOneWidget);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 1000);
      expect(controller.shop.purchases, isEmpty);
      expect(store.value, before);
      await press(tester, 'shop-buy-museum');
      await tester.tap(find.byKey(const ValueKey('shop-confirm')));
      await tester.pumpAndSettle();
      expect(controller.shop.balance, 800);
      expect(controller.shop.purchases.single.reward.id, 'museum');
      expect(store.value, before);
    },
  );
  testWidgets(
    'Blocked cases, changed price and error flow remain usable at 200 percent on narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(RewardPreviewScreen(reward: rewardExamples[0]), scale: 2),
      );
      await press(tester, 'reward-scenario-insufficientPoints');
      expect(find.byKey(const ValueKey('reward-start')), findsNothing);
      await press(tester, 'reward-scenario-unavailable');
      expect(find.byKey(const ValueKey('reward-start')), findsNothing);
      await press(tester, 'reward-scenario-priceChanged');
      await press(tester, 'reward-start');
      expect(find.textContaining('z 100 na 150 pkt'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      await press(tester, 'reward-scenario-failed');
      await start(tester);
      await press(tester, 'reward-advance');
      await press(tester, 'reward-release');
      await tester.scrollUntilVisible(
        find.textContaining('potwierdził zwolnienie'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('potwierdził zwolnienie'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Copy failure preserves the readable invalid code and retries safely',
    (tester) async {
      bool fail = true;
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            if (fail) {
              throw PlatformException(code: 'clipboard_unavailable');
            }
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        host(RewardPreviewScreen(reward: rewardExamples[1])),
      );
      await start(tester);
      await press(tester, 'reward-advance');
      await press(tester, 'reward-copy');
      expect(find.textContaining('Nie udało się skopiować'), findsOneWidget);
      expect(find.text('TEST-NIEWAZNY'), findsOneWidget);
      fail = false;
      await press(tester, 'reward-copy');
      expect(copied, 'TEST-NIEWAZNY');
      expect(find.textContaining('Skopiowano przykładowy kod'), findsOneWidget);
    },
  );
}
