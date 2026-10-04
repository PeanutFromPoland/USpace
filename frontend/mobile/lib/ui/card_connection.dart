import 'package:flutter/material.dart';

import '../data/catalog.dart';
import 'components.dart';

class CardConnectionScreen extends StatefulWidget {
  const CardConnectionScreen({super.key, required this.cityId});
  final String cityId;
  @override
  State<CardConnectionScreen> createState() => _CardConnectionScreenState();
}

class _CardConnectionScreenState extends State<CardConnectionScreen> {
  String scenario = 'none';
  static const scenarios = {
    'none': (
      'Brak połączenia',
      'Bez potwierdzonej karty dla miasta konto ma status Turysta.',
    ),
    'checking': (
      'Sprawdzanie',
      'Przykład: trwa sprawdzanie uprawnień przez operatora. Nie potwierdzono statusu Miejscowy.',
    ),
    'rejected': (
      'Odrzucone',
      'Przykład: operator nie potwierdził uprawnień. Numer karty sam w sobie nie jest potwierdzeniem.',
    ),
    'expired': (
      'Wygasło',
      'Przykład: potrzebne jest ponowne potwierdzenie przez operatora. Nie zakładamy dalszego obowiązywania uprawnień.',
    ),
    'error': (
      'Błąd odczytu',
      'Przykład: nie udało się odczytać statusu. Nie zmieniamy ostatniego potwierdzonego stanu.',
    ),
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'Karta miejska'),
    body: pageBody([
      SectionTitle('Karta · ${cityLabel(widget.cityId)}'),
      const Notice(
        'Operator kart nie jest podłączony. Nie pobieramy numeru prawdziwej karty. Demonstracja nie łączy karty ani nie potwierdza uprawnień.',
      ),
      const SizedBox(height: 16),
      const Text('Aktualny stan konta demo: brak połączenia, Turysta.'),
      const SectionTitle('Podgląd komunikatów — przykład'),
      const Text('Wybór zmienia tylko przykład komunikatu; nie zmienia konta.'),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: scenario,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Przykładowy stan połączenia karty',
        ),
        items: [
          for (final entry in scenarios.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value.$1)),
        ],
        onChanged: (value) {
          if (value != null) setState(() => scenario = value);
        },
      ),
      const SizedBox(height: 16),
      Semantics(liveRegion: true, child: Notice(scenarios[scenario]!.$2)),
      const SectionTitle('Potwierdzenie statusu'),
      const Text(
        'Status dla konkretnego miasta musi potwierdzić operator. Waga recenzji Turysty pozostaje do ustalenia. Nie zmniejszamy punktów na podstawie tej etykiety.',
      ),
    ]),
  );
}
