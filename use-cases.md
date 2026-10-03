# Przypadki użycia USpace

Aktualizacja: 2026-10-03, zgodnie z dopiskami użytkownika do tabeli rozbieżności kontraktu v0.1.
Platforma: mobilna aplikacja Flutter (Dart), interfejs i komunikacja po polsku. Docelowe systemy i model sesji wymagają dalszego uzgodnienia.
Zakres: zachowania użytkownika i systemu potrzebne do zaprojektowania frontendu; nie jest to projekt algorytmów ani potwierdzenie działających integracji. Dane i integracje demonstracyjne są jawnie oznaczone.

## Spis treści

- [Przypadki użycia USpace](#przypadki-użycia-uspace)
  - [Spis treści](#spis-treści)
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
  - [Decyzje otwarte i konsekwencje dla kontraktu](#decyzje-otwarte-i-konsekwencje-dla-kontraktu)

## Aktorzy

- Użytkownik — osoba korzystająca z USpace, z potrzebami dostępności lub bez nich.
- Pomocnik — dobrowolne oznaczenie uczestnictwa niezależne od wskazanych potrzeb i statusu dla miasta.
- Użytkownik ze zweryfikowanym statusem dla konkretnego miasta — zakres potwierdzenia i uprawnień zależy od obsługiwanej integracji.
- Użytkownik bez potwierdzonego statusu dla miasta — brak weryfikacji nie oznacza automatycznie turysty.
- System USpace — dostarcza dane, statusy i dostępne działania.
- Bot weryfikujący — analizuje recenzje po stronie systemu.
- Moderator — rozpatruje treści wymagające moderacji.
- Zewnętrzny operator karty — zgodnie z przyjętym założeniem dostępności API.
- OpenStreetMap — źródło/podkład geograficzny; nie jest źródłem prywatnych profili, punktów ani recenzji USpace.

Etykiety „Miejscowy” i „Turysta” oraz warunki ich wyświetlania pozostają do ustalenia. Status dla jednego miasta nie nadaje takiego samego statusu w innych miastach.

## UC-01 Rejestracja i personalizacja profilu

- Aktorzy: użytkownik, system.
- Warunki wstępne: użytkownik uruchomił aplikację USpace.
- Cel: utworzyć konto i ustawić podstawowy wygląd profilu.

### Scenariusz główny

1. Użytkownik wybiera utworzenie konta.
2. System wyświetla formularz z wymaganymi danymi logowania.
3. Użytkownik uzupełnia formularz i potwierdza rejestrację.
4. System tworzy konto z domyślnym wyglądem i prywatnymi potrzebami. Nie nadaje automatycznie etykiety Turysta na podstawie braku karty.
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

- Karta nieważna lub brak potwierdzenia posiadacza/statusu: komunikat i możliwość poprawienia danych; brak automatycznej zmiany na Turystę.
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
- Warunki wstępne: dostęp online; wymóg konta do samego przeglądania pozostaje do ustalenia.
- Cel: znaleźć miejsce i zrozumieć jego dopasowanie oraz braki informacji.

### Scenariusz główny

1. Użytkownik wybiera miasto lub obszar ręcznie i otwiera mapę albo równoważną listę.
2. System dostarcza miejsca i dane dostępności USpace. Mapa wykorzystuje podkład OSM.
3. System uwzględnia aktywne filtry i przekazuje wyniki z informacją o dopasowaniu.
4. Aplikacja pokazuje te same wyniki i filtry na mapie oraz liście. Przełączenie widoku nie wymaga ponownego wyboru filtrów.
5. Użytkownik wybiera miejsce.
6. System pokazuje wejścia/elementy obiektu, oceny, recenzje, daty obserwacji i weryfikacji oraz utrudnienia tymczasowe.
7. Brak danych jest wyraźnie odróżniony od potwierdzonego spełnienia warunku i od braku udogodnienia.

### Scenariusze alternatywne

- Brak personalizacji: wyniki bez dopasowania do prywatnych potrzeb.
- Brak wyników: pusty wynik z możliwością zmiany obszaru/filtrów, nie komunikat awarii.
- Błąd danych USpace: komunikat błędu i ponowienie.
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
5. Gdy można ocenić jakość, użytkownik wybiera ocenę 1–5 zgodnie z etykietami dla danej cechy. Ocena 3 jest oceną pośrednią, nie brakiem zdania.
6. Użytkownik potwierdza lub zmienia datę wizyty. Godzina jest opcjonalna i wpisywana samodzielnie.
7. Użytkownik potwierdza wysłanie.
8. Aplikacja pokazuje potwierdzenie zapisu, status publikacji, status weryfikacji i status punktów. Zwykła recenzja jest widoczna i oczekuje na weryfikację; wyjątki opisuje UC-08.

### Scenariusze alternatywne

- Nie wiem lub brak możliwości oceny: osobna odpowiedź albo pominięcie, bez wpisywania 3/5.
- Element nie występuje: nie wymusza się oceny jakości ani stanu działania.
- Wszystkie pytania pominięte lub bez obserwacji: prośba o merytoryczną odpowiedź na przynajmniej jeden element albo anulowanie.
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
3. Wybiera „Lajk — potwierdzam” albo „Dislajk — nie potwierdzam”. Ikony mają etykiety dostępne dla czytnika ekranu.
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
- Warunki wstępne: zalogowanie, dostęp do katalogu nagród.
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

1. Użytkownik korzysta z czytelnych etykiet, kontrastów i prostych komunikatów; kolor nie jest jedynym nośnikiem informacji.
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

## Decyzje otwarte i konsekwencje dla kontraktu

1. Etykiety Miejscowy/Turysta i zakres potwierdzenia dla miasta; ważna karta nie dowodzi automatycznie zamieszkania.
2. Pies terapeutyczny: osobna pozycja i jej znaczenie.
3. Wpływ głosów społeczności na akceptację, ukrywanie i usuwanie; progi oraz ranking.
4. Kwalifikacja weryfikatorów, źródła informacji o wizytach i wymagane zgody. Pobyt w okolicy nie dowodzi znajomości konkretnej cechy.
5. Zmiana/cofnięcie głosu, agregacja procentów per cecha i całej recenzji, zasady potwierdzenia jakości głosów do punktów.
6. Mechanizm logowania/sesji, zakres bez konta, wymóg konta przy zgłoszeniach; docelowe systemy Flutter.

Zmiany wymagają późniejszego dostosowania kontraktu v0.1: identyfikacji pojedynczej obserwacji w głosie, liczników przy cechach, usunięcia operacji QR, statusu akceptacji bota i uzupełnienia uzgodnionego modelu sesji. Nie traktujemy starej propozycji głosowania na całą recenzję jako zatwierdzonej. W tym zadaniu aktualizujemy use case’y i pamięć decyzji, bez implementacji ani publikacji zmian w Git.
