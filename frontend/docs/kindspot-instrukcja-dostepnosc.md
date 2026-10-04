# KindSpot – instrukcja wdrożenia dostępności frontendu (dla agenta AI)

Wersja: 2, 2026-10-03. Zmiany względem wersji 1: dopasowanie do Fluttera, kontraktu v0.1 i przypadków użycia (logowanie, głosy przy cechach, tryb spokojny, ankieta).

## 0. Kontekst – przeczytaj najpierw

Budujesz frontend aplikacji mobilnej **KindSpot** we **Flutterze** (`frontend/`). Osoby z niepełnosprawnościami i ich bliscy oceniają w niej dostępność miejsc (restauracje, kina, urzędy, gabinety). Mapa korzysta z podkładu OpenStreetMap. Konto można połączyć z Kartą Miejską (np. Krakowską) w celu weryfikacji statusu w mieście (UC-02).

Przed pracą przeczytaj [kontrakt frontend–backend](KindSpot-kontrakt-frontend-backend-v0.1.md), [przypadki użycia](use-cases.md) (zwłaszcza UC-12) i [ankietę recenzji](KindSpot-ankieta-recenzji.md).

**Cel dostępności:** WCAG 2.2 poziom AA oraz testy z użytkownikami.

**Użytkownicy, dla których projektujesz:**
- osoby na wózku, z trudnościami w chodzeniu, które nie mogą korzystać ze schodów;
- osoby niewidome i słabowidzące, osoby z daltonizmem;
- osoby głuche i słabosłyszące (dla wielu z nich pierwszym językiem jest Polski Język Migowy, a polski jest drugim);
- osoby neuroróżnorodne: w spektrum autyzmu, z ADHD, z dysleksją, z niepełnosprawnością intelektualną;
- osoby źle znoszące hałas, tłum, intensywne światło;
- osoby z ograniczoną sprawnością rąk;
- opiekunowie, rodzice z wózkiem dziecięcym.

**Oznaczenia priorytetów:**
- **[KONIECZNE]** – wymóg WCAG 2.2 A/AA, wymóg prawny albo warunek działania głównej funkcji aplikacji. Nie pomijaj.
- **[ZALECANE]** – mocno poprawia dostępność. Wdrażaj, jeśli nie koliduje z KONIECZNYMI.
- **[OPCJONALNE]** – rozszerzenie na później.

**Kolejność:** zadania są ułożone od najprostszych (konfiguracja, tokeny, teksty) do najtrudniejszych (złożone funkcje, treści specjalistyczne, procesy z ludźmi). Realizuj je po kolei. Każde zadanie ma kryterium akceptacji. Zadanie jest skończone dopiero, gdy kryterium jest spełnione.

**Zasada nadrzędna:** gdy potrzeby różnych grup się wykluczają, pierwszeństwo mają potrzeby głównych odbiorców, czyli osób z niepełnosprawnościami (zasada „primary audience” z ISO 24495-1:2023, definicja 3.2).

---

## Poziom 0 – Decyzje przed kodem

Ustalone:

1. **Technologia frontendu:** Flutter (Dart). W tej instrukcji podane są odpowiedniki API Fluttera.
2. **Logowanie w PoC:** e-mail i hasło (kontrakt §2, UC-17). Karta Miejska nie służy do logowania.

Zapytaj zespół, nie zgaduj:

3. **Bibliotekę mapy:** np. `flutter_map` z kafelkami OSM. Sprawdź, czy znaczniki dają się opisać przez `Semantics`. Dostawca kafelków i atrybucja są osobnym uzgodnieniem (kontrakt §1).
4. **Czy aplikację wdraża miasto (podmiot publiczny).** Jeśli tak, dochodzą obowiązki prawne z poziomu 4 (deklaracja dostępności, tekst łatwy do czytania, Polski Język Migowy).
5. **Słownik pojęć:** jedna nazwa na jedną rzecz, np. zawsze „recenzja”, nigdy na zmianę „opinia” i „ocena”. Etykiety cech i potrzeb pochodzą z katalogu backendu (`GET /configuration`), nie z kodu.

---

## Poziom 1 – Najprostsze: tokeny, typografia, teksty

