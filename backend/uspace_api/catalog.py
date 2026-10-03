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

FEATURE_BY_ID = {feature["id"]: feature for feature in FEATURES}

PRESETS = [
    {"id": "step_free", "label": "Bez schodów", "rules": [{"featureId": "step_free_entrance", "importance": "required", "minRating": None}]},
    {"id": "quiet", "label": "Spokojne miejsce", "rules": [{"featureId": "quiet_environment", "importance": "preferred", "minRating": None}]},
]

NEEDS = [
    {"id": key, "label": label, "description": label, "suggestedPresetIds": ["step_free"] if key in {"wheelchair", "walking_difficulty", "no_stairs"} else (["quiet"] if key in {"noise", "crowds", "quiet"} else [])}
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
    "uiOptions": {"themeIds": ["default", "high_contrast"], "textScales": [1, 1.25, 1.5, 2]},
    "limits": {"maxReviewAnswers": 50, "maxNewParts": 10, "maxCommentLength": 2000, "maxPartNameLength": 120, "maxReportDescriptionLength": 1000, "maxSearchLimit": 100},
}
