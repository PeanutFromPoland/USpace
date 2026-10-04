import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uspace/data/product_api.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/domain/review.dart';
import 'package:uspace/integration/api_controller.dart';
import 'package:uspace/ui/api_app.dart';
import 'package:uspace/ui/review_survey.dart';

class Sessions implements ApiSessionStore {
  String? token;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String? value) async {
    token = value;
  }
}

http.Response jsonResponse(Json body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);
const config = <String, dynamic>{
  'features': [
    {
      'id': 'elevator',
      'label': 'Winda',
      'description': 'Winda w obiekcie',
      'supportsRating': true,
      'supportsOperationalState': true,
      'supportsMultipleTargets': true,
      'ratingLabels': [
        'Bardzo trudno',
        'Trudno',
        'Przeciętnie',
        'Dobrze',
        'Bardzo dobrze',
      ],
    },
  ],
  'needs': [],
  'presets': [],
  'cities': [
    {'id': 'city_krakow', 'label': 'Kraków'},
  ],
  'cardTypes': [],
};
const me = <String, dynamic>{
  'id': 'usr_test',
  'displayName': 'Test Hackaton',
  'uiSettings': {'colorThemeId': 'green'},
  'preferences': {'needIds': [], 'rules': [], 'presetIds': []},
  'privacy': {'needsVisibility': 'private'},
  'memberships': [],
  'pointsBalance': 1000,
  'stats': {'reviewCount': 0, 'verificationCount': 0},
};
const place = Place(
  id: 'place_test',
  name: 'Miejsce',
  category: 'other',
  cityId: 'city_krakow',
  address: 'Adres',
  lat: 50,
  lon: 20,
  description: '',
  features: [],
  observedOn: '',
);

