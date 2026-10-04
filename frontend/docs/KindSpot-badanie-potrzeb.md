# Badanie potrzeb użytkowników

Wersja: 2, 2026-10-03. Ankieta badawcza poza aplikacją: sprawdza, jak ludzie dziś szukają informacji o dostępności, jak często trafiają na nieprzewidziane bariery i czy chcieliby oceniać miejsca w KindSpot. Czas wypełnienia: około 10 minut.

Zmiana względem wersji 1: pytanie B18 dotyczy połączenia konta z Kartą Miejską, a nie logowania kartą. Karta służy do weryfikacji statusu w mieście (UC-02), a logowanie to osobny mechanizm (UC-17).

## Zgoda i dane

Pytanie o rodzaj niepełnosprawności to dane o zdrowiu, czyli szczególna kategoria danych według [art. 9 RODO](https://eur-lex.europa.eu/eli/reg/2016/679/oj). Dlatego:

- ankieta jest **anonimowa**: bez imienia, e-maila, numeru Karty Miejskiej i bez zapisywania adresu IP;
- przed pierwszym pytaniem jest **wyraźna zgoda** (osobny przycisk, niezaznaczony z góry);
- każde pytanie o zdrowie ma odpowiedź **„Wolę nie odpowiadać”**;
- ankieta jest dla osób **pełnoletnich**; osoba niepełnoletnia wypełnia ją tylko z opiekunem i zaznacza to w B1;
- zgłoszenie do testów prototypu jest w **osobnym formularzu**, żeby kontakt nie łączył się z odpowiedziami.

Tekst zgody:

> Ta ankieta pomaga nam zbudować aplikację KindSpot. Zajmie około 10 minut.
> Nie pytamy o imię ani adres. Nie wiemy, kto odpowiada.
> Zapytamy o Twoje potrzeby, także związane ze zdrowiem. Każde pytanie możesz pominąć.
> Odpowiedzi czyta tylko zespół KindSpot. Usuniemy je do [data].
> Możesz przerwać w każdej chwili.
> [Zgadzam się i zaczynam]  [Nie, dziękuję]

Przed publikacją trzeba uzupełnić: kto jest administratorem danych, gdzie są przechowywane i do kiedy.

## Pytania

20 pytań w 4 częściach, jedno pytanie na ekran. Tylko B1 jest obowiązkowe, bo od niego zależy sformułowanie B2 („Ty” albo „osoba, którą się opiekujesz”).

| Nr | Pytanie | Typ | Odpowiedzi |
|---|---|---|---|
| **1. O Tobie** | | | |
| B1 | Kto wypełnia ankietę? | jeden wybór | Mam niepełnosprawność lub jestem osobą neuroróżnorodną · Opiekuję się taką osobą · Jedno i drugie · Wypełniam z opiekunem |
| B2 | Które potrzeby Cię dotyczą? | wiele wyborów | 16 potrzeb z katalogu ([lista](KindSpot-mapowanie-pytan.md)) · Inne · Wolę nie odpowiadać |
| B3 | Ile masz lat? | jeden wybór | 18–29 · 30–44 · 45–64 · 65 i więcej · Wolę nie odpowiadać |
| B4 | Gdzie mieszkasz? | jeden wybór | Kraków · Inne duże miasto · Mniejsze miasto · Wieś · Wolę nie odpowiadać |
| **2. Jak dziś sprawdzasz miejsca** | | | |
| B5 | Jak często sprawdzasz dostępność miejsca przed wyjściem? | jeden wybór | Zawsze · Często · Czasem · Rzadko · Nigdy |
| B6 | Skąd bierzesz te informacje? | wiele wyborów | Google Maps · Strona miejsca · Telefon do miejsca · Grupy na Facebooku · Znajomi · Wheelmap · Mapa miasta · Nie sprawdzam · Inne |
| B7 | Na ile ufasz tym informacjom? | 1–5 | 1 = wcale · 5 = całkowicie |
| B8 | W ostatnich 3 miesiącach: ile razy na miejscu była bariera, o której nie było informacji? | jeden wybór | 0 · 1–2 · 3–5 · Więcej niż 5 · Nie pamiętam |
| B9 | Czy zdarza Ci się zrezygnować z wyjścia, bo nie da się sprawdzić dostępności? | jeden wybór | Często · Czasem · Nigdy |
| B10 | Opowiedz o ostatniej takiej sytuacji. | tekst lub nagranie, opcjonalne | – |
| **3. Czego potrzebujesz** | | | |
| B11 | Które informacje są dla Ciebie najważniejsze przed wizytą? | wiele wyborów, maks. 5 | cechy z [mapowania](KindSpot-mapowanie-pytan.md) |
| B12 | Czyja ocena jest dla Ciebie najbardziej wiarygodna? | jeden wybór | Osoby z podobnymi potrzebami · Właściciela miejsca · Urzędu lub audytora · Zwykłe recenzje w internecie · Nie wiem |
| B13 | Jak ważne jest, żeby ocena była świeża, z datą i informacją o awariach? | 1–5 | 1 = nieważne · 5 = bardzo ważne |
| **4. KindSpot** | | | |
| B14 | Czy chcesz oceniać miejsca po wizycie? | jeden wybór | Tak · Może · Nie |
| B15 | Co by Cię do tego zachęciło? | wiele wyborów | Pomaganie innym · Nagrody od miasta, np. bilety · Punkty i odznaki · Nic · Inne |
| B16 | Ile czasu możesz poświęcić na jedną ocenę? | jeden wybór | Do 1 minuty · 1–3 minuty · 3–5 minut · Więcej |
| B17 | Jak wolisz oceniać? | wiele wyborów | Krótka ankieta · Własny opis · Zdjęcia · Głosem |
| B18 | Czy chcesz połączyć konto z Kartą Miejską, żeby odbierać nagrody od miasta? | jeden wybór | Tak · Nie · Nie mam karty · Nie wiem |
| B19 | Które ułatwienia w aplikacji są dla Ciebie niezbędne? | wiele wyborów | Czytnik ekranu · Duży tekst · Prosty język · Tryb spokojny · Filmy w PJM · Lista zamiast mapy · Sterowanie głosem · Inne |
| B20 | Czy chcesz przetestować prototyp aplikacji? | jeden wybór | Tak – przejdź do osobnego formularza kontaktowego · Nie |

## Jak przeprowadzić badanie

**Formy wypełnienia:**

- formularz online sprawdzony z TalkBack i VoiceOver przed publikacją;
- wersja w tekście łatwym do czytania, sprawdzona przez osobę z niepełnosprawnością intelektualną;
- krótki film w PJM z instrukcją i napisami;
- wywiad telefoniczny albo wideo z osobą z zespołu;
- wersja papierowa w dużej czcionce (co najmniej 14 pt).

**Kolejność:**

1. Pilotaż z 3–5 osobami z różnych grup: czy pytania są zrozumiałe i ile trwa wypełnianie.
2. Poprawki po pilotażu.
3. Rekrutacja przez organizacje pozarządowe, grupy wsparcia i grupy na Facebooku (za zgodą administratorów).
4. Zbieranie odpowiedzi przez ustalony czas, np. 7 dni.
5. Analiza: liczby odpowiedzi dla całości i dla grup z B2, cytaty z B10.

**Uczciwość wyników:** próba z grup i organizacji nie jest reprezentatywna. Przy każdym wyniku podajemy liczbę odpowiedzi (np. „23 z 41 osób”) i nie uogólniamy na wszystkie osoby z niepełnosprawnościami w Polsce. Do tego służą dane GUS, Eurostatu i PFRON ([źródła](KindSpot-problem-i-statystyki.md)).

Do prawdziwego badania nie używamy stron wymagających konta (np. artefaktów Claude), bo wykluczyłoby to większość respondentów. Klikalny prototyp służy jako wzór przebiegu.
