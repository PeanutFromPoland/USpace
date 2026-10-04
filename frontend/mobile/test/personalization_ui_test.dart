import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:uspace/data/product_api.dart';
import 'package:uspace/integration/api_controller.dart';
import 'package:uspace/ui/api_forms.dart';
import 'package:uspace/ui/api_personalization.dart';
import 'package:uspace/ui/graphics.dart';
import 'package:uspace/ui/theme.dart';

import 'product_api_test.dart' show Sessions, config, me, jsonResponse;

Future<void> click(WidgetTester tester, String text) async {
  final target = find.text(text).first;
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await Scrollable.ensureVisible(tester.element(target), alignment: .5);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets(
    'Purchased avatar frame theme and confirmed title survive a new controller',
    (tester) async {
      Json account = jsonDecode(
        jsonEncode({
          ...me,
          'pointsBalance': 795,
          'appearance': {
            'avatarId': 'avatar_default',
            'frameId': 'frame_default',
            'titleId': 'title_default',
          },
          'achievements': [
            {'id': 'title_confirmed', 'label': 'Potwierdzony tytuł'},
          ],
        }),
      ) as Json;
      final owned = [
        {'id': 'avatar_cat', 'kind': 'avatar', 'label': 'Kot'},
        {'id': 'frame_bow', 'kind': 'frame', 'label': 'Obręcz z kokardą'},
        {'id': 'explorer', 'kind': 'theme', 'label': 'Odkrywca'},
        {'id': 'gardener', 'kind': 'theme', 'label': 'Ogrodnik'},
        {
          'id': 'title_default',
          'kind': 'title',
          'label': 'Bez publicznego tytułu',
        },
        {
          'id': 'title_confirmed',
          'kind': 'title',
          'label': 'Potwierdzony tytuł',
        },
      ];
      final client = MockClient((r) async {
        if (r.method == 'PATCH') {
          final update = jsonDecode(r.body) as Json;
          account['appearance'] = {
            ...account['appearance'] as Json,
            ...update['appearance'] as Json,
          };
          return jsonResponse(account);
        }
        if (r.method == 'PUT') {
          account['uiSettings'] = jsonDecode(r.body);
          return jsonResponse(account['uiSettings'] as Json);
        }
        if (r.url.path.endsWith('/configuration')) return jsonResponse(config);
        if (r.url.path.endsWith('/cosmetics')) {
          return jsonResponse({'items': owned, 'nextCursor': null});
        }
        return jsonResponse(account);
      });
      final sessions = Sessions()..token = 'session';
      final controller = ApiController(
        ProductApi(Uri.parse('https://api.example/api/v1/'), client: client),
        sessions,
      );
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(home: ApiCosmeticPicker(controller: controller)),
      );
      await tester.pumpAndSettle();
      Future<void> use(String label) async {
        await tester.scrollUntilVisible(
          find.text(label).first,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        final card = find
            .ancestor(of: find.text(label).first, matching: find.byType(Card))
            .first;
        final button = find.descendant(
          of: card,
          matching: find.byType(OutlinedButton),
        );
        await Scrollable.ensureVisible(tester.element(button), alignment: .5);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
      }

      await use('Kot');
      await use('Obręcz z kokardą');
      await use('Odkrywca');
      expect(controller.profile.theme, 'explorer');
      await use('Ogrodnik');
      expect(controller.profile.theme, 'gardener');
      expect(controller.profile.darkMode, isTrue);
      await tester.pumpWidget(
        MaterialApp(
          home: ApiCosmeticPicker(controller: controller, titlesOnly: true),
        ),
      );
      await tester.pumpAndSettle();
      await use('Potwierdzony tytuł');
      final restored = ApiController(
        ProductApi(Uri.parse('https://api.example/api/v1/'), client: client),
        sessions,
      );
      await restored.load();
      expect(restored.account['appearance'], {
        'avatarId': 'avatar_cat',
        'frameId': 'frame_bow',
        'titleId': 'title_confirmed',
      });
      expect(restored.profile.theme, 'gardener');
      expect(restored.profile.darkMode, isTrue);
      expect(restored.account['pointsBalance'], 795);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Profile titles empty state fits 320px and 200 percent without inventing an award',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = ApiController(
        ProductApi(
          Uri.parse('https://api.example/api/v1/'),
          client: MockClient((r) async {
            if (r.url.path.endsWith('/cosmetics')) {
              return jsonResponse({
                'items': [
                  {
                    'id': 'title_default',
                    'kind': 'title',
                    'label': 'Bez publicznego tytułu',
                  },
                ],
                'nextCursor': null,
              });
            }
            return jsonResponse({
              ...me,
              'achievements': [],
              'appearance': {
                'avatarId': 'avatar_default',
                'frameId': 'frame_default',
              },
            });
          }),
        ),
        Sessions(),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: kindSpotTheme(controller.profile),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: ApiCosmeticPicker(controller: controller, titlesOnly: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(KindSpotAvatar), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Nie masz jeszcze zdobytych tytułów.'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Potwierdzony tytuł'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Confirmed cosmetic purchase uses server balance and owned state disables a second buy',
    (tester) async {
      var owned = false;
      var purchases = 0;
      final reward = <String, dynamic>{
        'id': 'reward_avatar_cat',
        'name': 'Profilowe: Kot',
        'description': 'Kot',
        'costPoints': 100,
        'availability': 'available',
        'deliveryMethods': ['account_item'],
        'cosmetic': {'id': 'avatar_cat', 'kind': 'avatar', 'label': 'Kot'},
      };
      final controller = ApiController(
        ProductApi(
          Uri.parse('https://api.example/api/v1/'),
          client: MockClient((r) async {
            if (r.url.path.endsWith('/rewards/reward_avatar_cat')) {
              return jsonResponse({
                ...reward,
                'owned': owned,
                'eligibility': {
                  'eligible': !owned,
                  'reasonCode': owned ? 'ALREADY_OWNED' : null,
                },
              });
            }
            if (r.method == 'POST') {
              expect(r.headers['Idempotency-Key'], isNotEmpty);
              purchases++;
              owned = true;
              return jsonResponse({
                'id': 'redemption_cat',
                'status': 'fulfilled',
                'pointsBalance': 900,
              }, 201);
            }
            if (r.url.path.endsWith('/redemptions/redemption_cat')) {
              return jsonResponse({
                'id': 'redemption_cat',
                'rewardName': 'Profilowe: Kot',
                'status': 'fulfilled',
                'pointsStatus': 'charged',
              });
            }
            return jsonResponse({...me, 'pointsBalance': owned ? 900 : 1000});
          }),
        )..token = 'session',
        Sessions(),
      )..account = me;
      await tester.pumpWidget(
        MaterialApp(
          home: ApiReward(controller: controller, id: 'reward_avatar_cat'),
        ),
      );
      await tester.pumpAndSettle();
      await click(tester, 'Kup nagrodę');
      await tester.tap(find.text('Anuluj'));
      await tester.pumpAndSettle();
      expect(purchases, 0);
      await click(tester, 'Kup nagrodę');
      await tester.tap(find.text('Kupuję'));
      await tester.pumpAndSettle();
      expect(purchases, 1);
      expect(controller.account['pointsBalance'], 900);
      expect(find.text('Odbiór nagrody'), findsOneWidget);
      await tester.pumpWidget(
        MaterialApp(
          key: const ValueKey('reopened'),
          home: ApiReward(controller: controller, id: 'reward_avatar_cat'),
        ),
      );
      await tester.pumpAndSettle();
      final buy = find.widgetWithText(FilledButton, 'Kup nagrodę');
      await tester.scrollUntilVisible(
        buy,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(buy).onPressed, isNull);
      expect(purchases, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
