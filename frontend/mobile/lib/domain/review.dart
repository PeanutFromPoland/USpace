import 'models.dart';

/// Rodzaj utrudnienia tymczasowego (kontrakt §3, `TemporaryIssue.kind`).
enum IssueKind { construction, outage, other }

String issueKindLabel(IssueKind kind) => switch (kind) {
  IssueKind.construction => 'Remont',
  IssueKind.outage => 'Awaria',
  IssueKind.other => 'Inne',
};

/// Wybór w pytaniu o cechę. Każde pokazane pytanie wymaga odpowiedzi
/// (Teoria aplikacji E): ocena 1–5, „Tak” dla cech bez oceny,
/// „0 – Brak funkcji” albo „Nie mogłem sprawdzić”.
sealed class AnswerChoice {
  const AnswerChoice();
}

class RatedChoice extends AnswerChoice {
  const RatedChoice(this.rating) : assert(rating >= 1 && rating <= 5);
  final int rating;
  @override
  bool operator ==(Object other) =>
      other is RatedChoice && other.rating == rating;
  @override
  int get hashCode => rating.hashCode;
}

class PresentChoice extends AnswerChoice {
  const PresentChoice();
  @override
  bool operator ==(Object other) => other is PresentChoice;
  @override
  int get hashCode => 1;
}

class AbsentChoice extends AnswerChoice {
  const AbsentChoice();
  @override
  bool operator ==(Object other) => other is AbsentChoice;
  @override
  int get hashCode => 2;
}

class UnknownChoice extends AnswerChoice {
  const UnknownChoice();
  @override
  bool operator ==(Object other) => other is UnknownChoice;
  @override
  int get hashCode => 3;
}

/// Odpowiedź o jedną cechę dla całego miejsca albo jednej jego części.
class AnswerDraft {
  AnswerDraft(this.featureId);
  final String featureId;

  /// Istniejąca część miejsca; null oznacza całe miejsce, chyba że podano
  /// [newPartName].
  String? partId;

  /// Nazwa nowej części, np. „Drzwi od ul. Białej” (kontrakt: `newParts`).
  String? newPartName;
  AnswerChoice? choice;
  OperationalState? state;
  String comment = '';
  IssueKind? issueKind;
  String issueDescription = '';

  bool get answered => choice != null;

  Presence? get presence => switch (choice) {
    RatedChoice() || PresentChoice() => Presence.present,
    AbsentChoice() => Presence.absent,
    UnknownChoice() => Presence.unknown,
    null => null,
  };

  /// Brak funkcji to ocena 0, która nie wlicza się do średniej
  /// (decyzja użytkownika 2026-10-03). Niewiedza nie ma oceny.
  int? get rating => switch (choice) {
    RatedChoice(:final rating) => rating,
    AbsentChoice() => 0,
    _ => null,
  };

  bool get hasDetails =>
      comment.trim().isNotEmpty ||
      issueKind != null ||
      (newPartName?.trim().isNotEmpty ?? false);
}

class ReviewDraft {
  ReviewDraft({required this.place, required DateTime today})
    : visitedOn = DateTime(today.year, today.month, today.day);
  final Place place;
  DateTime visitedOn;

  /// Godzina wpisywana samodzielnie, format HH:mm. Brak = null.
  String? visitedAtLocalTime;
  final List<AnswerDraft> answers = [];

  /// Odpowiedź na pytanie „Czy polecisz to miejsce?” (1–5) albo null.
  int? recommendation;

  bool get started => answers.any((a) => a.answered) || recommendation != null;

  List<AnswerDraft> answersFor(String featureId) =>
      answers.where((a) => a.featureId == featureId).toList();

  List<AnswerDraft> get unanswered =>
      answers.where((a) => !a.answered).toList();

  /// Data wizyty nie może być późniejsza niż dziś (kontrakt §3).
  bool isFutureDate(DateTime today) =>
      visitedOn.isAfter(DateTime(today.year, today.month, today.day));
}

/// Zamienia szkic na `ReviewCreate` z kontraktu frontend–backend v0.1.
/// Strefa czasowa pochodzi z miasta; w PoC oba miasta są w Polsce.
Map<String, dynamic> reviewCreateJson(ReviewDraft draft) {
  final newParts = <Map<String, dynamic>>[];
  final partClientIds = <AnswerDraft, String>{};
  for (final answer in draft.answers) {
    final name = answer.newPartName?.trim();
    if (answer.partId == null && name != null && name.isNotEmpty) {
      final clientId = 'part_local_${newParts.length + 1}';
      partClientIds[answer] = clientId;
      newParts.add({
        'clientId': clientId,
        'kind': 'entrance',
        'name': name,
        'description': null,
      });
    }
  }
  final answers = <Map<String, dynamic>>[];
  final issues = <Map<String, dynamic>>[];
  for (final (index, answer) in draft.answers.indexed) {
    if (!answer.answered) continue;
    final present = answer.presence == Presence.present;
    final comment = answer.comment.trim();
    answers.add({
      'clientId': 'answer_local_${index + 1}',
      'featureId': answer.featureId,
      'targetId': answer.partId,
      'targetClientId': partClientIds[answer],
      'presence': answer.presence!.name,
      'operationalState': present ? _stateWire(answer.state) : null,
      'rating': answer.rating,
      'comment': comment.isEmpty ? null : comment,
    });
    if (answer.issueKind case final kind?) {
      issues.add({
        'featureId': answer.featureId,
        'targetId': answer.partId,
        'targetClientId': partClientIds[answer],
        'kind': kind.name,
        'description': answer.issueDescription.trim(),
      });
    }
  }
  final detailed = draft.answers.any((a) => a.hasDetails);
  return {
    'mode': detailed ? 'detailed' : 'quick',
    'visitedOn': _isoDate(draft.visitedOn),
    'visitedAtLocalTime': draft.visitedAtLocalTime,
    'timeZone': 'Europe/Warsaw',
    'newParts': newParts,
    'answers': answers,
    'temporaryIssues': issues,
    'recommendation': draft.recommendation,
  };
}

String? _stateWire(OperationalState? state) => switch (state) {
  OperationalState.working => 'working',
  OperationalState.notWorking => 'not_working',
  OperationalState.limited => 'limited',
  OperationalState.unknown => 'unknown',
  null => null,
};

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