### 1.1 [KONIECZNE] Tokeny kolorów z kontrastem
- Pastelowe kolory marki (pomarańczowy, jasnoniebieski) stosuj **tylko jako tła** kart i sekcji.
- Tekst, ikony, obramowania pól i przyciski rób w ciemnych odcieniach.
- Wartości startowe (sprawdzone obliczeniem):

| Rola | Kolor | Na tle | Kontrast |
|---|---|---|---|
| Tekst podstawowy | `#1F2937` | `#FFE3C7` (pastel pomarańczowy) | 11,9:1 |
| Tekst podstawowy | `#1F2937` | `#DCEFFC` (pastel niebieski) | 12,4:1 |
| Przycisk główny (biały tekst) | tło `#B54708` | – | 5,4:1 |
| Przycisk drugorzędny (biały tekst) | tło `#1D5F8C` | – | 6,9:1 |
| ZAKAZ: biały tekst na `#FFB570` | – | – | 1,74:1 ❌ |
| ZAKAZ: biały tekst na `#9AD0F5` | – | – | 1,65:1 ❌ |

- Przygotuj osobne tokeny dla trybu jasnego i ciemnego. Każdą parę sprawdź.
- **Kryterium:** tekst ≥ 4,5:1, duży tekst (≥ 18,66 px pogrubiony albo ≥ 24 px) ≥ 3:1, ikony, obramowania pól i stany fokusu ≥ 3:1 względem sąsiednich kolorów. Podstawa: WCAG 1.4.3, 1.4.11.

### 1.2 [KONIECZNE] Typografia
- Krój bezszeryfowy, systemowy albo podobny (Arial, Calibri, Roboto, SF Pro). Jeden krój w całej aplikacji.
- Tekst podstawowy co najmniej 16 px / 16 sp. Interlinia około 1,5.
- Wyrównanie do lewej. Bez justowania.
- Bez kursywy w treści. Bez całych zdań wielkimi literami. Bez fontów skondensowanych.
- Nie dziel wyrazów przenoszeniem (wyłącz automatyczne dzielenie wyrazów).
- Ważne informacje wyróżniaj pogrubieniem, nie kolorem.
- Krótkie linie tekstu: maksymalnie około 60 znaków.
- „Fonty dla dyslektyków” (np. OpenDyslexic) nie są wymagane, bo nie mają mocnego potwierdzenia w badaniach. Zamiast nich zadbaj o odstępy.
- **Kryterium:** układ działa przy odstępach z WCAG 1.4.12: interlinia 1,5, odstęp akapitu 2× rozmiar czcionki, odstęp liter 0,12, odstęp słów 0,16. Nic nie ucina się i nie nachodzi na siebie.

### 1.3 [KONIECZNE] Skalowanie tekstu przez system
- Respektuj Dynamic Type (iOS) i rozmiar czcionki (Android). We Flutterze tekst skaluje się sam przez `MediaQuery.textScalerOf(context)`: nie ograniczaj go w dół i nie nadpisuj `textScaler` na stałe.
- Ustawienie `textScale` z `UiSettings` (kontrakt §3) mnoży skalę systemową, nie zastępuje jej.
- Żadnych sztywnych wysokości kontenerów z tekstem.
- **Kryterium:** przy tekście powiększonym do 200% cała treść i wszystkie funkcje są dostępne, bez ucinania i bez przewijania w dwóch kierunkach (WCAG 1.4.4, 1.4.10).

### 1.4 [KONIECZNE] Zasady pisania tekstów w interfejsie (prosty język)
Dotyczy wszystkich tekstów: przycisków, nagłówków, komunikatów błędów, formularzy, powiadomień, regulaminu punktów. Norma ISO 24495-1:2023 wprost zalicza komunikaty błędów, formularze i strony do „dokumentów”.

