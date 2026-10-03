import 'models.dart';
import '../data/catalog.dart';

// Demo adapter only. Production matching will use the backend's Match response.
MatchResult evaluateDemoMatch(Place place, List<FilterRule> rules) {
  var missing = false;
  var failed = false;
  var preferred = 0;
  final reasons = <String>[];
  final active = rules
      .where((r) => r.importance != Importance.ignored)
      .toList();
  for (final rule in active) {
    final fact = place.fact(rule.featureId);
    if (rule.importance == Importance.preferred) {
      if (fact?.presence == Presence.present &&
          fact?.state != OperationalState.notWorking) {
        preferred++;
      }
      continue;
    }
    if (fact == null ||
        fact.presence == Presence.unknown ||
        fact.presence == Presence.disputed) {
      missing = true;
      reasons.add(rule.featureId);
      continue;
    }
    if (fact.presence == Presence.absent ||
        fact.state == OperationalState.notWorking ||
        fact.state == OperationalState.limited) {
      failed = true;
      reasons.add(rule.featureId);
      continue;
    }
    if (fact.state == OperationalState.unknown ||
        (featureById(rule.featureId).operational && fact.state == null)) {
      missing = true;
      reasons.add(rule.featureId);
    }
    if (rule.minRating != null) {
      if (fact.rating == null) {
        missing = true;
        reasons.add(rule.featureId);
      } else if (fact.rating! < rule.minRating!) {
        failed = true;
        reasons.add(rule.featureId);
      }
    }
  }
  return MatchResult(
    active.isEmpty
        ? MatchStatus.notEvaluated
        : failed
        ? MatchStatus.doesNotMatch
        : missing
        ? MatchStatus.insufficientData
        : MatchStatus.matches,
    reasons.toSet().toList(),
    preferred,
  );
}

List<SearchHit> searchDemoPlaces(
  List<Place> places,
  DemoProfile profile,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  final hits = places
      .where(
        (p) =>
            p.cityId == profile.cityId &&
            '${p.name} ${p.category} ${p.address}'.toLowerCase().contains(
              normalized,
            ),
      )
      .map((p) => SearchHit(p, evaluateDemoMatch(p, profile.rules)))
      .where(
        (h) =>
            h.match.status != MatchStatus.doesNotMatch &&
            (profile.includeUnknown ||
                h.match.status != MatchStatus.insufficientData),
      )
      .toList();
  hits.sort((a, b) {
    final unknown = (a.match.status == MatchStatus.insufficientData ? 1 : 0)
        .compareTo(b.match.status == MatchStatus.insufficientData ? 1 : 0);
    if (unknown != 0) return unknown;
    final preferences = b.match.preferenceCount.compareTo(
      a.match.preferenceCount,
    );
    return preferences != 0
        ? preferences
        : a.place.name.compareTo(b.place.name);
  });
  return hits;
}
