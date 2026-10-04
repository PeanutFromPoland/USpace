import 'dart:convert';

import 'package:flutter/material.dart';

import 'graphics.dart';

import '../app_controller.dart';
import '../data/survey_catalog.dart';
import '../domain/models.dart';
import '../domain/review.dart';
import 'components.dart';

const _missingAnswer =
    'Wybierz odpowiedź. Jeśli nie wiesz, wybierz „Nie mogłem sprawdzić”.';
const _wholePlace = '__whole__';
const _newPart = '__new__';

/// Ankieta recenzji miejsca (UC-05, UC-06): jedno pytanie na ekran,
/// wymagana odpowiedź na każde pokazane pytanie, szkic zachowany w pamięci.
class ReviewSurveyScreen extends StatefulWidget {
  const ReviewSurveyScreen({
    super.key,
    required this.controller,
    required this.place,
    this.today,
    this.providedQuestions,
    this.providedWantedFeatures,
  });
  final AppController controller;
  final Place place;

  /// Dzisiejsza data; parametr ułatwia testy.
  final DateTime? today;
  final List<SurveyQuestion>? providedQuestions;
  final Set<String>? providedWantedFeatures;

  @override
  State<ReviewSurveyScreen> createState() => _ReviewSurveyScreenState();
}

class _ReviewSurveyScreenState extends State<ReviewSurveyScreen> {
  late ReviewDraft draft;
  late bool resumed;
  bool showAll = false;
  int step = 0;
  String? error;
  bool sending = false;
  Map<String, dynamic>? submitted;
  final scroll = ScrollController();

  DateTime get today => widget.today ?? DateTime.now();

  List<SurveyQuestion> get allQuestions =>
      widget.providedQuestions ?? surveyQuestions;
  List<SurveyQuestion> catalogQuestions(bool all) {
    final provided = widget.providedQuestions;
    if (provided == null) {
      return questionsForNeeds(widget.controller.profile.needIds, all: all);
    }
    final wanted = widget.providedWantedFeatures;
    if (all || wanted == null || wanted.isEmpty) return provided;
    return provided.where((q) => wanted.contains(q.featureId)).toList();
  }

  List<SurveyQuestion> get questions => catalogQuestions(showAll);

  // Kroki: 0 wstęp, 1 data, potem pytania, polecenie, podsumowanie, wynik.
  int get questionStart => 2;
  int get recommendStep => questionStart + questions.length;
  int get summaryStep => recommendStep + 1;
  int get resultStep => summaryStep + 1;

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.reviewDraft(widget.place.id);
    resumed = existing != null && existing.started;
    draft = existing ?? ReviewDraft(place: widget.place, today: today);
    _ensureAnswers();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void _ensureAnswers() {
    for (final q in questions) {
      if (draft.answersFor(q.featureId).isEmpty) {
        draft.answers.add(AnswerDraft(q.featureId));
      }
    }
    // Kolejność odpowiedzi zgodna z kolejnością pytań.
    final order = {
      for (final (i, q)
          in (widget.providedQuestions ?? surveyQuestions).indexed)
        q.featureId: i,
    };
    draft.answers.sort(
      (a, b) => order[a.featureId]!.compareTo(order[b.featureId]!),
    );
  }

  void _changed() {
    widget.controller.keepReviewDraft(draft);
    setState(() {});
  }

