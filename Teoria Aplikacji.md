# USpace — teoria wyglądu i działania frontendu

Notatka projektowa oparta na pliku „Teoria Aplikacji.md”. Zakres: to, co użytkownik widzi i robi w aplikacji. Sposób działania usług i reguły przetwarzania danych opisuje osobny kontrakt frontend–backend.

Sekcje A–G porządkują dotychczasowe założenia. Sekcja H oraz lista braków w sekcji I są propozycjami do doprecyzowania, nie zamkniętymi decyzjami.

## A. Cel i odbiorcy

USpace to aplikacja mobilna pomagająca osobom z niepełnosprawnościami i innymi potrzebami dostępności znaleźć odpowiednie miejsca. Recenzowanie, weryfikowanie informacji i zdobywanie nagród łączą pomoc innym z elementami zabawy.

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

## B. Platforma i interfejs

- Interfejs jest projektowany przede wszystkim na telefon i dostosowuje układ do różnych rozmiarów ekranów.
- Działanie offline nie jest wymagane.
- Kolorystyka wykorzystuje pastelowy kolor akcentu oraz biel/czerń. Użytkownik może zmienić motyw kolorystyczny.
- Celem dostępności jest WCAG 2.2 AA oraz testy z użytkownikami.

Do doprecyzowania: aplikacja webowa czy natywna, zakres wsparcia tabletów i komputerów, domyślny motyw, tryb jasny/ciemny, typografia, ikony i wspólne komponenty. Czytelność podstawowego motywu nie może zależeć od zmiany kolorów przez użytkownika.

## C. Wyszukiwanie i personalizacja

Aplikacja pokazuje miejsca na mapie OpenStreetMap. Użytkownik może zapisać filtry na profilu, aby szybko do nich wracać.

- Filtry ogólne: gotowe ustawienia uruchamiane jednym kliknięciem, np. „Miejsca dostosowane do poruszania się na wózku”.
- Filtry szczegółowe: dla każdej cechy użytkownik wybiera:
  - Warunek konieczny — cecha musi występować; dla cechy ocenianej gwiazdkami użytkownik może wskazać minimalny poziom.
  - Preferencja — cecha jest pożądana, ale nieobowiązkowa; użytkownik nie wskazuje minimalnej oceny.
  - Bez znaczenia — cecha nie wpływa na wybór.

Do doprecyzowania: lista jako alternatywa dla mapy; wybór miasta bez lokalizacji telefonu; wyszukiwarka; aktywne filtry; zapis, zastosowanie i reset; kolejność wyników; prezentacja miejsc z brakami danych; zachowanie wyników po powrocie ze szczegółów.

## D. Konto i prywatność

Profil pozwala na połączenie Karty Miejskiej i prezentację statusu połączenia. Recenzje mogą mieć oznaczenie „Turysta” lub „Miejscowy”. Dokładne znaczenie tych etykiet i widok użytkownika bez potwierdzonego statusu wymagają ustalenia.

Preferencje i potrzeby są domyślnie prywatne. Użytkownik może świadomie je upublicznić. Publiczny profil może pokazywać:

- opcjonalne oznaczenia i osiągnięcia, np. „Znany weryfikator”;
- liczbę recenzji i weryfikacji;
- wybrane elementy wizualne zdobyte za punkty lub osiągnięcia.

Użytkownik może zmienić ikonę, ramkę lub inne dostępne elementy wyglądu profilu.

Do doprecyzowania: rejestracja i logowanie; korzystanie bez konta i bez karty; wylogowanie; odzyskiwanie dostępu; ustawienia prywatności i podgląd publicznego profilu; widoki połączenia karty w toku, odrzucenia, wygaśnięcia i błędu.

## E. Recenzje i obserwacje

### Krótka ankieta

Użytkownik wybiera elementy do oceny, np. podjazd lub udogodnienia dotyczące psa przewodnika.

- Istnienie: występuje / nie występuje / nie wiem.
- Jakość: ocena 1–5 z opisem znaczenia poszczególnych ocen, gdy jakość można ocenić.
- Stan: działa / nie działa / ograniczona dostępność, jeśli element występuje i takie pytanie jest dla niego odpowiednie.

Można pominąć pytanie. „Nie wiem” lub brak odpowiedzi nie są oceną 3/5. Formularz powinien pokazywać pytania odpowiednie do wcześniejszych odpowiedzi.

### Recenzja szczegółowa

Użytkownik może uzasadnić ocenę każdego elementu oraz dodać własne pozycje. Obserwacje mogą dotyczyć konkretnych części obiektu, np. wejścia głównego lub drzwi od wskazanej ulicy.

Recenzja uwzględnia datę i godzinę wizyty oraz utrudnienia tymczasowe, np. budowę podjazdu lub awarię windy.

Data jest domyślnie ustawiona na dzień pisania i może zostać zmieniona. Godzinę wskazuje użytkownik; nie jest automatycznie ustawiana na godzinę wysłania. Obowiązkowość godziny pozostaje do ustalenia.

Recenzje podejrzewane o fałsz lub zawierające wulgarną treść można zgłaszać.

Do doprecyzowania: jeden formularz z rozwinięciem czy dwa tryby; kolejność pytań; opisy skali; pola obowiązkowe; wybór i dodanie wejścia; podsumowanie przed wysłaniem; zachowanie szkicu; edycja własnej recenzji; formularz zgłoszenia i wynik jego wysłania.