void main() {
  test('API URL remains on configured origin and local HTTP is explicit', () {
    expect(
      () =>
          ProductApi(Uri.parse('http://example.com/api/v1/'), localHttp: true),
      throwsArgumentError,
    );
    expect(
      () => ProductApi(Uri.parse('https://user:password@example.com/api/v1/')),
      throwsArgumentError,
    );
    expect(
      ProductApi(
        Uri.parse('http://10.0.2.2:8000/api/v1/'),
        localHttp: true,
      ).base.host,
      '10.0.2.2',
    );
    expect(
      () => ProductApi.validateBase(
        Uri.parse('https://example.com/api/../other'),
        false,
      ),
      throwsArgumentError,
    );
  });
  test(
    'Every product method carries JSON, bearer and stable idempotency headers',
    () async {
      final requests = <http.Request>[];
      final api = ProductApi(
        Uri.parse('https://api.example/api/v1/'),
        client: MockClient((request) async {
          requests.add(request);
          return jsonResponse({'ok': true});
        }),
      )..token = 'test-session';
      await api.configuration();
      await api.login('x@example.invalid', 'password');
      await api.register('x@example.invalid', 'password', 'Test Hackaton');
      await api.me();
      await api.search({'cityId': 'city_krakow'});
      await api.place('place_test');
      await api.submit('place_test', {'answers': []}, 'review-key');
      await api.redeem({'rewardId': 'reward_frame'}, 'reward-key');
      await api.call('GET', 'me/redemptions', query: {'cursor': 'a/b+c='});
      expect(requests[0].headers.containsKey('Authorization'), isFalse);
      expect(requests[1].headers.containsKey('Authorization'), isFalse);
      expect(requests[3].headers['Authorization'], 'Bearer test-session');
      expect(requests[6].headers['Idempotency-Key'], 'review-key');
      expect(requests[7].headers['Idempotency-Key'], 'reward-key');
      expect(requests.last.url.queryParameters['cursor'], 'a/b+c=');
      expect(requests.every((r) => !r.followRedirects), isTrue);
      expect(requests[6].url.path, '/api/v1/places/place_test/reviews');
      await expectLater(api.call('GET', '../outside'), throwsArgumentError);
    },
  );
  test(
    'Session reload uses server balance, no local credits or automatic resets',
    () async {
      final requests = <String>[];
      final sessions = Sessions()..token = 'saved-session';
      final api = ProductApi(
        Uri.parse('https://api.example/api/v1/'),
        client: MockClient((r) async {
          requests.add('${r.method} ${r.url.path}');
          return jsonResponse(
            r.url.path.endsWith('configuration')
                ? config
                : {...me, 'pointsBalance': 800},
          );
        }),
      );
      final c = ApiController(api, sessions);
      await c.load();
      await c.load();
      expect(c.isDemoSignedIn, isTrue);
      expect(c.account['pointsBalance'], 800);
      expect(requests.every((r) => r.startsWith('GET ')), isTrue);
      expect(c.apiQuestions.single.feature.id, 'elevator');
      expect(c.apiQuestions.single.feature.operational, isTrue);
    },
  );
  test(
    'Unknown/absent have no API rating; present maps the one collected score',
    () {
      final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3))
        ..recommendation = 5;
      draft.answers.addAll([
        AnswerDraft('ramp')..choice = const RatedChoice(4),
        AnswerDraft('elevator')..choice = const AbsentChoice(),
        AnswerDraft('quiet_environment')..choice = const UnknownChoice(),
      ]);
      final body = apiReviewJson(draft);
      expect(body['recommendation'], 5);
      expect(body['answers'][0]['rating'], {
        'overall': 4,
        'average_rating': 4.0,
      });
      expect(body['answers'][1]['rating'], isNull);
      expect(body['answers'][2]['rating'], isNull);
      expect(body['answers'][1]['presence'], 'absent');
    },
  );
  test('Failed submission preserves draft and reuses key; edited payload gets new key', () async {
    final keys = <String>[];
    var fail = true;
    final api = ProductApi(
      Uri.parse('https://api.example/api/v1/'),
      client: MockClient((r) async {
        keys.add(r.headers['Idempotency-Key']!);
        if (fail) throw http.ClientException('connection lost');
        return jsonResponse({
          'id': 'rev_confirmed',
          'publicationStatus': 'visible',
          'verificationStatus': 'pending',
        });
      }),
    )..token = 'test';
    final c = ApiController(api, Sessions())..account = me;
    final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3));
    draft.answers.add(AnswerDraft('ramp')..choice = const RatedChoice(4));
    c.keepReviewDraft(draft);
    await expectLater(c.submitReview(draft), throwsA(isA<ProductApiError>()));
    await expectLater(c.submitReview(draft), throwsA(isA<ProductApiError>()));
    expect(keys[0], keys[1]);
    expect(c.reviewDraft(place.id), same(draft));
    draft.recommendation = 5;
    await expectLater(c.submitReview(draft), throwsA(isA<ProductApiError>()));
    expect(keys[2], isNot(keys[1]));
    fail = false;
    final result = await c.submitReview(draft);
    expect(result['id'], 'rev_confirmed');
    expect(keys[3], keys[2]);
    expect(c.reviewDraft(place.id), isNull);
  });
  test('401 clears session, private drafts and API state; errors never expose response content', () async {
    final sessions = Sessions()..token = 'test';
    final api = ProductApi(
      Uri.parse('https://api.example/api/v1/'),
      client: MockClient(
        (r) async => jsonResponse({
          'error': {
            'code': 'AUTH_REQUIRED',
            'message': 'private token user secret',
          },
        }, 401),
      ),
    )..token = 'test';
    final c = ApiController(api, sessions)..account = me;
    c.keepReviewDraft(ReviewDraft(place: place, today: DateTime(2026, 10, 3)));
    await expectLater(
      api.me(),
      throwsA(
        isA<ProductApiError>().having(
          (e) => e.message,
          'message',
          isNot(contains('secret')),
        ),
      ),
    );
    expect(c.account, isEmpty);
    expect(c.isDemoSignedIn, isFalse);
    expect(c.reviewDraft(place.id), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(sessions.token, isNull);
  });
  testWidgets('Real API entry reaches a server place and an enabled survey', (
    tester,
  ) async {
    final api = ProductApi(
      Uri.parse('https://api.example/api/v1/'),
      client: MockClient((r) async {
        if (r.url.path.endsWith('configuration')) return jsonResponse(config);
        if (r.url.path.endsWith('/me')) return jsonResponse(me);
        if (r.url.path.endsWith('/search')) {
          return jsonResponse({
            'items': [
              {
                'id': 'place_test',
                'name': 'Miejsce',
                'cityId': 'city_krakow',
                'categoryId': 'other',
                'address': 'Adres',
                'location': {'lat': 50, 'lon': 20},
                'match': {'status': 'not_evaluated'},
              },
            ],
            'nextCursor': null,
          });
        }
        return jsonResponse({
          'id': 'place_test',
          'name': 'Miejsce',
          'cityId': 'city_krakow',
          'address': 'Adres',
          'location': {'lat': 50, 'lon': 20},
          'features': [],
          'parts': [],
          'temporaryIssues': [],
          'match': {'status': 'not_evaluated'},
        });
      }),
    );
    final c = ApiController(api, Sessions()..token = 'test');
    await tester.pumpWidget(ConnectedKindSpotApp(controller: c));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Miejsce'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Otwórz ankietę'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Otwórz ankietę'));
    await tester.pumpAndSettle();
    expect(find.byType(ReviewSurveyScreen), findsOneWidget);
    expect(find.text('Liczba pytań: 1'), findsOneWidget);
    expect(find.textContaining('Recenzja trafi do systemu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
