import 'package:flutter/material.dart';

import 'components.dart';

class FilterHelpScreen extends StatelessWidget {
  const FilterHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: adaptiveAppBar(context, 'Jak działają filtry'),
    body: pageBody([
      const SectionTitle('Wybierz, co jest ważne'),
      const Text(
        'Warunek konieczny: miejsce musi spełniać wymaganie, a dla ocenialnej cechy także wskazany próg. Preferencja: pomaga ustalić dopasowanie, bez progu oceny. Bez znaczenia: cecha nie wpływa na wybór.',
      ),
      const SectionTitle('Brak danych to osobny stan'),
      const Text(
        'Brak funkcji oznacza 0, a brak informacji nie ma oceny liczbowej. „Uwzględnij miejsca z brakami danych” pozwala pokazać niepewne wyniki. Znane niespełnienie wymagań nadal wyklucza miejsce.',
      ),
      const SectionTitle('Zapisz filtr'),
      const Text(
        'Nadaj nazwę zestawowi, aby móc wybrać go później. Zapisane filtry pozostają po ponownym uruchomieniu. Sam zapis nie zmienia wyników — wybierz następnie Użyj filtru.',
      ),
      const SectionTitle('Użyj filtru'),
      const Text(
        'Pokaż wyniki z bieżącymi wyborami bez tworzenia zapisanego zestawu. Zmiana działa w tej sesji; inne ekrany i wybór miasta jej nie kasują. Nowe uruchomienie wyczyści aktywny filtr.',
      ),
      const SectionTitle('Presety i kolejność'),
      const Text(
        'Szybki wybór zastępuje wybory w formularzu. Możesz je poprawić. Kolejność miejsc ustawiasz na mapie/liście: średnia ocen, potem liczba recenzji albo sama liczba recenzji. Dane miejsc są przykładowe.',
      ),
    ]),
  );
}
