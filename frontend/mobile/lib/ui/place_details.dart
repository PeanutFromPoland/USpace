import 'package:flutter/material.dart';

import 'graphics.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/matching.dart';
import '../domain/models.dart';
import 'components.dart';
import 'survey_entry.dart';

class PlaceDetailsScreen extends StatefulWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.controller,
    required this.place,
    this.onOpenReviews,
    this.surveyBuilder,
  });
  final AppController controller;
  final Place place;
  final VoidCallback? onOpenReviews;
  final SurveyBuilder? surveyBuilder;
  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  String? saveMessage;
  bool saveFailed = false;

  Future<void> save() async {
    final saved = widget.controller.isPlaceSaved(widget.place.id);
    setState(() {
      saveMessage = null;
      saveFailed = false;
    });
    try {
      await widget.controller.setPlaceSaved(widget.place.id, !saved);
      if (mounted) {
        setState(
          () => saveMessage = saved
              ? 'Usunięto miejsce z zapisanych.'
              : 'Zapisano miejsce na tym urządzeniu.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          saveFailed = true;
          saveMessage = 'Nie udało się zmienić zapisanych miejsc. Poprzedni stan pozostaje bez zmian. Spróbuj ponownie.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final place = widget.place;
      final saved = widget.controller.isPlaceSaved(place.id);
      final match = evaluateDemoMatch(place, widget.controller.activeRules);
      return Scaffold(
        appBar: adaptiveAppBar(context, 'Szczegóły miejsca'),
        body: pageBody([
          Text(place.category, style: Theme.of(context).textTheme.labelLarge),
          Semantics(
            header: true,
            child: Text(
              place.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Text('${place.address} · ${cityLabel(place.cityId)}'),
          const SizedBox(height: 16),
          StatusTag(match.status),
          for (final id in match.reasons)
            Text('Wymaga uwagi: ${featureById(id).label}'),
          const SizedBox(height: 12),
          Text(place.description),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
          Semantics(
            label: saved
                ? 'Miejsce zapisane. Usuń z zapisanych'
                : 'Miejsce niezapisane. Zapisz miejsce',
            excludeSemantics: true,
            button: true,
            enabled: !widget.controller.saving,
            onTap: widget.controller.saving ? null : save,
            child: FilledButton.icon(
              key: const ValueKey('place-save'),
              onPressed: widget.controller.saving ? null : save,
              icon: KindSpotSymbol(
                saved
                    ? Icons.bookmark_remove_outlined
                    : Icons.bookmark_add_outlined,
              ),
              label: Text(
                widget.controller.saving
                    ? 'Zapisywanie…'
                    : saved
                    ? 'Usuń z zapisanych'
                    : 'Zapisz miejsce',
              ),
            ),
          ),
          if (saveMessage != null)
            Semantics(
              liveRegion: true,
              child: Notice(
                saveMessage!,
                icon: saveFailed
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
              ),
            ),
          if (saveFailed)
            OutlinedButton(
              key: const ValueKey('place-save-retry'),
              onPressed: widget.controller.saving ? null : save,
              child: const Text('Ponów zmianę zapisanych'),
            ),
          const Text(
            'Lista zapisanych jest lokalna dla konta demo. Nie jest synchronizowana z API.',
          ),
          const SectionTitle('Utrudnienia i aktualność'),
          if (place.issue != null)
            Notice(place.issue!, icon: Icons.warning_amber)
          else
            const Text(
              'Brak zgłoszonych utrudnień w danych demo. Nie potwierdza to braku utrudnień na miejscu.',
            ),
          Text(
            'Obserwacje z ${dateLabel(place.observedOn)}. Warunki mogą się zmienić.',
          ),
          const SectionTitle('Wejścia i części miejsca'),
          if (place.parts.isEmpty)
            const Text('Brak informacji o poszczególnych wejściach.'),
          for (final part in place.parts)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        part.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Text(
                      'Brak odrębnych obserwacji dostępności dla tego wejścia. Cechy poniżej dotyczą miejsca ogólnie.',
                    ),
                  ],
                ),
              ),
            ),
          const SectionTitle('Informacje o dostępności'),
          const Text(
            'Brak danych nie oznacza dostępności. Ocena ogólna nie zastępuje informacji o konkretnej cesze.',
          ),
          for (final feature in features)
            _FeatureCard(feature: feature, fact: place.fact(feature.id)),
          const SectionTitle('Recenzje'),
          Text(
            place.aggregateRating == null
                ? 'Średnia ocen: brak danych.'
                : 'Przykładowa średnia ocen: ${place.aggregateRating!.toStringAsFixed(1)} / 5.',
          ),
          Text(
            place.reviewCount == null
                ? 'Liczba recenzji: brak danych.'
                : 'Przykładowa liczba recenzji: ${place.reviewCount}.',
          ),
          if (widget.onOpenReviews != null)
            OutlinedButton(
              key: const ValueKey('place-reviews'),
              onPressed: widget.onOpenReviews,
              child: const Text('Przejdź do recenzji'),
            )
          else
            const Notice(
              'Lista recenzji zostanie udostępniona w zakresie demonstracyjnym. Ankieta i dodawanie recenzji pozostają odłożone.',
            ),
          SurveyEntry(place: place, builder: widget.surveyBuilder),
        ]),
      );
    },
  );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.fact});
  final FeatureDefinition feature;
  final FeatureFact? fact;
  @override
  Widget build(BuildContext context) {
    final presence = fact?.presence ?? Presence.unknown;
    final entries = <String>[presenceLabel(presence)];
    if (presence == Presence.present) {
      if (feature.operational) {
        entries.add(stateLabel(fact?.state ?? OperationalState.unknown));
      }
      final rating = fact?.rating;
      if (feature.ratable) {
        entries.add(
          rating == null
              ? 'Ocena: brak danych.'
              : rating >= 1 && rating <= 5
              ? 'Ocena: $rating / 5 · ${feature.ratingLabels[rating - 1]}'
              : 'Ocena: brak poprawnych danych.',
        );
      }
    } else if (presence == Presence.absent) {
      entries.add('Brak funkcji · ocena 0 / 5.');
    } else {
      entries.add('Brak potwierdzonej oceny liczbowej.');
    }
    if (fact?.note case final note? when note.isNotEmpty) entries.add(note);
    return Semantics(
      container: true,
      label: '${feature.label}. ${entries.join(' ')}',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KindSpotGraphic(
                    'feature_${feature.id}',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final text in entries) Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
