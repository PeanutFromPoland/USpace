import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/app_controller.dart';
import 'package:uspace/data/demo_repository.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/domain/demo_shop.dart';

import 'domain_test.dart' show MemoryStore;

void main() {
  test('Green defaults include older profiles without theme data', () {
    expect(const DemoProfile().theme, 'green');
    expect(DemoProfile.fromJson({}).theme, 'green');
    expect(DemoProfile.fromJson({'theme': 'pink'}).theme, 'pink');
  });
  test('Buy debits once, rejects duplicate and insufficient balance, redemption keeps history', () async {
    final controller = AppController(DemoRepository(MemoryStore()));
    await controller.load();
    controller.buyDemoReward('museum');
    expect(controller.shop.balance, 800);
    expect(controller.shop.purchases.single.redeemed, isFalse);
    expect(() => controller.buyDemoReward('museum'), throwsStateError);
    expect(() => controller.buyDemoReward('premium'), throwsStateError);
    expect(() => controller.buyDemoReward('missing'), throwsStateError);
    expect(controller.shop.balance, 800);
    controller.redeemDemoReward('TEST-1');
    expect(controller.shop.purchases.single.redeemed, isTrue);
    expect(controller.shop.purchases.single.reward.id, 'museum');
    expect(() => controller.redeemDemoReward('TEST-1'), throwsStateError);
    expect(controller.shop.balance, 800);
  });
  test('Real startup resets account and shop, preserves named filters and accessibility, reseeds garden', () async {
    final store = MemoryStore();
    final initial = AppController(
      DemoRepository(store),
      resetAccountOnLaunch: true,
    );
    await initial.load();
    await initial.saveNamedFilter('Spokojnie', [
      const FilterRule('quiet', Importance.required, 4),
    ], true);
    await initial.saveProfile(
      initial.profile.copyWith(
        needIds: ['wheelchair'],
        publicNeeds: true,
        helper: true,
        cityId: 'warsaw',
        theme: 'pink',
        darkMode: true,
        highContrast: true,
        reduceMotion: true,
        savedPlaceIds: ['library'],
        reviewReports: {'garden-review-a': 'spam'},
      ),
    );
    initial.useFilter([
      const FilterRule('quiet', Importance.required, 4),
    ], true);
    initial.buyDemoReward('museum');
    initial.redeemDemoReward('TEST-1');
    final restarted = AppController(
      DemoRepository(store),
      resetAccountOnLaunch: true,
    );
    await restarted.load();
    expect(restarted.shop.balance, 1000);
    expect(restarted.shop.purchases, isEmpty);
    expect(restarted.profile.namedFilters.single.name, 'Spokojnie');
    expect(restarted.profile.namedFilters.single.rules.single.minRating, 4);
    expect(restarted.profile.theme, 'pink');
    expect(
      restarted.profile.darkMode &&
          restarted.profile.highContrast &&
          restarted.profile.reduceMotion,
      isTrue,
    );
    expect(restarted.profile.needIds, isEmpty);
    expect(restarted.profile.helper || restarted.profile.publicNeeds, isFalse);
    expect(restarted.profile.cityId, 'krakow');
    expect(restarted.profile.savedPlaceIds, ['garden']);
    expect(restarted.profile.reviewReports, isEmpty);
    expect(restarted.activeRules, isEmpty);
    restarted.buyDemoReward('museum');
    expect(restarted.shop.balance, 800);
    await restarted.load();
    expect(
      restarted.shop.balance,
      800,
      reason: 'A reload within the same launch must not mint more points.',
    );
    await restarted.closeDemoSession();
    expect(() => restarted.buyDemoReward('explorer'), throwsStateError);
    await restarted.openDemoSession();
    expect(restarted.shop.balance, 800);
  });
  test('Use filter changes matching without persisting even after unrelated profile save', () async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    final all = controller.search('').map((h) => h.place.id).toSet();
    final persisted = store.value;
    controller.useFilter([
      const FilterRule('quiet', Importance.required, 5),
    ], false);
    expect(controller.search('').length, lessThan(all.length));
    expect(store.value, persisted);
    await controller.saveProfile(controller.profile.copyWith(darkMode: true));
    expect(controller.activeRules.single.minRating, 5);
    final restart = AppController(DemoRepository(store));
    await restart.load();
    expect(restart.activeRules, isEmpty);
    expect(restart.search('').map((h) => h.place.id).toSet(), all);
  });
  test('Named filters save separately, duplicate/invalid name and write failure do not mutate state', () async {
    final store = MemoryStore();
    final controller = AppController(DemoRepository(store));
    await controller.load();
    const rules = [FilterRule('quiet', Importance.required, 4)];
    await controller.saveNamedFilter('  Cisza  ', rules, true);
    expect(controller.activeRules, isEmpty);
    expect(controller.profile.namedFilters.single.name, 'Cisza');
    expect(controller.profile.namedFilters.single.includeUnknown, isTrue);
    await expectLater(
      controller.saveNamedFilter('CISZA', rules, false),
      throwsArgumentError,
    );
    await expectLater(
      controller.saveNamedFilter(' ', rules, false),
      throwsArgumentError,
    );
    store.fail = true;
    await expectLater(
      controller.saveNamedFilter('Drugi', rules, false),
      throwsStateError,
    );
    expect(controller.profile.namedFilters.length, 1);
    store.fail = false;
    final restarted = AppController(
      DemoRepository(store),
      resetAccountOnLaunch: true,
    );
    await restarted.load();
    expect(
      restarted.profile.namedFilters.single.rules.single.featureId,
      'quiet',
    );
  });
  test(
    'Failed initial reset preserves stored settings until retry succeeds',
    () async {
      final store = MemoryStore();
      final repository = DemoRepository(store);
      await repository.save(
        const DemoSnapshot(
          profile: DemoProfile(theme: 'orange', highContrast: true),
        ),
      );
      final old = store.value;
      store.fail = true;
      final controller = AppController(repository, resetAccountOnLaunch: true);
      await controller.load();
      expect(controller.loadError, isNotNull);
      expect(store.value, old);
      expect(() => controller.buyDemoReward('museum'), throwsStateError);
      store.fail = false;
      await controller.load();
      expect(controller.loadError, isNull);
      expect(controller.profile.highContrast, isTrue);
      expect(controller.profile.theme, 'orange');
      expect(controller.profile.savedPlaceIds, ['garden']);
    },
  );
  test('Shop is only an in-memory test ledger and reset starts another clean session', () {
    final shop = DemoShop();
    shop.buy('museum');
    shop.buy('explorer');
    expect(shop.balance, 700);
    expect(shop.purchases.map((p) => p.reward.id), ['explorer', 'museum']);
    shop.reset();
    expect(shop.balance, 1000);
    expect(shop.purchases, isEmpty);
  });
}
