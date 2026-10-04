import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/demo_reviews.dart';
import '../domain/models.dart';
import '../domain/reviews.dart';
import 'components.dart';
import 'graphics.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    required this.place,
    this.userId = demoUserId,
    this.reviews,
    this.votes = const {},
    this.reportedIds = const {},
    this.onVote,
    this.onReport,
    this.allowVoteChanges = false,
  });
  final Place place;
  final String userId;
  final List<DemoReview>? reviews;
  final Map<String, ReviewVote> votes;
  final Set<String> reportedIds;
  final Future<void> Function(String observationId, ReviewVote? vote)? onVote;
  final Future<void> Function(String reviewId, ReviewReportReason reason)?
  onReport;
  final bool allowVoteChanges;
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _messages = <String, String>{};
  final _reasons = <String, ReviewReportReason>{};
  late final Map<String, ReviewVote> _votes = Map.of(widget.votes);
  late final Set<String> _reported = Set.of(widget.reportedIds);
  String? _busy;
  bool _dialogOpen = false;

  Future<void> _vote(
    DemoReview review,
    ReviewObservation observation,
    ReviewVote requested,
  ) async {
    if (_dialogOpen ||
        _busy != null ||
        review.authorId == widget.userId ||
        widget.onVote == null) {
      return;
    }
    final old = _votes[observation.id];
    if (old != null && !widget.allowVoteChanges) return;
    final next = old == requested ? null : requested;
    setState(() {
      _busy = observation.id;
      _messages.remove(observation.id);
    });
    try {
      await widget.onVote!(observation.id, next);
      if (!mounted) return;
      setState(() {
        if (next == null) {
          _votes.remove(observation.id);
        } else {
          _votes[observation.id] = next;
        }
        _messages[observation.id] = next == null
            ? 'Cofnięto lokalny głos demo. Bez punktów i skutków moderacji.'
            : 'Zapisano lokalny głos demo. Bez punktów i skutków moderacji.';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages[observation.id] = 'Nie udało się zapisać głosu. Poprzedni wybór pozostaje. Spróbuj ponownie tym samym przyciskiem.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = null;
        });
      }
    }
  }

  Future<void> _report(DemoReview review) async {
    if (_dialogOpen ||
        _busy != null ||
        widget.onReport == null ||
        _reported.contains(review.id)) {
      return;
    }
    _dialogOpen = true;
    var reason = _reasons[review.id] ?? ReviewReportReason.falseInformation;
    final chosen = await showDialog<ReviewReportReason>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          scrollable: true,
          title: const Text('Zgłoszenie demo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zgłoszenie zapisze się tylko na tym urządzeniu. Nie trafi do moderatora i nie ukryje recenzji.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReviewReportReason>(
                initialValue: reason,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Powód zgłoszenia',
                ),
                items: [
                  for (final item in ReviewReportReason.values)
                    DropdownMenuItem(
                      value: item,
                      child: Text(reportReasonLabel(item)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    update(() {
                      reason = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj'),
            ),
            FilledButton(
              key: const ValueKey('review-report-confirm'),
              onPressed: () => Navigator.pop(context, reason),
              child: const Text('Zapisz zgłoszenie demo'),
            ),
          ],
        ),
      ),
    );
    _dialogOpen = false;
    if (chosen == null || !mounted) return;
    _reasons[review.id] = chosen;
    setState(() {
      _busy = review.id;
      _messages.remove(review.id);
    });
    try {
      await widget.onReport!(review.id, chosen);
      if (mounted) {
        setState(() {
          _reported.add(review.id);
          _messages[review.id] = 'Zapisano zgłoszenie tylko w demo. Recenzja pozostaje bez zmian; nie wysłano do moderacji.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages[review.id] = 'Nie udało się zapisać zgłoszenia. Wybrany powód zachowano. Spróbuj ponownie.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = null;
        });
      }
    }
  }

  Widget _message(String id) => _messages[id] == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(liveRegion: true, child: Notice(_messages[id]!)),
        );

  @override
  Widget build(BuildContext context) {
    final reviews = (widget.reviews ?? demoReviewsFor(widget.place))
        .where(
          (review) =>
              review.placeId == widget.place.id &&
              (review.publication == ReviewPublication.visible ||
                  review.authorId == widget.userId),
        )
        .toList();
    return Scaffold(
      appBar: adaptiveAppBar(context, 'Recenzje miejsca'),
      body: pageBody([
        SectionTitle(widget.place.name),
        const Notice(
          'Recenzje, autorzy, statusy i liczniki są fikcyjnymi przykładami. To wybrane fragmenty, nie wszystkie recenzje użyte w przykładowej średniej miejsca. Głos i zgłoszenie nie przyznają punktów.',
        ),
        const SizedBox(height: 12),
        const Notice(
          'Ankietę i dodawanie recenzji przygotowuje inna osoba. W tym demo odczytujesz gotowe przykłady.',
        ),
        if (reviews.isEmpty)
          const KindSpotGraphic('illustration_empty_reviews', height: 130),
        if (reviews.isEmpty)
          const SectionTitle(
            'Brak przykładowych recenzji',
            subtitle: 'Brak recenzji nie potwierdza dostępności miejsca.',
          ),
        for (final review in reviews) _review(context, review),
      ]),
    );
  }

  Widget _review(BuildContext context, DemoReview review) {
    final own = review.authorId == widget.userId;
    return Card(
      key: ValueKey(review.id),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                review.authorName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              '${review.cityStatus} · Wizyta ${dateLabel(review.visitedOn)}',
            ),
            Text('Publikacja: ${publicationLabel(review.publication)}'),
            Text('Sprawdzanie: ${verificationLabel(review.verification)}'),
            Text('Punkty: ${reviewPointsLabel(review.points)}'),
            if (review.publication == ReviewPublication.held)
              Notice(review.holdReason ?? 'Treść wstrzymana — przykład.'),
            if (own)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Notice(
                  'Własnej recenzji nie można weryfikować. Brak wiedzy nie wymaga głosu.',
                ),
              ),
            for (final observation in review.observations)
              _observation(context, review, observation),
            if (!own && review.publication == ReviewPublication.visible)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: OutlinedButton(
                  key: ValueKey('report-${review.id}'),
                  onPressed:
                      _busy != null ||
                          widget.onReport == null ||
                          _reported.contains(review.id)
                      ? null
                      : () => _report(review),
                  child: Text(
                    _reported.contains(review.id)
                        ? 'Zgłoszone lokalnie w demo'
                        : _busy == review.id
                        ? 'Zapisywanie…'
                        : 'Zgłoś recenzję w demo',
                  ),
                ),
              ),
            if (!own && widget.onReport == null)
              const Text('Zgłaszanie jest niedostępne w tym widoku.'),
            _message(review.id),
          ],
        ),
      ),
    );
  }

  Widget _observation(
    BuildContext context,
    DemoReview review,
    ReviewObservation observation,
  ) {
    final name = featureById(observation.featureId).label;
    final selected = _votes[observation.id];
    final own = review.authorId == widget.userId;
    final (agree, disagree) = displayedVoteCounts(observation, selected);
    final fact = observation.fact;
    final value = fact.presence == Presence.unknown
        ? 'Nie mogłem sprawdzić · bez oceny'
        : '${presenceLabel(fact.presence)}${fact.presence == Presence.present && fact.rating != null ? ' · ${fact.rating} / 5' : ''}';
    return Padding(
      key: ValueKey(observation.id),
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              '$name · ${observation.partLabel}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(value),
          if (fact.state != null) Text(stateLabel(fact.state!)),
          Text(observation.comment),
          Text(
            'Zgadzam się: ${agree ?? 'brak danych'} · Nie zgadzam się: ${disagree ?? 'brak danych'}',
          ),
          if (!own) ...[
            const SizedBox(height: 8),
            for (final vote in ReviewVote.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  selected: selected == vote,
                  label:
                      '${vote == ReviewVote.agree ? 'Zgadzam się' : 'Nie zgadzam się'}: $name, ${observation.partLabel}',
                  child: OutlinedButton(
                    key: ValueKey('${observation.id}-${vote.name}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed:
                        _busy != null ||
                            widget.onVote == null ||
                            (selected != null && !widget.allowVoteChanges)
                        ? null
                        : () => _vote(review, observation, vote),
                    child: Text(
                      '${selected == vote ? 'Wybrano: ' : ''}${vote == ReviewVote.agree ? 'Zgadzam się' : 'Nie zgadzam się'}',
                    ),
                  ),
                ),
              ),
            if (widget.onVote == null)
              const Text('Głosowanie jest niedostępne w tym widoku.'),
          ],
          if (_busy == observation.id)
            Semantics(liveRegion: true, child: Text('Zapisywanie głosu…')),
          _message(observation.id),
        ],
      ),
    );
  }
}
