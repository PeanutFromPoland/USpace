import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app_controller.dart';
import '../data/demo_repository.dart';
import '../data/product_api.dart';
import '../data/survey_catalog.dart';
import '../domain/models.dart';
import '../domain/review.dart';

abstract interface class ApiSessionStore {
  Future<String?> read();
  Future<void> write(String? token);
}

class SecureApiSessionStore implements ApiSessionStore {
  SecureApiSessionStore(this.origin);
  final String origin;
  final storage = const FlutterSecureStorage();
  @override
  Future<String?> read() async {
    final value = await storage.read(key: 'kindspot.api.session.v1');
    if (value == null) return null;
    final saved = jsonDecode(value) as Json;
    return saved['origin'] == origin ? saved['token'] as String? : null;
  }

  @override
  Future<void> write(String? token) => token == null
      ? storage.delete(key: 'kindspot.api.session.v1')
      : storage.write(
          key: 'kindspot.api.session.v1',
          value: jsonEncode({'origin': origin, 'token': token}),
        );
}

/// Separate from demo: no local balance, purchases or account reset.
class ApiAccessibilityStore extends DemoStore {
  final storage = const FlutterSecureStorage();
  @override
  Future<String?> read() => storage.read(key: 'kindspot.api.ui.v1');
  @override
  Future<void> write(String value) =>
      storage.write(key: 'kindspot.api.ui.v1', value: value);
  @override
  Future<void> clear() => storage.delete(key: 'kindspot.api.ui.v1');
}

class ApiController extends AppController {
  ApiController(this.api, this.sessionStore, {this.uiStore})
    : super(DemoRepository(SecureDemoStore()), autoDemoLogin: false) {
    api.onUnauthorized = expireSession;
  }
  final ProductApi api;
  final ApiSessionStore sessionStore;
  final DemoStore? uiStore;
  Json configuration = {};
  Json account = {};
  Json? temporarySearch;
  String? selectedCity;
  String placeSort = 'best_rated';
  String? notice;
  Json localAccessibility = {};
  Json get effectiveUi => {
    ...localAccessibility,
    ...account['uiSettings'] as Json? ?? {},
  };
  Future<void> setLocalAccessibility(Json settings) async {
    await uiStore?.write(jsonEncode(settings));
    localAccessibility = {...settings};
    notifyListeners();
  }

  final Map<String, String> voteKeys = {};
  final Map<String, (String, String)> _submissions = {};
  @override
  bool get isRemote => true;
  @override
  bool get isDemoSignedIn => api.token != null && account.isNotEmpty;
  @override
  DemoProfile get profile {
    final ui = effectiveUi;
    final preferences = account['preferences'] as Json? ?? {};
    final theme = (ui['colorThemeId'] as String? ?? 'green').replaceFirst(
      'pastel_',
      '',
    );
    return DemoProfile(
      needIds: List<String>.from(preferences['needIds'] as List? ?? []),
      theme: theme,
      darkMode: ui['darkMode'] == true,
      highContrast: ui['highContrast'] == true,
      reduceMotion: ui['reduceMotion'] == true,
      publicNeeds:
          (account['privacy'] as Json?)?['needsVisibility'] == 'public',
    );
  }

