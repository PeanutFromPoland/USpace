# KindSpot — teoria wyglądu i działania frontendu

Nowa nazwa zatwierdzona 2026-10-03: KindSpot (wcześniej USpace). Starsze nazwy w dokumentacji i kontrakcie odnoszą się do tego samego projektu; ankieta pozostaje odłożona.


Notatka projektowa oparta na pliku „Teoria Aplikacji.md”. Zakres: to, co użytkownik widzi i robi w aplikacji. Sposób działania usług i reguły przetwarzania danych opisuje osobny kontrakt frontend–backend.

Aktualizacja decyzji użytkownika: 2026-10-03. Ustalenia zapisano poniżej; kwestie oznaczone „do ustalenia” nie są zatwierdzonymi regułami. Opis pozostaje teoretyczny, bez implementacji ekranów.

## A. Cel i odbiorcy

KindSpot to aplikacja mobilna pomagająca osobom z niepełnosprawnościami i innymi potrzebami dostępności znaleźć odpowiednie miejsca. Recenzowanie, weryfikowanie informacji i zdobywanie nagród łączą pomoc innym z elementami zabawy.

Użytkownik może wskazać kilka potrzeb jednocześnie:

| Obszar | Potrzeby użytkownika |
|---|---|
| Mobilność | Poruszam się na wózku; mam trudności z chodzeniem; nie mogę korzystać ze schodów; potrzebuję częstych miejsc odpoczynku |
| Wzrok i słuch | Jestem niewidomy / słabowidzący; jestem głuchy / niedosłyszący |
| Wrażliwość na otoczenie | Źle znoszę hałas, tłum lub intensywne światło; potrzebuję spokojnych miejsc |
| Orientacja i obsługa | Mam trudności z orientacją; mam trudności z czytaniem skomplikowanych informacji; mam ograniczoną sprawność rąk |
| Podróżowanie z innymi | Podróżuję z osobą wymagającą pomocy; podróżuję z dzieckiem / wózkiem dziecięcym; podróżuję z psem przewodnikiem / terapeutycznym |

Z aplikacji mogą korzystać również osoby bez wskazanych potrzeb, które chcą rozbudowywać informacje o miejscach. Mogą być oznaczane jako „Pomocnicy”.

Do doprecyzowania: czy oznaczenie Pomocnika może wybrać każdy użytkownik; czy pies przewodnik i pies terapeutyczny są osobnymi pozycjami.

### Zakres prezentacji PoC

Nie ustalamy teraz zamkniętej listy funkcji pierwszej wersji: pokazujemy tyle, ile uda się przygotować. Pokaz jawnie odróżnia działające elementy, dane demonstracyjne i teoretyczne przebiegi, zwłaszcza zakup i odbiór nagród.

## B. Platforma i interfejs

- Platforma: mobilna aplikacja Flutter (Dart), projektowana przede wszystkim na telefon, z układem dostosowującym się do ekranu.
- Działanie offline nie jest wymagane.
- Znany użytkownikom sposób korzystania z mapy, inspirowany Google Maps: mapa jako ekran główny i przyciski na dole, z wyróżnionym głównym przyciskiem pośrodku oraz dodatkowymi po lewej i prawej. Środkowy przycisk otwiera mapę.
- Główne sekcje: Zapisane miejsca, Filtry, Proponowane miejsca w okolicy, Nagrody, Profil.
- Cofnięcie z ekranu aplikacji wraca na mapę; cofnięcie z mapy wyświetla pytanie, czy wyjść z aplikacji. Obsługa cofnięcia podczas formularza, dialogu i klawiatury wymaga scenariuszy wyjątkowych; nie zakładamy utraty szkicu.
- Kolory akcentu do wyboru: pastelowy pomarańczowy, pastelowy różowy i jasnoniebieski. Każdy z motywem białym lub czarnym: łącznie sześć kombinacji.
- Cel: maksymalna łatwość obsługi dla osób z niepełnosprawnościami i ich bliskich, WCAG 2.2 AA oraz testy z użytkownikami. Każda kombinacja wymaga sprawdzenia kontrastu; pastelowy wygląd nie zastępuje dostępności.

Do ustalenia: rozmieszczenie pięciu sekcji względem środkowego przycisku mapy; motyw domyślny, dokładne kolory, typografia, ikony, rozmiary kontrolek i szczegółowy układ większych ekranów. Inspiracja Google Maps określa znajomy wzorzec, nie gotową makietę.

