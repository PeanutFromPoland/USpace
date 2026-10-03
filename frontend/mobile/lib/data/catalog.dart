import '../domain/models.dart';

const features = <FeatureDefinition>[
  FeatureDefinition(
    'step_free_entrance',
    'Wejście bez schodów',
    'Dojście i wejście bez pokonywania stopni.',
    ratingLabels: [
      'Bardzo trudne wejście',
      'Duże trudności',
      'Możliwa pomoc',
      'Małe utrudnienia',
      'Swobodne wejście',
    ],
  ),
  FeatureDefinition(
    'ramp',
    'Podjazd',
    'Wygoda korzystania z podjazdu.',
    operational: true,
    ratingLabels: [
      'Bardzo trudny',
      'Trudny',
      'Wymaga pomocy',
      'Wygodny',
      'Wygodny samodzielnie',
    ],
  ),
  FeatureDefinition(
    'lift',
    'Winda',
    'Dostępność i wygoda windy.',
    operational: true,
    ratingLabels: [
      'Bardzo trudna obsługa',
      'Duże utrudnienia',
      'Możliwa pomoc',
      'Wygodna',
      'Swobodna obsługa',
    ],
  ),
  FeatureDefinition(
    'accessible_toilet',
    'Dostosowana toaleta',
    'Przestrzeń i wyposażenie toalety.',
    operational: true,
    ratingLabels: [
      'Bardzo duże bariery',
      'Duże bariery',
      'Częściowo dostosowana',
      'Dobrze dostosowana',
      'Swobodne korzystanie',
    ],
  ),
  FeatureDefinition(
    'rest',
    'Miejsca odpoczynku',
    'Ławki lub dostępne miejsca siedzące.',
    ratingLabels: [
      'Bardzo trudno odpocząć',
      'Mało miejsc',
      'Częściowo wystarczające',
      'Dobre warunki',
      'Wiele wygodnych miejsc',
    ],
  ),
  FeatureDefinition(
    'quiet',
    'Spokojne otoczenie',
    'Warunki akustyczne i możliwość spokojnego pobytu.',
    ratingLabels: [
      'Bardzo głośno',
      'Głośno',
      'Umiarkowany hałas',
      'Spokojnie',
      'Bardzo cicho',
    ],
  ),
  FeatureDefinition(
    'low_crowd',
    'Niewielki tłum',
    'Możliwość pobytu bez zatłoczenia w czasie wizyty.',
    ratingLabels: [
      'Bardzo tłoczno',
      'Tłoczno',
      'Umiarkowanie',
      'Mało osób',
      'Dużo wolnej przestrzeni',
    ],
  ),
  FeatureDefinition(
    'gentle_light',
    'Łagodne oświetlenie',
    'Światło bez intensywnych lub migających efektów.',
    ratingLabels: [
      'Bardzo intensywne',
      'Intensywne',
      'Umiarkowane',
      'Łagodne',
      'Bardzo komfortowe',
    ],
  ),
  FeatureDefinition(
    'guide_dog',
    'Pies przewodnik',
    'Możliwość korzystania z miejsca z psem przewodnikiem.',
    ratable: false,
    ratingLabels: [],
  ),
  FeatureDefinition(
    'orientation',
    'Czytelne oznaczenia',
    'Prosta orientacja i informacje o miejscu.',
    ratingLabels: [
      'Bardzo nieczytelne',
      'Trudne',
      'Częściowo czytelne',
      'Czytelne',
      'Bardzo proste i czytelne',
    ],
  ),
  FeatureDefinition(
    'hearing_loop',
    'Pętla indukcyjna',
    'Wsparcie dla osób korzystających z aparatów słuchowych.',
    operational: true,
    ratingLabels: [
      'Bardzo słaba jakość',
      'Słaba',
      'Przeciętna',
      'Dobra',
      'Bardzo dobra',
    ],
  ),
  FeatureDefinition(
    'easy_controls',
    'Łatwa obsługa',
    'Obsługa bez precyzyjnych ruchów dłoni.',
    ratingLabels: [
      'Bardzo trudna',
      'Trudna',
      'Potrzebna pomoc',
      'Łatwa',
      'Bardzo łatwa',
    ],
  ),
];
const needs = <NeedDefinition>[
  NeedDefinition('wheelchair', 'Poruszam się na wózku', 'Mobilność', [
    'step_free_entrance',
    'accessible_toilet',
  ]),
  NeedDefinition('walking', 'Mam trudności z chodzeniem', 'Mobilność', [
    'step_free_entrance',
    'rest',
  ]),
  NeedDefinition('stairs', 'Nie mogę korzystać ze schodów', 'Mobilność', [
    'step_free_entrance',
  ]),
  NeedDefinition('rest', 'Potrzebuję częstego odpoczynku', 'Mobilność', [
    'rest',
  ]),
  NeedDefinition('vision', 'Jestem niewidomy / słabowidzący', 'Wzrok i słuch', [
    'orientation',
  ]),
  NeedDefinition('hearing', 'Jestem głuchy / niedosłyszący', 'Wzrok i słuch', [
    'hearing_loop',
  ]),
  NeedDefinition('noise', 'Źle znoszę hałas', 'Otoczenie', ['quiet']),
  NeedDefinition('crowd', 'Źle znoszę tłum', 'Otoczenie', ['low_crowd']),
  NeedDefinition('light', 'Źle znoszę intensywne światło', 'Otoczenie', [
    'gentle_light',
  ]),
  NeedDefinition('calm', 'Potrzebuję spokojnych miejsc', 'Otoczenie', [
    'quiet',
  ]),
  NeedDefinition(
    'orientation',
    'Mam trudności z orientacją',
    'Orientacja i obsługa',
    ['orientation'],
  ),
  NeedDefinition(
    'reading',
    'Potrzebuję prostych informacji',
    'Orientacja i obsługa',
    ['orientation'],
  ),
  NeedDefinition(
    'hands',
    'Mam ograniczoną sprawność rąk',
    'Orientacja i obsługa',
    ['easy_controls'],
  ),
  NeedDefinition(
    'companion',
    'Podróżuję z osobą wymagającą pomocy',
    'Podróżowanie z innymi',
    [],
  ),
  NeedDefinition(
    'child',
    'Podróżuję z dzieckiem / wózkiem',
    'Podróżowanie z innymi',
    ['step_free_entrance', 'rest'],
  ),
  NeedDefinition(
    'dog',
    'Podróżuję z psem przewodnikiem',
    'Podróżowanie z innymi',
    ['guide_dog'],
  ),
];
FeatureDefinition featureById(String id) =>
    features.firstWhere((e) => e.id == id);
