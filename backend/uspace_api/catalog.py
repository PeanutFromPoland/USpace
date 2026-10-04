"""Synthetic Polish catalogue for the demonstrational API."""

NEED_LABELS = {
    "wheelchair": "Poruszanie się na wózku",
    "walking_difficulty": "Trudności z chodzeniem",
    "no_stairs": "Brak możliwości korzystania ze schodów",
    "rest": "Miejsce odpoczynku",
    "low_vision": "Niewidzenie lub słabowidzenie",
    "hearing": "Głuchota lub niedosłuch",
    "noise": "Wrażliwość na hałas",
    "crowds": "Wrażliwość na tłum",
    "light": "Wrażliwość na światło",
    "quiet": "Spokojne miejsca",
    "orientation": "Wsparcie orientacji",
    "simple_text": "Proste informacje",
    "hand_mobility": "Ograniczona sprawność rąk",
    "assisted_travel": "Podróż z osobą wymagającą pomocy",
    "child_stroller": "Podróż z dzieckiem lub wózkiem dziecięcym",
    "guide_dog": "Podróż z psem przewodnikiem",
}

FEATURES = [
    {"id": "step_free_entrance", "label": "Wejście bez schodów", "description": "Dostęp bez stopni", "categoryId": "mobility", "supportsRating": False, "supportsOperationalState": False, "supportsMultipleTargets": True, "ratingLabels": None},
    {"id": "ramp", "label": "Podjazd", "description": "Podjazd przy wejściu", "categoryId": "mobility", "supportsRating": True, "supportsOperationalState": True, "supportsMultipleTargets": True, "ratingLabels": ["Bardzo trudno", "Trudno", "Przeciętnie", "Dobrze", "Bardzo dobrze"]},
    {"id": "elevator", "label": "Winda", "description": "Winda w obiekcie", "categoryId": "mobility", "supportsRating": True, "supportsOperationalState": True, "supportsMultipleTargets": True, "ratingLabels": ["Bardzo trudno", "Trudno", "Przeciętnie", "Dobrze", "Bardzo dobrze"]},
    {"id": "quiet_environment", "label": "Spokojne otoczenie", "description": "Poziom hałasu i tłoku", "categoryId": "sensory", "supportsRating": True, "supportsOperationalState": False, "supportsMultipleTargets": False, "ratingLabels": ["Bardzo źle", "Źle", "Przeciętnie", "Dobrze", "Bardzo dobrze"]},
    {"id": "accessible_toilet", "label": "Dostępna toaleta", "description": "Toaleta dostosowana do potrzeb", "categoryId": "mobility", "supportsRating": True, "supportsOperationalState": True, "supportsMultipleTargets": False, "ratingLabels": ["Bardzo trudno", "Trudno", "Przeciętnie", "Dobrze", "Bardzo dobrze"]},
]