## C. Wyszukiwanie i personalizacja

Miasto jest wybierane na podstawie lokalizacji telefonu; użytkownik może je ręcznie zmienić na liście miast. Bez zgody na lokalizację pozostaje wybór ręczny.

Przy rozpoczęciu wyszukiwania używany jest ostatni filtr użytkownika. Filtry są zapisywane na profilu. Zachowanie przy pierwszym użyciu, gdy nie ma poprzedniego filtra, oraz zakres pamiętania filtra między miastami/urządzeniami pozostają do ustalenia.

- Filtry ogólne: presety ustawiane jednym kliknięciem.
- Filtry szczegółowe: warunek konieczny (dla cech ocenialnych minimalne gwiazdki), preferencja bez progu gwiazdek, bez znaczenia.
- Mapa i równoważna lista prezentują miejsca z aktywnymi filtrami.
- Lista miejsc ma dwa sposoby sortowania: według liczby recenzji oraz od najlepszej oceny. Są to opcje sortowania, nie dodatkowe filtry dostępności.
- Dostępna jest sekcja proponowanych miejsc w okolicy oraz sekcja zapisanych miejsc.

Do ustalenia: czy liczba recenzji jest malejąca, co oznacza najlepsza ocena miejsca (ogólna czy dla wybranych potrzeb), promień okolicy, szczegóły rankingu, działania zapisywania/usuwania miejsca, wyszukiwarka, Zastosuj/Zapisz/Resetuj i prezentacja braków danych.

### Szczegóły miejsca

Informacje mają być pokazywane zawsze w tej samej kolejności. Kolejność ustalimy w następnym kroku. Należy uwzględnić wejścia, cechy, daty i aktualność, utrudnienia, recenzje oraz brak danych; brak danych nie oznacza dostępności.

## D. Konto i prywatność

Konto jest obowiązkowe: nie przewidujemy korzystania z funkcji aplikacji jako gość. Ekrany logowania/rejestracji pozostają dostępne przed uwierzytelnieniem, podobnie jak niezbędne ułatwienia ich obsługi.

Konto bez połączonej i potwierdzonej karty dla wybranego miasta jest oznaczane „Turysta” w tym mieście. Recenzje turysty mają nieco mniejsze znaczenie. Dokładna waga oraz jej wpływ na ocenę, ranking i widoczne wyjaśnienie nie są jeszcze ustalone. Nie zakładamy, że oznacza to mniejszą liczbę punktów. Jest to etykieta produktu, nie dowód faktycznego miejsca zamieszkania.

Profil umożliwia połączenie karty i przedstawia potwierdzony status dla miasta. Potrzeby są domyślnie prywatne; użytkownik może je świadomie upublicznić. Publiczne mogą być opcjonalne osiągnięcia, statystyki oraz wybrany wygląd profilu. Pomocnik jest niezależny od statusu Turysta/Miejscowy i własnych potrzeb.

Do ustalenia: mechanizm logowania i sesji, odzyskiwanie dostępu, ekran prywatności, podgląd publicznego profilu oraz zachowanie przy sprawdzaniu, odrzuceniu i wygaśnięciu połączenia karty. Sam numer karty nie dowodzi tożsamości; sposób potwierdzenia pozostaje po stronie integracji.

## E. Recenzje i obserwacje

Użytkownik wypełnia wspólny formularz: krótką ankietę, którą można rozwinąć o komentarze i konkretne wejścia/elementy obiektu. Do każdego pytania przygotowujemy przykładowy szkic odpowiedzi, ułatwiający napisanie uzasadnienia; przykład nie powinien być publikowany jako obserwacja użytkownika bez jego świadomego użycia.

Ankieta rozdziela istnienie cechy (występuje / nie występuje / nie wiem), jakość 1–5 i stan działania, gdy cecha występuje i można taki stan ocenić. Ocena 3 nie oznacza braku zdania. Można opisać własne elementy i utrudnienia tymczasowe.

Każde pytanie ankiety wymaga odpowiedzi: 1–5 gwiazdek, „Brak funkcji” (traktowane jako 0 gwiazdek) albo „Niewiedza”. Ostatnia opcja jest publikowana jako „Nie mogłem sprawdzić” i nie otrzymuje oceny liczbowej. Brak funkcji i niewiedza pozostają odrębnymi stanami. Wymóg dotyczy każdego punktu prezentowanej ankiety; dokładny zestaw pytań ustalimy na przykładzie. Wpływ 0 na ocenę zbiorczą miejsca doprecyzujemy przy zasadach agregacji; niewiedza nie może być pokazana jako brak funkcji.

