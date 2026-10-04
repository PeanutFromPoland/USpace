import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/domain/matching.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/app_controller.dart';

class MemoryStore implements DemoStore {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (fail) throw StateError('write failed');
    value = data;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  test('Unknown data never becomes a matched requirement', () {
    const rule = FilterRule('step_free_entrance', Importance.required, 4);
    final place = demoPlaces.firstWhere((p) => p.id == 'cafe');
    expect(
      evaluateDemoMatch(place, [rule]).status,
      MatchStatus.insufficientData,
    );
    expect(
      searchDemoPlaces([place], const DemoProfile(rules: [rule]), ''),
      isEmpty,
    );
    expect(
      searchDemoPlaces(
        [place],
        const DemoProfile(rules: [rule], includeUnknown: true),
        '',
      ).single.match.status,
      MatchStatus.insufficientData,
    );
  });
  test(
    'Known failure stays excluded even when unknown places are included',
    () {
      final result = searchDemoPlaces(
        demoPlaces,
        const DemoProfile(
          rules: [FilterRule('lift', Importance.required, 1)],
          includeUnknown: true,
        ),
        '',
      );
      expect(result.any((h) => h.place.id == 'museum'), isFalse);
    },
  );
  test('Preferences ignore rating thresholds; required checks them', () {
    final place = demoPlaces.first;
    final fact = place.features.first;
    expect(
      evaluateDemoMatch(place, [
        FilterRule(fact.featureId, Importance.preferred, 5),
      ]).status,
      MatchStatus.matches,
    );
    expect(
      evaluateDemoMatch(place, [
        FilterRule(fact.featureId, Importance.required, 5),
      ]).status,
      MatchStatus.matches,
    );
  });
  test(
    'Profile survives restart and failed writes preserve confirmed state',
    () async {
      final store = MemoryStore();
      final controller = AppController(DemoRepository(store));
      await controller.load();
      expect(controller.profile.publicNeeds, isFalse);
      await controller.saveProfile(
        controller.profile.copyWith(
          needIds: ['wheelchair'],
          theme: 'pink',
          darkMode: true,
        ),
      );
      final restart = AppController(DemoRepository(store));
      await restart.load();
      expect(restart.profile.needIds, ['wheelchair']);
      expect(restart.profile.darkMode, isTrue);
      store.fail = true;
      await expectLater(
        restart.saveProfile(restart.profile.copyWith(theme: 'orange')),
        throwsStateError,
      );
      expect(restart.profile.theme, 'pink');
      expect(restart.saving, isFalse);
    },
  );
  test(
    'Corrupt storage presents an error without silently erasing data',
    () async {
      final store = MemoryStore()..value = '{invalid';
      final controller = AppController(DemoRepository(store));
      await controller.load();
      expect(controller.loadError, isNotNull);
      expect(store.value, '{invalid');
    },
  );
}