# Existing Flutter questionnaire, canonical API identifiers. Not the proposed extra 13 features.
FLUTTER_QUESTION_FEATURES = [{'id': 'step_free_entrance', 'label': 'Wejście bez schodów', 'description': 'Dojście i wejście bez pokonywania stopni.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': True, 'ratingLabels': ['Bardzo trudne wejście', 'Duże trudności', 'Możliwa pomoc', 'Małe utrudnienia', 'Swobodne wejście']}, {'id': 'ramp', 'label': 'Podjazd', 'description': 'Wygoda korzystania z podjazdu.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': True, 'supportsMultipleTargets': True, 'ratingLabels': ['Bardzo trudny', 'Trudny', 'Wymaga pomocy', 'Wygodny', 'Wygodny samodzielnie']}, {'id': 'elevator', 'label': 'Winda', 'description': 'Dostępność i wygoda windy.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': True, 'supportsMultipleTargets': True, 'ratingLabels': ['Bardzo trudna obsługa', 'Duże utrudnienia', 'Możliwa pomoc', 'Wygodna', 'Swobodna obsługa']}, {'id': 'accessible_toilet', 'label': 'Dostosowana toaleta', 'description': 'Przestrzeń i wyposażenie toalety.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': True, 'supportsMultipleTargets': True, 'ratingLabels': ['Bardzo duże bariery', 'Duże bariery', 'Częściowo dostosowana', 'Dobrze dostosowana', 'Swobodne korzystanie']}, {'id': 'rest', 'label': 'Miejsca odpoczynku', 'description': 'Ławki lub dostępne miejsca siedzące.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo trudno odpocząć', 'Mało miejsc', 'Częściowo wystarczające', 'Dobre warunki', 'Wiele wygodnych miejsc']}, {'id': 'quiet_environment', 'label': 'Spokojne otoczenie', 'description': 'Warunki akustyczne i możliwość spokojnego pobytu.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo głośno', 'Głośno', 'Umiarkowany hałas', 'Spokojnie', 'Bardzo cicho']}, {'id': 'low_crowd', 'label': 'Niewielki tłum', 'description': 'Możliwość pobytu bez zatłoczenia w czasie wizyty.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo tłoczno', 'Tłoczno', 'Umiarkowanie', 'Mało osób', 'Dużo wolnej przestrzeni']}, {'id': 'gentle_light', 'label': 'Łagodne oświetlenie', 'description': 'Światło bez intensywnych lub migających efektów.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo intensywne', 'Intensywne', 'Umiarkowane', 'Łagodne', 'Bardzo komfortowe']}, {'id': 'guide_dog', 'label': 'Pies przewodnik', 'description': 'Możliwość korzystania z miejsca z psem przewodnikiem.', 'categoryId': 'accessibility', 'supportsRating': False, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': []}, {'id': 'orientation', 'label': 'Czytelne oznaczenia', 'description': 'Prosta orientacja i informacje o miejscu.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo nieczytelne', 'Trudne', 'Częściowo czytelne', 'Czytelne', 'Bardzo proste i czytelne']}, {'id': 'hearing_loop', 'label': 'Pętla indukcyjna', 'description': 'Wsparcie dla osób korzystających z aparatów słuchowych.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': True, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo słaba jakość', 'Słaba', 'Przeciętna', 'Dobra', 'Bardzo dobra']}, {'id': 'easy_controls', 'label': 'Łatwa obsługa', 'description': 'Obsługa bez precyzyjnych ruchów dłoni.', 'categoryId': 'accessibility', 'supportsRating': True, 'supportsOperationalState': False, 'supportsMultipleTargets': False, 'ratingLabels': ['Bardzo trudna', 'Trudna', 'Potrzebna pomoc', 'Łatwa', 'Bardzo łatwa']}]
QUESTION_METADATA = {'step_free_entrance': {'questionText': 'Czy da się wejść bez schodów?', 'isEnvironmental': False}, 'ramp': {'questionText': 'Jak oceniasz podjazd?', 'isEnvironmental': False}, 'elevator': {'questionText': 'Jak oceniasz windę?', 'isEnvironmental': False}, 'accessible_toilet': {'questionText': 'Jak oceniasz toaletę dla osób z niepełnosprawnościami?', 'isEnvironmental': False}, 'rest': {'questionText': 'Czy są miejsca, żeby usiąść i odpocząć?', 'isEnvironmental': False}, 'quiet_environment': {'questionText': 'Jak głośno było?', 'isEnvironmental': True}, 'low_crowd': {'questionText': 'Jak tłoczno było?', 'isEnvironmental': True}, 'gentle_light': {'questionText': 'Jakie było światło?', 'isEnvironmental': True}, 'guide_dog': {'questionText': 'Czy można wejść z psem przewodnikiem?', 'isEnvironmental': False}, 'orientation': {'questionText': 'Czy łatwo się zorientować?', 'isEnvironmental': False}, 'hearing_loop': {'questionText': 'Jak oceniasz pętlę indukcyjną?', 'isEnvironmental': False}, 'easy_controls': {'questionText': 'Czy klamki, przyciski i terminal da się obsłużyć bez wysiłku?', 'isEnvironmental': False}}
NEED_FEATURES = {'wheelchair': ['step_free_entrance', 'accessible_toilet'], 'walking_difficulty': ['step_free_entrance', 'rest'], 'no_stairs': ['step_free_entrance'], 'rest': ['rest'], 'low_vision': ['orientation'], 'hearing': ['hearing_loop'], 'noise': ['quiet_environment'], 'crowds': ['low_crowd'], 'light': ['gentle_light'], 'quiet': ['quiet_environment'], 'orientation': ['orientation'], 'simple_text': ['orientation'], 'hand_mobility': ['easy_controls'], 'assisted_travel': [], 'child_stroller': ['step_free_entrance', 'rest'], 'guide_dog': ['guide_dog']}
for candidate in FLUTTER_QUESTION_FEATURES:
    if not any(existing["id"] == candidate["id"] for existing in FEATURES):
        FEATURES.append(candidate)
for feature in FEATURES:
    feature.update(QUESTION_METADATA[feature["id"]])

FEATURES.sort(key=lambda feature: next(i for i, item in enumerate(FLUTTER_QUESTION_FEATURES) if item["id"] == feature["id"]))

FEATURE_BY_ID = {feature["id"]: feature for feature in FEATURES}

PRESETS = [
    {"id": "step_free", "label": "Bez schodów", "rules": [{"featureId": "step_free_entrance", "importance": "required", "minRating": None}]},
    {"id": "quiet", "label": "Spokojne miejsce", "rules": [{"featureId": "quiet_environment", "importance": "preferred", "minRating": None}]},
]

NEEDS = [
    {"id": key, "label": label, "description": label, "featureIds": NEED_FEATURES.get(key, []), "suggestedPresetIds": ["step_free"] if key in {"wheelchair", "walking_difficulty", "no_stairs"} else (["quiet"] if key in {"noise", "crowds", "quiet"} else [])}
    for key, label in NEED_LABELS.items()
]

CITIES = [{"id": "city_krakow", "label": "Kraków (demo)", "center": {"lat": 50.0647, "lon": 19.9450}, "timeZone": "Europe/Warsaw"}]
CARD_TYPES = [{"id": "demo_city_card", "cityId": "city_krakow", "label": "Karta demonstracyjna", "formatHint": "Dane syntetyczne; bez połączenia z operatorem"}]

CONFIGURATION = {
    "needs": NEEDS,
    "features": FEATURES,
    "presets": PRESETS,
    "cities": CITIES,
    "cardTypes": CARD_TYPES,
    "uiOptions": {"themeIds": ["default", "high_contrast", "green", "orange", "pink", "blue"], "rewardThemeIds": ["explorer", "gardener"], "textScales": [1, 1.25, 1.5, 2]},
    "limits": {"maxReviewAnswers": 50, "maxNewParts": 10, "maxCommentLength": 2000, "maxPartNameLength": 120, "maxReportDescriptionLength": 1000, "maxSearchLimit": 100},
}