Data wizyty domyślnie bieżąca, z możliwością zmiany. Godzina opcjonalna i wpisywana samodzielnie. Przykładową ankietę przygotujemy w następnym kroku. Recenzję można zgłosić jako fałszywą/obraźliwą/spamową.

Do ustalenia: pytania i znaczenie skali, przykładowe odpowiedzi, kolejność formularza, podsumowanie, szkic po cofnięciu, edycja i komunikaty wysłania. QR zostało usunięte z zakresu. Opcjonalne pytania doprecyzowujące nie blokują poprawnej ankiety.

## F. Prezentacja weryfikacji recenzji

- Lajk/dislajk dotyczy konkretnego elementu cudzej recenzji i wskazanego wejścia, nie całej recenzji.
- Lajk oznacza „Zgadzam się”; dislajk oznacza „Nie zgadzam się”. Każdy może mieć opcjonalne uzasadnienie.
- W jednej recenzji można zgodzić się z opinią o podjeździe i nie zgodzić z opinią o udogodnieniach dla osób niewidomych.
- Autor nie może weryfikować własnej recenzji. Brak wiedzy nie wymusza głosu.
- Przy elementach pokazywane są głosy; sposób zbiorczego procentu recenzji pozostaje do ustalenia.
- Autor widzi osobno publikację, sprawdzanie i status punktów. Zwykła recenzja widoczna/oczekująca; spam może być wstrzymany z informacją dla autora.
- Akceptacja bota wystarcza do uruchomienia nagrodzenia po stronie systemu, ale nie stanowi gwarancji dostępności miejsca.

Do ustalenia: zmiana/cofnięcie głosu, procenty i sortowanie recenzji, kwalifikacja weryfikatorów oraz wpływ głosów na akceptację/ukrywanie/usuwanie. Nie przyjmujemy nieustalonych progów ani samodzielnego przyznawania punktów w interfejsie.

## G. Punkty i nagrody

Użytkownik widzi saldo oraz katalog elementów wizualnych i miejskich benefitów. Nagroda ma opis, koszt i sposób odbioru: na koncie, kod lub informację o zapisaniu na karcie. Punkty nieprzekazywalne, dobrowolne zwroty wyłączone.

Potwierdzenie zakupu i odbioru przygotowujemy na razie teoretycznie jako część PoC. Prezentacja nie sugeruje faktycznego pobrania punktów lub wydania biletu, jeśli nie zostało to zrealizowane. Zachowujemy zaplanowane stany przetwarzania i błędu oraz przywrócenia punktów po nieudanej realizacji.

Do ustalenia: wygląd katalogu, „Moje nagrody”, dialog kosztu, instrukcja i ważność kodu, historia punktów oraz dokładne komunikaty. Mechanizm ekonomii punktów nie jest wyliczany wyłącznie w kliencie.

## H. Usprawnienia dotyczące dostępności — propozycja

- Równoważna lista miejsc pozwala korzystać z głównych funkcji bez mapy.
- Przyciski, filtry, gwiazdki i pola mają czytelne etykiety, także dla czytnika ekranu.
- Statusy i błędy mają opis tekstowy; kolor nie jest jedynym nośnikiem informacji.
- Interfejs zachowuje czytelność po powiększeniu tekstu i dostosowuje układ do ekranu.
- Nawigacja jest przewidywalna, a fokus widoczny i niezasłonięty.
- Podstawowe czynności nie wymagają wyłącznie przeciągania lub złożonych gestów.
- Kontrolki są łatwe do wybrania, a formularze nie wymagają precyzyjnego trafiania w małe gwiazdki.
- Błędy wskazują pole i sposób poprawy, zachowując wprowadzone dane.
- Komunikaty o wysłaniu, błędzie i zmianie statusu są dostępne dla czytnika ekranu.
- Teksty są krótkie, a działania jednoznacznie nazwane.
- Efekty grywalizacji można ograniczyć; nie stosujemy migających dekoracji.
- Ustawienia dostępności można otworzyć przed logowaniem, niezależnie od deklarowania potrzeb.
- Logowanie pozwala korzystać z menedżera haseł i wklejać dane.

Cel WCAG 2.2 AA wymaga późniejszego sprawdzenia ekranów i ścieżek. Ta lista nie jest deklaracją osiągniętej zgodności. Część punktów jest dodatkowym założeniem użyteczności.