Stosuj:
1. **Najważniejsze najpierw.** Pierwsze zdanie mówi, co się stało albo co zrobić.
2. **Zdania krótkie:** w interfejsie maksymalnie 15 słów. Polskie wytyczne podają 10–15 (gov.pl) albo 15–20 słów (Urząd m.st. Warszawy). Jedna myśl w zdaniu.
3. **Szyk naturalny:** podmiot, orzeczenie, dopełnienie.
4. **Strona czynna.** Unikaj form na -no, -to i „się” („zostało ustalone”, „uznaje się”).
5. **Bez imiesłowów** na -ąc, -ący.
6. **Zwracaj się do użytkownika na „ty”.** O aplikacji lub zespole pisz „my”.
7. **Formy neutralne płciowo.** Zamiast „Dodałeś/Dodałaś recenzję” pisz „Recenzja dodana. Dziękujemy!”. Profil użytkownika nie powinien wymagać podawania płci tylko po to, żeby odmieniać teksty. Wyjątek zatwierdzony przez zespół 2026-10-03: etykieta „Nie mogłem sprawdzić” w ankiecie.
8. **Słowa znane i krótkie.** Zastępuj trudne prostymi („weryfikować” → „sprawdzać”, „aktualnie” → „teraz”). Słowa powyżej 4 sylab traktuj jako trudne.
9. **Bez metafor, idiomów, żartów językowych i masła maślanego** („w miesiącu maju” → „w maju”).
10. **Skróty:** unikaj. Jeśli są konieczne, rozwiń je przy pierwszym użyciu.
11. **Liczby cyframi** („3 recenzje”, nie „trzy recenzje”). Bez liczb rzymskich.
12. **Nagłówki krótkie, mogą mieć formę pytania. Wielka litera tylko na początku.**
13. **Wyliczenia zamiast ciągłego tekstu.**
14. **Tekst musi działać czytany na głos.** Według ISO czytelnikiem jest też ktoś, komu tekst czyta czytnik ekranu. Zamiast „★★★★☆” pisz „4 na 5”. Emoji nie może nieść znaczenia samodzielnie.
15. **Ton przyjazny, nie nakazowy.**

**Kryterium:** każdy nowy tekst przechodzi listę kontrolną z punktu 4.6. Narzędzia Jasnopis i Logios można użyć pomocniczo, ale ISO podkreśla, że liczy się to, czy czytelnik znajdzie, zrozumie i użyje informacji, a nie wynik formuły czytelności.

### 1.5 [KONIECZNE] Komunikaty błędów
- Mów, co jest nie tak i jak to naprawić. Np. „Wpisz numer karty. {formatHint}” (podpowiedź formatu z `configuration.cardTypes`).
- Komunikat jest przy polu, a czytnik ekranu go odczytuje. Błędy pól przychodzą z API jako `fieldErrors` z kodami; tekst po polsku tworzy frontend (kontrakt §2).
- **Kryterium:** WCAG 3.3.1, 3.3.3. Żaden błąd nie jest sygnalizowany samym kolorem.

### 1.6 [KONIECZNE] Nigdy sam kolor
- Status dostępności miejsca = kolor + kształt + tekst. Np.:
  - ✓ w kółku, napis „Dostępne”;
  - ◐ w trójkącie, napis „Częściowo”;
  - ✕ w kwadracie, napis „Niedostępne”.
- Dotyczy znaczników na mapie, ocen, filtrów, wykresów i stanów formularza.
- **Kryterium:** WCAG 1.4.1. Ekran w skali szarości nadal przekazuje wszystkie informacje.

### 1.7 [KONIECZNE] Ikona zawsze z tekstem
- Kafelki 16 potrzeb (UC-03), filtry, zakładki i przyciski mają widoczny podpis, nie tylko ikonę.
- Ten sam piktogram zawsze oznacza to samo pojęcie.
- **Kryterium:** każdy element interaktywny ma widoczną nazwę, a nazwa dostępności zawiera widoczny tekst (WCAG 2.5.3).

### 1.8 [KONIECZNE] Rozmiar celów dotykowych
- Minimum 44×44 pt (iOS) / 48×48 dp (Android). WCAG wymaga absolutnego minimum 24×24 px z odstępami.
- Dotyczy też ocen 1–5, opcji „0 – Brak funkcji” i „Nie mogłem sprawdzić”, lajków przy cechach i znaczników na mapie.
- We Flutterze zostaw `MaterialTapTargetSize.padded` (domyślne na telefonach).
- **Kryterium:** WCAG 2.5.8. Test `androidTapTargetGuideline` i `iOSTapTargetGuideline` (punkt 4.4) oraz Accessibility Scanner.

### 1.9 [ZALECANE] Paleta kategorii bezpieczna dla daltonistów
- Do kategorii i wykresów użyj palety Okabe–Ito: https://jfly.uni-koeln.de/color/
- Unikaj par czerwony–zielony jako jedynej różnicy.

