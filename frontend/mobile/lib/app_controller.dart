import 'package:flutter/foundation.dart';

import 'data/catalog.dart';
import 'data/city_locator.dart';
import 'data/demo_repository.dart';
import 'data/demo_reviews.dart';
import 'domain/reviews.dart';
import 'domain/matching.dart';
import 'domain/models.dart';
import 'domain/review.dart';
import 'domain/named_filters.dart';
import 'domain/demo_shop.dart';

class AppController extends ChangeNotifier {
  AppController(
    this.repository, {
    CityLocator? cityLocator,
    this.resetAccountOnLaunch = false,
    this.autoDemoLogin = const bool.fromEnvironment(
      'USPACE_AUTO_DEMO_LOGIN',
      defaultValue: true,
    ),
  }) : cityLocator = cityLocator ?? DeviceCityLocator();
  bool get isRemote => false;
  Future<Map<String, dynamic>> submitReview(ReviewDraft draft) async =>
      submitDemoReview(draft);
  final CityLocator cityLocator;
  final bool resetAccountOnLaunch;
  bool _launchPrepared = false;
  final shop = DemoShop();
  List<FilterRule>? _temporaryRules;
  bool? _temporaryUnknown;
  List<FilterRule> get activeRules => _temporaryRules ?? profile.rules;
  bool get activeIncludeUnknown => _temporaryUnknown ?? profile.includeUnknown;
  final DemoRepository repository;
  // Local test identity only; this does not authenticate against a backend.
  final bool autoDemoLogin;
  bool _signedOut = false;
  int sessionRevision = 0;
  String? sessionError;
  bool get isDemoSignedIn =>
      (autoDemoLogin && !_signedOut) || profile.onboarded;

  Future<void> openDemoSession() async {
    if (isDemoSignedIn) return;
    await saveProfile(profile.copyWith(onboarded: true));
    _signedOut = false;
    sessionError = null;
    sessionRevision++;
    notifyListeners();
  }

  Future<void> closeDemoSession() async {
    sessionError = null;
    try {
      await saveProfile(profile.copyWith(onboarded: false));
      _signedOut = true;
      sessionRevision++;
    } catch (_) {
      sessionError = 'Nie udało się zakończyć sesji demo. Spróbuj ponownie. Konto pozostaje otwarte.';
    }
    notifyListeners();
  }

  DemoSnapshot snapshot = const DemoSnapshot();
  bool loading = true, saving = false;
  String? loadError;
  DemoProfile get profile => snapshot.profile;
  List<SearchHit> search(String query) => searchDemoPlaces(
    demoPlaces,
    profile.copyWith(rules: activeRules, includeUnknown: activeIncludeUnknown),
    query,
  );

  // Szkice recenzji tylko w pamięci, po jednym na miejsce: wyjście z ankiety
  // nie kasuje odpowiedzi. Zasady trwałego szkicu: DO-USTALENIA.md.
  final Map<String, ReviewDraft> _reviewDrafts = {};
  final List<Map<String, dynamic>> demoSubmittedReviews = [];
  ReviewDraft? reviewDraft(String placeId) => _reviewDrafts[placeId];
  void keepReviewDraft(ReviewDraft draft) =>
      _reviewDrafts[draft.place.id] = draft;
  void discardReviewDraft(String placeId) => _reviewDrafts.remove(placeId);
  void refreshReviewDrafts() => notifyListeners();

  /// Wersja demonstracyjna: recenzja nie trafia do systemu. Statusy
  /// publikacji, sprawdzania i punktów pochodzą wyłącznie z backendu.
  Map<String, dynamic> submitDemoReview(ReviewDraft draft) {
    final payload = reviewCreateJson(draft);
    demoSubmittedReviews.add(payload);
    _reviewDrafts.remove(draft.place.id);
    notifyListeners();
    return payload;
  }