Źródło kryteriów: [WCAG 2.2 — lista wymagań](https://www.w3.org/WAI/WCAG22/quickref/).

## I. Czego jeszcze brakuje do frontendowego PoC

### Najbliższe ustalenia

1. Ostateczne rozmieszczenie pięciu sekcji wokół środkowego przycisku mapy.
2. Stała kolejność informacji na karcie miejsca.
3. Przykładowa ankieta, etykiety skali i szkice odpowiedzi. Zasada odpowiedzi jest ustalona: 1–5, brak funkcji=0 albo niewiedza bez oceny.
4. Stany wyjątkowe — przygotujemy je w kolejnym kroku, w tym cofnięcie z formularza i wygaśnięcie sesji.
5. Reguły listy: liczba recenzji, znaczenie najlepszej oceny i promień okolicy; zapis i usuwanie miejsc.
6. Pierwsze użycie bez poprzedniego filtra, zapis/reset i zachowanie przy zmianie miasta.
7. Waga recenzji turysty; skutki głosów, zmiana głosu i kwalifikowanie weryfikatorów.
8. Szczegóły konta/sesji oraz sześciu motywów (paleta, kontrast, typografia, ikony).

### Materiały przed implementacją poszczególnych ścieżek

Makiety, nawigacja, wspólne komponenty i przykładowe dane. Zakres demonstracji pozostaje elastyczny: pokazujemy przygotowaną część, jawnie oznaczając symulacje. Nie przyjmujemy, że cała planowana lista musi powstać przed pokazem.

### Stany do przygotowania

Ładowanie i brak wyników; brak danych dostępności; odmowa lokalizacji; błąd mapy/połączenia; szkic formularza i nieznany wynik wysłania; zgłoszona/ukryta recenzja; głos niedostępny; punkty oczekujące; nagroda niedostępna i realizacja w toku/błąd. Nie są jeszcze rozpisanymi scenariuszami.

### Pozostałe rozszerzenia

Powiadomienia i panel moderatora pozostają do ustalenia. Zapisane miejsca są zatwierdzoną sekcją, nie opcjonalnym pomysłem; QR jest wyłączone.

## J. Zakres usunięty z notatki

Usunięto opis działania bota, zmiany ukrytej reputacji, doboru weryfikatorów na podstawie pobytu, progów moderacji, mechanizmu naliczania punktów oraz technicznego wykorzystania API karty i nagród.

Zachowano ich skutki widoczne w interfejsie: statusy, ograniczenia dostępnych działań, informacje o punktach i sposobach odbioru nagród. Szczegóły komunikacji pozostają w osobnym dokumencie KindSpot-kontrakt-frontend-backend-v0.1.md. Decyzje użytkownika aktualizują także use-cases.md i odpowiednie założenia kontraktu; nie potwierdzają istnienia działającego API.


## Decyzja użytkownika — funkcjonalność i dostępność CP-02, 2026-10-03

Końcowy projekt graficzny wykona później inna osoba. Teraz rozwijamy działanie aplikacji i dostępność; aktualny wygląd jest roboczy. CP-02 zmieniono na dostępność funkcjonalną, ze sprawdzeniem wszystkich kryteriów WCAG 2.2 A/AA oraz zastosowania do Fluttera według WCAG2ICT. Kryteria, wyniki i wymagane dowody: KindSpot-CP02-WCAG.md. CP-02 pozostaje w trakcie; wcześniejsze oddanie sześciu motywów nie jest odbiorem całości udogodnień.

Czytnik, duży tekst/kontrast, klawiatura/przełączniki, obsługa bez złożonych gestów, przewidywalne cofanie, czytelne trwałe błędy i zachowanie wyborów muszą być sprawdzane w istniejących ścieżkach. Brak informacji przekazywanej wyłącznie dźwiękiem, kolorem lub wymagającej mówienia. Nie wymagamy deklaracji niepełnosprawności dla ustawień dostępności. Kontrast i rozmiary/fokus są wymaganiami funkcjonalnymi również przed grafiką.

Nie deklarujemy „wszystkich potrzeb wszystkich osób obsłużonych” na podstawie samych testów automatycznych. Testy urządzenia/czytnika i z użytkownikami pozostają potrzebne. Brakujące funkcje mają późniejsze checkpointy, nie fikcyjny wynik zgodności. Ankieta i recenzje nadal odłożone. Emulator uruchamia wyłącznie użytkownik. Po zmianie grafiki ponownie sprawdzamy dostępność.