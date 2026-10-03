import '../domain/models.dart';
import '../domain/reviews.dart';
import 'catalog.dart';

// Small fictional excerpts, never the full source of Place.reviewCount/rating.
List<DemoReview> demoReviewsFor(Place place) {
  if (place.id == 'cafe') return const [];
  final entrance = place.parts.isEmpty
      ? 'Całe miejsce'
      : place.parts.first.name;
  return [
    DemoReview(
      id: '${place.id}-review-a',
      placeId: place.id,
      authorId: 'demo-author-a',
      authorName: 'Alicja · przykład',
      visitedOn: '2026-10-01',
      cityStatus: 'Miejscowy · przykład',
      verification: ReviewVerification.accepted,
      points: ReviewPoints.systemRecorded,
      observations: [
        ReviewObservation(
          id: '${place.id}-obs-a-entrance',
          featureId: 'step_free_entrance',
          partLabel: entrance,
          fact: const FeatureFact(
            'step_free_entrance',
            Presence.present,
            rating: 4,
          ),
          comment: 'Podczas przykładowej wizyty przejście było szerokie. Ocenę odnoszę tylko do wskazanego wejścia.',
          agreements: 8,
          disagreements: 2,
        ),
        ReviewObservation(
          id: '${place.id}-obs-a-loop',
          featureId: 'hearing_loop',
          partLabel: 'Punkt obsługi',
          fact: const FeatureFact('hearing_loop', Presence.unknown),
          comment: 'Nie mogłem sprawdzić działania pętli. Brak oceny nie oznacza braku funkcji.',
          agreements: null,
          disagreements: null,
        ),
      ],
    ),
    DemoReview(
      id: '${place.id}-review-b',
      placeId: place.id,
      authorId: 'demo-author-b',
      authorName: 'Bartek · przykład',
      visitedOn: '2026-10-02',
      cityStatus: 'Turysta · przykład',
      verification: ReviewVerification.disputed,
      observations: [
        ReviewObservation(
          id: '${place.id}-obs-b-ramp',
          featureId: 'ramp',
          partLabel: entrance,
          fact: const FeatureFact(
            'ramp',
            Presence.present,
            rating: 3,
            state: OperationalState.limited,
          ),
          comment: 'W przykładowej obserwacji podjazd wymagał pomocy. Nie jest to ocena wszystkich wejść.',
          agreements: 3,
          disagreements: 1,
        ),
        ReviewObservation(
          id: '${place.id}-obs-b-rest',
          featureId: 'rest',
          partLabel: 'Całe miejsce',
          fact: const FeatureFact('rest', Presence.absent),
          comment: 'W trakcie przykładowej wizyty nie znalazłem miejsca do odpoczynku.',
          agreements: 2,
          disagreements: 0,
        ),
      ],
    ),
    DemoReview(
      id: '${place.id}-review-own',
      placeId: place.id,
      authorId: demoUserId,
      authorName: demoAccountName,
      visitedOn: '2026-10-03',
      cityStatus: 'Turysta · przykład',
      observations: [
        ReviewObservation(
          id: '${place.id}-obs-own',
          featureId: 'quiet',
          partLabel: 'Całe miejsce',
          fact: const FeatureFact('quiet', Presence.present, rating: 4),
          comment: 'To przykładowa własna recenzja konta testowego. Nie powstała przez formularz.',
          agreements: 0,
          disagreements: 0,
        ),
      ],
    ),
    DemoReview(
      id: '${place.id}-review-held',
      placeId: place.id,
      authorId: demoUserId,
      authorName: demoAccountName,
      visitedOn: '2026-10-03',
      cityStatus: 'Turysta · przykład',
      publication: ReviewPublication.held,
      points: ReviewPoints.notAwarded,
      holdReason: 'Przykładowa treść oczekuje na moderację. Nie została wysłana do żadnego systemu.',
      observations: const [],
    ),
  ];
}