---

## Poziom 2 – Komponenty

### 2.1 [KONIECZNE] Nazwy, role i stany wszystkich elementów
- Każdy element interaktywny ma nazwę, rolę i stan (np. „Filtr: wózek, zaznaczony”) – WCAG 4.1.2.
- Zdjęcia z treścią mają opis alternatywny. Elementy dekoracyjne są ukryte przed czytnikiem – WCAG 1.1.1.
- Grupuj powiązane elementy karty miejsca, żeby czytnik nie odczytywał ich po kawałku.
- Flutter: `Semantics(label:, value:, button:, selected:)` dla własnych kontrolek, `MergeSemantics` do grupowania, `ExcludeSemantics` dla dekoracji. Standardowe widżety Material (`FilledButton`, `RadioListTile`, `CheckboxListTile`, `TextField` z `InputDecoration.labelText`) mają semantykę wbudowaną.
- **Kryterium:** przejście każdego ekranu z TalkBack i VoiceOver bez elementów „bez nazwy”; test `labeledTapTargetGuideline` (punkt 4.4).

### 2.2 [KONIECZNE] Pytanie o cechę: odpowiedź i stan działania
Zgodnie z kontraktem (`Answer`), Teorią aplikacji (E) i [ankietą recenzji](KindSpot-ankieta-recenzji.md):
1. **Odpowiedź (wymagana):** 1–5 z etykietami cechy z katalogu (`ratingLabels`), **0 – Brak funkcji** (`absent`, `rating: 0`) albo **Nie mogłem sprawdzić** (`unknown`, `rating: null`). Cecha bez oceny jakości ma „Tak, jest” zamiast 1–5. Przy cechach otoczenia (hałas, tłum, światło) nie ma opcji „0 – Brak funkcji”.
2. **„Czy działa?” (opcjonalnie)**, tylko przy odpowiedzi 1–5 lub „Tak” i cesze ze stanem: Działa / Ograniczona dostępność / Nie działa / Nie wiem.

- Każda grupa to natywna grupa opcji (`RadioGroup` z `RadioListTile`), w kontenerze semantycznym z nazwą cechy i części miejsca.
- „Dalej” bez odpowiedzi nie przechodzi dalej: trwały komunikat „Wybierz odpowiedź. Jeśli nie wiesz, wybierz „Nie mogłem sprawdzić”.” przy pytaniu, odczytywany przez czytnik (`liveRegion`), z ramką i tekstem „Brak odpowiedzi.” przy karcie.
- 3 to ocena pośrednia, nie „brak zdania”. Ocena 0 nie wlicza się do średniej (decyzja 2026-10-03).
- Wdrożenie: `frontend/mobile/lib/ui/review_survey.dart`.
- **Kryterium:** odpowiedź da się wybrać dotykiem, czytnikiem ekranu i przełącznikami (Switch Access / Switch Control); wybór oznacza kolor i znak ✓, nie sam kolor.

### 2.3 [KONIECZNE] Komunikaty o stanie
- Po zmianie filtrów, zapisaniu szkicu, dodaniu recenzji czytnik ogłasza wynik bez przenoszenia fokusu, np. „Znaleziono 12 miejsc”, „Szkic zapisany”.
- Flutter: `SemanticsService.announce(tekst, TextDirection.ltr)` albo `Semantics(liveRegion: true)` na elemencie z komunikatem.
- **Kryterium:** WCAG 4.1.3.

### 2.4 [KONIECZNE] Fokus
- Kolejność fokusu zgodna z kolejnością wizualną (WCAG 2.4.3).
- Fokus jest zawsze widoczny (WCAG 2.4.7) i nie jest zasłonięty przez dolny pasek, wysuwany panel ani baner (WCAG 2.4.11, nowe w 2.2).
- Po zamknięciu okna fokus wraca do elementu, który je otworzył.

### 2.5 [KONIECZNE] Przewidywalność
- Wybór opcji nie zmienia sam ekranu ani kontekstu. Filtry szczegółowe zatwierdza przycisk „Pokaż wyniki” (WCAG 3.2.2).
- Nawigacja główna jest zawsze w tym samym miejscu i kolejności (WCAG 3.2.3).
- Przycisk „Pomoc” lub „Kontakt” jest zawsze w tym samym miejscu (WCAG 3.2.6, nowe w 2.2).
- Te same funkcje mają te same nazwy w całej aplikacji (WCAG 3.2.4).