  Future<void> load() async {
    loading = true;
    loadError = null;
    notifyListeners();
    try {
      final loaded = await repository.load();
      if (resetAccountOnLaunch && !_launchPrepared) {
        final previous = loaded.profile;
        final fresh = DemoProfile(
          namedFilters: previous.namedFilters,
          theme: previous.theme,
          darkMode: previous.darkMode,
          highContrast: previous.highContrast,
          reduceMotion: previous.reduceMotion,
          savedPlaceIds: const ['garden'],
        );
        final candidate = DemoSnapshot(profile: fresh);
        await repository.save(candidate);
        snapshot = candidate;
        shop.reset();
        _reviewDrafts.clear();
        demoSubmittedReviews.clear();
        _temporaryRules = null;
        _temporaryUnknown = null;
        _launchPrepared = true;
      } else {
        snapshot = loaded;
      }
    } catch (_) {
      loadError =
          'Nie udało się odczytać zapisanych danych. Możesz ponowić próbę.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> saveProfile(DemoProfile profile) async {
    if (saving) {
      throw StateError('Trwa zapis. Spróbuj ponownie za chwilę.');
    }
    saving = true;
    notifyListeners();
    final candidate = DemoSnapshot(profile: profile);
    try {
      await repository.save(candidate);
      snapshot = candidate;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  bool isPlaceSaved(String id) => profile.savedPlaceIds.contains(id);

  Future<void> setPlaceSaved(String id, bool saved) async {
    if (!isDemoSignedIn) throw StateError('Konto demo jest zamknięte.');
    if (saving) throw StateError('Trwa zapis.');
    if (saved && !demoPlaces.any((place) => place.id == id)) {
      throw ArgumentError.value(id, 'id', 'Nieznane miejsce');
    }
    if (isPlaceSaved(id) == saved) return;
    final ids = profile.savedPlaceIds.where((value) => value != id).toList();
    if (saved) ids.insert(0, id);
    await saveProfile(profile.copyWith(savedPlaceIds: List.unmodifiable(ids)));
  }

  Future<void> reportDemoReview(String id, ReviewReportReason reason) async {
    if (loading || loadError != null) {
      throw StateError('Dane demo nie są gotowe.');
    }
    if (!isDemoSignedIn) throw StateError('Konto demo jest zamknięte.');
    if (saving) throw StateError('Trwa zapis.');
    final eligible = demoPlaces
        .expand(demoReviewsFor)
        .any(
          (review) =>
              review.id == id &&
              review.authorId != demoUserId &&
              review.publication == ReviewPublication.visible,
        );
    if (!eligible) {
      throw ArgumentError.value(id, 'id', 'Recenzja niedostępna do zgłoszenia');
    }
    if (profile.reviewReports.containsKey(id)) return;
    final reports = Map<String, String>.of(profile.reviewReports)
      ..[id] = reason.name;
    await saveProfile(
      profile.copyWith(reviewReports: Map.unmodifiable(reports)),
    );
  }

  void _requireSession() {
    if (loading || loadError != null || !isDemoSignedIn) {
      throw StateError('Konto nie jest gotowe.');
    }
    if (saving) throw StateError('Trwa zapis.');
  }

  void buyDemoReward(String rewardId) {
    _requireSession();
    shop.buy(rewardId);
    notifyListeners();
  }

  void redeemDemoReward(String purchaseId) {
    _requireSession();
    shop.redeem(purchaseId);
    notifyListeners();
  }

  void useFilter(List<FilterRule> rules, bool includeUnknown) {
    _requireSession();
    _temporaryRules = List.unmodifiable(rules);
    _temporaryUnknown = includeUnknown;
    notifyListeners();
  }

  Future<void> saveNamedFilter(
    String name,
    List<FilterRule> rules,
    bool includeUnknown,
  ) async {
    _requireSession();
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 60) {
      throw ArgumentError('Nazwa musi mieć od 1 do 60 znaków.');
    }
    if (profile.namedFilters.any(
      (f) => f.name.toLowerCase() == trimmed.toLowerCase(),
    )) {
      throw ArgumentError(
        'Filtr o takiej nazwie już istnieje. Wybierz inną nazwę.',
      );
    }
    final filter = NamedFilter(
      name: trimmed,
      rules: List.unmodifiable(rules),
      includeUnknown: includeUnknown,
    );
    await saveProfile(
      profile.copyWith(
        namedFilters: List.unmodifiable([...profile.namedFilters, filter]),
      ),
    );
  }

  Future<void> reset() async {
    if (saving) {
      throw StateError('Trwa zapis.');
    }
    saving = true;
    notifyListeners();
    try {
      await repository.clear();
      snapshot = DemoSnapshot(
        profile: DemoProfile(
          savedPlaceIds: resetAccountOnLaunch ? const ['garden'] : const [],
        ),
      );
      shop.reset();
      _reviewDrafts.clear();
      demoSubmittedReviews.clear();
      _temporaryRules = null;
      _temporaryUnknown = null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
