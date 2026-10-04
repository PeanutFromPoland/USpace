import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uspace/data/product_api.dart';
import 'package:uspace/integration/api_controller.dart';
import 'package:uspace/ui/api_app.dart';
import 'package:uspace/ui/review_survey.dart';

import 'product_api_test.dart' show Sessions, config, me, place, jsonResponse;

void main() {
  testWidgets(
    'API login at 320 px and 200% preserves fields after error, then enters server account',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      var fail = true;
      final sessions = Sessions();
      final api = ProductApi(
        Uri.parse('https://api.example/api/v1/'),
        client: MockClient((r) async {
          if (r.url.path.endsWith('/configuration')) {
            return jsonResponse(config);
          }
          if (r.url.path.endsWith('/auth/login')) {
            if (fail) {
              return jsonResponse({
                'error': {'code': 'INVALID_CREDENTIALS'},
              }, 401);
            }
            return jsonResponse({
              'accessToken': 'session',
              'me': {...me, 'pointsBalance': 800},
            });
          }
          return jsonResponse({'items': [], 'nextCursor': null});
        }),
      );
      final controller = ApiController(api, sessions);
      await tester.pumpWidget(ConnectedKindSpotApp(controller: controller));
      await tester.pumpAndSettle();
      final email = find.byKey(const ValueKey('api-email'));
      final password = find.byKey(const ValueKey('api-password'));
      await tester.scrollUntilVisible(
        email,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(email, 'hackaton@example.invalid');
      await tester.scrollUntilVisible(
        password,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(password, 'Test-pass-12345!');
      final login = find.byKey(const ValueKey('api-login'));
      await tester.scrollUntilVisible(
        login,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(login);
      await tester.pumpAndSettle();
      expect(controller.isDemoSignedIn, isFalse);
      expect(
        controller.notice,
        isNull,
      ); // Invalid credentials do not expire a session.
      expect(tester.takeException(), isNull);
      fail = false;
      await tester.scrollUntilVisible(
        login,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(login);
      await tester.pumpAndSettle();
      expect(controller.account['pointsBalance'], 800);
      expect(sessions.token, 'session');
      expect(find.byType(ApiHome), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Connected survey retries failed submission with unchanged key and server status',
    (tester) async {
      var fail = true;
      final keys = <String>[];
      final bodies = <Json>[];
      final api = ProductApi(
        Uri.parse('https://api.example/api/v1/'),
        client: MockClient((r) async {
          keys.add(r.headers['Idempotency-Key']!);
          bodies.add(jsonDecode(r.body) as Json);
          if (fail) throw http.ClientException('lost connection');
          return jsonResponse({
            'id': 'rev_server',
            'publicationStatus': 'visible',
            'verificationStatus': 'pending',
            'pointAward': {'status': 'pending', 'amount': null},
          });
        }),
      )..token = 'session';
      final controller = ApiController(api, Sessions())
        ..configuration = config
        ..account = me;
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewSurveyScreen(
            controller: controller,
            place: place,
            today: DateTime(2026, 10, 3),
            providedQuestions: controller.apiQuestions,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zaczynam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dalej'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('4 – Dobrze'),
        150,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('4 – Dobrze'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dalej'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dalej'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wyślij recenzję'));
      await tester.pumpAndSettle();
      expect(controller.reviewDraft(place.id), isNotNull);
      expect(
        find.textContaining('Nie udało się wysłać recenzji'),
        findsOneWidget,
      );
      fail = false;
      await tester.tap(find.text('Wyślij recenzję'));
      await tester.pumpAndSettle();
      expect(keys[0], keys[1]);
      expect(bodies[1]['answers'][0]['featureId'], 'elevator');
      expect(bodies[1]['answers'][0]['rating']['overall'], 4);
      expect(find.text('Recenzja wysłana'), findsOneWidget);
      expect(find.text('Punkty jeszcze nieprzyznane.'), findsOneWidget);
      expect(controller.reviewDraft(place.id), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Backend need links select questions and allow showing the full catalogue',
    (tester) async {
      final api = ProductApi(
        Uri.parse('https://api.example/api/v1/'),
        client: MockClient((r) async => jsonResponse({'ok': true})),
      );
      final controller = ApiController(api, Sessions())
        ..account = {
          ...me,
          'preferences': {
            'needIds': ['wheelchair'],
          },
        }
        ..configuration = {
          ...config,
          'needs': [
            {
              'id': 'wheelchair',
              'featureIds': ['elevator'],
            },
          ],
          'features': [
            ...config['features'] as List,
            {
              ...(config['features'] as List).first as Json,
              'id': 'quiet_environment',
              'isEnvironmental': true,
            },
          ],
        };
      expect(controller.wantedSurveyFeatures, {'elevator'});
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewSurveyScreen(
            controller: controller,
            place: place,
            providedQuestions: controller.apiQuestions,
            providedWantedFeatures: controller.wantedSurveyFeatures,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Liczba pytań: 1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Pokaż wszystkie pytania (2)'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Pokaż wszystkie pytania (2)'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Liczba pytań: 2'),
        -200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Liczba pytań: 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