### 2.6 [KONIECZNE] Formularze i recenzje
- Każde pole ma widoczną etykietę i instrukcję (WCAG 3.3.2).
- Miejsce i data wizyty wypełniają się automatycznie (data domyślnie dzisiejsza). **Godzina jest opcjonalna i wpisywana samodzielnie**, bez automatycznego wpisywania godziny wysłania (kontrakt §3, UC-05). Nie każ wpisywać drugi raz tego, co aplikacja już wie (WCAG 3.3.7, nowe w 2.2).
- Brak limitów czasu. Szkic zapisuje się automatycznie i nie znika po wygaśnięciu sesji (WCAG 2.2.1).
- **Kryterium:** przerwanie recenzji w połowie i powrót po godzinie nie traci danych.

### 2.7 [KONIECZNE] Logowanie bez łamigłówek
- Logowanie w PoC: e-mail i hasło (kontrakt §2). Mechanizm docelowy jest otwarty (UC-17).
- Bez CAPTCHA z obrazkami i bez przepisywania kodów.
- Pola logowania nie blokują wklejania ani menedżera haseł (UC-17). Flutter: `AutofillGroup` oraz `autofillHints: [AutofillHints.email]` i `[AutofillHints.password]`; nie wyłączaj wklejania.
- Karta Miejska służy do weryfikacji statusu w mieście (UC-02), nie do logowania.
- **Kryterium:** WCAG 3.3.8 (nowe w 2.2).

### 2.8 [KONIECZNE] Ruch, animacje, gesty
- Respektuj ustawienia „Ogranicz ruch” (iOS) i „Usuń animacje” (Android): wyłącz animacje przejść, mapy i odznak. Flutter: `MediaQuery.disableAnimationsOf(context)` lub ustawienie `reduceMotion` z `UiSettings`.
- Nic nie miga częściej niż 3 razy na sekundę (WCAG 2.3.1).
- Każdy gest wielopalcowy lub ścieżkowy (szczypanie mapy) ma alternatywę: przyciski „+” i „−” (WCAG 2.5.1).
- Przeciąganie mapy ma alternatywę: przyciski przesuwania albo widok listy (WCAG 2.5.7, nowe w 2.2).
- Aplikacja działa w pionie i poziomie (WCAG 1.3.4).

### 2.9 [KONIECZNE] Multimedia i dźwięk
- Każde wideo ma napisy (WCAG 1.2.2). Nagranie tylko audio ma transkrypcję (WCAG 1.2.1).
- Żadna informacja nie jest przekazywana tylko dźwiękiem. Powiadomienie = wizualnie + wibracja (opcjonalnie dźwięk).

### 2.10 [ZALECANE] Wibracje
- Krótka wibracja po zatwierdzeniu oceny, filtra albo wysłaniu recenzji. Respektuj systemowe wyłączenie wibracji.

### 2.11 [ZALECANE] Kontakt z miejscem bez telefonu
- Na karcie miejsca najpierw e-mail, SMS i formularz, dopiero potem telefon.
- [OPCJONALNE] Link do tłumacza PJM (np. Migam), jeśli miejsce z niego korzysta.

---

## Poziom 3 – Funkcje

### 3.1 [KONIECZNE] Widok listy jako pełny odpowiednik mapy
- Mapa jest praktycznie niedostępna dla osób niewidomych. Lista miejsc ma **te same dane i filtry** co mapa.
- Lista domyślnie sortowana po odległości.
- Przełącznik „Mapa / Lista” jest zawsze widoczny. W profilu można ustawić listę jako widok domyślny.
- Znaczniki na mapie mają etykiety dostępności. Klaster ogłasza liczbę miejsc („8 miejsc w tym obszarze”).
- Etykieta miejsca zawiera nazwę, ocenę dla profilu użytkownika, odległość i kierunek, np. „Kawiarnia Równik, dla wózków 4,6 na 5, 120 metrów, północny wschód”.
- **Kryterium:** cały scenariusz „znajdź dostępną kawiarnię w pobliżu i otwórz jej kartę” da się przejść z czytnikiem ekranu bez dotykania mapy.

