import 'package:flutter/material.dart';

import '../app_controller.dart';
import 'components.dart';

class CustomizationScreen extends StatelessWidget {
  const CustomizationScreen({
    super.key,
    required this.category,
    required this.controller,
  });
  final String category;
  final AppController controller;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, category),
    body: pageBody([
      SectionTitle(category),
      const Text(
        'Personalizacja konta jest w przygotowaniu. Tutaj wybierzesz wygląd z dostępnych elementów oraz nagród zdobytych w sklepie.',
      ),
      if (controller.shop.purchases.any(
        (p) => p.reward.id == 'explorer' || p.reward.id == 'frame',
      )) ...[
        const SectionTitle('Kupione elementy w tej sesji'),
        for (final purchase in controller.shop.purchases.where(
          (p) => p.reward.id == 'explorer' || p.reward.id == 'frame',
        ))
          Text(purchase.reward.name),
        const Text(
          'Zakup jest zapamiętany w tej sesji. Nakładanie elementów na profil przygotujemy w kolejnym etapie.',
        ),
      ],
    ]),
  );
}