## F. Prezentacja weryfikacji recenzji

- Użytkownik nie ma możliwości weryfikowania własnej recenzji.
- Przy recenzji widoczne są liczba weryfikacji i procent potwierdzeń.
- Recenzje z dużą liczbą weryfikacji i wysokim odsetkiem potwierdzeń mogą być wyświetlane wyżej. Interfejs nazywa zastosowane sortowanie.
- Autor widzi status sprawdzania recenzji oraz informację o punktach oczekujących lub przyznanych za dane działanie.
- Komunikaty wyjaśniają, że punkty dotyczą przydatnego wkładu, niezależnie od pozytywnej czy negatywnej oceny miejsca. Krótka ankieta nie wymaga rozbudowanego komentarza.

Do doprecyzowania: odpowiedzi weryfikatora; ocena całej recenzji czy wybranych elementów; prezentacja braku głosów; lista zadań weryfikacji; statusy publikacji i sprawdzania; komunikat po ukryciu/usunięciu.

W dotychczasowej notatce występuje sprzeczność: recenzje mają znikać po oznaczeniu jako fałszywe, ale o usunięciu ma decydować moderator. Do czasu uzgodnienia nie określamy automatycznego usuwania. Opisujemy jedynie wymagany widok statusu i informację dla autora. Niedokończone zdanie o progu moderacji usunięto.

## G. Punkty i nagrody

Użytkownik widzi saldo i katalog nagród:

- elementy wizualne: ikony, ramki, tytuły i ozdoby;
- nagrody miejskie, np. bilety komunikacji miejskiej lub do muzeów.

Przy nagrodzie widoczne są koszt, opis oraz sposób odbioru. Nagroda może pojawić się na koncie, jako kod z instrukcją odbioru lub jako informacja o zapisaniu jej na Karcie Miejskiej.

Interfejs nie udostępnia przekazywania punktów ani dobrowolnego zwracania zakupionych nagród.

Do doprecyzowania: potwierdzenie kosztu; „Moje nagrody”; status realizacji; kod i jego ważność; brak punktów/uprawnień; wyczerpana nagroda; błąd zakupu; informacja o przywróceniu punktów po nieudanym wydaniu; historia punktów i ograniczenie animacji.

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

### Najpierw: decyzje potrzebne do makiet

1. Mapa ekranów i nawigacja: ekran startowy, główne sekcje, przejścia i powrót.
2. Karta miejsca: kolejność informacji, wyjaśnienie dopasowania, konkretne wejścia, utrudnienia, aktualność i brak danych.
3. Przebieg wyszukiwania: mapa/lista, miasto, lokalizacja, filtry i puste wyniki.
4. Formularz recenzji: kolejność pytań, zależności między nimi, minimum do wysłania i szkic.
5. Statusy recenzji: rozstrzygnięcie sprzeczności oraz teksty widoczne dla autora i odbiorcy.
6. Granice logowania i połączenia karty; widoki użytkownika bez personalizacji.
7. Przyjęcie konkretnych wymagań dostępności z sekcji H.

### Następnie: pełne ścieżki PoC

- Weryfikacja i zgłoszenie recenzji, z wynikiem czynności.
- Wybór nagrody, potwierdzenie kosztu i odbiór, także przy nieudanej realizacji.
- Profil, ustawienia prywatności i połączenie karty.
- Wspólne komponenty i podstawowe zasady wizualne.
- Przykładowe treści i dane obejmujące różne wejścia, brak danych i awarię windy.
- Zachowanie filtrów, szkiców i przewinięcia przy nawigacji oraz wygaśnięciu sesji.

### Stany wymagające osobnych widoków lub komunikatów

- Ładowanie, treść, brak danych, brak wyników, błąd i ponowienie.
- Brak zgody na lokalizację; ręczny wybór miasta.
- Niedostępna mapa przy działającej liście miejsc.
- Formularz wysyłany, wysłany, niewysłany lub z nieznanym wynikiem po utracie połączenia.
- Recenzja widoczna i oczekująca, zgłoszona, ukryta lub usunięta.
- Weryfikacja niedostępna, już wykonana lub niemożliwa do oceny.
- Punkty oczekujące, przyznane i nieprzyznane.
- Nagroda niedostępna, brak punktów, przetwarzanie zakupu, gotowy kod i błąd realizacji.

### Opcjonalne rozszerzenia z use case’ów

QR z UC-05 i pytania doprecyzowujące z UC-07 nie były rozwinięte w tej notatce. Trzeba zdecydować, czy wchodzą do PoC. Podobnie do decyzji pozostają powiadomienia, ulubione miejsca i osobny panel moderatora.

## J. Zakres usunięty z notatki

Usunięto opis działania bota, zmiany ukrytej reputacji, doboru weryfikatorów na podstawie pobytu, progów moderacji, mechanizmu naliczania punktów oraz technicznego wykorzystania API karty i nagród.

Zachowano ich skutki widoczne w interfejsie: statusy, ograniczenia dostępnych działań, informacje o punktach i sposobach odbioru nagród. Szczegóły komunikacji pozostają w osobnym dokumencie USpace-kontrakt-frontend-backend-v0.1.md. Nie zmieniono use-cases.md ani kontraktu.
