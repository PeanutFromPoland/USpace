import '../domain/models.dart';
import 'catalog.dart';

/// Przykładowa ankieta PoC (frontend/docs/KindSpot-ankieta-recenzji.md).
/// Korzysta wyłącznie z cech istniejącego katalogu; dodatkowe cechy
/// z frontend/docs/KindSpot-mapowanie-pytan.md czekają na odbiór.
class SurveyQuestion {
  const SurveyQuestion(
    this.featureId,
    this.text, {
    this.hint,
    this.environmental = false,
    this.multiTarget = false,
    this.definition,
  });
  final String featureId;
  final String text;
  final String? hint;

  /// Cecha otoczenia (hałas, tłum, światło) zawsze „jest”: ankieta nie
  /// pokazuje opcji „0 – Brak funkcji”. Propozycja do odbioru.
  final bool environmental;

  /// Cecha może występować w kilku miejscach budynku (wejścia, części).
  final bool multiTarget;

  final FeatureDefinition? definition;
  FeatureDefinition get feature => definition ?? featureById(featureId);
}

const surveyQuestions = <SurveyQuestion>[
  SurveyQuestion(
    'step_free_entrance',
    'Czy da się wejść bez schodów?',
    hint: 'Dojście i wejście bez pokonywania stopni.',
    multiTarget: true,
  ),
  SurveyQuestion('ramp', 'Jak oceniasz podjazd?', multiTarget: true),
  SurveyQuestion('lift', 'Jak oceniasz windę?', multiTarget: true),
  SurveyQuestion(
    'accessible_toilet',
    'Jak oceniasz toaletę dla osób z niepełnosprawnościami?',
    multiTarget: true,
  ),
  SurveyQuestion(
    'rest',
    'Czy są miejsca, żeby usiąść i odpocząć?',
    hint: 'Ławki lub dostępne miejsca siedzące.',
  ),
  SurveyQuestion('quiet', 'Jak głośno było?', environmental: true),
  SurveyQuestion('low_crowd', 'Jak tłoczno było?', environmental: true),
  SurveyQuestion(
    'gentle_light',
    'Jakie było światło?',
    hint: 'Czy były ostre lub migające lampy.',
    environmental: true,
  ),
  SurveyQuestion('guide_dog', 'Czy można wejść z psem przewodnikiem?'),
  SurveyQuestion(
    'orientation',
    'Czy łatwo się zorientować?',
    hint: 'Oznaczenia, plan miejsca, proste informacje.',
  ),
  SurveyQuestion('hearing_loop', 'Jak oceniasz pętlę indukcyjną?'),
  SurveyQuestion(
    'easy_controls',
    'Czy klamki, przyciski i terminal da się obsłużyć bez wysiłku?',
  ),
];

SurveyQuestion questionFor(String featureId) =>
    surveyQuestions.firstWhere((q) => q.featureId == featureId);

/// Pytania dopasowane do potrzeb. Bez wskazanych potrzeb
/// ankieta pokazuje wszystkie pytania. [all] pokazuje wszystkie zawsze.
List<SurveyQuestion> questionsForNeeds(
  List<String> needIds, {
  bool all = false,
}) {
  final wanted = <String>{
    for (final need in needs.where((n) => needIds.contains(n.id)))
      ...need.features,
  };
  if (all || wanted.isEmpty) return surveyQuestions;
  return surveyQuestions.where((q) => wanted.contains(q.featureId)).toList();
}

const recommendationLabels = [
  'Nie polecam',
  'Raczej nie polecam',
  'Średnio',
  'Raczej polecam',
  'Zdecydowanie polecam',
];
