import 'rewards_demo.dart';

const demoShopCatalog = [
  RewardExample(
    'explorer',
    'Motyw profilu „Odkrywca”',
    'Wygląd profilu do przyszłej personalizacji.',
    100,
    RewardDelivery.profile,
  ),
  RewardExample(
    'museum',
    'Bilet do muzeum',
    'Przykładowa nagroda odbierana kodem.',
    200,
    RewardDelivery.code,
  ),
  RewardExample(
    'transport',
    'Bilet komunikacji miejskiej',
    'Przykładowy benefit na karcie miejskiej.',
    150,
    RewardDelivery.cityCard,
  ),
  RewardExample(
    'frame',
    'Obramowanie „Pomocnik”',
    'Obramowanie awatara do przyszłej personalizacji.',
    500,
    RewardDelivery.profile,
  ),
  RewardExample(
    'premium',
    'Zestaw „Miejski odkrywca”',
    'Przykład droższej nagrody do sprawdzenia niewystarczającego salda.',
    1200,
    RewardDelivery.profile,
  ),
];

class DemoPurchase {
  const DemoPurchase({
    required this.id,
    required this.reward,
    required this.boughtAt,
    this.redeemedAt,
  });
  final String id;
  final RewardExample reward;
  final DateTime boughtAt;
  final DateTime? redeemedAt;
  bool get redeemed => redeemedAt != null;
  DemoPurchase redeem(DateTime time) => DemoPurchase(
    id: id,
    reward: reward,
    boughtAt: boughtAt,
    redeemedAt: time,
  );
}

class DemoShop {
  int get balance =>
      1000 - _purchases.fold<int>(0, (sum, p) => sum + p.reward.exampleCost);
  final List<DemoPurchase> _purchases = [];
  List<DemoPurchase> get purchases => List.unmodifiable(_purchases.reversed);
  bool owns(String rewardId) => _purchases.any((p) => p.reward.id == rewardId);
  DemoPurchase buy(String rewardId) {
    final matches = demoShopCatalog.where((r) => r.id == rewardId);
    if (matches.isEmpty) throw StateError('Nie znaleziono nagrody.');
    final reward = matches.single;
    if (owns(rewardId)) {
      throw StateError('Ta nagroda została już kupiona w tej sesji.');
    }
    if (balance < reward.exampleCost) {
      throw StateError('Za mało punktów na tę nagrodę.');
    }
    final purchase = DemoPurchase(
      id: 'TEST-${_purchases.length + 1}',
      reward: reward,
      boughtAt: DateTime.now(),
    );
    _purchases.add(purchase);
    return purchase;
  }

  void redeem(String id) {
    final index = _purchases.indexWhere((p) => p.id == id);
    if (index < 0) throw StateError('Nie znaleziono zakupu.');
    if (_purchases[index].redeemed) {
      throw StateError('Nagroda została już zrealizowana.');
    }
    _purchases[index] = _purchases[index].redeem(DateTime.now());
  }

  void reset() => _purchases.clear();
}
