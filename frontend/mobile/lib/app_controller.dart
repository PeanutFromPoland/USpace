import 'package:flutter/foundation.dart';

import 'data/catalog.dart';
import 'data/demo_repository.dart';
import 'domain/matching.dart';
import 'domain/models.dart';

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