### 3.2 [KONIECZNE] Ankieta recenzji – jedno pytanie na ekran
- Szczegóły: [ankieta recenzji](KindSpot-ankieta-recenzji.md) i [mapowanie pytań na cechy](KindSpot-mapowanie-pytan.md).
- Jeden aspekt na ekran, pasek postępu („Pytanie 3 z 8”), przyciski „Wstecz” i „Dalej”. Systemowe cofnięcie wraca do poprzedniego kroku, a wyjście z ankiety zachowuje szkic w pamięci.
- Pytania dobierane do potrzeb recenzenta według katalogu. Osoba widząca może pominąć pytania o udogodnienia dla osób niewidomych.
- Dla cech, które występują w kilku miejscach budynku (np. drzwi), przycisk „+ Dodaj kolejne”: wybór istniejącej części miejsca albo nowa część z nazwą („od ul. Białej”).
- Utrudnienie tymczasowe: rodzaj (remont / awaria / inne) i opis, np. „winda zepsuta”, „podjazd w budowie”.
- Szczegóły (uzasadnienie, utrudnienie, kolejne części) są w tym samym formularzu, rozwijane (UC-06).
- Każde pokazane pytanie wymaga odpowiedzi (Teoria aplikacji E). Komunikat mówi wprost, jak odpowiedzieć przy braku wiedzy.
- Po wysłaniu ekran pokazuje trzy statusy z odpowiedzi serwera: publikacja, weryfikacja, punkty.
- **Kryterium:** szybką ankietę da się wypełnić w mniej niż 2 minuty z czytnikiem ekranu (sprawdź w teście z użytkownikiem).

### 3.3 [ZALECANE] Panel „Moje ustawienia dostępności” w profilu
- Odpowiada `UiSettings` z kontraktu (`PUT /me/ui-settings`, UC-12): `colorThemeId`, `highContrast`, `reduceMotion`, `textScale`, `simpleLanguage`. Dostępny także przed logowaniem (zapis lokalny) i niezależny od potrzeb oraz filtrów (kontrakt §7).
- Dodatkowo, po potwierdzeniu w kontrakcie: `calmMode` ([propozycja nr 3](KindSpot-kontrakt-propozycje-zmian.md)), lista jako widok domyślny, wyłączenie powiadomień o punktach.
- Domyślnie dziedziczy ustawienia systemowe.

### 3.4 [ZALECANE] Tryb spokojny (`calmMode`, propozycja)
- Stonowane kolory (nadal z kontrastem!), brak czerwonych kropek z liczbą powiadomień, brak animacji i wyskakujących okien, mniej elementów na ekranie, brak dźwięków.

### 3.5 [ZALECANE] „Przygotuj wizytę” na karcie miejsca
- Zdjęcia krok po kroku: wejście, droga do sali, toaleta, ciche miejsce.
- Godziny największego tłoku i ciche godziny (jeśli są).
- Opis prostym językiem, co czeka na miejscu.
- To cyfrowa wersja „historyjek społecznych” i map sensorycznych stosowanych przez muzea dla osób w spektrum autyzmu.

### 3.6 [ZALECANE, poza PoC] Opisy zdjęć dodawanych przez recenzentów
Zdjęcia w recenzji to decyzja otwarta i nie ma ich w kontrakcie v0.1 ([propozycja nr 7](KindSpot-kontrakt-propozycje-zmian.md)). Gdy zostaną dodane:
- Przy dodawaniu zdjęcia pole „Co widać na zdjęciu?”, np. „wejście od ul. Białej, dwa stopnie, brak poręczy”.
- [OPCJONALNE] Opis wygenerowany przez AI jako podpowiedź. Recenzent musi go zatwierdzić albo poprawić.

### 3.7 [ZALECANE] Dyktowanie
- Przycisk mikrofonu przy każdym polu tekstowym recenzji (pomaga osobom niewidomym, z ograniczoną sprawnością rąk, z dysleksją).

### 3.8 [ZALECANE] Grywalizacja bez presji
- Punkty i odznaki tak. Bez serii dni, odliczania czasu, rankingów porównujących ludzi i komunikatów typu „stracisz punkty”.
- Możliwość wyciszenia powiadomień o punktach.
- Zasady punktów opisane prostym językiem (i w tekście łatwym do czytania, punkt 4.1).

