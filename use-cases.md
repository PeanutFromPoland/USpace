# Przypadki użycia

## Spis treści

- [Przypadki użycia](#przypadki-użycia)
  - [Spis treści](#spis-treści)
  - [Aktorzy](#aktorzy)
  - [UC-01 Rejestracja i personalizacja profilu](#uc-01-rejestracja-i-personalizacja-profilu)
    - [Scenariusz główny](#scenariusz-główny)
    - [Scenariusz alternatywny](#scenariusz-alternatywny)
  - [UC-02 Przyznawanie roli mieszkańca](#uc-02-przyznawanie-roli-mieszkańca)
    - [Scenariusz główny](#scenariusz-główny-1)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-1)
  - [UC-03 Konfiguracja profilu dostępności i filtrów](#uc-03-konfiguracja-profilu-dostępności-i-filtrów)
    - [Scenariusz główny](#scenariusz-główny-2)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-2)
  - [UC-04 Wyszukiwanie dostępnych miejsc na mapie](#uc-04-wyszukiwanie-dostępnych-miejsc-na-mapie)
    - [Scenariusz główny](#scenariusz-główny-3)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-3)
  - [UC-05 Dodawanie krótkiej recenzji ankietowej](#uc-05-dodawanie-krótkiej-recenzji-ankietowej)
    - [Scenariusz główny](#scenariusz-główny-4)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-4)
  - [UC-06 Dodawanie szczegółowej recenzji dostępności](#uc-06-dodawanie-szczegółowej-recenzji-dostępności)
    - [Scenariusz główny](#scenariusz-główny-5)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-5)
  - [UC-07 Automatyczne dopytywanie o szczegóły w recenzjach](#uc-07-automatyczne-dopytywanie-o-szczegóły-w-recenzjach)
    - [Scenariusz główny](#scenariusz-główny-6)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-6)
  - [UC-08 Automatyczna weryfikacja wiarygodności recenzji](#uc-08-automatyczna-weryfikacja-wiarygodności-recenzji)
    - [Scenariusz główny](#scenariusz-główny-7)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-7)
  - [UC-09 Weryfikowanie recenzji przez użytkowników](#uc-09-weryfikowanie-recenzji-przez-użytkowników)
    - [Scenariusz główny](#scenariusz-główny-8)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-8)
  - [UC-10 Przyznawanie punktów za recenzje i weryfikacje](#uc-10-przyznawanie-punktów-za-recenzje-i-weryfikacje)
    - [Scenariusz główny](#scenariusz-główny-9)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-9)
  - [UC-11 Wymiana punktów na nagrody](#uc-11-wymiana-punktów-na-nagrody)
    - [Scenariusz główny](#scenariusz-główny-10)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-10)
  - [UC-12 Korzystanie z dostępnego interfejsu aplikacji](#uc-12-korzystanie-z-dostępnego-interfejsu-aplikacji)
    - [Scenariusz główny](#scenariusz-główny-11)
    - [Scenariusz alternatywny](#scenariusz-alternatywny-11)

## Aktorzy

- System
- Użytkownik
- Turysta - domyślna rola użytkownika
- Mieszkaniec - rola użytkownika po pozytywnej weryfikacji karty miejskiej
- Bot weryfikujący - moduł systemu analizujący recenzje
- Moderator
- Zewnętrzne API karty miejskiej
- OpenStreetMap

## UC-01 Rejestracja i personalizacja profilu

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik ma zainstalowaną aplikację mobilną USpace
- Cel: umożliwić użytkownikowi utworzenie konta i podstawową personalizację profilu

### Scenariusz główny

1. Użytkownik uruchamia aplikację i wybiera utworzenie konta.
2. System wyświetla formularz rejestracji.
3. Użytkownik podaje wymagane dane logowania.
4. System tworzy konto użytkownika i nadaje mu domyślną rolę turysty.
5. Użytkownik wybiera ikonę profilu lub inne dostępne elementy wizualnej personalizacji.
6. System zapisuje ustawienia profilu.

### Scenariusz alternatywny

1. Jeżeli użytkownik poda niepoprawne lub zajęte dane, system informuje go o błędzie.
2. Użytkownik poprawia dane i ponawia rejestrację.
3. Jeżeli użytkownik pominie personalizację, system tworzy konto z domyślnym wyglądem profilu.

## UC-02 Przyznawanie roli mieszkańca

- Aktorzy: system, użytkownik, zewnętrzne API karty miejskiej
- Warunki wstępne: użytkownik posiada konto
- Cel: przyznać status mieszkańca, który jest istotny przy ocenie wiarygodności recenzji i dostępie do miejskich benefitów

### Scenariusz główny

1. Użytkownik w panelu użytkownika klika przycisk "Zweryfikuj status mieszkańca".
2. System wyświetla formularz wprowadzenia numeru karty miejskiej, np. Krakowskiej Karty Miejskiej lub Krakowskiej Karty Rodzinnej 3+.
3. Użytkownik wprowadza numer karty.
4. System wysyła do zewnętrznego API zapytanie, czy dana karta istnieje i jest ważna.
5. Zewnętrzne API zwraca pozytywny wynik weryfikacji.
6. System usuwa użytkownikowi rolę turysty i przyznaje rolę mieszkańca na czas obowiązywania karty.
7. System informuje użytkownika o pozytywnej weryfikacji.

### Scenariusz alternatywny

1. Jeżeli system otrzyma negatywny wynik weryfikacji, informuje użytkownika o wyniku.
2. Użytkownik nadal posiada rolę turysty.
3. Użytkownik może poprawić numer karty i ponowić próbę weryfikacji.

## UC-03 Konfiguracja profilu dostępności i filtrów

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik jest zalogowany na swoim koncie
- Cel: zapisać potrzeby użytkownika, aby mógł szybko wyszukiwać miejsca dopasowane do swoich ograniczeń i preferencji

### Scenariusz główny

1. Użytkownik otwiera ustawienia dostępności.
2. System wyświetla listę potrzeb, np. poruszanie się na wózku, trudności z chodzeniem, brak możliwości korzystania ze schodów, słabowidzenie, niedosłyszenie, wrażliwość na hałas, tłum lub intensywne światło, potrzeba spokojnych miejsc, trudności z orientacją, trudności z czytaniem skomplikowanych informacji, ograniczona sprawność rąk, potrzeba częstych miejsc odpoczynku, podróż z osobą wymagającą pomocy albo podróż z dzieckiem lub wózkiem dziecięcym.
3. Użytkownik wybiera potrzeby, które go dotyczą.
4. System proponuje szybkie filtry ogólne pasujące do wybranych potrzeb.
5. Użytkownik może ustawić szczegółowe filtry dla wybranych cech miejsca.
6. Dla każdej cechy użytkownik wybiera jedną z opcji: warunek konieczny, preferencja albo bez znaczenia.
7. Przy warunku koniecznym użytkownik określa minimalną ocenę cechy.
8. System zapisuje filtry w profilu użytkownika jako prywatne preferencje.

### Scenariusz alternatywny

1. Jeżeli użytkownik nie ustawi szczegółowych filtrów, system zapisuje wyłącznie filtry ogólne.
2. Jeżeli użytkownik nie wybierze żadnych potrzeb, system pozwala korzystać z aplikacji bez personalizacji filtrów.
3. Użytkownik może później wrócić do ustawień i zmienić zapisane filtry.

## UC-04 Wyszukiwanie dostępnych miejsc na mapie

- Aktorzy: system, użytkownik, OpenStreetMap
- Warunki wstępne: użytkownik korzysta z aplikacji mobilnej i ma dostęp do internetu
- Cel: pokazać użytkownikowi miejsca spełniające jego potrzeby dostępnościowe

### Scenariusz główny

1. Użytkownik otwiera widok mapy.
2. System pobiera lokalizacje miejsc z OpenStreetMap.
3. System stosuje zapisane filtry użytkownika.
4. System oznacza na mapie miejsca, które spełniają wymagania użytkownika.
5. Użytkownik wybiera miejsce z mapy.
6. System wyświetla kartę miejsca z ocenami dostępności, recenzjami, datą ostatnich weryfikacji oraz informacjami o możliwych utrudnieniach, np. remoncie lub awarii windy.

### Scenariusz alternatywny

1. Jeżeli użytkownik nie ma zapisanych filtrów, system wyświetla miejsca bez personalizacji wyników.
2. Jeżeli OpenStreetMap nie zwróci danych dla danego obszaru, system informuje użytkownika o braku wyników.
3. Jeżeli użytkownik nie ma połączenia z internetem, system informuje, że aplikacja wymaga dostępu online.

## UC-05 Dodawanie krótkiej recenzji ankietowej

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik jest zalogowany i wybrał miejsce, które chce ocenić
- Cel: umożliwić szybkie dodanie recenzji dostępności miejsca

### Scenariusz główny

1. Użytkownik wybiera opcję dodania recenzji miejsca albo skanuje kod QR znajdujący się w danym miejscu.
2. System otwiera krótką ankietę dotyczącą dostępności.
3. Użytkownik ocenia wskazane elementy w skali od 1 do 5, gdzie 1 oznacza ocenę negatywną, 3 oznacza brak zdania, a 5 oznacza ocenę idealną.
4. Użytkownik może oznaczyć, że dany element nie występuje, np. brak podjazdu dla wózków.
5. Użytkownik może pominąć pytanie, jeżeli nie wie, czy dany element występował, albo nie jest w stanie go ocenić.
6. System domyślnie zapisuje, że recenzja dotyczy dnia wizyty.
7. Użytkownik potwierdza wysłanie recenzji.
8. System zapisuje recenzję jako oczekującą na weryfikację.

### Scenariusz alternatywny

1. Jeżeli użytkownik chce wskazać inną datę wizyty, zmienia datę przed wysłaniem recenzji.
2. Jeżeli użytkownik pominie wszystkie pytania, system prosi o ocenę przynajmniej jednego elementu albo anulowanie recenzji.
3. Jeżeli użytkownik utraci połączenie z internetem, system informuje, że recenzja nie może zostać wysłana.

## UC-06 Dodawanie szczegółowej recenzji dostępności

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik jest zalogowany i wybrał miejsce, które chce ocenić
- Cel: umożliwić opisanie konkretnych elementów dostępności oraz uzasadnienie ocen

### Scenariusz główny

1. Użytkownik wybiera opcję dodania szczegółowej recenzji.
2. System wyświetla formularz z kategoriami dostępności miejsca.
3. Użytkownik opisuje oceniane elementy i uzasadnia swoje oceny, np. "Podjazd 4/5, bo był dobry, ale trochę za stromy".
4. Jeżeli cecha może występować w kilku miejscach budynku, system umożliwia dodanie wielu pozycji, np. "Drzwi główne 5/5", "Drzwi od ulicy Białej 3/5", "Drzwi od ulicy Czarnej - brak udogodnienia".
5. Użytkownik wskazuje godzinę wizyty.
6. Użytkownik oznacza tymczasowe utrudnienia, np. remont podjazdu lub awarię windy.
7. System zapisuje recenzję jako oczekującą na weryfikację.

### Scenariusz alternatywny

1. Jeżeli użytkownik nie chce dodawać opisu tekstowego, może wrócić do krótkiej ankiety.
2. Jeżeli użytkownik opisze element bez oceny, system prosi o uzupełnienie oceny albo oznaczenie braku możliwości oceny.
3. Jeżeli użytkownik wskaże utrudnienie tymczasowe, system oznacza informację jako wymagającą późniejszej ponownej weryfikacji.

## UC-07 Automatyczne dopytywanie o szczegóły w recenzjach

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik wypełnia recenzję
- Cel: zwiększyć przydatność recenzji przez doprecyzowanie niejasnych lub zbyt ogólnych informacji

### Scenariusz główny

1. Użytkownik wpisuje treść recenzji lub uzupełnia ankietę.
2. System analizuje, czy recenzja zawiera wystarczająco szczegółowe informacje.
3. System wykrywa brakujące szczegóły, np. brak informacji o lokalizacji ocenianych drzwi, godzinie wizyty albo przyczynie niskiej oceny.
4. System wyświetla użytkownikowi krótkie pytania doprecyzowujące.
5. Użytkownik odpowiada na pytania.
6. System uzupełnia recenzję o doprecyzowane informacje.

### Scenariusz alternatywny

1. Jeżeli użytkownik nie chce odpowiadać na pytania, może pominąć doprecyzowanie.
2. System zapisuje recenzję, ale oznacza ją jako mniej szczegółową.
3. Jeżeli system nie wykryje braków, nie zadaje dodatkowych pytań.

## UC-08 Automatyczna weryfikacja wiarygodności recenzji

- Aktorzy: system, bot weryfikujący, moderator
- Warunki wstępne: użytkownik przesłał recenzję
- Cel: ograniczyć liczbę niewiarygodnych recenzji i przyznawać punkty tylko za konstruktywne treści

### Scenariusz główny

1. System przekazuje nową recenzję do bota weryfikującego.
2. Bot analizuje recenzję pod kątem wiarygodności, m.in. stylu pisania, długości, kompletności, powtarzalnych schematów i zgodności z innymi danymi o miejscu.
3. Bot uznaje recenzję za wiarygodną.
4. System oznacza recenzję jako zaakceptowaną.
5. System przekazuje informację do modułu punktów.

### Scenariusz alternatywny

1. Jeżeli bot uzna recenzję za podejrzaną, system przekazuje ją do moderatora oraz do weryfikacji przez innych użytkowników.
2. Jeżeli bot wykryje treść obraźliwą lub spam, system blokuje publikację recenzji do czasu decyzji moderatora.
3. Jeżeli recenzja jest bardzo krótka, ale zawiera poprawne odpowiedzi ankietowe, system może oznaczyć ją jako wymagającą dodatkowej weryfikacji zamiast ją odrzucać.

## UC-09 Weryfikowanie recenzji przez użytkowników

- Aktorzy: system, użytkownik, moderator
- Warunki wstępne: w systemie istnieje recenzja wymagająca dodatkowej weryfikacji
- Cel: wykorzystać społeczność do potwierdzania jakości recenzji i aktualności informacji o dostępności

### Scenariusz główny

1. System wybiera użytkowników, którzy byli w danym miejscu albo w miejscach w okolicy.
2. System pomija autora recenzji, ponieważ użytkownik nie może weryfikować własnych recenzji.
3. System proponuje wybranym użytkownikom weryfikację recenzji.
4. Użytkownik sprawdza recenzję i ocenia, czy jest konstruktywna, zgodna z jego doświadczeniem i przydatna dla innych.
5. System zapisuje wynik weryfikacji.
6. System aktualizuje ukrytą reputację weryfikacji użytkownika.
7. Po osiągnięciu wymaganego poziomu zgodności system akceptuje albo odrzuca recenzję.

### Scenariusz alternatywny

1. Jeżeli użytkownicy nie osiągną zgodności, system przekazuje recenzję moderatorowi.
2. Jeżeli użytkownik błędnie weryfikuje recenzje, system obniża jego ukrytą reputację weryfikacji.
3. Jeżeli użytkownik konstruktywnie weryfikuje recenzje, system zwiększa jego ukrytą reputację weryfikacji.

## UC-10 Przyznawanie punktów za recenzje i weryfikacje

- Aktorzy: system, użytkownik, bot weryfikujący, moderator
- Warunki wstępne: użytkownik dodał recenzję albo zweryfikował recenzję innego użytkownika
- Cel: zachęcić użytkowników do tworzenia konstruktywnych recenzji oraz sprawdzania jakości treści

### Scenariusz główny

1. Użytkownik dodaje recenzję albo wykonuje weryfikację recenzji innego użytkownika.
2. System oznacza działanie jako oczekujące na potwierdzenie.
3. Bot, inni użytkownicy albo moderator potwierdzają, że działanie było konstruktywne i wiarygodne.
4. System przyznaje użytkownikowi punkty.
5. System aktualizuje publiczne statystyki profilu, np. liczbę recenzji i weryfikacji.
6. System może przyznać użytkownikowi osiągnięcie potwierdzające autentyczność profilu, np. "znany weryfikator".

### Scenariusz alternatywny

1. Jeżeli recenzja nie przejdzie weryfikacji, system nie przyznaje punktów.
2. Jeżeli recenzja jest negatywna, ale konstruktywna, system może przyznać punkty.
3. Jeżeli recenzja jest pozytywna, ale niekonstruktywna albo niewiarygodna, system nie przyznaje punktów.

## UC-11 Wymiana punktów na nagrody

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik posiada zweryfikowane punkty na koncie
- Cel: umożliwić użytkownikowi odbiór benefitów za wkład w rozwój bazy dostępności

### Scenariusz główny

1. Użytkownik otwiera katalog nagród.
2. System wyświetla dostępne nagrody, np. elementy wizualne profilu, obramówki profilu, bilety komunikacji miejskiej, bilety do muzeów lub wejściówki do miejsc organizowanych przez miasto.
3. Użytkownik wybiera nagrodę.
4. System sprawdza, czy użytkownik ma wystarczającą liczbę punktów.
5. System odejmuje punkty z konta użytkownika.
6. System przypisuje nagrodę do konta użytkownika albo generuje sposób jej odbioru.
7. System informuje użytkownika, że zakup punktowy został zrealizowany.

### Scenariusz alternatywny

1. Jeżeli użytkownik nie ma wystarczającej liczby punktów, system blokuje zakup i informuje o brakującej liczbie punktów.
2. Jeżeli nagroda nie jest już dostępna, system informuje użytkownika i nie pobiera punktów.
3. System nie pozwala przekazywać punktów innym użytkownikom.
4. System nie pozwala zwracać zakupionych nagród.

## UC-12 Korzystanie z dostępnego interfejsu aplikacji

- Aktorzy: system, użytkownik
- Warunki wstępne: użytkownik korzysta z aplikacji mobilnej USpace
- Cel: zapewnić możliwość korzystania z aplikacji osobom z różnymi potrzebami dostępnościowymi

### Scenariusz główny

1. Użytkownik uruchamia aplikację.
2. System wyświetla interfejs zgodny z WCAG 2.2 AA.
3. System zapewnia czytelne etykiety elementów interfejsu, w tym etykiety dla czytników ekranu.
4. System stosuje czytelne kontrasty, proste komunikaty i spokojną kolorystykę, np. pastelowy pomarańczowy albo jasnoniebieski.
5. Użytkownik korzysta z głównych funkcji aplikacji bez konieczności wykonywania skomplikowanych gestów.
6. System umożliwia korzystanie z filtrów ogólnych jednym kliknięciem.

### Scenariusz alternatywny

1. Jeżeli użytkownik korzysta z czytnika ekranu, system przekazuje nazwy i stany elementów interfejsu.
2. Jeżeli użytkownik ma trudności z czytaniem skomplikowanych informacji, system prezentuje krótkie komunikaty i jednoznaczne akcje.
3. Jeżeli testy z użytkownikami wykażą problem dostępnościowy, wymaganie zostaje oznaczone do poprawy przed wdrożeniem.
