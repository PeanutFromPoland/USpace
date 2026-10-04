import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/ui/profile.dart';
import 'package:uspace/ui/card_connection.dart';
import 'package:uspace/ui/points_history.dart';

import 'domain_test.dart' show MemoryStore;

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: content!,
  ),
  home: Scaffold(body: child),
);
Future<void> show(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Finder privacy() =>
    find.widgetWithText(SwitchListTile, 'Pokaż potrzeby w publicznym profilu');

void main() {
  testWidgets(
    'Privacy requires consent, committed public preview, reversible private state',
    (tester) async {
      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      await controller.saveProfile(
        controller.profile.copyWith(needIds: ['wheelchair']),
      );
      await tester.pumpWidget(host(ProfileScreen(controller: controller)));
      await show(tester, privacy());
      await tester.tap(privacy());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isFalse);
      await tester.tap(privacy());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Potwierdzam'));
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isTrue);
      expect(find.text('Publiczny profil — podgląd'), findsOneWidget);
      expect(find.text('Poruszam się na wózku'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('Saldo'),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Zamknij'));
      await tester.pumpAndSettle();
      await tester.tap(privacy());
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isFalse);
      await show(tester, find.text('Podgląd publicznego profilu'));
      await tester.tap(find.text('Podgląd publicznego profilu'));
      await tester.pumpAndSettle();
      expect(find.text('Potrzeby prywatne'), findsOneWidget);
      expect(find.text('Poruszam się na wózku'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Failed privacy write stays private and persistent retry retains confirmed consent',
    (tester) async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      await tester.pumpWidget(host(ProfileScreen(controller: controller)));
      await show(tester, privacy());
      store.fail = true;
      await tester.tap(privacy());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Potwierdzam'));
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isFalse);
      expect(find.text('Publiczny profil — podgląd'), findsNothing);
      await show(tester, find.byKey(const ValueKey('profile-retry')));
      await tester.pump(const Duration(seconds: 10));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 160));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Nadal obowiązuje ostatni potwierdzony stan'),
        findsOneWidget,
      );
      store.fail = false;
      await show(tester, find.byKey(const ValueKey('profile-retry')));
      await tester.tap(find.byKey(const ValueKey('profile-retry')));
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isTrue);
      expect(find.text('Publiczny profil — podgląd'), findsOneWidget);
      expect(find.text('Udostępnić potrzeby?'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Profile has no role separating users by their needs', (
    tester,
  ) async {
    final controller = AppController(DemoRepository(MemoryStore()));
    await controller.load();
    await tester.pumpWidget(host(ProfileScreen(controller: controller)));
    expect(find.text('Pomocnik'), findsNothing);
    expect(find.text('Chcę być Pomocnikiem'), findsNothing);
    expect(controller.profile.toJson().containsKey('helper'), isFalse);
  });
  testWidgets(
    'CP09 unavailable card and points fit narrow dark screen at 200 percent without claiming success',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        host(const CardConnectionScreen(cityId: 'warszawa'), scale: 2),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      await show(tester, find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sprawdzanie').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .initialValue,
        'checking',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const PointsHistoryScreen(), scale: 2));
      await tester.pumpAndSettle();
      expect(find.text('Saldo niedostępne'), findsOneWidget);
      await show(tester, find.text('Jak odczytasz historię?'));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('To nie jest potwierdzenie pustej historii'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Profile privacy confirmation and public preview remain usable at 200 percent',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AppController(DemoRepository(MemoryStore()));
      await controller.load();
      await controller.saveProfile(
        controller.profile.copyWith(needIds: ['wheelchair', 'rest']),
      );
      await tester.pumpWidget(
        host(ProfileScreen(controller: controller), scale: 2),
      );
      await show(tester, privacy());
      await tester.tap(privacy());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Potwierdzam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Potwierdzam'));
      await tester.pumpAndSettle();
      expect(controller.profile.publicNeeds, isTrue);
      expect(find.text('Publiczny profil — podgląd'), findsOneWidget);
      await tester.ensureVisible(find.text('Zamknij'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zamknij'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
