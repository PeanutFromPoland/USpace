// Fixtures for a theoretical presentation. No purchases or balance mutations.
enum RewardDelivery { profile, code, cityCard }

enum RewardScenario {
  success,
  insufficientPoints,
  unavailable,
  priceChanged,
  unknownResult,
  failed,
}

enum RewardPreviewStatus { processing, ready, unknown, failed, released }

class RewardExample {
  const RewardExample(
    this.id,
    this.name,
    this.description,
    this.exampleCost,
    this.delivery,
  );
  final String id, name, description;
  final int exampleCost;
  final RewardDelivery delivery;
}

const rewardExamples = [
  RewardExample(
    'explorer',
    'Motyw profilu „Odkrywca”',
    'Element wizualny na koncie. W podglądzie nie zmieniamy profilu.',
    100,
    RewardDelivery.profile,
  ),
  RewardExample(
    'museum',
    'Bilet do muzeum',
    'Przykładowy odbiór kodem. Nie wskazano rzeczywistego muzeum ani operatora.',
    200,
    RewardDelivery.code,
  ),
  RewardExample(
    'transport',
    'Bilet komunikacji miejskiej',
    'Przykładowy zapis na karcie. Brak integracji i rzeczywistego biletu.',
    150,
    RewardDelivery.cityCard,
  ),
];
String rewardScenarioLabel(RewardScenario value) => switch (value) {
  RewardScenario.success => 'Gotowy odbiór',
  RewardScenario.insufficientPoints => 'Za mało punktów',
  RewardScenario.unavailable => 'Nagroda niedostępna',
  RewardScenario.priceChanged => 'Zmiana kosztu',
  RewardScenario.unknownResult => 'Nieznany wynik',
  RewardScenario.failed => 'Błąd realizacji i zwolnienie punktów',
};

class RewardPreview {
  const RewardPreview(this.reward, this.scenario, this.status);
  final RewardExample reward;
  final RewardScenario scenario;
  final RewardPreviewStatus status;
  String get operationId => 'PRZYKLAD-${reward.id}';
  RewardPreview advance() => RewardPreview(reward, scenario, switch (status) {
    RewardPreviewStatus.processing => switch (scenario) {
      RewardScenario.unknownResult => RewardPreviewStatus.unknown,
      RewardScenario.failed => RewardPreviewStatus.failed,
      _ => RewardPreviewStatus.ready,
    },
    RewardPreviewStatus.unknown => RewardPreviewStatus.ready,
    RewardPreviewStatus.failed => RewardPreviewStatus.released,
    _ => status,
  });
  String get statusText => switch (status) {
    RewardPreviewStatus.processing =>
      'Przykład: realizacja w toku. Kod ani benefit nie są jeszcze gotowe.',
    RewardPreviewStatus.ready =>
      'Przykład: realizacja zakończona. Nie wydano prawdziwej nagrody.',
    RewardPreviewStatus.unknown => 'Przykład: wynik jest nieznany. Sprawdź tę samą realizację; nie ponawiaj zakupu.',
    RewardPreviewStatus.failed => 'Przykład: realizacja nieudana. Zwolnienie lub zwrot punktów nie jest jeszcze potwierdzony.',
    RewardPreviewStatus.released => 'Przykład: system potwierdził zwolnienie lub zwrot punktów po awarii. Saldo demo pozostało bez zmian.',
  };
}
