# KindSpot — CP-02: dostępność funkcjonalna

Aktualizacja: 2026-10-03. Decyzja użytkownika: teraz funkcjonalność i dostępność; końcowym projektem graficznym zajmie się później inna osoba. CP-01 odebrany. CP-02 pozostaje w trakcie, według nowych kryteriów; wcześniejsze oddanie wyglądu nie jest odbiorem dostępności.

## Zakres i podstawa

Sprawdzamy wszystkie kryteria WCAG 2.2 poziomów A i AA: 55 pozycji. Numery i poziomy według [W3C WCAG 2.2](https://www.w3.org/TR/WCAG22/) oraz [listy kryteriów W3C](https://www.w3.org/WAI/WCAG22/quickref/). Nazwy poniżej są skrótami roboczymi, nie oficjalnym tłumaczeniem. 4.1.1 jest usunięte w WCAG 2.2 i nie wchodzi do tej listy.

Interpretację dla natywnej aplikacji Flutter opieramy na [W3C WCAG2ICT](https://www.w3.org/TR/wcag2ict-22/). Jest to wskazówka stosowania do oprogramowania poza WWW, nie certyfikat ani nowa norma zgodności. Kryteria zależne od technologii mają wyjaśnione zastosowanie. Nie przenosimy automatycznie wymogów HTML/CSS do Androida.

Badamy aktualne ekrany i pełne istniejące ścieżki: start/odczyt i błąd profilu, ręczne wejście demo, mapa/lista, miasto, wyszukiwanie, filtry, potrzeby, szczegóły miejsca, profil/prywatność, ustawienia, informacyjne Zapisane/Proponowane/Nagrody, potwierdzenia i wyjście. Ustawienia dostępności muszą być dostępne również przed wejściem na konto.

Nie implementujemy w tym etapie ankiety, recenzji, rzeczywistego logowania, kart ani ekonomii nagród. Kryteria dotyczące tych przyszłych funkcji są przypisane do późniejszych checkpointów; nie otrzymują fikcyjnego wyniku pozytywnego. Nie wymuszamy deklarowania niepełnosprawności, aby korzystać z udogodnień. Potrzeby pozostają prywatne domyślnie.

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

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie |
|---|---|---|---|
| 1.1.1 Alternatywy tekstowe | A | Częściowo | Pinezki/ikony przycisków mają tooltipy, statusy tekst. Sprawdzić nazwy kart miejsc, dekoracje oraz kompletność równoważnej listy czytnikiem. |
| 1.2.1 Nagrania audio/wideo | A | Nie dotyczy teraz | Brak odtwarzanych nagrań. Przy dodaniu mediów przygotować odpowiednie alternatywy. |
| 1.2.2 Napisy nagrań | A | Nie dotyczy teraz | Brak nagrań wymagających napisów. |
| 1.2.3 Audiodeskrypcja/alternatywa | A | Nie dotyczy teraz | Brak takich nagrań. |
| 1.2.4 Napisy transmisji | AA | Nie dotyczy teraz | Brak transmisji. |
| 1.2.5 Audiodeskrypcja nagrań | AA | Nie dotyczy teraz | Brak takich nagrań. |
| 1.3.1 Struktura informacji | A | Częściowo | SectionTitle ma rolę nagłówka; standardowe pola mają etykiety. Sprawdzić powiązania każdej cechy z jej polem i odczytywanie wybranych wartości. |
| 1.3.2 Kolejność | A | Do testu | Zweryfikować czytnikiem i klawiaturą kolejność pól, listy, mapy oraz adaptacyjnego menu; pozaekranowe sekcje nie mogą przejmować fokusu. |
| 1.3.3 Wskazówki sensoryczne | A | Częściowo | Tekst nazw czynności istnieje. Instrukcje nie mogą opierać się tylko na kolorze, położeniu lub kształcie; przegląd wszystkich komunikatów. |
| 1.3.4 Orientacja | AA | Do testu | Nie znaleziono blokady orientacji. Przejść wszystkie ekrany w pionie i poziomie, także z dużym tekstem i klawiaturą. |
| 1.3.5 Cel pól | AA | Późniejszy etap | Obecnie brak formularza tożsamości z takimi danymi osobowymi. W CP-03 dobrać autofill i typy pól zgodnie z mechanizmem logowania. |
| 1.4.1 Informacja bez koloru | A | Częściowo | StatusTag ma tekst i różne ikony; potrzeby/filtry opisowe. Sprawdzić także zaznaczenie, fokus, błędy i wszystkie stany kontrolek. |
| 1.4.2 Sterowanie dźwiękiem | A | Nie dotyczy teraz | Brak dźwięku odtwarzanego automatycznie przez aplikację. |
| 1.4.3 Kontrast tekstu | AA | Do poprawy | Potwierdzony zbyt niski kontrast muted w ciemnych kartach. Objąć testami wszystkie faktycznie używane pary, także etykiety, daty, dialogi i błędy. |
| 1.4.4 Powiększenie tekstu | AA | Częściowo | Są testy 200% części ekranów. Brakuje pełnego przejścia potrzeb, filtrów, szczegółów i dialogów, w tym długich wybranych opcji list. |
| 1.4.5 Tekst jako tekst | AA | Częściowo | Treści interfejsu to Text, bez banerów zastępujących tekst. Podkład mapy nie może być jedynym źródłem nazw/danych miejsc. |
| 1.4.10 Układ bez utraty treści | AA | Częściowo | Adaptacyjne menu i pionowe przewijanie. Sprawdzić wszystkie ekrany na wąskim obszarze i w poziomie; lista musi działać poza mapą. |
| 1.4.11 Kontrast kontrolek | AA | Do testu | Poprzednie pomiary dotyczą tekstu. Zmierzyć rozpoznawalne granice i stany przycisków/pól, przełączników, pinezek oraz fokusu. |
| 1.4.12 Odstępy tekstu | AA | Nie dotyczy teraz wprost | Natywne widgety Flutter nie są językiem znaczników z użytkowym nadpisywaniem odstępów. Według WCAG2ICT warunek technologiczny nie zachodzi; czytelność nadal testujemy. Dla przyszłego HTML/WebView ocenić ponownie. |
| 1.4.13 Treść hover/fokus | AA | Do testu | Są Tooltipy. Sprawdzić ich zamykanie, trwałość i dostępność przy fokusie/wskaźniku; nie może w nich być jedynej ważnej informacji. |

### Obsługa

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie |
|---|---|---|---|
| 2.1.1 Klawiatura | A | Do testu | Sprawdzić Tab/Shift+Tab, Enter/Space, strzałki, Escape: menu, filtry, potrzeby, listę, szczegóły, ustawienia i dialogi. Nie wymagać manipulacji mapą. |
| 2.1.2 Brak pułapki fokusu | A | Do testu | Wejście i wyjście z dropdownów/dialogów; powrót bez utraty możliwości dalszej obsługi. |
| 2.1.4 Skróty znakowe | A | Nie dotyczy teraz | Brak własnych skrótów pojedynczym znakiem. Nie dodawać bez możliwości wyłączenia/przypisania lub ograniczenia do fokusu. |
| 2.2.1 Czas na czynności | A | Częściowo | Formularze bez limitu czasu. Snackbar błędu znika; sprawdzić platformowe wydłużanie i zapewnić trwały błąd/możliwość odczytania oraz ponowienia. Sesje później w CP-03. |
| 2.2.2 Ruch/aktualizacja | A | Częściowo | Brak karuzel i ruchomych dekoracji. Sprawdzić ładowanie, aktualizację wyników i faktyczne działanie ograniczania animacji; uzasadnić wyjątki dla potrzebnego postępu. |
| 2.3.1 Błyski | A | Do testu | Brak widocznej w kodzie dekoracji migającej; przejrzeć rzeczywiste przejścia i stany ładowania. Ponowna ocena po dodaniu grafiki/mediów. |
| 2.4.1 Pomijanie bloków | A | Nie dotyczy teraz wprost | WCAG2ICT wskazuje zakres zestawów dokumentów/oprogramowania; pojedyncza aplikacja nie jest zestawem stron WWW. Dostęp do głównej treści i pomijanie mapy pozostają wymaganiem produktu. |
| 2.4.2 Nazwa ekranu | A | Częściowo | Są widoczne tytuły, ale zmiana sekcji IndexedStack wymaga sprawdzenia ogłoszenia nazwy/semantyki trasy. |
| 2.4.3 Porządek fokusu | A | Do testu | Zweryfikować otwarcie/zamknięcie tras i dialogów, powrót do kontrolki, przewijanie oraz ukryte ekrany. |
| 2.4.4 Cel odnośników | A | Do testu | Link OSM istnieje. Czytnik powinien rozpoznawać cel i możliwość otwarcia informacji o źródle; sprawdzić błąd otwarcia. |
| 2.4.5 Różne drogi dostępu | AA | Nie dotyczy teraz wprost | Jeden program, bez zestawu dokumentów/programów w rozumieniu WCAG2ICT. Mapa i lista są dodatkowo wymagane przez produkt; nie traktować ich jako samodzielnego dowodu zgodności tego kryterium. |
| 2.4.6 Nagłówki/etykiety | AA | Częściowo | Są nazwy sekcji i etykiety pól. Powtarzalne „Znaczenie cechy” musi mieć zrozumiały kontekst konkretnej cechy przy odczycie. |
| 2.4.7 Widoczny fokus | AA | Do testu | Menu ma focusColor, Material swoje stany. Zweryfikować widoczność na każdej kontrolce i w każdym motywie. |
| 2.4.11 Niezasłonięty fokus | AA | Do testu | Sprawdzić pasek menu, klawiaturę ekranową, snackbar i przewijanie tak, aby aktywny element nie był całkowicie zasłonięty. |
| 2.5.1 Gesty | A | Częściowo | Zoom ma +/− i jest lista. Pełną ścieżkę wykonać pojedynczymi aktywacjami bez szczypania; nie pomijać funkcji dostępnych tylko na mapie. |
| 2.5.2 Anulowanie aktywacji | A | Do testu | Kod używa onTap/onPressed. Sprawdzić wciśnięcie, przesunięcie poza element i zwolnienie, także przy potwierdzeniach i przełącznikach. |
| 2.5.3 Widoczna nazwa | A | Częściowo | Menu ma zgodne nazwy semantyczne. Sprawdzić pozostałe etykiety, pinezki, karty i rozpoznanie nazw przez sterowanie głosowe. |
| 2.5.4 Ruch urządzenia | A | Nie dotyczy teraz | Brak czynności sterowanych potrząsaniem/przechyleniem. |
| 2.5.7 Bez przeciągania | AA | Częściowo | Lista i przyciski zoom zapewniają alternatywy części działań mapy. Sprawdzić równoważność całej ścieżki i obsługę przewijania technologiami asystującymi. |
| 2.5.8 Cele dotykowe | AA | Częściowo | Testy rozmiarów obejmują menu. Pomierzyć każdą aktywną kontrolkę i odstępy, również pinezki, link i strzałkę cofania; test urządzenia przy dużym tekście. |

### Zrozumiałość

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie |
|---|---|---|---|
| 3.1.1 Język | A | Częściowo | MaterialApp locale pl i polskie lokalizacje. Sprawdzić wymowę treści przez TalkBack/VoiceOver. |
| 3.1.2 Fragmenty językowe | AA | Do testu | Przejrzeć obcojęzyczne fragmenty, szczególnie atrybucję mapy; oznaczyć język, gdy to wymagane i wspierane. Nazwy własne ocenić z uwzględnieniem wyjątku. |
| 3.2.1 Sam fokus | A | Do testu | Sprawdzić, że przesunięcie fokusu nie uruchamia akcji/zmiany ekranu ani zapisu. |
| 3.2.2 Zmiana danych | A | Częściowo | Motywy i miasto aktualizują wynik, potrzeby/filtry zapis przyciskiem. Sprawdzić brak nieoczekiwanych przejść i czytelny sposób zapisu. |
| 3.2.3 Stała nawigacja | AA | Częściowo | Kolejność menu jest stała; adaptacyjny układ i trasy zweryfikować wszystkimi metodami obsługi. |
| 3.2.4 Stałe nazwy czynności | AA | Częściowo | Wspólne przyciski/statusy istnieją. Przejrzeć rozbieżne nazwy dostępu do tych samych ustawień i stanów. |
| 3.2.6 Stała pomoc | A | Nie dotyczy teraz | Brak mechanizmu kontaktowej pomocy wymienionego w kryterium. Jeśli zostanie dodany, musi być w konsekwentnym miejscu. Ustawienia dostępności nadal łatwo dostępne. |
| 3.3.1 Błędy danych | A | Częściowo | Błąd odczytu jest trwały; błędy zapisu są w toastach. Rozróżnić błąd danych i błąd operacji, zapewnić trwałą informację i związek z czynnością/polem. |
| 3.3.2 Instrukcje pól | A | Częściowo | Są etykiety i znaczenie reguł. Sprawdzić kontekst cechy, skali i utraty niezapisanej edycji. |
| 3.3.3 Pomoc po błędzie | AA | Częściowo | Jest ponowienie i zachowanie wyborów. Przetestować błąd przy zapisie UI, nie tylko repozytorium; przyszłe błędy logowania w CP-03. |
| 3.3.4 Zapobieganie pomyłkom | AA | Częściowo | Usunięcie lokalnych danych i upublicznienie potrzeb mają potwierdzenie. Sprawdzić ich odczyt i możliwość anulowania; zakupy/operacje backendu później. |
| 3.3.7 Bez ponownego wpisywania | A | Częściowo | Potrzeby/filtry inicjalizują się z profilu. Zweryfikować zachowanie formularza po nieudanym zapisie. Zasady szkicu po cofnięciu wymagają decyzji; nie zakładamy ich. |
| 3.3.8 Dostępne uwierzytelnienie | AA | Późniejszy etap | Auto-konto demo nie sprawdza uwierzytelnienia. W CP-03 ocenić rzeczywisty mechanizm, wklejanie, autofill i alternatywy wobec testów poznawczych. |

### Współpraca z technologiami asystującymi

| Kryterium | Poziom | Wynik obecny | Dowód / działanie i sprawdzenie |
|---|---|---|---|
| 4.1.2 Nazwa/rola/stan | A | Częściowo | Część semantyki i standardowych kontrolek istnieje. Sprawdzić stany włączone/wybrane/zajęte, dropdowny, karty i dialogi czytnikiem. |
| 4.1.3 Komunikaty zmian | AA | Częściowo | Snackbar ma liveRegion. Wynik wyszukiwania, błąd mapy i zapis ustawień nie mają pełnych dowodów odczytu; uzupełnić ogłoszenia bez przejmowania fokusu i bez powtarzania na każde kafelkowanie. |

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
