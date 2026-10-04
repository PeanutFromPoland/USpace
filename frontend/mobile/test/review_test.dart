import 'package:flutter_test/flutter_test.dart';
import 'package:uspace/data/catalog.dart';
import 'package:uspace/data/survey_catalog.dart';
import 'package:uspace/domain/models.dart';
import 'package:uspace/domain/review.dart';

void main() {
  final place = demoPlaces.firstWhere((p) => p.id == 'library');

  test('Survey questions use only features from the catalog', () {
    for (final question in surveyQuestions) {
      expect(() => featureById(question.featureId), returnsNormally);
    }
  });

  test('Questions follow needs; no needs shows every question', () {
    expect(questionsForNeeds([]).length, surveyQuestions.length);
    expect(questionsForNeeds(['stairs', 'noise']).map((q) => q.featureId), [
      'step_free_entrance',
      'quiet',
    ]);
    expect(
      questionsForNeeds(['stairs'], all: true).length,
      surveyQuestions.length,
    );
  });

  test('Absent is rating 0, unknown has no rating, present keeps state', () {
    final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3));
    draft.answers.addAll([
      AnswerDraft('step_free_entrance')..choice = const AbsentChoice(),
      AnswerDraft('quiet')..choice = const UnknownChoice(),
      AnswerDraft('ramp')
        ..choice = const RatedChoice(4)
        ..state = OperationalState.notWorking,
      AnswerDraft('guide_dog')..choice = const PresentChoice(),
    ]);
    final json = reviewCreateJson(draft);
    final answers = json['answers'] as List;
    expect(answers[0]['presence'], 'absent');
    expect(answers[0]['rating'], 0);
    expect(answers[0]['operationalState'], isNull);
    expect(answers[1]['presence'], 'unknown');
    expect(answers[1]['rating'], isNull);
    expect(answers[2]['rating'], 4);
    expect(answers[2]['operationalState'], 'not_working');
    expect(answers[3]['presence'], 'present');
    expect(answers[3]['rating'], isNull);
    expect(json['mode'], 'quick');
    expect(json['visitedOn'], '2026-10-03');
    expect(json['visitedAtLocalTime'], isNull);
    expect(json['recommendation'], isNull);
  });

  test('State is dropped when the feature is not present', () {
    final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3));
    draft.answers.add(
      AnswerDraft('lift')
        ..choice = const AbsentChoice()
        ..state = OperationalState.working,
    );
    final answer = (reviewCreateJson(draft)['answers'] as List).single;
    expect(answer['operationalState'], isNull);
  });

  test('New parts, comments and temporary issues make a detailed review', () {
    final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3))
      ..visitedAtLocalTime = '14:30'
      ..recommendation = 4;
    draft.answers.addAll([
      AnswerDraft('ramp')
        ..partId = 'library-main'
        ..choice = const RatedChoice(4)
        ..comment = ' Trochę stromy. ',
      AnswerDraft('ramp')
        ..newPartName = 'Wejście od ulicy Białej'
        ..choice = const AbsentChoice()
        ..issueKind = IssueKind.construction
        ..issueDescription = 'Podjazd w budowie',
    ]);
    final json = reviewCreateJson(draft);
    expect(json['mode'], 'detailed');
    expect(json['visitedAtLocalTime'], '14:30');
    expect(json['recommendation'], 4);
    final parts = json['newParts'] as List;
    expect(parts.single['name'], 'Wejście od ulicy Białej');
    final answers = json['answers'] as List;
    expect(answers[0]['targetId'], 'library-main');
    expect(answers[0]['targetClientId'], isNull);
    expect(answers[0]['comment'], 'Trochę stromy.');
    expect(answers[1]['targetId'], isNull);
    expect(answers[1]['targetClientId'], parts.single['clientId']);
    final issue = (json['temporaryIssues'] as List).single;
    expect(issue['kind'], 'construction');
    expect(issue['targetClientId'], parts.single['clientId']);
  });

  test('Unanswered questions are not sent and future dates are rejected', () {
    final draft = ReviewDraft(place: place, today: DateTime(2026, 10, 3));
    draft.answers.add(AnswerDraft('quiet'));
    expect(draft.unanswered, hasLength(1));
    expect(reviewCreateJson(draft)['answers'], isEmpty);
    draft.visitedOn = DateTime(2026, 10, 4);
    expect(draft.isFutureDate(DateTime(2026, 10, 3, 23, 59)), isTrue);
  });
}