  void _goTo(int target) {
    setState(() {
      step = target;
      error = null;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> _next() async {
    if (sending) return;
    if (step == 1 && draft.isFutureDate(today)) {
      setState(() => error = 'Data wizyty nie może być późniejsza niż dziś.');
      return;
    }
    if (step >= questionStart && step < recommendStep) {
      final question = questions[step - questionStart];
      if (draft.answersFor(question.featureId).any((a) => !a.answered)) {
        setState(() => error = _missingAnswer);
        return;
      }
    }
    if (step == summaryStep) {
      final missing = _firstUnansweredStep();
      if (missing != null) {
        _goTo(missing);
        setState(() => error = _missingAnswer);
        return;
      }
      if (widget.controller.isRemote &&
          draft.answers
              .where((a) => a.answered)
              .every((a) => a.presence == Presence.unknown)) {
        setState(
          () => error = 'Podaj co najmniej jedną obserwację. Same niewiadome nie wystarczą.',
        );
        return;
      }
      setState(() {
        sending = true;
        error = null;
      });
      try {
        submitted = await widget.controller.submitReview(draft);
        if (mounted) _goTo(resultStep);
      } catch (e) {
        if (mounted) {
          setState(
            () => error = widget.controller.isRemote
                ? 'Nie udało się wysłać recenzji. Odpowiedzi zostały. Spróbuj ponownie.'
                : 'Nie udało się zapisać recenzji. Spróbuj ponownie.',
          );
        }
      } finally {
        if (mounted) setState(() => sending = false);
      }
      return;
    }
    _goTo(step + 1);
  }

  int? _firstUnansweredStep() {
    for (final (i, q) in questions.indexed) {
      if (draft.answersFor(q.featureId).any((a) => !a.answered)) {
        return questionStart + i;
      }
    }
    return null;
  }

  void _back() {
    if (sending) return;
    if (step == 0 || step == resultStep) {
      Navigator.of(context).pop();
    } else {
      _goTo(step - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inQuestions = step >= questionStart && step < recommendStep;
    return PopScope(
      canPop: !sending && (step == 0 || step == resultStep),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: adaptiveAppBar(context, 'Recenzja miejsca'),
        body: Column(
          children: [
            if (inQuestions)
              _Progress(
                current: step - questionStart + 1,
                total: questions.length,
              ),
            Expanded(
              child: AbsorbPointer(
                absorbing: sending,
                child: pageBody(
                  [
                    if (error != null) _ErrorNotice(error!),
                    ..._stepContent(context),
                  ],
                  key: ValueKey('step-$step'),
                  controller: scroll,
                ),
              ),
            ),
            if (step != resultStep) _bottomBar(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _stepContent(BuildContext context) {
    if (step == 0) return _intro(context);
    if (step == 1) return _date(context);
    if (step < recommendStep) {
      return _question(context, questions[step - questionStart]);
    }
    if (step == recommendStep) return _recommend(context);
    if (step == summaryStep) return _summary(context);
    return _result(context);
  }

  Widget _bottomBar(BuildContext context) {
    final nextLabel = switch (step) {
      0 => 'Zaczynam',
      _ when step == summaryStep => 'Wyślij recenzję',
      _ => 'Dalej',
    };
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            if (step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: sending ? null : _back,
                  child: const Text('Wstecz'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: sending ? null : _next,
                child: Text(sending ? 'Wysyłanie…' : nextLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Wstęp ----------

  List<Widget> _intro(BuildContext context) {
    final mine = catalogQuestions(false);
    return [
      _Heading(widget.place.name),
      Text(widget.place.address),
      const SizedBox(height: 16),
      Notice(
        widget.controller.isRemote
            ? 'Recenzja trafi do systemu. Punkty przyznaje serwer po sprawdzeniu.'
            : 'Wersja demonstracyjna. Recenzja nie jest wysyłana do systemu, a punkty przyznaje tylko system.',
      ),
      const SizedBox(height: 16),
      Text(
        'Odpowiesz na pytania dopasowane do Twoich potrzeb. '
        'Na każde pytanie wybierz odpowiedź. Jeśli czegoś nie wiesz, '
        'wybierz „Nie mogłem sprawdzić”.',
      ),
      const SizedBox(height: 16),
      Text(
        'Liczba pytań: ${questions.length}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (mine.length < allQuestions.length)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Pokaż wszystkie pytania (${allQuestions.length})'),
          subtitle: const Text('Także te spoza Twoich potrzeb.'),
          value: showAll,
          onChanged: (v) {
            showAll = v;
            _ensureAnswers();
            _changed();
          },
        ),
      if (resumed) ...[
        const SizedBox(height: 16),
        const Notice(
          'Kontynuujesz rozpoczętą recenzję. Twoje odpowiedzi są zachowane.',
          icon: Icons.history,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              widget.controller.discardReviewDraft(widget.place.id);
              setState(() {
                draft = ReviewDraft(place: widget.place, today: today);
                resumed = false;
                _ensureAnswers();
              });
            },
            child: const Text('Zacznij od nowa'),
          ),
        ),
      ],
    ];
  }

  // ---------- Data ----------

  List<Widget> _date(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final time = draft.visitedAtLocalTime;
    return [
      const _Heading('Kiedy była wizyta?'),
      const Text('Domyślnie dzisiaj. Godzina jest opcjonalna.'),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data wizyty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(localizations.formatFullDate(draft.visitedOn)),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.visitedOn,
                    firstDate: today.subtract(const Duration(days: 365)),
                    lastDate: today,
                    helpText: 'Data wizyty',
                  );
                  if (picked != null) {
                    draft.visitedOn = picked;
                    _changed();
                  }
                },
                child: const Text('Zmień datę'),
              ),
            ],
          ),
        ),
      ),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Godzina (opcjonalnie)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(time ?? 'Nie podano'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 12, minute: 0),
                        helpText: 'Godzina wizyty',
                      );
                      if (picked != null) {
                        draft.visitedAtLocalTime =
                            '${picked.hour.toString().padLeft(2, '0')}:'
                            '${picked.minute.toString().padLeft(2, '0')}';
                        _changed();
                      }
                    },
                    child: Text(
                      time == null ? 'Dodaj godzinę' : 'Zmień godzinę',
                    ),
                  ),
                  if (time != null)
                    TextButton(
                      onPressed: () {
                        draft.visitedAtLocalTime = null;
                        _changed();
                      },
                      child: const Text('Usuń godzinę'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  // ---------- Pytanie o cechę ----------

  List<Widget> _question(BuildContext context, SurveyQuestion question) {
    final answers = draft.answersFor(question.featureId);
    return [
      Text(
        question.feature.label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KindSpotFeatureIcon(question.featureId),
          const SizedBox(width: 12),
          Expanded(child: _Heading(question.text)),
        ],
      ),
      if (question.hint != null) Text(question.hint!),
      const SizedBox(height: 12),
      for (final (i, answer) in answers.indexed)
        _AnswerCard(
          key: ObjectKey(answer),
          question: question,
          answer: answer,
          place: widget.place,
          index: i,
          showError: error != null && !answer.answered,
          onChanged: () {
            if (error != null && answers.every((a) => a.answered)) {
              error = null;
            }
            _changed();
          },
          onRemove: i == 0
              ? null
              : () {
                  draft.answers.remove(answer);
                  _changed();
                },
        ),
      if (question.multiTarget)
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              final added = AnswerDraft(question.featureId);
              final lastIndex = draft.answers.lastIndexOf(answers.last);
              draft.answers.insert(lastIndex + 1, added);
              _changed();
            },
            icon: const KindSpotSymbol(Icons.add),
            label: const Text('Oceń inne wejście lub część'),
          ),
        ),
    ];
  }

  // ---------- Polecenie ----------

  List<Widget> _recommend(BuildContext context) => [
    const _Heading('Czy polecisz to miejsce osobom z podobnymi potrzebami?'),
    const Text('To pytanie możesz pominąć.'),
    const SizedBox(height: 12),
    RadioGroup<int>(
      groupValue: draft.recommendation,
      onChanged: (v) {
        draft.recommendation = v;
        _changed();
      },
      child: Column(
        children: [
          for (var i = 1; i <= 5; i++)
            RadioListTile<int>(
              value: i,
              contentPadding: EdgeInsets.zero,
              title: Text('$i – ${recommendationLabels[i - 1]}'),
            ),
        ],
      ),
    ),
    if (draft.recommendation != null)
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {
            draft.recommendation = null;
            _changed();
          },
          child: const Text('Wyczyść odpowiedź'),
        ),
      ),
  ];

  // ---------- Podsumowanie ----------

  List<Widget> _summary(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final time = draft.visitedAtLocalTime;
    return [
      const _Heading('Sprawdź i wyślij'),
      Text(
        'Wizyta: ${localizations.formatFullDate(draft.visitedOn)}'
        '${time == null ? '' : ', godz. $time'}',
      ),
      Text(
        'Polecenie: ${draft.recommendation == null ? 'bez odpowiedzi' : '${draft.recommendation} – ${recommendationLabels[draft.recommendation! - 1]}'}',
      ),
      const SizedBox(height: 12),
      for (final (i, question) in questions.indexed)
        for (final answer in draft.answersFor(question.featureId))
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KindSpotFeatureIcon(question.featureId, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${question.feature.label} · ${partLabel(widget.place, answer)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  Text(answerLabel(question, answer)),
                  if (answer.state case final state?
                      when answer.presence == Presence.present)
                    Text('Stan: ${stateLabel(state)}'),
                  if (answer.comment.trim().isNotEmpty)
                    Text('Uzasadnienie: ${answer.comment.trim()}'),
                  if (answer.issueKind case final kind?)
                    Text(
                      'Utrudnienie: ${issueKindLabel(kind)}'
                      '${answer.issueDescription.trim().isEmpty ? '' : ' – ${answer.issueDescription.trim()}'}',
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _goTo(questionStart + i),
                      child: Text(
                        'Zmień',
                        semanticsLabel: 'Zmień: ${question.feature.label}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    ];
  }

  // ---------- Wynik ----------

  List<Widget> _result(BuildContext context) {
    if (widget.controller.isRemote) {
      final award = submitted?['pointAward'] as Map<String, dynamic>?;
      return [
        const _Heading('Recenzja wysłana'),
        const Text(
          'Serwer odebrał recenzję. Statusy możesz sprawdzić na liście recenzji.',
        ),
        Text(
          'Publikacja: ${submitted?['publicationStatus'] == 'visible' ? 'widoczna' : 'wstrzymana'}',
        ),
        Text(
          'Sprawdzanie: ${submitted?['verificationStatus'] == 'accepted' ? 'zaakceptowana' : 'oczekuje'}',
        ),
        Text(
          award?['status'] == 'granted'
              ? 'Punkty przyznane: ${award?['amount']}'
              : 'Punkty jeszcze nieprzyznane.',
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Wróć do miejsca'),
        ),
      ];
    }
    final json = const JsonEncoder.withIndent('  ').convert(submitted);
    return [
      Semantics(
        liveRegion: true,
        child: const _Heading('Recenzja zapisana w wersji demonstracyjnej'),
      ),
      const Text('Nie została wysłana do systemu. Dziękujemy za odpowiedzi!'),
      const SizedBox(height: 16),
      const _StatusRow(
        icon: Icons.public_off,
        title: 'Publikacja',
        text: 'Nieopublikowana: brak połączenia z systemem.',
      ),
      const _StatusRow(
        icon: Icons.hourglass_empty,
        title: 'Sprawdzanie',
        text: 'Brak sprawdzania w wersji demonstracyjnej.',
      ),
      const _StatusRow(
        icon: Icons.stars_outlined,
        title: 'Punkty',
        text: 'Punkty przyznaje tylko system po sprawdzeniu recenzji.',
      ),
      const SizedBox(height: 8),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Dane w formacie kontraktu (dla zespołu)'),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Wróć do miejsca'),
      ),
    ];
  }
}

String partLabel(Place place, AnswerDraft answer) {
  if (answer.partId case final id?) {
    for (final part in place.parts) {
      if (part.id == id) return part.name;
    }
  }
  final name = answer.newPartName?.trim();
  if (name != null && name.isNotEmpty) return name;
  return 'Całe miejsce';
}

String choiceLabel(SurveyQuestion question, AnswerChoice choice) =>
    switch (choice) {
      RatedChoice(:final rating) =>
        '$rating – ${question.feature.ratingLabels[rating - 1]}',
      PresentChoice() => 'Tak, jest',
      AbsentChoice() => '0 – Brak funkcji',
      UnknownChoice() => 'Nie mogłem sprawdzić',
    };

String answerLabel(SurveyQuestion question, AnswerDraft answer) =>
    answer.choice == null
    ? 'Bez odpowiedzi'
    : choiceLabel(question, answer.choice!);

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({
    super.key,
    required this.question,
    required this.answer,
    required this.place,
    required this.index,
    required this.showError,
    required this.onChanged,
    this.onRemove,
  });
  final SurveyQuestion question;
  final AnswerDraft answer;
  final Place place;
  final int index;
  final bool showError;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  late final comment = TextEditingController(text: widget.answer.comment);
  late final issue = TextEditingController(
    text: widget.answer.issueDescription,
  );
  late final partName = TextEditingController(
    text: widget.answer.newPartName ?? '',
  );

  @override
  void dispose() {
    comment.dispose();
    issue.dispose();
    partName.dispose();
    super.dispose();
  }

  List<AnswerChoice> get options {
    final feature = widget.question.feature;
    return [
      if (feature.ratable)
        for (var i = 5; i >= 1; i--) RatedChoice(i)
      else
        const PresentChoice(),
      if (!widget.question.environmental) const AbsentChoice(),
      const UnknownChoice(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final answer = widget.answer;
    final question = widget.question;
    final scheme = Theme.of(context).colorScheme;
    final partValue =
        answer.partId ?? (answer.newPartName != null ? _newPart : _wholePlace);
    return Card(
      shape: widget.showError
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: scheme.error, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.multiTarget) ...[
              DropdownButtonFormField<String>(
                initialValue: partValue,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Którego miejsca dotyczy odpowiedź?',
                ),
                items: [
                  const DropdownMenuItem(
                    value: _wholePlace,
                    child: Text('Całe miejsce'),
                  ),
                  for (final part in widget.place.parts)
                    DropdownMenuItem(value: part.id, child: Text(part.name)),
                  const DropdownMenuItem(
                    value: _newPart,
                    child: Text('Inne wejście lub część'),
                  ),
                ],
                onChanged: (v) {
                  answer.partId = (v == _wholePlace || v == _newPart)
                      ? null
                      : v;
                  answer.newPartName = v == _newPart ? partName.text : null;
                  widget.onChanged();
                },
              ),
              if (partValue == _newPart)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: partName,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa wejścia lub części',
                      hintText: 'np. Drzwi od ul. Białej',
                    ),
                    onChanged: (v) {
                      answer.newPartName = v;
                      widget.onChanged();
                    },
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (widget.showError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Brak odpowiedzi.',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Semantics(
              container: true,
              label:
                  'Odpowiedź: ${question.feature.label}, ${partLabel(widget.place, answer)}',
              child: RadioGroup<AnswerChoice>(
                groupValue: answer.choice,
                onChanged: (v) {
                  answer.choice = v;
                  if (answer.presence != Presence.present) answer.state = null;
                  widget.onChanged();
                },
                child: Column(
                  children: [
                    for (final option in options)
                      RadioListTile<AnswerChoice>(
                        value: option,
                        contentPadding: EdgeInsets.zero,
                        title: Text(choiceLabel(question, option)),
                      ),
                  ],
                ),
              ),
            ),
            if (answer.presence == Presence.present &&
                question.feature.operational) ...[
              const SizedBox(height: 8),
              Text(
                'Czy działa? (opcjonalnie)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              RadioGroup<OperationalState>(
                groupValue: answer.state,
                onChanged: (v) {
                  answer.state = v;
                  widget.onChanged();
                },
                child: Column(
                  children: [
                    for (final state in [
                      OperationalState.working,
                      OperationalState.limited,
                      OperationalState.notWorking,
                      OperationalState.unknown,
                    ])
                      RadioListTile<OperationalState>(
                        value: state,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          state == OperationalState.unknown
                              ? 'Nie wiem'
                              : stateLabel(state),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              initiallyExpanded:
                  answer.comment.isNotEmpty || answer.issueKind != null,
              title: const Text('Uzasadnienie i utrudnienia (opcjonalnie)'),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                TextField(
                  controller: comment,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Uzasadnienie',
                    hintText: 'Przykład: 4, bo podjazd jest dobry, ale trochę stromy.',
                  ),
                  onChanged: (v) {
                    answer.comment = v;
                    widget.onChanged();
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Utrudnienie tymczasowe',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                RadioGroup<IssueKind?>(
                  groupValue: answer.issueKind,
                  onChanged: (v) {
                    answer.issueKind = v;
                    widget.onChanged();
                  },
                  child: Column(
                    children: [
                      const RadioListTile<IssueKind?>(
                        value: null,
                        contentPadding: EdgeInsets.zero,
                        title: Text('Brak utrudnień'),
                      ),
                      for (final kind in IssueKind.values)
                        RadioListTile<IssueKind?>(
                          value: kind,
                          contentPadding: EdgeInsets.zero,
                          title: Text(issueKindLabel(kind)),
                        ),
                    ],
                  ),
                ),
                if (answer.issueKind != null)
                  TextField(
                    controller: issue,
                    decoration: const InputDecoration(
                      labelText: 'Co się dzieje?',
                      hintText: 'np. winda zepsuta, podjazd w budowie',
                    ),
                    onChanged: (v) {
                      answer.issueDescription = v;
                      widget.onChanged();
                    },
                  ),
              ],
            ),
            if (widget.onRemove != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: widget.onRemove,
                  icon: const KindSpotSymbol(Icons.delete_outline),
                  label: const Text('Usuń tę odpowiedź'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
    ),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.current, required this.total});
  final int current, total;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(liveRegion: true, child: Text('Pytanie $current z $total')),
        const SizedBox(height: 6),
        ExcludeSemantics(
          child: LinearProgressIndicator(value: current / total),
        ),
      ],
    ),
  );
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KindSpotSymbol(
                Icons.error_outline,
                color: scheme.onErrorContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title, text;
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: KindSpotSymbol(icon),
      title: Text(title),
      subtitle: Text(text),
    ),
  );
}
