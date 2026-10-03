import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/matching.dart';
import '../domain/models.dart';
import 'components.dart';
import 'place_details.dart';
import 'survey_entry.dart';

class KindSpotSavedPlacesScreen extends StatefulWidget {
  const KindSpotSavedPlacesScreen({
    super.key,
    required this.controller,
    this.onOpenSection,
    this.onOpenReviews,
    this.surveyBuilder,
  });
  final AppController controller;
  final SurveyBuilder? surveyBuilder;
  final VoidCallback? onOpenSection;
  final void Function(BuildContext context, Place place)? onOpenReviews;
  @override
  State<KindSpotSavedPlacesScreen> createState() =>
      _KindSpotSavedPlacesScreenState();
}

class _KindSpotSavedPlacesScreenState extends State<KindSpotSavedPlacesScreen> {
  String? message;
  String? failedId;
  Future<void> remove(String id) async {
    setState(() {
      message = null;
      failedId = null;
    });
    try {
      await widget.controller.setPlaceSaved(id, false);
      if (mounted) setState(() => message = 'Usunięto miejsce z zapisanych.');
    } catch (_) {
      if (mounted) {
        setState(() {
          failedId = id;
          message = 'Nie udało się usunąć miejsca. Poprzednia lista pozostaje bez zmian. Spróbuj ponownie.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final ids = widget.controller.profile.savedPlaceIds;
      return pageBody([
        const SectionTitle(
          'Zapisane miejsca',
          subtitle: 'Ostatnio zapisane na początku',
        ),
        demoNotice(),
        const SizedBox(height: 12),
        const Text(
          'Lokalne zapisy konta demo. Pokazujemy wszystkie miasta niezależnie od aktywnych filtrów. Dopasowanie uwzględnia bieżące filtry.',
        ),
        if (message != null)
          Semantics(
            liveRegion: true,
            child: Notice(
              message!,
              icon: failedId == null
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
            ),
          ),
        if (failedId != null)
          OutlinedButton(
            key: const ValueKey('saved-remove-retry'),
            onPressed: widget.controller.saving
                ? null
                : () => remove(failedId!),
            child: const Text('Ponów usunięcie'),
          ),
        if (ids.isEmpty)
          const Notice(
            'Nie masz zapisanych miejsc. Otwórz szczegóły miejsca na mapie lub liście i wybierz „Zapisz miejsce”.',
          ),
        for (final id in ids) _savedCard(context, id),
      ]);
    },
  );

  Widget _savedCard(BuildContext context, String id) {
    Place? place;
    for (final candidate in demoPlaces) {
      if (candidate.id == id) {
        place = candidate;
        break;
      }
    }
    final found = place;
    return Card(
      key: ValueKey('saved-$id'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (found == null) ...[
              const Text(
                'Miejsce niedostępne',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Nie ma danych tego miejsca w obecnym katalogu demo. Nie oznacza to dostępności ani zamknięcia miejsca.',
              ),
            ] else ...[
              Semantics(
                header: true,
                child: Text(
                  found.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('${found.address} · ${cityLabel(found.cityId)}'),
              const SizedBox(height: 8),
              StatusTag(
                evaluateDemoMatch(found, widget.controller.activeRules).status,
              ),
              if (found.issue != null)
                Notice(found.issue!, icon: Icons.warning_amber),
              Text(
                'Obserwacje: ${dateLabel(found.observedOn)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: ValueKey('saved-open-$id'),
                onPressed: () {
                  widget.onOpenSection?.call();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (routeContext) => PlaceDetailsScreen(
                        controller: widget.controller,
                        place: found,
                        surveyBuilder: widget.surveyBuilder,
                        onOpenReviews: widget.onOpenReviews == null
                            ? null
                            : () => widget.onOpenReviews!(routeContext, found),
                      ),
                    ),
                  );
                },
                child: Text('Otwórz szczegóły: ${found.name}'),
              ),
            ],
            OutlinedButton(
              key: ValueKey('saved-remove-$id'),
              onPressed: widget.controller.saving ? null : () => remove(id),
              child: Text(
                widget.controller.saving
                    ? 'Zapisywanie…'
                    : 'Usuń z zapisanych${found == null ? '' : ': ${found.name}'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
