import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../domain/models.dart';
import 'reviews.dart';

void openDemoReviews(
  BuildContext context,
  Place place,
  AppController controller,
) {
  final revision = controller.sessionRevision;
  Navigator.pushReplacement<void, void>(
    context,
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '/reviews/${place.id}'),
      builder: (_) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isDemoSignedIn ||
              controller.sessionRevision != revision) {
            return Scaffold(
              appBar: AppBar(title: const Text('Konto demo zamknięte')),
              body: const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Otwórz konto demo, aby odczytać recenzje.'),
              ),
            );
          }
          return ReviewsScreen(
            place: place,
            reportedIds: controller.profile.reviewReports.keys.toSet(),
            onReport: (id, reason) {
              if (controller.sessionRevision != revision) {
                throw StateError('Sesja zmieniła się.');
              }
              return controller.reportDemoReview(id, reason);
            },
          );
        },
      ),
    ),
  );
}