### 3.9 [ZALECANE] Motywy: ciemny i wysoki kontrast
- Reaguj na systemowy tryb ciemny i „Zwiększ kontrast” (Flutter: `MediaQuery.highContrastOf(context)`) oraz na `highContrast` i `colorThemeId` z `UiSettings`. Każdy motyw osobno spełnia kontrasty z punktu 1.1.
- Zdjęcia i mapa nie odwracają kolorów przy systemowym odwróceniu barw.

### 3.10 [KONIECZNE] Głosy przy cechach (UC-09)
- Lajk i dislajk dotyczą jednej obserwacji, np. „Podjazd przy wejściu od ul. Białej”, a nie całej recenzji.
- Przyciski mają widoczny tekst i etykietę dla czytnika: „Lajk — potwierdzam”, „Dislajk — nie potwierdzam”, nie same ikony kciuka.
- Przy cesze widać liczby potwierdzeń i niepotwierdzeń. Stan własnego głosu jest odczytywany („zaznaczone”).
- Przy własnej recenzji przycisków nie ma, a powód jest napisany tekstem.
- Zgłoszenie recenzji (UC-13) to osobna akcja, nie dislajk.

---

## Poziom 4 – Najtrudniejsze: treści specjalistyczne, prawo, procesy z ludźmi

### 4.1 [ZALECANE; KONIECZNE, jeśli wdraża miasto] Tekst łatwy do czytania (ETR)
- ISO 24495-1 rozróżnia **prosty język** (dla wszystkich, poziom 1.4) i **język łatwy** (dla osób z trudnościami w rozumieniu tekstu). KindSpot potrzebuje obu.
- Ustawa o zapewnianiu dostępności osobom ze szczególnymi potrzebami wymaga od podmiotów publicznych informacji w tekście łatwym do czytania.
- Wersja ETR obejmuje minimum: czym jest aplikacja, jak dodać recenzję, jak działają punkty i nagrody, jak chronimy prywatność.
- Zasady ETR (Inclusion Europe, wytyczne Urzędu m.st. Warszawy):
  - czcionka co najmniej 14 pt, interlinia co najmniej 1,5, duże marginesy;
  - mało tekstu na ekranie;
  - każde zdanie od nowej linii, najlepiej mieszczące się w jednej linii; gdy dwie linie, łam w miejscu naturalnej pauzy;
  - jedna myśl w zdaniu, czas teraźniejszy, bez kolumn;
  - obraz obok każdego akapitu, ten sam obraz dla tego samego pojęcia, obrazy dla dorosłych, a nie dziecięce;
  - wykresy najpierw opisane słowami.
- **Wymóg procesu:** tekst musi sprawdzić co najmniej jedna osoba z niepełnosprawnością intelektualną.
- Logo „Easy-to-Read” Inclusion Europe można użyć tylko po spełnieniu ich wytycznych. Wymaga ono podpisu „© European Easy-to-Read Logo: Inclusion Europe” i kolor `#333399`.
- Piktogramy ARASAAC są darmowe, ale na licencji CC BY-NC-SA (niekomercyjnej). **Przed użyciem zapytaj zespół o model wdrożenia** i ewentualnie wybierz inny zestaw ikon.

### 4.2 [ZALECANE; KONIECZNE, jeśli wdraża miasto] Nagrania w Polskim Języku Migowym
- Krótkie wideo w PJM z napisami: czym jest aplikacja, jak dodać recenzję, zasady punktów.
- Wymaga współpracy z tłumaczem PJM i najlepiej z osobą głuchą jako konsultantem.

### 4.3 [KONIECZNE, jeśli wdraża miasto] Deklaracja dostępności
- Aplikacje mobilne podmiotów publicznych muszą mieć deklarację dostępności (ustawa o dostępności cyfrowej). Wzór: deklaracje aplikacji mKraków.
- Przygotuj w aplikacji miejsce na link do deklaracji (np. w „Ustawieniach” i w sklepie z aplikacjami).

