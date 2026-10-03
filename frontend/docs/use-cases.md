# Przypadki użycia KindSpot

Nowa nazwa zatwierdzona 2026-10-03: KindSpot (wcześniej USpace). Starsze nazwy w dokumentacji i kontrakcie odnoszą się do tego samego projektu. Ankietę wznowiono 2026-10-03 (Teoria aplikacji, sekcja końcowa).


Aktualizacja: 2026-10-03, zgodnie z dopiskami użytkownika do tabeli rozbieżności kontraktu v0.1.
Platforma: mobilna aplikacja Flutter (Dart), interfejs i komunikacja po polsku. Docelowe systemy i model sesji wymagają dalszego uzgodnienia.
Zakres: zachowania użytkownika i systemu potrzebne do zaprojektowania frontendu; nie jest to projekt algorytmów ani potwierdzenie działających integracji. Dane i integracje demonstracyjne są jawnie oznaczone.

## Spis treści

## Spis treści

- [Aktorzy](#aktorzy)
- [UC-01 Rejestracja i personalizacja profilu](#uc-01-rejestracja-i-personalizacja-profilu)
  - [Scenariusz główny](#scenariusz-główny)
  - [Scenariusze alternatywne](#scenariusze-alternatywne)
- [UC-02 Weryfikacja statusu dla miasta i połączenie karty](#uc-02-weryfikacja-statusu-dla-miasta-i-połączenie-karty)
  - [Scenariusz główny](#scenariusz-główny-1)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-1)
- [UC-03 Konfiguracja profilu dostępności i filtrów](#uc-03-konfiguracja-profilu-dostępności-i-filtrów)
  - [Scenariusz główny](#scenariusz-główny-2)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-2)
- [UC-04 Wyszukiwanie miejsc na mapie i liście](#uc-04-wyszukiwanie-miejsc-na-mapie-i-liście)
  - [Scenariusz główny](#scenariusz-główny-3)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-3)
- [UC-05 Dodawanie krótkiej recenzji ankietowej](#uc-05-dodawanie-krótkiej-recenzji-ankietowej)
  - [Scenariusz główny](#scenariusz-główny-4)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-4)
- [UC-06 Rozwinięcie recenzji o szczegóły](#uc-06-rozwinięcie-recenzji-o-szczegóły)
  - [Scenariusz główny](#scenariusz-główny-5)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-5)
- [UC-07 Opcjonalne pytania doprecyzowujące](#uc-07-opcjonalne-pytania-doprecyzowujące)
  - [Scenariusz główny](#scenariusz-główny-6)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-6)
- [UC-08 Automatyczna weryfikacja recenzji](#uc-08-automatyczna-weryfikacja-recenzji)
  - [Scenariusz główny](#scenariusz-główny-7)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-7)
- [UC-09 Weryfikowanie pojedynczych cech przez użytkowników](#uc-09-weryfikowanie-pojedynczych-cech-przez-użytkowników)
  - [Scenariusz główny](#scenariusz-główny-8)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-8)
  - [Kwalifikowanie do weryfikacji — punkt wymagający wyjaśnienia i decyzji](#kwalifikowanie-do-weryfikacji--punkt-wymagający-wyjaśnienia-i-decyzji)
- [UC-10 Punkty za recenzje i weryfikacje](#uc-10-punkty-za-recenzje-i-weryfikacje)
  - [Scenariusz główny](#scenariusz-główny-9)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-9)
- [UC-11 Wymiana punktów na nagrody](#uc-11-wymiana-punktów-na-nagrody)
  - [Scenariusz główny](#scenariusz-główny-10)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-10)
- [UC-12 Korzystanie z dostępnego interfejsu](#uc-12-korzystanie-z-dostępnego-interfejsu)
  - [Scenariusz główny](#scenariusz-główny-11)
  - [Scenariusze alternatywne i kryteria sprawdzenia](#scenariusze-alternatywne-i-kryteria-sprawdzenia)
- [UC-13 Zgłaszanie recenzji](#uc-13-zgłaszanie-recenzji)
  - [Scenariusz główny](#scenariusz-główny-12)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-11)
- [UC-14 Historia punktów](#uc-14-historia-punktów)
  - [Scenariusz główny](#scenariusz-główny-13)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-12)
- [UC-15 Moje nagrody i odbiór](#uc-15-moje-nagrody-i-odbiór)
  - [Scenariusz główny](#scenariusz-główny-14)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-13)
- [UC-16 Prywatność potrzeb i publiczny profil](#uc-16-prywatność-potrzeb-i-publiczny-profil)
  - [Scenariusz główny](#scenariusz-główny-15)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-14)
- [UC-17 Logowanie, wylogowanie i wygaśnięcie sesji](#uc-17-logowanie-wylogowanie-i-wygaśnięcie-sesji)
  - [Scenariusz główny](#scenariusz-główny-16)
  - [Scenariusze alternatywne](#scenariusze-alternatywne-15)
  - [Model sesji do ustalenia](#model-sesji-do-ustalenia)
- [UC-18 Zapisane miejsca](#uc-18-zapisane-miejsca)
- [UC-19 Nawigacja i wyjście](#uc-19-nawigacja-i-wyjście)
- [Decyzje otwarte i konsekwencje dla kontraktu](#decyzje-otwarte-i-konsekwencje-dla-kontraktu)


## Aktorzy

- Użytkownik — osoba korzystająca z KindSpot, z potrzebami dostępności lub bez nich.
- Pomocnik — dobrowolne oznaczenie uczestnictwa niezależne od wskazanych potrzeb i statusu dla miasta.
- Użytkownik ze zweryfikowanym statusem dla konkretnego miasta — zakres potwierdzenia i uprawnień zależy od obsługiwanej integracji.
- Turysta — użytkownik konta bez połączonej i potwierdzonej karty dla danego miasta; oznaczenie dotyczy miasta. Recenzje mają nieco mniejszą wagę, jej wartość i zastosowanie pozostają do ustalenia.
- System KindSpot — dostarcza dane, statusy i dostępne działania.
- Bot weryfikujący — analizuje recenzje po stronie systemu.
- Moderator — rozpatruje treści wymagające moderacji.
- Zewnętrzny operator karty — zgodnie z przyjętym założeniem dostępności API.
- OpenStreetMap — źródło/podkład geograficzny; nie jest źródłem prywatnych profili, punktów ani recenzji KindSpot.

Etykieta „Turysta” dotyczy konta bez karty dla miasta; jest etykietą produktu, nie dowodem faktycznego miejsca zamieszkania. Zakres potwierdzenia „Miejscowego” wynika z integracji. Status dla jednego miasta nie nadaje takiego samego statusu w innych miastach.

## UC-01 Rejestracja i personalizacja profilu

- Aktorzy: użytkownik, system.
- Warunki wstępne: użytkownik uruchomił aplikację KindSpot.
- Cel: utworzyć konto i ustawić podstawowy wygląd profilu.

### Scenariusz główny

1. Użytkownik wybiera utworzenie konta.
2. System wyświetla formularz z wymaganymi danymi logowania.
3. Użytkownik uzupełnia formularz i potwierdza rejestrację.
4. System tworzy konto z domyślnym wyglądem i prywatnymi potrzebami. Konto bez karty dla wybranego miasta ma oznaczenie Turysta.
5. Użytkownik wybiera dostępne elementy personalizacji oraz może dobrowolnie zaznaczyć oznaczenie Pomocnika.
6. System potwierdza zapis profilu.

### Scenariusze alternatywne

- Niepoprawne lub zajęte dane: komunikat przy odpowiednich polach i możliwość poprawy.
- Pominięcie personalizacji: pozostaje domyślny wygląd.
- Błąd połączenia: formularz pozostaje do poprawy/ponowienia bez ogłoszenia niepotwierdzonego sukcesu.
- Sposób logowania po rejestracji i wymagane dane tożsamości pozostają do ustalenia; patrz UC-17.

## UC-02 Weryfikacja statusu dla miasta i połączenie karty

- Aktorzy: użytkownik, system, operator karty.
- Warunki wstępne: użytkownik jest zalogowany.
- Cel: połączyć kartę i przedstawić potwierdzony status oraz dostępne uprawnienia dla wybranego miasta.

### Scenariusz główny

1. Użytkownik otwiera połączenie Karty Miejskiej i wybiera miasto.
2. System pokazuje obsługiwane typy kart dla tego miasta.
3. Użytkownik wybiera typ i podaje wymagane dane.
4. System pokazuje stan sprawdzania i przeprowadza potwierdzenie zgodne z założeniami integracji, obejmujące powiązanie z użytkownikiem i właściwy zakres statusu.
5. System zwraca wynik, okres ważności, jeśli jest znany, i uprawnienia wynikające z danego typu karty.
6. Aplikacja prezentuje potwierdzony status dla wybranego miasta i informację o połączeniu karty.

### Scenariusze alternatywne

- Karta nieważna lub brak potwierdzenia posiadacza/statusu: komunikat i możliwość poprawienia danych; brak potwierdzonej karty dla miasta oznacza Turystę; błąd usługi nie jest przedstawiany jako dowód zamieszkania ani powód do samodzielnego unieważnienia istniejącego potwierdzenia.
- Operator niedostępny: błąd usługi różny od negatywnej weryfikacji, możliwość ponowienia.
- Wygaśnięcie potwierdzenia: widoczny aktualny status i możliwość ponownej weryfikacji.
- Różne typy kart: mogą dawać różne uprawnienia; frontend pokazuje otrzymany wynik, nie zgaduje ich.
- Samo istnienie ważnego numeru karty nie jest dowodem tożsamości ani zamieszkania. Szczegóły procedury potwierdzenia wymagają dokumentacji operatora.

## UC-03 Konfiguracja profilu dostępności i filtrów

- Aktorzy: użytkownik, system.
- Warunki wstępne: użytkownik jest zalogowany, aby zapisać ustawienia na profilu.
- Cel: zapisać potrzeby i filtry ułatwiające wybór miejsc.

### Scenariusz główny

1. Użytkownik otwiera ustawienia potrzeb i filtrów.
2. System pokazuje potrzeby: wózek, trudności z chodzeniem, brak możliwości korzystania ze schodów, odpoczynek, niewidzenie/słabowidzenie, głuchota/niedosłuch, hałas, tłum, światło, spokojne miejsca, orientacja, złożony tekst, sprawność rąk, podróż z osobą wymagającą pomocy, dzieckiem/wózkiem dziecięcym oraz psem przewodnikiem.
3. Użytkownik wybiera dowolną liczbę potrzeb. Oznaczenie Pomocnika jest niezależne od tego wyboru.
4. System proponuje pasujące presety.
5. Użytkownik ustawia dla cech: warunek konieczny, preferencję albo bez znaczenia.
6. Dla wymaganej cechy ocenianej gwiazdkami użytkownik określa minimalną ocenę; dla pozostałych nie wymusza się oceny.
7. System zapisuje ustawienia jako prywatne i potwierdza zapis.
8. Dobrowolne upublicznienie potrzeb odbywa się osobno w UC-16.

### Scenariusze alternatywne

- Brak potrzeb: korzystanie bez personalizacji.
- Brak szczegółowych reguł: użytkownik może poprzestać na presetach.
- Błąd zapisu: wybory zostają zachowane, aplikacja nie informuje o niepotwierdzonym zapisie.
- Użytkownik wraca do ustawień i zmienia je.
- Pies terapeutyczny pozostaje potrzebą z opisu źródłowego, ale osobna pozycja i jej zakres wymagają uzgodnienia; akceptacja dopisku nie rozstrzygnęła tego punktu.

## UC-04 Wyszukiwanie miejsc na mapie i liście

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie i dostęp online; korzystanie jako gość jest wyłączone.
- Cel: znaleźć miejsce i zrozumieć jego dopasowanie oraz braki informacji.

### Scenariusz główny

1. Miasto jest wybierane na podstawie lokalizacji telefonu; użytkownik może je ręcznie zmienić na liście miast. Otwiera mapę albo równoważną listę.
2. System dostarcza miejsca i dane dostępności KindSpot. Mapa wykorzystuje podkład OSM.
3. Początkowo aktywny jest ostatnio używany filtr użytkownika; system przekazuje wyniki z informacją o dopasowaniu. Pierwsze użycie bez poprzedniego filtra pozostaje do ustalenia.
4. Aplikacja pokazuje te same wyniki i filtry na mapie oraz liście. Przełączenie widoku nie wymaga ponownego wyboru filtrów.
5. Użytkownik wybiera sortowanie: najwięcej recenzji (malejąco) lub najlepsza średnia ocen (malejąco, następnie liczba recenzji malejąco przy remisie) i otwiera miejsce. Wyższa średnia wygrywa niezależnie od liczby recenzji. Agregat miejsca pochodzi z danych systemu; demo używa jawnie fikcyjnych wartości.
6. System pokazuje wejścia/elementy obiektu, oceny, recenzje, daty obserwacji i weryfikacji oraz utrudnienia tymczasowe.
7. Brak danych jest wyraźnie odróżniony od potwierdzonego spełnienia warunku i od braku udogodnienia. Kolejność informacji na karcie miejsca będzie ustalona osobno i stosowana konsekwentnie.

### Scenariusze alternatywne

- Brak personalizacji: wyniki bez dopasowania do prywatnych potrzeb.
- Brak wyników: pusty wynik z możliwością zmiany obszaru/filtrów, nie komunikat awarii.
- Błąd danych KindSpot: komunikat błędu i ponowienie.
- Błąd podkładu mapy: dostępna lista pozostaje użyteczna.
- Brak lokalizacji telefonu lub zgody: pozostaje ręczny wybór miasta/obszaru.
- Brak internetu: komunikat o wymaganiu online; bez obietnicy pracy offline.

## UC-05 Dodawanie krótkiej recenzji ankietowej

- Aktorzy: użytkownik, system.
- Warunki wstępne: użytkownik zalogowany, wybrane miejsce.
- Cel: dodać przydatne obserwacje przez krótką ankietę.

### Scenariusz główny

1. Użytkownik wybiera dodanie recenzji z karty miejsca.
2. System otwiera wspólny formularz z wyborem ocenianych elementów.
3. Użytkownik wskazuje istnienie: występuje, nie występuje albo nie wiem.
4. Jeśli odpowiedź i rodzaj cechy na to pozwalają, użytkownik wskazuje stan: działa, nie działa albo ograniczona dostępność.
5. Dla każdego pytania ankiety użytkownik wybiera 1–5 gwiazdek, „Brak funkcji” (0 gwiazdek) albo „Niewiedza” (publikowane jako „Nie mogłem sprawdzić”, bez oceny liczbowej). Ocena 3 nie jest brakiem zdania. Każde pytanie będzie miało przykładowy szkic uzasadnienia, niepublikowany automatycznie jako obserwacja.
6. Użytkownik potwierdza lub zmienia datę wizyty. Godzina jest opcjonalna i wpisywana samodzielnie.
7. Użytkownik potwierdza wysłanie.
8. Aplikacja pokazuje potwierdzenie zapisu, status publikacji, status weryfikacji i status punktów. Zwykła recenzja jest widoczna i oczekuje na weryfikację; wyjątki opisuje UC-08.

### Scenariusze alternatywne

- Nie wiem lub brak możliwości sprawdzenia: obowiązkowo można wybrać Niewiedzę; recenzja pokazuje „Nie mogłem sprawdzić”, bez wpisywania 0 lub 3/5.
- Element nie występuje: „Brak funkcji” jest traktowane jako 0 gwiazdek; nie wymusza się stanu działania.
- Pytanie bez odpowiedzi: prośba o gwiazdki, brak funkcji albo niewiedzę. Jeśli wszystkie odpowiedzi to niewiedza, warunek publikacji pozostaje do ustalenia — wymóg co najmniej jednej merytorycznej obserwacji był wcześniejszą propozycją, nie rozstrzygnięciem tego przypadku.
- Utrata połączenia: zachowany szkic i komunikat o wyniku wysłania; brak niepotwierdzonego sukcesu.
- Użytkownik rozwija ten sam formularz według UC-06, bez utraty odpowiedzi.

## UC-06 Rozwinięcie recenzji o szczegóły

- Aktorzy: użytkownik, system.
- Warunki wstępne: użytkownik wypełnia formularz z UC-05.
- Cel: uszczegółowić obserwacje bez tworzenia drugiego niezależnego formularza.

### Scenariusz główny

1. Użytkownik rozwija szczegóły wybranych elementów.
2. Dopisuje uzasadnienie, np. „Podjazd 4/5, ale trudno było wjechać samodzielnie”.
3. Wskazuje konkretne wejście/część obiektu albo dodaje brakującą pozycję, np. drzwi od innej ulicy.
4. Dla każdej pozycji stosuje odpowiedzi z UC-05; ocena jest wpisywana tylko wtedy, gdy można ją ocenić.
5. Może podać godzinę wizyty; brak godziny nie blokuje wysłania.
6. Opisuje utrudnienie tymczasowe, np. budowę podjazdu lub awarię windy.
7. Potwierdza wysłanie i widzi aktualne statusy z UC-08/UC-10.

### Scenariusze alternatywne

- Rezygnacja z komentarza: można wysłać poprawną ankietę bez opisu tekstowego.
- Brak możliwości oceny: brak wymuszenia gwiazdek.
- Powrót do ankiety: wprowadzone odpowiedzi nie są tracone.
- Tymczasowe utrudnienie: informacja o konieczności późniejszego sprawdzenia aktualności.

## UC-07 Opcjonalne pytania doprecyzowujące

- Aktorzy: użytkownik, system.
- Warunki wstępne: wypełnianie recenzji.
- Cel: zaproponować bardziej użyteczny opis, bez blokowania poprawnej ankiety.

### Scenariusz główny

1. System proponuje krótkie pytania dotyczące brakujących szczegółów, np. lokalizacji drzwi lub powodu niskiej oceny.
2. Użytkownik odpowiada lub edytuje odpowiednie pole szkicu.
3. System prezentuje uzupełniony szkic do potwierdzenia.
4. Doprecyzowanie nie jest zatwierdzeniem wiarygodności ani osobną publikacją recenzji.

### Scenariusze alternatywne

- Pominięcie pytania nie blokuje wysłania poprawnej recenzji; brak godziny pozostaje dozwolony.
- Brak sugestii: formularz działa bez dodatkowych pytań.
- Błąd usługi sugestii: można kontynuować i wysłać ankietę.
- Pominięcie sugestii samo w sobie nie oznacza odrzucenia, niewiarygodności ani ustalonej kary punktowej.

## UC-08 Automatyczna weryfikacja recenzji

- Aktorzy: system, bot, użytkownik, moderator.
- Warunki wstępne: recenzja została zapisana.
- Cel: przedstawić wynik sprawdzenia i ograniczać nadużycia.
- Zatwierdzona decyzja: pozytywny wynik bota wystarcza do akceptacji recenzji i uruchomienia przyznania punktów w UC-10; nie wymaga dodatkowego głosu człowieka.

### Scenariusz główny

1. Zwykła recenzja jest widoczna i ma status oczekiwania na weryfikację.
2. System przeprowadza analizę jakości i sygnałów nadużycia, uwzględniając także strukturalne odpowiedzi ankietowe.
3. Bot akceptuje recenzję.
4. System aktualizuje status weryfikacji i przekazuje wynik do procesu punktów.
5. Autor widzi niezależnie: status publikacji, status weryfikacji oraz status punktów. Akceptacja przez bota nie jest gwarancją dostępności miejsca.

### Scenariusze alternatywne

- Podejrzana recenzja: wymaga dodatkowego sprawdzenia; system pokazuje autorowi aktualny status. Skutki głosów społeczności pozostają do ustalenia.
- Wykryty spam lub treść obraźliwa: publikacja jest wstrzymana do decyzji moderatora (`hidden_pending_moderation`), z jawną informacją dla autora.
- Krótka, poprawna ankieta: brak rozbudowanego tekstu sam w sobie nie oznacza odrzucenia.
- Analiza trwa lub jest chwilowo niedostępna: status oczekiwania, bez samodzielnej akceptacji ani przyznania punktów w kliencie.

## UC-09 Weryfikowanie pojedynczych cech przez użytkowników

- Aktorzy: użytkownik, system, moderator.
- Warunki wstępne: system udostępnia możliwość głosowania na obserwacje cech w cudzej recenzji.
- Cel: wyrazić zgodność lub niezgodność z konkretną obserwacją, a nie ogólną ocenę autora.
- Zatwierdzona decyzja: lajk/dislajk dotyczy pojedynczej ocenianej cechy, z uwzględnieniem wskazanego wejścia/części obiektu.

### Scenariusz główny

1. System udostępnia recenzję i działania dostępne dla użytkownika.
2. Użytkownik wybiera konkretną obserwację, np. podjazd przy wejściu od ulicy Białej.
3. Wybiera „Lajk — zgadzam się” albo „Dislajk — nie zgadzam się”, z opcjonalnym uzasadnieniem każdego głosu. Ikony mają etykiety dostępne dla czytnika ekranu. W tej samej recenzji można dać lajka podjazdowi i dislajka obserwacji o dostępności dla niewidomych.
4. System zapisuje głos przy tej obserwacji i aktualizuje jej liczniki.
5. Aplikacja pokazuje liczby potwierdzeń i niepotwierdzeń przy danej cesze. Sposób liczenia zbiorczego procentu recenzji pozostaje do ustalenia.
6. Status punktów za wkład jest prezentowany niezależnie; sam głos nie przyznaje automatycznie punktów.

### Scenariusze alternatywne

- Własna recenzja: brak możliwości głosowania; ograniczenie jest sprawdzane przez system.
- Brak wiedzy: użytkownik może pominąć cechę, bez wymuszonego lajka/dislajka. Osobny trzeci typ głosu nie został zatwierdzony.
- Wiedza o jednej cesze: nie trzeba głosować na pozostałe.
- Głos już istnieje: sposób zmiany/cofnięcia wymaga ustalenia, UI pokazuje stan przekazany przez system.
- Sprzeczne głosy: dane pozostają rozróżnialne; progi i skutki dla akceptacji, ukrywania oraz usuwania są otwarte. Nie zakładamy automatycznego usunięcia.

### Kwalifikowanie do weryfikacji — punkt wymagający wyjaśnienia i decyzji

Frontend może pokazywać zadania i uprawnienia przekazane przez system. Nie ustala z samej lokalizacji, kto zna dane miejsce. Pobyt w okolicy nie potwierdza wejścia do budynku ani znajomości konkretnej cechy. Nawet zadeklarowana wcześniejsza wizyta może nie obejmować danego wejścia lub aktualnej awarii. Do ustalenia pozostaje źródło takiej informacji, wymagane zgody i to, czy głosowanie jest otwarte dla wszystkich zalogowanych osób czy tylko zakwalifikowanych. Do czasu decyzji nie opisujemy konkretnego mechanizmu kwalifikacji.

## UC-10 Punkty za recenzje i weryfikacje

- Aktorzy: użytkownik, system, bot, moderator.
- Warunki wstępne: recenzja lub głos zostały zapisane.
- Cel: pokazać nagrodzenie konstruktywnego wkładu.

### Scenariusz główny

1. System zapisuje działanie i prezentuje autorowi status punktów oczekujących.
2. Właściwy proces potwierdza konstruktywność; akceptacja bota jest wystarczająca dla recenzji według UC-08.
3. System przyznaje punkty i zwraca aktualne saldo oraz wynik dla działania.
4. Frontend aktualizuje prezentację na podstawie tego wyniku.
5. System może zaktualizować statystyki i przyznać osiągnięcie, np. „Znany weryfikator”.

### Scenariusze alternatywne

- Brak pozytywnej weryfikacji wkładu: brak przyznania punktów, z odpowiednim statusem.
- Konstruktywna negatywna recenzja może być nagrodzona; pozytywny wydźwięk nie zapewnia nagrody.
- Sam lajk/dislajk nie daje automatycznie punktów. Proces potwierdzania jakości głosów i wysokości nagród wymaga decyzji.
- Ukryta reputacja nie jest saldem, nie jest wyświetlana ani wyliczana w kliencie.
- Oczekujące punkty nie są przedstawiane jako saldo do wydania. Jeśli ich kwota nie jest znana, UI pokazuje status, nie wymyśla liczby.

## UC-11 Wymiana punktów na nagrody

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie, dostęp do katalogu nagród. Potwierdzenia zakupu/odbioru są na obecnym etapie teoretycznym przebiegiem PoC; pokaz demonstracyjny nie deklaruje rzeczywistego wydania nagrody.
- Cel: wybrać nagrodę i zrozumieć wynik realizacji.

### Scenariusz główny

1. Użytkownik otwiera katalog i wybiera nagrodę.
2. System pokazuje opis, koszt, dostępność, wymagane uprawnienia i sposoby odbioru dla tej nagrody.
3. Użytkownik wybiera sposób odbioru i potwierdza koszt.
4. System ponownie sprawdza saldo, cenę, dostępność i uprawnienia.
5. System rozpoczyna realizację, zwraca status (`processing`) oraz stan punktów (`reserved` albo `charged`, zależnie od realizacji).
6. Frontend pokazuje przetwarzanie bez obietnicy gotowej nagrody.
7. Po zakończeniu system zwraca wynik: gotową nagrodę/kod (`ready`) albo wydany benefit (`fulfilled`) oraz potwierdzone saldo.
8. Użytkownik przechodzi do odbioru według UC-15.

### Scenariusze alternatywne

- Brak punktów: komunikat o brakującej kwocie, bez zakupu.
- Nagroda niedostępna lub brak uprawnień: informacja, bez pobrania punktów.
- Zmiana ceny: nowy koszt i ponowne potwierdzenie przez użytkownika.
- Nieudane wydanie (`failed`): system zwalnia rezerwację lub zwraca pobrane punkty (`released`); UI pokazuje wynik dopiero po jego potwierdzeniu. Nie jest to dobrowolny zwrot nagrody.
- Zerwane połączenie/nieznany wynik: odczyt statusu istniejącego zakupu albo bezpieczne ponowienie, bez tworzenia kolejnego zakupu.
- Punkty nie są przekazywalne; brak dobrowolnych zwrotów zakupionych nagród.

## UC-12 Korzystanie z dostępnego interfejsu

- Aktorzy: użytkownik, system.
- Warunki wstępne: uruchomiona aplikacja.
- Cel: zrealizować podstawowe ścieżki z różnymi sposobami obsługi; cel WCAG 2.2 AA sprawdzany w testach, nie tylko deklarowany.

### Scenariusz główny

1. Użytkownik korzysta z czytelnych etykiet, kontrastów i prostych komunikatów; kolor nie jest jedynym nośnikiem informacji. Wybiera pomarańczowy, różowy albo jasnoniebieski akcent, każdy z białym albo czarnym motywem (sześć kombinacji).
2. Wybiera preset jednym kliknięciem i wyszukuje miejsce.
3. Otwiera szczegóły, wypełnia recenzję i odczytuje wynik.
4. Może korzystać bez złożonych gestów; kontrolki i gwiazdki są dostępne alternatywnymi sposobami obsługi.
5. Może otworzyć ustawienia dostępności niezależnie od deklarowania potrzeb.

### Scenariusze alternatywne i kryteria sprawdzenia

- Bez mapy: lista oferuje wybór miejsca, szczegóły i wejście do recenzji dla tych samych wyników/filtrów.
- Czytnik ekranu: odczytuje etykiety, stany, oceny, lajki/dislajki oraz komunikaty błędów i sukcesu; kolejność przejścia jest logiczna.
- Powiększony tekst: podstawowe akcje i treści pozostają dostępne, bez nakładania i obcinania.
- Ograniczona sprawność rąk: nie wymaga się precyzyjnego przeciągania ani złożonych gestów do podstawowych czynności.
- Trudności z czytaniem: krótkie komunikaty i jednoznaczne akcje, bez konieczności pisania długiej recenzji.
- Zmiana palety: statusy pozostają zrozumiałe; podstawowy motyw sam zachowuje kontrast.
- Błędy formularza: oznaczone przy polach, możliwe do odczytania i poprawienia bez utraty danych.
- Problem wykryty w testach: poprawa i ponowne sprawdzenie danej ścieżki przed uznaniem jej za ukończoną.

## UC-13 Zgłaszanie recenzji

- Aktorzy: użytkownik, system, moderator.
- Warunki wstępne: widoczna recenzja, uprawnienie do zgłaszania; wymaganie logowania do zgłoszenia pozostaje do ustalenia.
- Cel: zgłosić fałszywą, obraźliwą lub spamową treść.

### Scenariusz główny

1. Użytkownik wybiera „Zgłoś” przy recenzji.
2. Wskazuje powód i może dopisać komentarz.
3. Potwierdza zgłoszenie.
4. System potwierdza przyjęcie; UI nie obiecuje automatycznego usunięcia ani nie traktuje zgłoszenia jak dislajka cechy.

### Scenariusze alternatywne

- Anulowanie: brak wysłania.
- Błąd wysłania: zachowana treść i możliwość ponowienia.
- Recenzja już niedostępna: jasny komunikat.
- Dalszy obieg zgłoszenia i progi moderacji pozostają do ustalenia; UI prezentuje faktyczny status.

## UC-14 Historia punktów

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie.
- Cel: zrozumieć saldo i pochodzenie zmian.

### Scenariusz główny

1. Użytkownik otwiera historię punktów.
2. System pokazuje potwierdzone saldo i operacje z kwotą, datą oraz powodem, np. recenzja, weryfikacja, zakup lub zwrot po awarii.
3. Oczekujące działania są odróżnione od operacji uwzględnionych w saldzie.
4. Użytkownik może przejść do powiązanej recenzji lub nagrody, jeśli jest dostępna.

### Scenariusze alternatywne

- Pusta historia: czytelny stan pusty.
- Błąd pobrania: ponowienie; frontend nie odtwarza salda na podstawie domysłów.
- Powiązana treść niedostępna: historia operacji pozostaje zrozumiała bez niej.

## UC-15 Moje nagrody i odbiór

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie; zakup lub posiadanie nagrody.
- Cel: odczytać status i sposób skorzystania z nagrody.

### Scenariusz główny

1. Użytkownik otwiera „Moje nagrody”.
2. Wybiera nagrodę i odczytuje jej stan.
3. Gotowy kod ma instrukcję odbioru, możliwość skopiowania i termin ważności, jeśli obowiązuje.
4. Benefit na karcie ma informację o zakończonym zapisaniu; element wizualny można wybrać do profilu, gdy jest dostępny.

### Scenariusze alternatywne

- Realizacja trwa: informacja o przetwarzaniu, bez prezentowania niegotowego kodu.
- Błąd realizacji: wynik i status zwolnienia/zwrotu punktów według UC-11.
- Brak nagród: stan pusty z przejściem do katalogu.
- Wygaśnięcie/wykorzystanie: aktualny stan, jeśli system dostarcza takie informacje.
- Błąd odczytu: ponowienie bez inicjowania kolejnego zakupu.

## UC-16 Prywatność potrzeb i publiczny profil

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie.
- Cel: świadomie zarządzać widocznością potrzeb oraz obejrzeć publiczny profil.

### Scenariusz główny

1. Użytkownik otwiera prywatność profilu.
2. System pokazuje, że potrzeby są domyślnie prywatne.
3. Użytkownik może świadomie włączyć ich upublicznienie i potwierdzić zmianę.
4. Po potwierdzonym zapisie aplikacja pokazuje podgląd publicznego profilu.
5. Użytkownik może ponownie ustawić potrzeby jako prywatne.
6. Publiczne elementy mogą obejmować wybrany wygląd, opcjonalne osiągnięcia oraz statystyki recenzji/weryfikacji. Ukryta reputacja, saldo i dane karty nie są pokazywane.

### Scenariusze alternatywne

- Brak zgody/zmiany: potrzeby pozostają prywatne.
- Błąd zapisu: UI nie ogłasza sukcesu i wskazuje ostatni potwierdzony stan.
- Brak wskazanych potrzeb: profil nie wymusza ich podania.
- Dokładny wybór publicznych osiągnięć i zakres ustawień ich widoczności wymagają doprecyzowania.

## UC-17 Logowanie, wylogowanie i wygaśnięcie sesji

- Aktorzy: użytkownik, system.
- Warunki wstępne: uruchomiona aplikacja Flutter.
- Cel: uzyskać dostęp do konta i kontynuować zadania po utracie sesji.

### Scenariusz główny

1. Użytkownik otwiera logowanie i podaje dane wymagane przez uzgodniony mechanizm.
2. System potwierdza logowanie i przekazuje dostęp do prywatnego profilu.
3. Użytkownik wraca do rozpoczętej ścieżki, jeśli nadal jest dostępna.
4. Po wybraniu wylogowania aplikacja kończy sesję i przestaje pokazywać prywatne dane tego konta innemu użytkownikowi.

### Scenariusze alternatywne

- Niepoprawne dane: komunikat i możliwość poprawy.
- Sesja wygasła: próba odnowienia, jeśli przewiduje ją uzgodniony model; inaczej powrót do logowania.
- Wygaśnięcie podczas recenzji: szkic jest zachowany dla właściwego konta; po ponownym logowaniu można kontynuować, bez wysłania go jako inny użytkownik.
- Utrata sesji podczas zakupu: po logowaniu odczyt istniejącej realizacji, bez ponownego zakupu na podstawie przypuszczenia.
- Problem z połączeniem: odróżniony od niepoprawnych danych logowania.
- Logowanie nie blokuje menedżera haseł ani wklejania danych, gdy używany jest mechanizm hasłowy.

### Model sesji do ustalenia

Zatwierdzona platforma to Flutter, nie trzeba ponownie wybierać między Flutterem a aplikacją webową. Mechanizm tożsamości (np. hasło lub logowanie operatora), wymagane dane, odnowienie, czas sesji, odzyskanie dostępu i przechowywanie poświadczeń nie zostały zatwierdzone. Scenariusz nie narzuca technologii ani konkretnych tokenów.

## UC-18 Zapisane miejsca

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie.
- Cel: wracać do miejsc zapisanych przez użytkownika.

### Scenariusz główny

1. Użytkownik otwiera sekcję Zapisane miejsca.
2. Aplikacja pokazuje zapisane miejsca.
3. Użytkownik wybiera miejsce i otwiera jego szczegóły.
4. Cofnięcie prowadzi na mapę zgodnie z UC-19.

### Do doprecyzowania

Sposób dodania i usunięcia z zapisanych, sortowanie, stan pusty oraz zachowanie dla niedostępnego miejsca. Zatwierdzono sekcję, nie szczegółowy mechanizm zapisu.

## UC-19 Nawigacja i wyjście

- Aktorzy: użytkownik, system.
- Warunki wstępne: zalogowanie.
- Cel: korzystać ze znajomej nawigacji i wracać na ekran główny.

### Scenariusz główny

1. Ekranem głównym jest mapa, ze stylistyką nawigacji inspirowaną Google Maps.
2. Na dole znajduje się główny przycisk pośrodku i dodatkowe przyciski po obu stronach. Środkowy przycisk otwiera mapę. Ostateczne rozmieszczenie pięciu dodatkowych sekcji pozostaje do doprecyzowania.
3. Sekcje obejmują Zapisane miejsca, Filtry, Proponowane miejsca w okolicy, Nagrody oraz Profil.
4. Cofnięcie z ekranu sekcji/szczegółów prowadzi na mapę.
5. Cofnięcie z mapy pyta, czy wyjść. Potwierdzenie wychodzi, odmowa pozostawia na mapie.

### Do doprecyzowania

Cofnięcie podczas edycji, otwartego dialogu/klawiatury i niezapisanych filtrów oraz zachowanie szkicu. Stany wyjątkowe zostaną przygotowane w kolejnym kroku; nie zakładamy ich reguł.

## Decyzje otwarte i konsekwencje dla kontraktu

1. Dokładna mniejsza waga recenzji Turysty i jej wpływ na wynik/ranking; konto bez karty dla miasta ma zatwierdzoną etykietę Turysta. Nie ustalono zmniejszania punktów.
2. Pies terapeutyczny: osobna pozycja i jej znaczenie.
3. Wpływ głosów społeczności na akceptację, ukrywanie i usuwanie; progi oraz ranking.
4. Kwalifikacja weryfikatorów, źródła informacji o wizytach i wymagane zgody. Pobyt w okolicy nie dowodzi znajomości konkretnej cechy.
5. Zmiana/cofnięcie głosu, agregacja procentów per cecha i całej recenzji, zasady potwierdzenia jakości głosów do punktów.
6. Mechanizm logowania/sesji i docelowe systemy Flutter. Konto wymagane do funkcji aplikacji, również przeglądania i zgłoszeń; gość wyłączony.
7. Układ pięciu sekcji wokół przycisku mapy, przykładowa ankieta, stała kolejność karty miejsca i stany wyjątkowe. Odpowiedź na każde pytanie: 1–5, brak funkcji=0 albo niewiedza bez oceny; publikacja ankiety z samą niewiedzą wymaga doprecyzowania.
8. Pamiętanie ostatniego filtra, pierwsze użycie, ranking proponowanych miejsc i reguły listy zapisanych.

Zmiany wymagają późniejszego dostosowania kontraktu v0.1: identyfikacji pojedynczej obserwacji w głosie, liczników przy cechach, usunięcia operacji QR, statusu akceptacji bota i uzupełnienia uzgodnionego modelu sesji. Nie traktujemy starej propozycji głosowania na całą recenzję jako zatwierdzonej. W tym zadaniu aktualizujemy use case’y i pamięć decyzji, bez implementacji ani publikacji zmian w Git.

## Decyzja użytkownika — funkcjonalność i dostępność CP-02, 2026-10-03

Końcowy projekt graficzny wykona później inna osoba. Teraz rozwijamy działanie aplikacji i dostępność; aktualny wygląd jest roboczy. CP-02 zmieniono na dostępność funkcjonalną, ze sprawdzeniem wszystkich kryteriów WCAG 2.2 A/AA oraz zastosowania do Fluttera według WCAG2ICT. Kryteria, wyniki i wymagane dowody: KindSpot-CP02-WCAG.md. CP-02 pozostaje w trakcie; wcześniejsze oddanie sześciu motywów nie jest odbiorem całości udogodnień.

Czytnik, duży tekst/kontrast, klawiatura/przełączniki, obsługa bez złożonych gestów, przewidywalne cofanie, czytelne trwałe błędy i zachowanie wyborów muszą być sprawdzane w istniejących ścieżkach. Brak informacji przekazywanej wyłącznie dźwiękiem, kolorem lub wymagającej mówienia. Nie wymagamy deklaracji niepełnosprawności dla ustawień dostępności. Kontrast i rozmiary/fokus są wymaganiami funkcjonalnymi również przed grafiką.

Nie deklarujemy „wszystkich potrzeb wszystkich osób obsłużonych” na podstawie samych testów automatycznych. Testy urządzenia/czytnika i z użytkownikami pozostają potrzebne. Brakujące funkcje mają późniejsze checkpointy, nie fikcyjny wynik zgodności. Ankieta i recenzje nadal odłożone. Emulator uruchamia wyłącznie użytkownik. Po zmianie grafiki ponownie sprawdzamy dostępność.
## Przejście do CP-03 i rozdzielenie kryteriów dostępności

Użytkownik zlecił rozpoczęcie CP-03 po zmianie struktury: projekt Flutter frontend/mobile, dokumenty frontend/docs, skrypty frontend/scripts. Brakujące kryteria macierzy mają właścicieli w odpowiednich checkpointach, a ich wymagania dopisano bezpośrednio w tych etapach. CP-02 nie jest automatycznie odebrany; przejście dalej jest jawnie zlecone. CP-12 ponownie sprawdza całe ścieżki oraz końcową grafikę.

Implementacja CP-03 przy obecnym backendzie obejmuje wyłącznie jawne lokalne konto demo. Backend uspace_api/main.py udostępnia health, bez endpointów auth. Nie wprowadzono wymagań hasła/email, czasu sesji ani fikcyjnej rejestracji. Test Hackaton otwiera się domyślnie przy starcie; zamknięcie sesji prowadzi do wejścia demo i usuwa prywatne trasy z historii. Ponowne wejście zachowuje ustawienia lokalnego demo. Następne uruchomienie wraca do automatycznego testowego startu, chyba że wyłączono USPACE_AUTO_DEMO_LOGIN. Błąd zapisu wyjścia pozostawia konto otwarte z wyraźną informacją, bez fałszywego sukcesu. Mechanizm produkcyjny nadal wymaga ustalenia i API.

## Decyzje CP-04 i CP-05 — 2026-10-03

Użytkownik zlecił równoległe wykonanie CP-04 i CP-05 z dodatkowym agentem. Nie oznacza to odbioru pełnego CP-02/WCAG ani produkcyjnego uwierzytelnienia CP-03.

- Najlepsze miejsca: średnia ocen malejąco ma bezwzględny priorytet; przy tej samej średniej wyżej jest więcej recenzji. Osobna opcja „Najwięcej recenzji” sortuje liczbę malejąco. Nie wyliczamy średniej miejsca ze średnich cech.
- Na potrzeby happy case okolica obejmuje całe wybrane miasto. Proponowane miejsca stosują zapisane filtry i wybraną kolejność, bez dodatkowego promienia ani potwierdzania wizyty.
- Komentarze: użytkownik wskazał największy stosunek lajków do dislajków. Implementacja należy do CP-08; zero dislajków, remisy i powiązanie z głosami per obserwacja nadal wymagają doprecyzowania. Nie zmieniamy teraz jednostki głosowania ani nie tworzymy komentarzy.
- Demo ma jawnie fikcyjne średnie i liczby recenzji; brak średniej/licznika pozostaje brakiem danych. Domyślna kolejność demo to najlepsza ocena, ostatni wybór jest zapisany lokalnie. Dla sortowania liczby techniczny remis rozstrzyga średnia, potem nazwa/ID; ostatnie klucze nie stanowią nowej reguły produktu.
- Miasto można ustalić po wybraniu „Użyj lokalizacji telefonu”. Demo rozpoznaje systemową nazwę miejscowości dla Krakowa/Warszawy w Polsce; nie zgaduje najbliższego miasta. Odmowa, wyłączona usługa, brak rozpoznania i inne miasta pozostawiają ręczny wybór. Zapisujemy tylko identyfikator miasta, bez współrzędnych/śledzenia w tle. Geokodowanie systemowe może użyć sieci.
- Potrzeby/filtry: zapis dopiero przyciskiem, czyszczenie zmienia szkic i wyłącza dołączenie braków danych; bez zapisu potwierdzone filtry pozostają. Trwały błąd zachowuje wybory. Presety oraz sugestie cech pozostają przykładami PoC, nie zatwierdzoną klasyfikacją potrzeb. Potrzeby prywatne domyślnie.

Operator produkcyjnej mapy, dane API i zakres agregacji recenzji dla średniej nadal należą do kontraktu CP-11. Synchronizacja filtrów i scenariusz szkicu po cofnięciu pozostają otwarte. Wyniki automatyczne nie zastępują testów lokalizacji/TalkBack na urządzeniu; emulator uruchamia tylko użytkownik. Szczegóły odbioru: KindSpot-CP04-CP05.md.
## Pozostałe checkpointy — decyzje użytkownika 2026-10-03

Użytkownik zlecił równoległą pracę nad pozostałymi etapami, po jednym agencie na checkpoint i z pytaniami przy niepewności. Etapy powstają w falach z uwagi na dostępne sloty i zależności; integracja wspólnych modeli i testy końcowe należą do agenta głównego. Nie wymaga się kolejnego odbioru każdego poprzednika przed przygotowaniem tych jawnie zleconych etapów; ukończenie techniczne nadal nie oznacza odbioru użytkownika.

- CP-06 zatwierdzony przebieg: nazwa/adres i dopasowanie → utrudnienia i aktualność → wejścia → cechy → recenzje. Przycisk Zapisz miejsce/Usuń z zapisanych w szczegółach; lokalna lista demo od ostatnio zapisanego. Lista zapisanych pozostaje niezależna od wyszukiwanych miast/filtrów; wpis bez danych katalogowych jest jawnie niedostępny i można go usunąć. Dostępność wejścia nie jest domyślnie dostępnością całego miejsca.
- CP-07 pozostaje odłożony: ankietę przygotowuje inna osoba we Flutterze. Nie tworzymy zastępczej ankiety ani formularza publikacji. Przygotowujemy sposób przekazania/włączenia modułu oraz wymagania dostępności i danych, bez narzucania niezatwierdzonych pytań.
- CP-11: użytkownik potwierdził brak API i przewiduje jego brak dla PoC. Rzeczywista integracja jest jawnie odroczona na potrzeby PoC. Można przygotować adaptery i testy kontraktu; ich istnienie nie oznacza połączenia aplikacji z backendem. Backend pozostaje odpowiedzialnością innego członka zespołu.
- CP-08/09/10 obejmują zatwierdzone prezentacje i jawne przebiegi demo. Nie tworzymy prawdziwych potwierdzeń karty, punktów, nagród ani skutków moderacji w kliencie. Potrzeby nadal prywatne domyślnie. Pytania o zmianę głosu i szczegóły rankingu zapisujemy oddzielnie.
- CP-12: testy automatyczne i przygotowanie APK/przebiegu pokazu w rzeczywistym zakresie. Urządzenie/czytnik oraz iOS pozostają niewykonane do uzyskania rzeczywistych dowodów. Emulator uruchamia wyłącznie użytkownik.
## Zmiana testowego konta i sklepu — praca w toku

Decyzja użytkownika 2026-10-03: przy nowym uruchomieniu saldo testowe 1000 pkt, zakupy i pozostałe dane konta od nowa; nazwane filtry i ustawienia dostępności zachowane. Przykładowy Ogród ciszy wraca w Zapisanych przy każdym starcie. Sklep ma odejmować punkty testowe, Moje nagrody obejmują niezrealizowane nagrody oraz historię zakupów. Poradnik punktów i mini regulamin na osobnym ekranie. Filtry: pomoc na górze, Zapisz filtr z nazwą oraz Użyj filtru tylko w sesji. Profil: pojedyncza adnotacja konta testowego, wejścia do przyszłej personalizacji; zarządzanie sesją i danymi na osobnym ekranie.

Użytkownik następnie przerwał implementację dla commita Frontend i rebase względem dev. To stan WIP: ostatnia analiza ma błędy parsowania app_controller.dart i uwagi lint; zmienione ścieżki wymagają dalszej implementacji oraz testów. Wynik 131 testów i istniejące APK dotyczą wcześniejszego stanu CP-06–12, nie aktualnych niedokończonych zmian. Ankieta i nowe moduły z dev nie są automatycznie podłączane przez rebase.
## Stan po połączeniu Frontend z dev — 2026-10-03

Na dev dostępne są teraz backend i niezależny moduł ankiety z dokumentami (review_survey.dart, review.dart, survey_catalog.dart). Zachowano ich kod, metody szkicu w kontrolerze oraz testy. Zachowano lokalne CP-04–12 i nieukończony sklep/filtry. Konflikt szczegółów rozstrzygnięto na rzecz nowego ekranu CP-06 z opcjonalnym SurveyBuilder; moduł ankiety można podłączyć przez ten punkt po wznowieniu pracy. Nie zintegrowano rzeczywistego API. Zapisy historyczne o braku kodu backendu/ankiety dotyczą wcześniejszego stanu, nie obecnego repozytorium.

Zachowano nazwę KindSpotApp z dev oraz alias USpaceApp dla wcześniejszych testów. Fizyczny folder to D:\Github\USpace, pakiet Dart uspace i identyfikator com.example.uspace pozostają bez zmian. Nazwy dokumentów zmienione na KindSpot-checkpointy.md i KindSpot-kontrakt-frontend-backend-v0.1.md. Nazwa produktu: KindSpot.

Aktualny commit jest WIP. Znane błędy parsowania kontrolera i nieukończone testy sklepu/filtrów pozostają do dokończenia po synchronizacji Git. Rebase nie jest dowodem działającej kompilacji i nie zmienia wcześniejszego APK.
## Wznowienie sklepu, filtrów i profilu — 2026-10-03

Ten zapis zastępuje wcześniejszy status WIP sklepu oraz dawny przebieg nagród bez pobierania punktów. Zgodnie z decyzją użytkownika lokalne PoC ma testowy portfel 1000 pkt; nie nadaje prawdziwych korzyści i nie zastępuje systemowego rozliczania produkcyjnego.

- Nowy proces aplikacji resetuje konto, zakupy i saldo do 1000 pkt. Zachowuje nazwane filtry oraz ustawienia dostępności (kolor, tryb ciemny, wysoki kontrast, ograniczenie animacji). Cofanie, przełączanie zakładek, powrót z tła i ponowne wejście do konta w tym samym procesie nie odnawiają salda.
- Ogród ciszy jest zapisany na start; usunięty w tej sesji wraca przy następnym uruchomieniu. Pozostałe zapisane miejsca i potrzeby resetują się.
- Zakup wymaga potwierdzenia, odejmuje punkty i blokuje ponowny zakup tego elementu do nowego startu. Niewystarczające saldo blokuje zakup. Moje nagrody w Nagrodach zawierają Do odebrania oraz Historię zakupów; realizacja testowa pozostawia wpis w historii. Poradnik punktów i mini regulamin mają osobny ekran. Nie ustalamy niezatwierdzonych stawek zdobywania punktów.
- Jak działają filtry znajduje się na górze filtrów. Zapisz filtr zapisuje nazwaną definicję bez jej automatycznego zastosowania. Użyj filtru stosuje wybór w bieżącej sesji bez zapisu na przyszłość. Nazwa 1–60 znaków; powtórzona nazwa wymaga zmiany. Błąd zapisu pozwala spróbować ponownie.
- Profil ma adnotację przy koncie, wejścia Awatar, Obramowanie, Tło profilu (funkcje przygotowywane) oraz Ustawienia konta z zarządzaniem sesją i usuwaniem lokalnych danych. Celowe usunięcie danych usuwa także zachowane filtry i ustawienia.
- Nowy domyślny akcent: pastelowy zielony, kolor bazowy #ADD8B4. Cztery akcenty w jasnym/ciemnym motywie; wcześniejszy zapisany wybór koloru zachowany zgodnie z decyzją o dostępności.
- Niezależny moduł ankiety z dev zachowany. Test integracji przekazuje go przez opcjonalny SurveyBuilder; domyślne PoC nadal go nie włącza. API nie jest podłączone.

Szczegóły i protokół sprawdzeń: KindSpot-sklep-testowy.md. Historyczne raporty i APK przed wznowieniem nie są wynikiem nowych zmian. Emulator uruchamia tylko użytkownik.