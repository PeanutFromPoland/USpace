enum Importance { required, preferred, ignored }

enum Presence { present, absent, unknown, disputed }

enum OperationalState { working, notWorking, limited, unknown }

enum MatchStatus { matches, doesNotMatch, insufficientData, notEvaluated }

class FeatureDefinition {
  const FeatureDefinition(
    this.id,
    this.label,
    this.description, {
    this.operational = false,
    this.ratable = true,
    required this.ratingLabels,
  });
  final String id, label, description;
  final bool operational, ratable;
  final List<String> ratingLabels;
}

class NeedDefinition {
  const NeedDefinition(this.id, this.label, this.category, this.features);
  final String id, label, category;
  final List<String> features;
}

class FilterRule {
  const FilterRule(this.featureId, this.importance, [this.minRating]);
  final String featureId;
  final Importance importance;
  final int? minRating;
  Map<String, dynamic> toJson() => {
    'featureId': featureId,
    'importance': importance.name,
    'minRating': importance == Importance.required ? minRating : null,
  };
  factory FilterRule.fromJson(Map<String, dynamic> json) => FilterRule(
    json['featureId'] as String,
    Importance.values.byName(json['importance'] as String),
    json['minRating'] as int?,
  );
}

class FeatureFact {
  const FeatureFact(
    this.featureId,
    this.presence, {
    this.rating,
    this.state,
    this.note = '',
  });
  final String featureId;
  final Presence presence;
  final int? rating;
  final OperationalState? state;
  final String note;
}

class PlacePart {
  const PlacePart(this.id, this.name);
  final String id, name;
}

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.cityId,
    required this.address,
    required this.lat,
    required this.lon,
    required this.description,
    required this.features,
    this.parts = const [],
    this.issue,
    required this.observedOn,
  });
  final String id, name, category, cityId, address, description, observedOn;
  final double lat, lon;
  final List<FeatureFact> features;
  final List<PlacePart> parts;
  final String? issue;
  FeatureFact? fact(String id) {
    for (final fact in features) {
      if (fact.featureId == id) return fact;
    }
    return null;
  }
}

class MatchResult {
  const MatchResult(this.status, this.reasons, this.preferenceCount);
  final MatchStatus status;
  final List<String> reasons;
  final int preferenceCount;
}

class SearchHit {
  const SearchHit(this.place, this.match);
  final Place place;
  final MatchResult match;
}

class DemoProfile {
  const DemoProfile({
    this.onboarded = false,
    this.needIds = const [],
    this.rules = const [],
    this.helper = false,
    this.publicNeeds = false,
    this.theme = 'blue',
    this.darkMode = false,
    this.highContrast = false,
    this.reduceMotion = false,
    this.cityId = 'krakow',
    this.includeUnknown = false,
  });
  final bool onboarded,
      helper,
      publicNeeds,
      darkMode,
      highContrast,
      reduceMotion,
      includeUnknown;
  final String theme, cityId;
  final List<String> needIds;
  final List<FilterRule> rules;
  DemoProfile copyWith({
    bool? onboarded,
    List<String>? needIds,
    List<FilterRule>? rules,
    bool? helper,
    bool? publicNeeds,
    String? theme,
    bool? darkMode,
    bool? highContrast,
    bool? reduceMotion,
    String? cityId,
    bool? includeUnknown,
  }) => DemoProfile(
    onboarded: onboarded ?? this.onboarded,
    needIds: needIds ?? this.needIds,
    rules: rules ?? this.rules,
    helper: helper ?? this.helper,
    publicNeeds: publicNeeds ?? this.publicNeeds,
    theme: theme ?? this.theme,
    darkMode: darkMode ?? this.darkMode,
    highContrast: highContrast ?? this.highContrast,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    cityId: cityId ?? this.cityId,
    includeUnknown: includeUnknown ?? this.includeUnknown,
  );
  Map<String, dynamic> toJson() => {
    'onboarded': onboarded,
    'needIds': needIds,
    'rules': rules.map((e) => e.toJson()).toList(),
    'helper': helper,
    'publicNeeds': publicNeeds,
    'theme': theme,
    'darkMode': darkMode,
    'highContrast': highContrast,
    'reduceMotion': reduceMotion,
    'cityId': cityId,
    'includeUnknown': includeUnknown,
  };
  factory DemoProfile.fromJson(Map<String, dynamic> json) => DemoProfile(
    onboarded: json['onboarded'] as bool? ?? false,
    needIds: List<String>.from(json['needIds'] as List? ?? []),
    rules: (json['rules'] as List? ?? [])
        .map((e) => FilterRule.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    helper: json['helper'] as bool? ?? false,
    publicNeeds: json['publicNeeds'] as bool? ?? false,
    theme: json['theme'] as String? ?? 'blue',
    darkMode: json['darkMode'] as bool? ?? false,
    highContrast: json['highContrast'] as bool? ?? false,
    reduceMotion: json['reduceMotion'] as bool? ?? false,
    cityId: json['cityId'] as String? ?? 'krakow',
    includeUnknown: json['includeUnknown'] as bool? ?? false,
  );
}

String presenceLabel(Presence value) => switch (value) {
  Presence.present => 'Występuje',
  Presence.absent => 'Brak funkcji · 0 / 5',
  Presence.unknown => 'Brak informacji',
  Presence.disputed => 'Sprzeczne informacje',
};
String stateLabel(OperationalState value) => switch (value) {
  OperationalState.working => 'Działa',
  OperationalState.notWorking => 'Nie działa',
  OperationalState.limited => 'Ograniczona dostępność',
  OperationalState.unknown => 'Stan nieznany',
};
String matchLabel(MatchStatus value) => switch (value) {
  MatchStatus.matches => 'Spełnia wymagania',
  MatchStatus.doesNotMatch => 'Nie spełnia wymagań',
  MatchStatus.insufficientData => 'Za mało informacji',
  MatchStatus.notEvaluated => 'Bez personalizacji',
};
String dateLabel(String value) => value.split('-').reversed.join('.');