String cityLabel(String id) => id == 'warsaw' ? 'Warszawa' : 'Kraków';
const demoUserId = 'demo-me';
const demoAccountName = 'Test Hackaton';

List<FilterRule> suggestedRules(List<String> selected) {
  final ids = <String>{};
  for (final need in needs.where((e) => selected.contains(e.id))) {
    ids.addAll(need.features);
  }
  return ids.map((id) => FilterRule(id, Importance.preferred)).toList();
}

const demoPlaces = <Place>[
  Place(
    id: 'garden',
    name: 'Ogród ciszy',
    category: 'Park i odpoczynek',
    cityId: 'krakow',
    address: 'Okolice Plant · przykład',
    lat: 50.0599,
    lon: 19.9403,
    description: 'Przykładowa zielona przestrzeń z szerokimi alejkami i miejscami odpoczynku. Informacje służą testowaniu aplikacji.',
    observedOn: '2026-10-02',
    parts: [
      PlacePart('garden-main', 'Wejście główne'),
      PlacePart('garden-side', 'Wejście boczne'),
    ],
    features: [
      FeatureFact('step_free_entrance', Presence.present, rating: 5),
      FeatureFact(
        'accessible_toilet',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
      FeatureFact('rest', Presence.present, rating: 5),
      FeatureFact('quiet', Presence.present, rating: 5),
      FeatureFact('low_crowd', Presence.present, rating: 4),
      FeatureFact('gentle_light', Presence.present, rating: 5),
      FeatureFact('guide_dog', Presence.present),
      FeatureFact('orientation', Presence.present, rating: 4),
    ],
  ),
  Place(
    id: 'library',
    name: 'Biblioteka otwarta',
    category: 'Kultura i nauka',
    cityId: 'krakow',
    address: 'Centrum Krakowa · przykład',
    lat: 50.0649,
    lon: 19.9342,
    description:
        'Przykładowa biblioteka z parterową czytelnią i dostępną toaletą.',
    observedOn: '2026-10-01',
    parts: [PlacePart('library-main', 'Wejście główne')],
    features: [
      FeatureFact('step_free_entrance', Presence.present, rating: 4),
      FeatureFact(
        'ramp',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
      FeatureFact(
        'accessible_toilet',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
      FeatureFact('quiet', Presence.present, rating: 4),
      FeatureFact('rest', Presence.present, rating: 4),
      FeatureFact('orientation', Presence.present, rating: 5),
      FeatureFact('guide_dog', Presence.present),
      FeatureFact(
        'hearing_loop',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
    ],
  ),
  Place(
    id: 'museum',
    name: 'Przestrzeń sztuki',
    category: 'Muzeum i wystawy',
    cityId: 'krakow',
    address: 'Okolice Starego Miasta · przykład',
    lat: 50.0668,
    lon: 19.9475,
    description: 'Przykładowa galeria na dwóch kondygnacjach. Informacja o awarii wymaga ponownego sprawdzenia.',
    observedOn: '2026-10-03',
    issue: 'Awaria windy — piętro może być niedostępne.',
    parts: [PlacePart('museum-main', 'Wejście od placu')],
    features: [
      FeatureFact('step_free_entrance', Presence.present, rating: 4),
      FeatureFact(
        'lift',
        Presence.present,
        rating: 4,
        state: OperationalState.notWorking,
      ),
      FeatureFact('accessible_toilet', Presence.unknown),
      FeatureFact('quiet', Presence.present, rating: 3),
      FeatureFact('guide_dog', Presence.present),
    ],
  ),
  Place(
    id: 'cafe',
    name: 'Kawiarnia pod chmurką',
    category: 'Jedzenie i spotkania',
    cityId: 'krakow',
    address: 'Okolice Kazimierza · przykład',
    lat: 50.0516,
    lon: 19.9458,
    description: 'Przykładowa kawiarnia, dla której brakuje części obserwacji dostępności.',
    observedOn: '2026-09-28',
    parts: [PlacePart('cafe-main', 'Wejście od ulicy')],
    features: [
      FeatureFact('step_free_entrance', Presence.unknown),
      FeatureFact('quiet', Presence.present, rating: 3),
      FeatureFact('rest', Presence.present, rating: 4),
      FeatureFact('guide_dog', Presence.unknown),
    ],
  ),
  Place(
    id: 'stairs',
    name: 'Klub na piętrze',
    category: 'Spotkania i wydarzenia',
    cityId: 'krakow',
    address: 'Centrum Krakowa · przykład',
    lat: 50.0614,
    lon: 19.9326,
    description: 'Przykładowe miejsce dostępne przez schody. Nie spełnia warunku wejścia bez schodów.',
    observedOn: '2026-10-02',
    features: [
      FeatureFact('step_free_entrance', Presence.absent),
      FeatureFact('lift', Presence.absent),
      FeatureFact('quiet', Presence.present, rating: 2),
    ],
  ),
  Place(
    id: 'warsaw-park',
    name: 'Zielony przystanek',
    category: 'Park i odpoczynek',
    cityId: 'warsaw',
    address: 'Śródmieście · przykład',
    lat: 52.2315,
    lon: 21.0135,
    description: 'Przykładowy park do testowania ręcznej zmiany miasta.',
    observedOn: '2026-10-02',
    parts: [PlacePart('warsaw-main', 'Wejście główne')],
    features: [
      FeatureFact('step_free_entrance', Presence.present, rating: 5),
      FeatureFact('rest', Presence.present, rating: 5),
      FeatureFact('quiet', Presence.present, rating: 4),
      FeatureFact('guide_dog', Presence.present),
    ],
  ),
  Place(
    id: 'warsaw-center',
    name: 'Centrum sąsiedzkie',
    category: 'Spotkania i wydarzenia',
    cityId: 'warsaw',
    address: 'Śródmieście · przykład',
    lat: 52.2371,
    lon: 21.0056,
    description: 'Przykładowe miejsce spotkań z udogodnieniami na parterze.',
    observedOn: '2026-10-01',
    features: [
      FeatureFact('step_free_entrance', Presence.present, rating: 4),
      FeatureFact(
        'accessible_toilet',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
      FeatureFact(
        'hearing_loop',
        Presence.present,
        rating: 4,
        state: OperationalState.working,
      ),
      FeatureFact('orientation', Presence.present, rating: 4),
    ],
  ),
];
