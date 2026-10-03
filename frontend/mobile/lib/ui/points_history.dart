import 'package:flutter/material.dart';

import 'components.dart';
import '../app_controller.dart';

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key, this.controller});
  final AppController? controller;
  @override
  Widget build(BuildContext context) {
    final account = controller;
    if (account != null) {
      return AnimatedBuilder(
        animation: account,
        builder: (context, _) => Scaffold(
          appBar: adaptiveAppBar(context, 'Saldo i historia punktów'),
          body: pageBody([
            SectionTitle('Saldo testowe: ${account.shop.balance} pkt'),
            const Text(
              '1000 pkt na start sesji. Saldo i zakupy odnawiają się przy nowym uruchomieniu.',
            ),
            const SectionTitle('Historia punktów tej sesji'),
            const Text('+1000 pkt · początek sesji testowej'),
            for (final purchase in account.shop.purchases)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '-${purchase.reward.exampleCost} pkt · ${purchase.reward.name} · ${purchase.id}',
                  ),
                ),
              ),
          ]),
        ),
      );
    }
    return Scaffold(
      appBar: adaptiveAppBar(context, 'Saldo i historia punktów'),
      body: pageBody([
        const SectionTitle('Saldo niedostępne'),
        const Notice(
          'System punktów nie jest podłączony. Nie znamy potwierdzonego salda; brak danych nie oznacza zera punktów.',
        ),
        const SectionTitle('Historia niedostępna'),
        const Text(
          'Nie pobrano operacji z systemu. To nie jest potwierdzenie pustej historii. Dane demonstracyjne, głosy i recenzje nie przyznają punktów.',
        ),
        const SectionTitle('Jak odczytasz historię?'),
        const Text(
          'Po podłączeniu systemu każda operacja pokaże datę, kwotę i powód. Działania oczekujące będą oddzielone od punktów potwierdzonych i dostępnych do wydania. Nieznana kwota pozostanie opisana statusem.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Powiązana recenzja lub nagroda będzie dostępna, gdy system zwróci odnośnik. Brak powiązanej treści nie usunie opisu operacji.',
        ),
      ]),
    );
  }
}
