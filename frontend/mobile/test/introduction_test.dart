import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/ui/introduction.dart';

class IntroMemory implements IntroductionStore {
  bool seen = false, fail = false;
  int writes = 0;
  @override
  Future<bool> hasSeen() async => seen;
  @override
  Future<void> markSeen() async {
    writes++;
    if (fail) throw StateError('storage');
    seen = true;
  }
}

void main() {
  testWidgets(
    'First launch shows three slides automatically and persists completion',
    (tester) async {
      final store = IntroMemory();
      await tester.pumpWidget(
        KindSpotIntroduction(
          store: store,
          child: const MaterialApp(home: Text('Aplikacja')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Slajd 1 z 3'), findsOneWidget);
      expect(find.text('Aplikacja'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Slajd 2 z 3'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Slajd 3 z 3'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(store.seen, isTrue);
      expect(store.writes, 1);
      expect(find.text('Aplikacja'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        KindSpotIntroduction(
          store: store,
          child: const MaterialApp(home: Text('Aplikacja')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Slajd 1 z 3'), findsNothing);
      expect(find.text('Aplikacja'), findsOneWidget);
    },
  );

  testWidgets(
    'Pause and background prevent automatic advances; skip persists',
    (tester) async {
      final store = IntroMemory();
      await tester.pumpWidget(
        KindSpotIntroduction(store: store, child: const SizedBox()),
      );
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('Slajd 1 z 3'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.tap(find.text('Zatrzymaj przewijanie'));
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('Slajd 1 z 3'), findsOneWidget);
      await tester.tap(find.text('Pomiń'));
      await tester.pumpAndSettle();
      expect(store.seen, isTrue);
    },
  );

  testWidgets(
    'Reduced motion and screen reader use manual slides at 320px and 200% text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screenReader in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(320, 640),
                textScaler: TextScaler.linear(2),
                disableAnimations: !screenReader,
                accessibleNavigation: screenReader,
              ),
              child: IntroductionSlides(onFinish: () async {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 20));
        expect(find.text('Slajd 1 z 3'), findsOneWidget);
        expect(find.text('Zatrzymaj przewijanie'), findsNothing);
        await tester.tap(find.text('Dalej'));
        await tester.pumpAndSettle();
        expect(find.text('Slajd 2 z 3'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets('Storage failure preserves introduction and allows retry', (
    tester,
  ) async {
    final store = IntroMemory()..fail = true;
    await tester.pumpWidget(
      KindSpotIntroduction(
        store: store,
        child: const MaterialApp(home: Text('Aplikacja')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pomiń'));
    await tester.pumpAndSettle();
    expect(store.seen, isFalse);
    expect(find.text('Kontynuuj bez zapisu'), findsOneWidget);
    store.fail = false;
    await tester.tap(find.text('Pomiń'));
    await tester.pumpAndSettle();
    expect(store.seen, isTrue);
  });
}
