# KindSpot — CP-02: dostępność funkcjonalna

Aktualizacja: 2026-10-03. Decyzja użytkownika: teraz funkcjonalność i dostępność; końcowym projektem graficznym zajmie się później inna osoba. CP-01 odebrany. CP-02 pozostaje w trakcie, według nowych kryteriów; wcześniejsze oddanie wyglądu nie jest odbiorem dostępności.

## Zakres i podstawa

Sprawdzamy wszystkie kryteria WCAG 2.2 poziomów A i AA: 55 pozycji. Numery i poziomy według [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/) oraz [listy kryteriów W3C](https://www.w3.org/WAI/WCAG22/quickref/). Nazwy poniżej są skrótami roboczymi, nie oficjalnym tłumaczeniem. 4.1.1 jest usunięte w WCAG 2.2 i nie wchodzi do tej listy.

Interpretację dla natywnej aplikacji Flutter opieramy na [W3C WCAG2ICT](https://www.w3.org/TR/wcag2ict-22/). Jest to wskazówka stosowania do oprogramowania poza WWW, nie certyfikat ani nowa norma zgodności. Kryteria zależne od technologii mają wyjaśnione zastosowanie. Nie przenosimy automatycznie wymogów HTML/CSS do Androida.

Badamy aktualne ekrany i pełne istniejące ścieżki: start/odczyt i błąd profilu, ręczne wejście demo, mapa/lista, miasto, wyszukiwanie, filtry, potrzeby, szczegóły miejsca, profil/prywatność, ustawienia, Zapisane/Proponowane, odczyt recenzji i symulację nagród, potwierdzenia i wyjście. Ustawienia dostępności muszą być dostępne również przed wejściem na konto.

Ankieta i publikacja recenzji pozostają odłożone. CP-08 dodał odczyt demonstracyjnych recenzji, CP-09 przykłady stanu karty, a CP-10 symulację nagrody. Nie implementujemy rzeczywistego logowania, kart ani ekonomii nagród. Kryteria dotyczące tych przyszłych funkcji są przypisane do późniejszych checkpointów; nie otrzymują fikcyjnego wyniku pozytywnego. Nie wymuszamy deklarowania niepełnosprawności, aby korzystać z udogodnień. Potrzeby pozostają prywatne domyślnie.

WCAG obejmuje wiele potrzeb, lecz nie wszystkie potrzeby każdej osoby. Dlatego kompletna lista kryteriów musi być uzupełniona testami z użytkownikami o różnych i łączonych potrzebach. Nie używamy etykiety „wszystkie niepełnosprawności obsłużone” jako wyniku automatycznego testu. [Zakres WCAG](https://www.w3.org/TR/WCAG22/#abstract).

## Co ma umożliwiać aplikacja

| Potrzeby | Zachowanie wymagane w szkielecie | Sposób odbioru |
|---|---|---|
| Niewidzenie, słabowidzenie | Nazwane kontrolki, odczytywane stany i nagłówki, logiczna kolejność, lista zamiast mapy, odczyt błędów i zmian | Semantyka Flutter oraz ręczny TalkBack; VoiceOver przed deklaracją obsługi iOS |
| Daltonizm, powiększanie, słaby kontrast | Tekst i ikona opisują status; kontrast każdego faktycznego koloru; tekst 200%, wąski ekran i orientacja pozioma | Pomiary komponentów i testy wszystkich ekranów; ustawienia Androida |
| Ograniczona sprawność rąk | Duże cele dotykowe, aktywacja po zwolnieniu, brak konieczności szczypania/przeciągania, obsługa klawiatury i przełączników | Testy klawiatury i dotyku; Switch Access na urządzeniu |
| Głuchota i niedosłuch | Wszystkie informacje i błędy dostępne tekstowo; brak czynności wymagającej usłyszenia dźwięku | Pełna ścieżka przy wyciszeniu; multimedia ponownie oceniane po ich dodaniu |
| Trudności z mową | Wprowadzanie danych i wykonanie czynności bez mówienia | Dotyk/klawiatura; ewentualne dyktowanie nie może być obowiązkowe |
| Trudności poznawcze, orientacja, czytanie | Jasne nazwy, stałe czynności, przewidywalne cofanie, instrukcje, zachowanie wyborów po błędzie, bez presji czasu | Zadania z użytkownikami; testy błędów i formularzy |
| Wrażliwość na ruch i błyski | Brak migających dekoracji; respektowanie ograniczenia animacji aplikacji i systemu | Przegląd animacji oraz test rzeczywistych przejść na urządzeniu |

## Stan wyjściowy — dowody i ograniczenia

Przejrzano lib/ui/*.dart, app_controller.dart oraz testy. 2026-10-03 ponownie wykonano 35 istniejących testów: wszystkie przeszły. Log: frontend/mobile/build/wcag-baseline.log. To regresja szkieletu, nie kompletny audyt WCAG.

Dotychczasowe dowody: kontrast wybranych par ColorScheme w sześciu motywach, część UI przy szerokości 320 i skali 200%, etykiety i rozmiary dolnego menu, powrót z ustawień/filtrów, dialog wyjścia, zapis/błąd zapisu i braki danych. Te testy nie obejmują każdej barwy ani wszystkich pól, dialogów i ekranów.

Nowy pomiar ujawnił konkretny błąd: stały kolor `muted` (#52645F) użyty w PlaceCard na tle surfaceContainerLow ma w ciemnych motywach kontrast **2.73:1–2.74:1**, przy jasnych 5.68:1–5.69:1. Dotyczy m.in. opisów cech i daty obserwacji. Wynik nie spełnia przyjętego progu dla małego tekstu. Pomiar wykonano przez Flutter: frontend/mobile/build/wcag_probe_test.dart. Pomyślne zakończenie skryptu pomiarowego nie oznacza spełnienia kryterium. Do poprawy w CP-02.

Emulatora nie uruchomiono. TalkBack, VoiceOver, Switch Access, głosowe sterowanie, pełne przejście klawiaturą i testy z użytkownikami nie są wykonane. W tym zadaniu zmieniono wymagania/checklistę i wykonano porównanie; nie zmieniono kodu aplikacji ani APK.

## Macierz A/AA

Każdy wiersz ma własny zakres i wynik. „Częściowo” oznacza istniejący mechanizm z niepełnym sprawdzeniem. „Do testu” oznacza brak wystarczającego dowodu. „Do poprawy” to potwierdzony problem lub brak potrzebnego mechanizmu. „Nie dotyczy teraz” wymaga podanego uzasadnienia i ponownej oceny po zmianie funkcji. „Późniejszy etap” nie oznacza zgodności nieistniejącej funkcji. Żaden wiersz „Do testu” nie może zostać zamieniony na „spełnione” na podstawie samej obecności standardowego widgetu Material.

### Postrzeganie

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie | Etap odpowiedzialny; zawsze regresja CP-12 |
|---|---|---|---|---|
| 1.1.1 Alternatywy tekstowe | A | Częściowo | Pinezki/ikony przycisków mają tooltipy, statusy tekst. Sprawdzić nazwy kart miejsc, dekoracje oraz kompletność równoważnej listy czytnikiem. | CP-04/06 (mapa/karty), CP-07 (przyszłe zdjęcia) |
| 1.2.1 Nagrania audio/wideo | A | Nie dotyczy teraz | Brak odtwarzanych nagrań. Przy dodaniu mediów przygotować odpowiednie alternatywy. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.2.2 Napisy nagrań | A | Nie dotyczy teraz | Brak nagrań wymagających napisów. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.2.3 Audiodeskrypcja/alternatywa | A | Nie dotyczy teraz | Brak takich nagrań. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.2.4 Napisy transmisji | AA | Nie dotyczy teraz | Brak transmisji. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.2.5 Audiodeskrypcja nagrań | AA | Nie dotyczy teraz | Brak takich nagrań. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.3.1 Struktura informacji | A | Częściowo | SectionTitle ma rolę nagłówka; standardowe pola mają etykiety. Sprawdzić powiązania każdej cechy z jej polem i odczytywanie wybranych wartości. | CP-03/05/06/07/09 (pola i treści) |
| 1.3.2 Kolejność | A | Do testu | Zweryfikować czytnikiem i klawiaturą kolejność pól, listy, mapy oraz adaptacyjnego menu; pozaekranowe sekcje nie mogą przejmować fokusu. | CP-02 (menu), CP-03–10 (kolejność ekranów) |
| 1.3.3 Wskazówki sensoryczne | A | Częściowo | Tekst nazw czynności istnieje. Instrukcje nie mogą opierać się tylko na kolorze, położeniu lub kształcie; przegląd wszystkich komunikatów. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.3.4 Orientacja | AA | Do testu | Nie znaleziono blokady orientacji. Przejść wszystkie ekrany w pionie i poziomie, także z dużym tekstem i klawiaturą. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.3.5 Cel pól | AA | Późniejszy etap | Obecnie brak formularza tożsamości z takimi danymi osobowymi. W CP-03 dobrać autofill i typy pól zgodnie z mechanizmem logowania. | CP-03 (autofill przy uzgodnionym logowaniu) |
| 1.4.1 Informacja bez koloru | A | Częściowo | StatusTag ma tekst i różne ikony; potrzeby/filtry opisowe. Sprawdzić także zaznaczenie, fokus, błędy i wszystkie stany kontrolek. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.4.2 Sterowanie dźwiękiem | A | Nie dotyczy teraz | Brak dźwięku odtwarzanego automatycznie przez aplikację. | Etap dodający multimedia; CP-12 ponowna ocena; brak mediów obecnie |
| 1.4.3 Kontrast tekstu | AA | Częściowo | CP-04: opisy i daty PlaceCard używają onSurfaceVariant zamiast stałego muted. Kontrast faktycznych par kart sprawdzony automatycznie. Pozostałe szczegóły/ekrany i końcowa grafika wymagają dalszego sprawdzenia. | CP-02 (motyw), CP-06 (szczegóły), CP-12 (grafika) |
| 1.4.4 Powiększenie tekstu | AA | Częściowo | CP-06–10: nowe szczegóły/zapisane, odczyt recenzji, profil i nagrody sprawdzone przy 320 px/200%; CP-12 dodatkowo 800×360/200%, szczegóły/recenzje/prywatność/nagroda. Rzeczywiste powiększenie na urządzeniu nadal do wykonania. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.4.5 Tekst jako tekst | AA | Częściowo | Treści interfejsu to Text, bez banerów zastępujących tekst. Podkład mapy nie może być jedynym źródłem nazw/danych miejsc. | CP-04/06 (lista i opisy), CP-12 (grafika) |
| 1.4.10 Układ bez utraty treści | AA | Częściowo | Pionowe przewijanie i adaptacyjne menu; testy CP-12 poziom 800×360/200% dla istniejących ścieżek demo bez utraty przycisków. Pełna klawiatura ekranowa i urządzenie nadal do testu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.4.11 Kontrast kontrolek | AA | Do testu | Poprzednie pomiary dotyczą tekstu. Zmierzyć rozpoznawalne granice i stany przycisków/pól, przełączników, pinezek oraz fokusu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.4.12 Odstępy tekstu | AA | Nie dotyczy teraz wprost | Natywne widgety Flutter nie są językiem znaczników z użytkowym nadpisywaniem odstępów. Według WCAG2ICT warunek technologiczny nie zachodzi; czytelność nadal testujemy. Dla przyszłego HTML/WebView ocenić ponownie. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 1.4.13 Treść hover/fokus | AA | Do testu | Są Tooltipy. Sprawdzić ich zamykanie, trwałość i dostępność przy fokusie/wskaźniku; nie może w nich być jedynej ważnej informacji. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |

### Obsługa

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie | Etap odpowiedzialny; zawsze regresja CP-12 |
|---|---|---|---|---|
| 2.1.1 Klawiatura | A | Do testu | Sprawdzić Tab/Shift+Tab, Enter/Space, strzałki, Escape: menu, filtry, potrzeby, listę, szczegóły, ustawienia i dialogi. Nie wymagać manipulacji mapą. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.1.2 Brak pułapki fokusu | A | Do testu | Wejście i wyjście z dropdownów/dialogów; powrót bez utraty możliwości dalszej obsługi. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.1.4 Skróty znakowe | A | Nie dotyczy teraz | Brak własnych skrótów pojedynczym znakiem. Nie dodawać bez możliwości wyłączenia/przypisania lub ograniczenia do fokusu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.2.1 Czas na czynności | A | Częściowo | Formularze bez limitu czasu. Snackbar błędu znika; sprawdzić platformowe wydłużanie i zapewnić trwały błąd/możliwość odczytania oraz ponowienia. Sesje później w CP-03. | CP-03 (sesja), CP-05/09 (trwałe błędy), CP-10/11 (operacje API) |
| 2.2.2 Ruch/aktualizacja | A | Częściowo | Brak karuzel i ruchomych dekoracji. Sprawdzić ładowanie, aktualizację wyników i faktyczne działanie ograniczania animacji; uzasadnić wyjątki dla potrzebnego postępu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.3.1 Błyski | A | Do testu | Brak widocznej w kodzie dekoracji migającej; przejrzeć rzeczywiste przejścia i stany ładowania. Ponowna ocena po dodaniu grafiki/mediów. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.4.1 Pomijanie bloków | A | Nie dotyczy teraz wprost | WCAG2ICT wskazuje zakres zestawów dokumentów/oprogramowania; pojedyncza aplikacja nie jest zestawem stron WWW. Dostęp do głównej treści i pomijanie mapy pozostają wymaganiem produktu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.4.2 Nazwa ekranu | A | Częściowo | Są widoczne tytuły, ale zmiana sekcji IndexedStack wymaga sprawdzenia ogłoszenia nazwy/semantyki trasy. | CP-03–10 (nazwy tras), CP-02 (sekcje) |
| 2.4.3 Porządek fokusu | A | Częściowo | Częściowo sprawdzone automatycznie: ExcludeFocus/ExcludeSemantics dla ukrytych sekcji, 24×Tab na Nagrodach omija ukrytą mapę; Escape i powrót tras w CP-12. Pełna kolejność/powrót fokusu na urządzeniu nadal wymagają testu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.4.4 Cel odnośników | A | Częściowo | CP-04: polska etykieta „Autorzy OpenStreetMap — informacje i licencja”; poza viewportem mapy, trwały błąd z adresem przy nieudanym otwarciu. Czytnik/otwarcie systemowe do sprawdzenia na urządzeniu. | CP-04 (odnośnik OSM), CP-10 (odbiór) |
| 2.4.5 Różne drogi dostępu | AA | Nie dotyczy teraz wprost | Jeden program, bez zestawu dokumentów/programów w rozumieniu WCAG2ICT. Mapa i lista są dodatkowo wymagane przez produkt; nie traktować ich jako samodzielnego dowodu zgodności tego kryterium. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.4.6 Nagłówki/etykiety | AA | Częściowo | Są nazwy sekcji i etykiety pól. Powtarzalne „Znaczenie cechy” musi mieć zrozumiały kontekst konkretnej cechy przy odczycie. | CP-03/05/07 (nazwy pól), CP-06/09 (sekcje) |
| 2.4.7 Widoczny fokus | AA | Do testu | Menu ma focusColor, Material swoje stany. Zweryfikować widoczność na każdej kontrolce i w każdym motywie. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.4.11 Niezasłonięty fokus | AA | Do testu | Sprawdzić pasek menu, klawiaturę ekranową, snackbar i przewijanie tak, aby aktywny element nie był całkowicie zasłonięty. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.5.1 Gesty | A | Częściowo | Zoom ma +/− i jest lista. Pełną ścieżkę wykonać pojedynczymi aktywacjami bez szczypania; nie pomijać funkcji dostępnych tylko na mapie. | CP-04 (mapa/lista/zoom), CP-05/07 (wybory bez gestów) |
| 2.5.2 Anulowanie aktywacji | A | Do testu | Kod używa onTap/onPressed. Sprawdzić wciśnięcie, przesunięcie poza element i zwolnienie, także przy potwierdzeniach i przełącznikach. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.5.3 Widoczna nazwa | A | Częściowo | Menu ma zgodne nazwy semantyczne. Sprawdzić pozostałe etykiety, pinezki, karty i rozpoznanie nazw przez sterowanie głosowe. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.5.4 Ruch urządzenia | A | Nie dotyczy teraz | Brak czynności sterowanych potrząsaniem/przechyleniem. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 2.5.7 Bez przeciągania | AA | Częściowo | Lista i przyciski zoom zapewniają alternatywy części działań mapy. Sprawdzić równoważność całej ścieżki i obsługę przewijania technologiami asystującymi. | CP-04 (mapa/lista), CP-05/07 (formularze) |
| 2.5.8 Cele dotykowe | AA | Częściowo | Pomierzone menu i głosy CP-08 ≥48; kontrolki recenzji/nagrody sprawdzone w wąskim UI. Pełny pomiar wszystkich kontrolek, pinezek, linków i cofania oraz urządzenie nadal do wykonania. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |

### Zrozumiałość

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie | Etap odpowiedzialny; zawsze regresja CP-12 |
|---|---|---|---|---|
| 3.1.1 Język | A | Częściowo | MaterialApp locale pl i polskie lokalizacje. Sprawdzić wymowę treści przez TalkBack/VoiceOver. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.1.2 Fragmenty językowe | AA | Częściowo | Atrybucja CP-04 po polsku, OpenStreetMap jako nazwa własna. Treści z przyszłego API/recenzji i czytnik nadal do weryfikacji. | CP-04 (atrybucja), CP-06/08 (treść miejsc/recenzji) |
| 3.2.1 Sam fokus | A | Do testu | Sprawdzić, że przesunięcie fokusu nie uruchamia akcji/zmiany ekranu ani zapisu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.2.2 Zmiana danych | A | Częściowo | Motywy i miasto aktualizują wynik, potrzeby/filtry zapis przyciskiem. Sprawdzić brak nieoczekiwanych przejść i czytelny sposób zapisu. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.2.3 Stała nawigacja | AA | Częściowo | Kolejność menu jest stała; adaptacyjny układ i trasy zweryfikować wszystkimi metodami obsługi. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.2.4 Stałe nazwy czynności | AA | Częściowo | Wspólne przyciski/statusy istnieją. Przejrzeć rozbieżne nazwy dostępu do tych samych ustawień i stanów. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.2.6 Stała pomoc | A | Nie dotyczy teraz | Brak mechanizmu kontaktowej pomocy wymienionego w kryterium. Jeśli zostanie dodany, musi być w konsekwentnym miejscu. Ustawienia dostępności nadal łatwo dostępne. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 3.3.1 Błędy danych | A | Częściowo | CP-03–06/08–10: trwałe błędy, retry i zachowanie potwierdzonego stanu przy zapisie; profil/prywatność, lokalne zgłoszenia i schowek nagrody testowane. CP-11 typed errors przygotowane, API i ankieta odłożone. | CP-03/04/05/07/09/10/11 (błędy operacji/pól) |
| 3.3.2 Instrukcje pól | A | Częściowo | Są etykiety i znaczenie reguł. Sprawdzić kontekst cechy, skali i utraty niezapisanej edycji. | CP-03/05/07/09/10 (instrukcje) |
| 3.3.3 Pomoc po błędzie | AA | Częściowo | Jest ponowienie i zachowanie wyborów. Przetestować błąd przy zapisie UI, nie tylko repozytorium; przyszłe błędy logowania w CP-03. | CP-03/05/07/09/10/11 (ponowienie) |
| 3.3.4 Zapobieganie pomyłkom | AA | Częściowo | Usunięcie lokalnych danych i upublicznienie potrzeb mają potwierdzenie. Sprawdzić ich odczyt i możliwość anulowania; zakupy/operacje backendu później. | CP-09 (prywatność/usunięcie), CP-10 (zakup), CP-11 (API) |
| 3.3.7 Bez ponownego wpisywania | A | Częściowo | Potrzeby/filtry inicjalizują się z profilu. Zweryfikować zachowanie formularza po nieudanym zapisie. Zasady szkicu po cofnięciu wymagają decyzji; nie zakładamy ich. | CP-03/05 (profil/filtry), CP-07 (szkic), CP-09/10 (operacje) |
| 3.3.8 Dostępne uwierzytelnienie | AA | Późniejszy etap | Auto-konto demo nie sprawdza uwierzytelnienia. W CP-03 ocenić rzeczywisty mechanizm, wklejanie, autofill i alternatywy wobec testów poznawczych. | CP-03 (mechanizm konta), CP-11 (rzeczywiste API) |

### Współpraca z technologiami asystującymi

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie | Etap odpowiedzialny; zawsze regresja CP-12 |
|---|---|---|---|---|
| 4.1.2 Nazwa/rola/stan | A | Częściowo | Kontekst cechy/wejścia i odróżnienie braku danych od zera; stany zapisu, celu głosów, prywatności i symulacji jawne. Testy semantyki modułów są częściowe; TalkBack/VoiceOver pozostają niewykonane. | CP-02 (wspólne kontrolki); każdy nowy ekran CP-03–10 |
| 4.1.3 Komunikaty zmian | AA | Częściowo | CP-04: wyniki po 600 ms ciszy. CP-05–10: trwałe błędy i potwierdzenia lokalnych operacji/statusów z liveRegion. Faktyczny odczyt czytnika oraz kolejność komunikatów na urządzeniu nadal do testu. | CP-03 (wejście/wyjście), CP-04 (wyniki/mapa), CP-05/07/09/10/11 (zapis/status) |

## Kolejność domknięcia CP-02

1. **Zakres i macierz:** niniejszy dokument oraz zmiana checkpointów/źródeł/pamięci — wykonane. Nie jest to zakończenie CP-02.
2. **Poprawki potwierdzonych luk i testy komponentów:** kolory opisów na kartach; pełny pomiar tekstu i kontrolek/fokusu; kontekst pól filtrów; trwałe błędy i komunikaty zmian; semantyka nazw tras/kart oraz fokus. Przy niezapisanej edycji najpierw rozstrzygnąć scenariusz w DO-USTALENIA.md.
3. **Regresja pełnych ścieżek:** duży tekst, wąski ekran i poziom; wszystkie formy i dialogi; brak utraty treści po błędzie; klawiatura i aktywacja bez przeciągania. Automatyczne guideline-testy Flutter są narzędziem częściowego sprawdzenia, nie całą normą. [Testy dostępności Flutter](https://docs.flutter.dev/ui/accessibility/accessibility-testing).
4. **Odbiór na urządzeniu:** ręcznie TalkBack, Switch Access, klawiatura i sterowanie głosowe na Androidzie uruchomionym przez użytkownika lub fizycznym telefonie. VoiceOver na iOS po uzyskaniu środowiska i przed deklaracją tej platformy. Testy z użytkownikami o różnych potrzebach; odnotować urządzenie, wersję, ścieżkę, wynik i poprawki.

CP-02 można odebrać dla jawnie określonej platformy i istniejących ścieżek dopiero po naprawieniu problemów stosowalnych kryteriów oraz zebraniu odpowiednich dowodów. Niewykonany test ręczny pozostaje niewykonany. Odroczenie sprawdzenia wymaga jawnej decyzji i nie daje podstaw do deklaracji pełnej zgodności. Kryterium niestosowalne ma uzasadnienie; kryterium przyszłej funkcji ma właściciela/checkpoint, a nie sukces.

## Protokół testów ręcznych

| Zadanie | Warunki | Oczekiwany rezultat |
|---|---|---|
| Wyszukaj i otwórz miejsce bez mapy | TalkBack, ekran wyłączony lub bez opierania się na widoku | Odczytywane wyniki i dostępność, wybór miejsca, dane szczegółowe i powrót |
| Ustaw potrzebę i filtr | TalkBack oraz Switch Access | Nazwa cechy i wartości, stan wyboru, dostępny zapis; nie trzeba trafić w małą ikonę |
| Przejdź główną ścieżkę klawiaturą | Tab/Shift+Tab, aktywacja, Escape | Widoczny i niezasłonięty fokus, logiczna kolejność, możliwość zamknięcia dialogów |
| Zapisz po awarii | Wymuszony błąd magazynu/sieci testowej | Trwały zrozumiały komunikat, zachowane wybory, odczyt błędu i możliwość ponowienia |
| Powiększ tekst i obróć ekran | 200%, wąski ekran, pion/poziom, klawiatura ekranowa | Wszystkie teksty i akcje osiągalne, bez utraty opcji dropdownów i przycisków |
| Obsłuż prywatność i wyjście | Czytnik/klawiatura; potwierdź i anuluj | Nazwane dialogi, poprawny fokus, zrozumiały rezultat i brak niezamierzonej operacji |

## Wymagania dla późniejszego projektu graficznego

Obecna paleta i układ są robocze. Zmiana grafiki może przebudować je, zachowując funkcjonalne udogodnienia i wymagania dostępności. Przekazanie zawiera macierz oraz testy; po zmianie stylu ponownie sprawdzamy kontrast, skalowanie, cele dotykowe, fokus, kolejność czytnika i wszystkie zmienione ścieżki. Poprzedni wynik dla starych kolorów nie odbiera nowych kolorów.

Praktyczny cel projektu dla dotykowych kontrolek Flutter to co najmniej 48×48 jednostek logicznych. Nie nazywamy tego dosłownym minimum WCAG AA: webowe 2.5.8 opisuje 24 CSS px i wyjątki. [W3C 2.5.8](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html). Kontrast wymaganych wizualnych identyfikatorów kontrolek badamy także osobno od tekstu. [W3C 1.4.11](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html).

PJM każdego ekranu, osobny ETR, fotografie i dyktowanie nie są automatycznie wymaganiami A/AA dla tego szkieletu. Ich potrzebę ustalamy z odbiorcami i modelem wdrożenia. Ograniczenie animacji jest utrzymanym wymaganiem produktu, również tam, gdzie wykracza ponad A/AA. Prosty język stosujemy w całej aplikacji; sam krótki tekst nie jest certyfikowanym ETR. Pełnego pliku kindspot-instrukcja-dostepnosc.md nadal nie otrzymano — dodatkowych wskazanych w nim reguł nie uznajemy za przeczytane.

## Ankieta recenzji — 2026-10-03

Ankietę wznowiono na polecenie użytkownika; jej ekrany wchodzą do zakresu kryteriów A/AA. Wykonano: testy widżetów Fluttera `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` i `textContrastGuideline` na ekranie pytania; przebieg przy szerokości 320 i tekście 200% w jasnym i ciemnym motywie; trwały komunikat braku odpowiedzi z `liveRegion`; cofanie krok po kroku z zachowaniem szkicu. Niewykonane: TalkBack, Switch Access, klawiatura i VoiceOver na urządzeniu oraz testy z użytkownikami. Pełne wymagania: kindspot-instrukcja-dostepnosc.md.

## Rozdzielenie prac — decyzja użytkownika po zmianie struktury

Użytkownik zlecił rozpoczęcie CP-03 i przypisanie braków macierzy do odpowiednich checkpointów. To upoważnienie do przejścia dalej bez deklaracji, że CP-02/WCAG zostały odebrane. Macierz nadal ma 55 pozycji, teraz z kolumną odpowiedzialnego etapu; wynik dotyczy konkretnego ekranu, a nie całego kryterium raz na zawsze. Każdy etap domyka swoje pola, statusy i ścieżki, CP-02 utrzymuje wspólne mechanizmy, CP-12 sprawdza całość i zmianę grafiki. Media niestosowalne mają właściciela warunkowego przy ich dodaniu, bez rozszerzania obecnego zakresu.

CP-03 demo: dodano jawne wejście/wyjście, trwały błąd wejścia/wyjścia, blokadę ponownej operacji, aktywację wejścia klawiaturą, usuwanie tras prywatnych po wyjściu. Weryfikacja lokalnych testów nie zamyka ręcznych testów czytnika ani kryterium rzeczywistego uwierzytelniania 3.3.8. Metoda produkcyjna, autofill i obsługa sesji API pozostają do ustalenia/podłączenia.

## Decyzje CP-04 i CP-05 — 2026-10-03

Użytkownik zlecił równoległe wykonanie CP-04 i CP-05 z dodatkowym agentem. Nie oznacza to odbioru pełnego CP-02/WCAG ani produkcyjnego uwierzytelnienia CP-03.

- Najlepsze miejsca: średnia ocen malejąco ma bezwzględny priorytet; przy tej samej średniej wyżej jest więcej recenzji. Osobna opcja „Najwięcej recenzji” sortuje liczbę malejąco. Nie wyliczamy średniej miejsca ze średnich cech.
- Na potrzeby happy case okolica obejmuje całe wybrane miasto. Proponowane miejsca stosują zapisane filtry i wybraną kolejność, bez dodatkowego promienia ani potwierdzania wizyty.
- Komentarze: użytkownik wskazał największy stosunek lajków do dislajków. Implementacja należy do CP-08; zero dislajków, remisy i powiązanie z głosami per obserwacja nadal wymagają doprecyzowania. Nie zmieniamy teraz jednostki głosowania ani nie tworzymy komentarzy.
- Demo ma jawnie fikcyjne średnie i liczby recenzji; brak średniej/licznika pozostaje brakiem danych. Domyślna kolejność demo to najlepsza ocena, ostatni wybór jest zapisany lokalnie. Dla sortowania liczby techniczny remis rozstrzyga średnia, potem nazwa/ID; ostatnie klucze nie stanowią nowej reguły produktu.
- Miasto można ustalić po wybraniu „Użyj lokalizacji telefonu”. Demo rozpoznaje systemową nazwę miejscowości dla Krakowa/Warszawy w Polsce; nie zgaduje najbliższego miasta. Odmowa, wyłączona usługa, brak rozpoznania i inne miasta pozostawiają ręczny wybór. Zapisujemy tylko identyfikator miasta, bez współrzędnych/śledzenia w tle. Geokodowanie systemowe może użyć sieci.
- Potrzeby/filtry: zapis dopiero przyciskiem, czyszczenie zmienia szkic i wyłącza dołączenie braków danych; bez zapisu potwierdzone filtry pozostają. Trwały błąd zachowuje wybory. Presety oraz sugestie cech pozostają przykładami PoC, nie zatwierdzoną klasyfikacją potrzeb. Potrzeby prywatne domyślnie.

Operator produkcyjnej mapy, dane API i zakres agregacji recenzji dla średniej nadal należą do kontraktu CP-11. Synchronizacja filtrów i scenariusz szkicu po cofnięciu pozostają otwarte. Wyniki automatyczne nie zastępują testów lokalizacji/TalkBack na urządzeniu; emulator uruchamia tylko użytkownik. Szczegóły odbioru: KindSpot-CP04-CP05.md.

## CP-06–12 — końcowe sprawdzenie PoC

Analiza bez uwag; 131 testów przeszło; APK debug zbudowane (189263704 bajtów, 2026-10-03 21:59:03). Emulator nie był uruchamiany. Raport: KindSpot-CP06-CP12.md. Ankieta odłożona i przygotowany SurveyBuilder, brak API dla PoC, głosy/ranking oczekują odpowiedzi. CP-02 i odbiór ręczny CP-12 niezamknięte.


Aktualizacja testowego sklepu 2026-10-03: 162 testy regresji przechodzą; pastelowy zielony dołączony do kontroli kontrastu jasnego/ciemnego/wysokiego kontrastu. Nowe przebiegi sklepu/poradnika/dialogu nazwy sprawdzone przy 200% i orientacji pionowej/poziomej; sklep spełnia automatyczne kontrole tekstu, etykiet i celów dotykowych Androida. Szczegóły w KindSpot-sklep-testowy.md. Statusy niewykonanych sprawdzeń urządzenia/czytników pozostają bez zmiany; to nie pełny odbiór WCAG.