  @override
  Future<void> load() async {
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      final savedUi = await uiStore?.read();
      if (savedUi != null) localAccessibility = jsonDecode(savedUi) as Json;
      configuration = await api.configuration();
      api.token = await sessionStore.read();
      if (api.token != null) account = await api.me();
      selectedCity ??=
          (configuration['cities'] as List).firstOrNull?['id'] as String?;
    } catch (e) {
      if (e is! ProductApiError || e.status != 401) loadError = _message(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> authenticate(
    String email,
    String password, {
    String? name,
  }) async {
    if (saving) return;
    saving = true;
    notifyListeners();
    try {
      if (name != null) await api.register(email, password, name);
      final result = await api.login(email, password);
      final token = result['accessToken'] as String;
      await sessionStore.write(token);
      api.token = token;
      account = result['me'] as Json;
      notice = null;
      sessionRevision++;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  void expireSession() {
    if (api.token == null && account.isEmpty) return;
    localAccessibility = {...effectiveUi};
    uiStore?.write(jsonEncode(localAccessibility)).catchError((_) {});
    api.token = null;
    account = {};
    temporarySearch = null;
    _submissions.clear();
    demoSubmittedReviews.clear();
    voteKeys.clear();
    for (final id in _draftPlaces.toList()) {
      discardReviewDraft(id);
    }
    _draftPlaces.clear();
    sessionRevision++;
    notice = 'Sesja wygasła. Zaloguj się ponownie.';
    sessionStore.write(null).catchError((_) {});
    notifyListeners();
  }

  final Set<String> _draftPlaces = {};
  @override
  void keepReviewDraft(ReviewDraft draft) {
    _draftPlaces.add(draft.place.id);
    super.keepReviewDraft(draft);
  }

  Future<void> logout() async {
    await api.call('POST', 'auth/logout');
    await sessionStore.write(null);
    expireSession();
    notice = null;
    notifyListeners();
  }

  Future<void> refreshMe() async {
    account = await api.me();
    notifyListeners();
  }

  void applySearch(Json draft) {
    temporarySearch = jsonDecode(jsonEncode(draft)) as Json;
    notifyListeners();
  }

  Json searchBody(String query) => {
    'cityId': selectedCity,
    'q': query.trim().isEmpty ? null : query.trim(),
    'rules':
        temporarySearch?['rules'] ??
        (account['preferences'] as Json?)?['rules'] ??
        [],
    'includeUnknownRequired':
        temporarySearch?['includeUnknownRequired'] ?? false,
    'sort': placeSort,
    'limit': 20,
  };
  Set<String> get wantedSurveyFeatures => {
    for (final need in (configuration['needs'] as List).cast<Json>())
      if (profile.needIds.contains(need['id']))
        ...List<String>.from(need['featureIds'] as List? ?? []),
  };
  List<SurveyQuestion> get apiQuestions => [
    for (final feature in (configuration['features'] as List).cast<Json>())
      SurveyQuestion(
        feature['id'] as String,
        feature['questionText'] as String? ??
            'Jak oceniasz: ${feature['label']}?',
        environmental: feature['isEnvironmental'] == true,
        hint: feature['description'] as String?,
        multiTarget: feature['supportsMultipleTargets'] == true,
        definition: FeatureDefinition(
          feature['id'] as String,
          feature['label'] as String,
          feature['description'] as String? ?? '',
          operational: feature['supportsOperationalState'] == true,
          ratable: feature['supportsRating'] == true,
          ratingLabels: List<String>.from(
            feature['ratingLabels'] as List? ?? [],
          ),
        ),
      ),
  ];
  @override
  Future<Json> submitReview(ReviewDraft draft) async {
    final revision = sessionRevision;
    final body = apiReviewJson(draft);
    final encoded = jsonEncode(body);
    final previous = _submissions[draft.place.id];
    final key = previous != null && previous.$1 == encoded
        ? previous.$2
        : operationKey();
    _submissions[draft.place.id] = (encoded, key);
    final result = await api.submit(draft.place.id, body, key);
    if (revision != sessionRevision) {
      throw const ProductApiError(
        'Sesja się zmieniła. Sprawdź recenzję na swoim koncie.',
      );
    }
    discardReviewDraft(draft.place.id);
    _draftPlaces.remove(draft.place.id);
    _submissions.remove(draft.place.id);
    // Confirmed submission stays successful even if a later profile refresh fails.
    notifyListeners();
    return result;
  }

  static String _message(Object e) => e is ProductApiError
      ? e.message
      : 'Nie udało się wczytać danych. Spróbuj ponownie.';
}

Json apiReviewJson(ReviewDraft draft) {
  final body = reviewCreateJson(draft);
  for (final answer in (body['answers'] as List).cast<Json>()) {
    final rating = answer['rating'] as int?;
    // The API keeps a dimensions object. The form currently collects one score.
    answer['rating'] = answer['presence'] == 'present' && rating != null
        ? {'overall': rating, 'average_rating': rating.toDouble()}
        : null;
  }
  return body;
}

Place apiPlace(Json json) {
  final location = json['location'] as Json;
  return Place(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['categoryId'] as String? ?? '',
    cityId: json['cityId'] as String,
    address: json['address'] as String,
    lat: (location['lat'] as num).toDouble(),
    lon: (location['lon'] as num).toDouble(),
    description: '',
    observedOn: '',
    features: const [],
    parts: [
      for (final part in (json['parts'] as List? ?? []).cast<Json>())
        PlacePart(part['id'] as String, part['name'] as String),
    ],
  );
}
