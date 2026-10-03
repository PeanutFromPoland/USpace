import 'package:flutter/foundation.dart';

import 'data/catalog.dart';
import 'data/demo_repository.dart';
import 'domain/matching.dart';
import 'domain/models.dart';
import 'domain/review.dart';

class AppController extends ChangeNotifier {
  AppController(
    this.repository, {
    this.autoDemoLogin = const bool.fromEnvironment(
      'USPACE_AUTO_DEMO_LOGIN',
      defaultValue: true,
    ),
  });
  final DemoRepository repository;
  // Local test identity only; this does not authenticate against a backend.
  final bool autoDemoLogin;
  bool get isDemoSignedIn => autoDemoLogin || profile.onboarded;
  DemoSnapshot snapshot = const DemoSnapshot();
  bool loading = true, saving = false;
  String? loadError;
  DemoProfile get profile => snapshot.profile;
  List<SearchHit> search(String query) =>
      searchDemoPlaces(demoPlaces, profile, query);

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
      snapshot = await repository.load();
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

  Future<void> reset() async {
    if (saving) {
      throw StateError('Trwa zapis.');
    }
    saving = true;
    notifyListeners();
    try {
      await repository.clear();
      snapshot = const DemoSnapshot();
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
