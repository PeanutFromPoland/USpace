# KindSpot — CP-07: przekazanie modułu ankiety Flutter

Stan 2026-10-03: ankieta i dodawanie recenzji pozostają odłożone na wyraźne polecenie użytkownika. Formularz przygotowuje inna osoba we Flutterze. Przygotowano tylko punkt włączenia modułu; nie jest to ukończenie funkcjonalnej ankiety ani odbiór WCAG. API nie jest przewidziane na potrzeby PoC.

## Punkt włączenia

Plik `frontend/mobile/lib/ui/survey_entry.dart` udostępnia:

```dart
typedef SurveyBuilder = Widget Function(BuildContext context, Place place);

SurveyEntry(place: place) // Trwały status i wyłączona akcja bez modułu.
SurveyEntry(
  place: place,
  builder: (context, selectedPlace) => PreparedSurveyScreen(
    place: selectedPlace,
  ),
)
```

`PreparedSurveyScreen` jest nazwą przykładową, nie istniejącą implementacją. Builder otrzymuje wybrane miejsce z katalogu aplikacji. Nie narzuca modelu odpowiedzi, payloadu ani schematu pytań. Jeśli moduł potrzebuje repozytorium/szkiców, autor przekazuje je przez domknięcie buildera, po uzgodnieniu ich interfejsów.

Wejście otwiera ekran przez `MaterialPageRoute<void>` o nazwie `/survey/{place.id}`. Moduł zwraca kompletny ekran, np. `Scaffold`, i korzysta z nadrzędnego `MaterialApp`, motywu, lokalizacji `pl`, skali tekstu oraz ustawienia ograniczenia animacji. Nie dodaje osobnego `MaterialApp`. Powrót kończy trasę i przywraca punkt wejścia. Ponowna aktywacja punktu wejścia jest zablokowana podczas otwartej trasy. Sam punkt wejścia nie zapisuje szkicu, nie publikuje recenzji i nie nalicza punktów; zakończenie trasy nie jest potwierdzeniem wysłania.

Na PoC builder pozostaje niepodany. Przy braku modułu tekst jawnie informuje „Ankieta w przygotowaniu” oraz „Dodawanie recenzji jest teraz niedostępne”; przycisk „Otwórz ankietę” jest wyłączony. Nie powstaje pusta trasa ani formularz zastępczy.

## Materiały i wymagania dla autora formularza

Źródła nadrzędne: `frontend/docs/Teoria Aplikacji.md`, `frontend/docs/use-cases.md` (UC-05–07) i `frontend/docs/KindSpot-CP02-WCAG.md`. Pytania, opisy skali, przykład uzasadnienia i kolejność wymagają przekazania i sprawdzenia z aktualnymi źródłami. Nie odtwarzamy brakujących pytań z katalogu cech.

- Odpowiedzi 1–5, brak funkcji=0 oraz niewiedza bez oceny jako „Nie mogłem sprawdzić” pozostają odrębne. Ocena 3 nie oznacza braku zdania. Istnienie cechy i stan działania nie są wzajemnie zastępowalne.
- Data wizyty domyślnie bieżąca, z możliwością zmiany; godzina opcjonalna i wpisywana samodzielnie. Nie wymagać godziny ani automatycznie udowodnionej wizyty.
- Rozwijanie szczegółów nie traci odpowiedzi; szkic przy błędzie jest zachowany. Zachowanie po cofnięciu oraz formularza z samą niewiedzą nadal wymaga decyzji w DO-USTALENIA.md. Nie zakładać reguły publikacji.
- Brak API oznacza jawny status niedostępności publikacji albo oddzielnie uzgodnioną symulację; nie udawać sukcesu zapisu po zwykłym powrocie z formularza. Publikacja, weryfikacja i punkty mają odrębne statusy. Żadne działanie formularza nie przyznaje prawdziwych punktów w kliencie.
- Nazwy pól i skali zawierają kontekst konkretnej cechy/wejścia; widoczny fokus, logiczna kolejność klawiatury/czytnika, obsługa bez przeciągania i bez wymagania mówienia. Tekst/błędy nie polegają wyłącznie na kolorze. Cele dotykowe projektu co najmniej 48×48 jednostek logicznych.
- Duży tekst 200%, wąski ekran, orientacja i klawiatura nie mogą zasłaniać dostępnych działań. Błąd jest trwały, opisowy, wskazuje pole lub operację i sposób poprawy; ponowienie zachowuje odpowiedzi. Zmiany stanu wymagają komunikatu semantycznego.
- Ocenie podlegają m.in. 1.3.1, 1.4.1/3/4/10/11, 2.1.1/2, 2.4.2/3/6/7/11, 2.5.1/3/7/8, 3.3.1/2/3/7 i 4.1.2/3 zgodnie z pełną macierzą; ta lista nie zastępuje macierzy 55 kryteriów. Testy urządzenia/czytnika oraz z użytkownikami pozostają konieczne. Końcowa zmiana grafiki wymaga regresji.

## Weryfikacja punktu wejścia

`flutter test --concurrency=1 test/cp07_survey_entry_test.dart`: 4 testy przeszły. Obejmują brak modułu i brak trasy, przekazanie poprawnego obiektu miejsca do wstrzykniętego ekranu oraz powrót, trwałą semantyczną informację na ekranie 320 px przy skali tekstu 200%. Nie uruchamiano emulatora, nie publikowano formularza i nie testowano rzeczywistej ankiety. Agent główny włączył opcjonalny SurveyBuilder przez USpaceApp oraz ekrany mapy/listy, zapisanych miejsc i szczegółów. Dodatkowy test prowadzi przez rzeczywisty USpaceApp → lista → szczegóły → przekazany moduł, sprawdza tożsamość Place, dokładnie jeden MaterialApp i powrót systemowy do szczegółów/listy. Zapis istniejącej sesji pozostaje niezmieniony, konto otwarte i potrzeby prywatne; powrót nie publikuje recenzji. Regresja całego APK należy do etapu scalania przez agenta głównego.
