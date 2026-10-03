import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../data/catalog.dart';
import '../domain/matching.dart';
import '../domain/models.dart';
import 'components.dart';

class PlaceDetailsScreen extends StatelessWidget {
  const PlaceDetailsScreen({
    super.key,
    required this.controller,
    required this.place,
  });
  final AppController controller;
  final Place place;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Szczegóły miejsca')),
      body: pageBody([
        Text(place.category, style: Theme.of(context).textTheme.labelLarge),
        Text(place.name, style: Theme.of(context).textTheme.headlineLarge),
        Text(place.address),
        const SizedBox(height: 16),
        demoNotice(),
        const SizedBox(height: 16),
        Text(place.description),
        const SizedBox(height: 16),
        StatusTag(evaluateDemoMatch(place, controller.profile.rules).status),
        if (place.issue != null)
          Notice(place.issue!, icon: Icons.warning_amber),
        const SectionTitle('Wejścia i części miejsca'),
        if (place.parts.isEmpty)
          const Text('Brak informacji o poszczególnych wejściach.'),
        for (final part in place.parts)
          ListTile(
            leading: const Icon(Icons.door_front_door_outlined),
            title: Text(part.name),
          ),
        const SectionTitle('Informacje o dostępności'),
        Text(
          'Obserwacje z ${dateLabel(place.observedOn)}. Warunki mogą się zmienić.',
        ),
        for (final feature in features)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    presenceLabel(
                      place.fact(feature.id)?.presence ?? Presence.unknown,
                    ),
                  ),
                  if (place.fact(feature.id)?.state case final state?)
                    Text(stateLabel(state)),
                  if (place.fact(feature.id)?.rating case final rating?)
                    Text(
                      'Ocena: $rating / 5 · ${feature.ratingLabels[rating - 1]}',
                    ),
                  if (place.fact(feature.id)?.note case final note?
                      when note.isNotEmpty)
                    Text(note),
                ],
              ),
            ),
          ),
        const SectionTitle('Recenzje'),
        const Notice(
          'Ankieta, dodawanie recenzji i weryfikowanie obserwacji zostaną przygotowane w późniejszym etapie.',
        ),
      ]),
    ),
  );
}
