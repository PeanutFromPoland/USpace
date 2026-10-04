import 'models.dart';

enum ReviewVote { agree, disagree }

enum ReviewReportReason { falseInformation, offensive, spam }

enum ReviewPublication { visible, held }

enum ReviewVerification { pending, accepted, disputed }

enum ReviewPoints { pending, systemRecorded, notAwarded }

class ReviewObservation {
  const ReviewObservation({
    required this.id,
    required this.featureId,
    required this.partLabel,
    required this.fact,
    required this.comment,
    this.agreements,
    this.disagreements,
  });
  final String id, featureId, partLabel, comment;
  final FeatureFact fact;
  final int? agreements, disagreements;
}

class DemoReview {
  const DemoReview({
    required this.id,
    required this.placeId,
    required this.authorId,
    required this.authorName,
    required this.visitedOn,
    required this.cityStatus,
    required this.observations,
    this.publication = ReviewPublication.visible,
    this.verification = ReviewVerification.pending,
    this.points = ReviewPoints.pending,
    this.holdReason,
  });
  final String id, placeId, authorId, authorName, visitedOn, cityStatus;
  final List<ReviewObservation> observations;
  final ReviewPublication publication;
  final ReviewVerification verification;
  final ReviewPoints points;
  final String? holdReason;
}

String reportReasonLabel(ReviewReportReason reason) => switch (reason) {
  ReviewReportReason.falseInformation => 'Fałszywa informacja',
  ReviewReportReason.offensive => 'Treść obraźliwa',
  ReviewReportReason.spam => 'Spam',
};
String publicationLabel(ReviewPublication value) => switch (value) {
  ReviewPublication.visible => 'Widoczna',
  ReviewPublication.held => 'Wstrzymana',
};
String verificationLabel(ReviewVerification value) => switch (value) {
  ReviewVerification.pending => 'Oczekuje na sprawdzenie',
  ReviewVerification.accepted => 'Zaakceptowana przez system — przykład',
  ReviewVerification.disputed => 'Sprzeczne weryfikacje — przykład',
};
String reviewPointsLabel(ReviewPoints value) => switch (value) {
  ReviewPoints.pending => 'Oczekujące',
  ReviewPoints.systemRecorded => 'Odnotowane przez system — przykład',
  ReviewPoints.notAwarded => 'Nieprzyznane — przykład',
};

// Adds only the current local demo vote. Unknown source counts stay unknown.
(int?, int?) displayedVoteCounts(
  ReviewObservation observation,
  ReviewVote? vote,
) => (
  observation.agreements == null
      ? null
      : observation.agreements! + (vote == ReviewVote.agree ? 1 : 0),
  observation.disagreements == null
      ? null
      : observation.disagreements! + (vote == ReviewVote.disagree ? 1 : 0),
);
