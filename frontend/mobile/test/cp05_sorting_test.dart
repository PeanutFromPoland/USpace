import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/matching.dart';
import 'package:uspace/domain/models.dart';

import 'domain_test.dart' show MemoryStore;

Place sample(
  String id, {
  double? rating,
  int? count,
  String? name,
  Presence presence = Presence.present,
  String cityId = 'krakow',
}) => Place(
  id: id,
  name: name ?? id,
  category: 'Przykład',
  cityId: cityId,
  address: 'Przykład',
  lat: 0,
  lon: 0,
  description: 'Fikcyjny test',
  observedOn: '2026-10-03',
  aggregateRating: rating,
  reviewCount: count,
  features: [
    FeatureFact(
      'quiet',
      presence,
      rating: presence == Presence.present ? 5 : null,
    ),
  ],
);
List<String> ids(List<Place> places, DemoProfile profile) =>
    searchDemoPlaces(places, profile, '').map((e) => e.place.id).toList();

void main() {
  test('Best rating desc then count desc, deterministic name and ID ties', () {
    final places = [
      sample('low', rating: 4, count: 100),
      sample('tie-b', name: 'B', rating: 5, count: 20),
      sample('unknown-count', rating: 5),
      sample('tie-a2', name: 'A', rating: 5, count: 20),
      sample('tie-a1', name: 'A', rating: 5, count: 20),
      sample('few', rating: 5, count: 10),
    ];
    expect(ids(places, const DemoProfile()), [
      'tie-a1',
      'tie-a2',
      'tie-b',
      'few',
      'unknown-count',
      'low',
    ]);
    expect(ids(places.reversed.toList(), const DemoProfile()), [
      'tie-a1',
      'tie-a2',
      'tie-b',
      'few',
      'unknown-count',
      'low',
    ]);
  });
  test('Missing mean follows all known means, including zero; not synthesized from feature ratings', () {
    final places = [
      sample('unknown', count: 300),
      sample('zero', rating: 0, count: 0),
      sample('high', rating: 4.9, count: 1),
    ];
    expect(ids(places, const DemoProfile()), ['high', 'zero', 'unknown']);
    expect(places.first.aggregateRating, isNull);
  });
  test('Review-count sort changes order but preserves result set and nullable values', () {
    final places = [
      sample('high-rating', rating: 5, count: 1),
      sample('many', rating: 3, count: 20),
      sample('count-tie', rating: 4, count: 20),
      sample('zero', rating: 4.5, count: 0),
      sample('unknown', rating: 5),
    ];
    final best = ids(places, const DemoProfile());
    final byCount = ids(
      places,
      const DemoProfile(placeSort: PlaceSort.reviewCount),
    );
    expect(byCount, ['count-tie', 'many', 'high-rating', 'zero', 'unknown']);
    expect(byCount.toSet(), best.toSet());
    expect(places.last.reviewCount, isNull);
  });
  test('Unknown status and preferences do not override approved rating order; known failure excluded', () {
    final places = [
      sample('unknown', rating: 5, count: 1, presence: Presence.unknown),
      sample('matched', rating: 4, count: 2),
      sample('failed', rating: 5, count: 100, presence: Presence.absent),
      sample('other-city', rating: 5, count: 100, cityId: 'warsaw'),
    ];
    const rule = FilterRule('quiet', Importance.required, 4);
    const profile = DemoProfile(rules: [rule], includeUnknown: true);
    final hits = searchDemoPlaces(places, profile, '');
    expect(hits.map((e) => e.place.id), ['unknown', 'matched']);
    expect(hits.first.match.status, MatchStatus.insufficientData);
    expect(ids(places, profile.copyWith(includeUnknown: false)), ['matched']);
    expect(
      ids(
        places,
        const DemoProfile(rules: [FilterRule('quiet', Importance.preferred)]),
      ),
      ['failed', 'unknown', 'matched'],
    );
  });
  test('Changing sort persists over restart; failed change preserves confirmed choice', () async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    expect(controller.profile.placeSort, PlaceSort.bestRated);
    await controller.saveProfile(
      controller.profile.copyWith(placeSort: PlaceSort.reviewCount),
    );
    final restart = AppController(DemoRepository(store));
    await restart.load();
    expect(restart.profile.placeSort, PlaceSort.reviewCount);
    store.fail = true;
    await expectLater(
      restart.saveProfile(
        restart.profile.copyWith(placeSort: PlaceSort.bestRated),
      ),
      throwsStateError,
    );
    expect(restart.profile.placeSort, PlaceSort.reviewCount);
  });
  test('Older demo profile uses explicit best-rated default without fabricating statistics', () {
    expect(DemoProfile.fromJson({}).placeSort, PlaceSort.bestRated);
    final cafe = demoPlaces.singleWhere((p) => p.id == 'cafe');
    expect(cafe.aggregateRating, isNull);
    expect(cafe.reviewCount, isNull);
    final hits = searchDemoPlaces(demoPlaces, const DemoProfile(), '');
    expect(hits.first.place.id, 'library');
    expect(hits.last.place.id, 'cafe');
  });
}