### 4.4 [KONIECZNE] Testy automatyczne i ręczne
Przy każdej funkcji:
- Automatycznie w testach widżetów Fluttera: `expect(tester, meetsGuideline(androidTapTargetGuideline))`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` i `textContrastGuideline`. Do tego Accessibility Scanner (Android) i Accessibility Inspector (Xcode). Narzędzia wyłapują tylko część problemów.
- Ręcznie:
  1. cały scenariusz z TalkBack i z VoiceOver;
  2. tekst 200%;
  3. „Ogranicz ruch” włączone;
  4. tryb ciemny i wysoki kontrast;
  5. symulacja daltonizmu (opcje programisty Androida, Chrome DevTools);
  6. obsługa samą klawiaturą zewnętrzną lub przełącznikami.
- **Kryterium:** żaden scenariusz główny (rejestracja, ustawienie filtrów, znalezienie miejsca, dodanie recenzji, wymiana punktów) nie ma blokującego błędu.

### 4.5 [KONIECZNE] Testy z użytkownikami
- Co najmniej po jednej osobie z grup: wózek, niewidoma, słabowidząca lub z daltonizmem, głucha, w spektrum autyzmu lub z ADHD, z niepełnosprawnością intelektualną.
- Testuj już na klikalnym prototypie, nie dopiero na gotowej aplikacji.
- Mierz to, co mówi definicja ISO: **czy użytkownik znalazł informację, zrozumiał ją i użył jej**, a nie tylko „czy mu się podoba”.

### 4.6 [KONIECZNE] Lista kontrolna tekstu (stosuj przy każdym nowym tekście)
Oparta na czterech zasadach ISO 24495-1:2023 i polskich wytycznych prostego języka:
1. **Istotny:** czy użytkownik dostaje to, czego potrzebuje, i nic ponad to?
2. **Łatwy do znalezienia:** czy najważniejsza informacja jest na początku? Czy nagłówki i przyciski mówią, co jest pod nimi?
3. **Zrozumiały:** zdania ≤ 15 słów, strona czynna, „ty” i „my”, bez żargonu, metafor, nierozwiniętych skrótów i form zależnych od płci?
4. **Użyteczny:** czy po przeczytaniu wiadomo, co zrobić dalej? Czy tekst ma sens odczytany na głos przez czytnik?

### 4.7 [OPCJONALNE] Rozszerzenia
- Integracja z Migam (połączenie z tłumaczem PJM).
- Tryb „co jest wokół mnie” z komunikatami o kierunku i odległości (inspiracja: Lazarillo, Microsoft Soundscape).
- Wersja ETR całego interfejsu, nie tylko wybranych treści.

---

## Źródła

**Normy i wytyczne**
- WCAG 2.2: https://www.w3.org/TR/WCAG22/
- W3C – wytyczne dla osób z niepełnosprawnościami poznawczymi: https://www.w3.org/TR/coga-usable/
- W3C – dostępność aplikacji mobilnych: https://www.w3.org/WAI/standards-guidelines/mobile/
- ISO 24495-1:2023 Plain language (strona normy, podgląd części informacyjnej): https://www.iso.org/standard/78907.html
- International Plain Language Federation: https://www.iplfederation.org/plain-language/

**Polskie wytyczne prostego języka i ETR**
- Najważniejsze zasady prostego języka (gov.pl, Redakcyjne ABC): https://www.gov.pl/web/redakcyjne-abc/najwazniejsze-zasady-prostego-jezyka
- Jak przygotować dokumenty w prostym języku i ETR – wytyczne (Urząd m.st. Warszawy, PDF): https://wsparcie.um.warszawa.pl/documents/67381/63310733/Jak+przygotowywa%C4%87+dokumenty+w+prostym+j%C4%99zyku+i+ETR+-+wytyczne.pdf/cf2a52ea-5a4c-6f6b-789d-9cdd4076f266?t=1666081703665
- Inclusion Europe – Easy-to-Read: https://www.inclusion-europe.eu/easy-to-read/

**Wytyczne platform**
- Apple Human Interface Guidelines – Accessibility: https://developer.apple.com/design/human-interface-guidelines/accessibility
- Android – Accessibility: https://developer.android.com/guide/topics/ui/accessibility
- Flutter – Accessibility: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility

**Zasoby**
- Paleta Okabe–Ito: https://jfly.uni-koeln.de/color/
- ARASAAC (piktogramy, CC BY-NC-SA): https://arasaac.org/
