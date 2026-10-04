# KindSpot — tworzenie aplikacji przez checkpointy

Data: 2026-10-03. Folder projektu: D:\Github\USpace. Platforma: Flutter (Dart). Komunikacja i UI: polski.
Status: CP-01 odebrany przez użytkownika („Akcpetuje, Dawaj dalej”, 2026-10-03). CP-02 — dostępność funkcjonalna — w trakcie po zmianie zakresu przez użytkownika. Końcowy projekt graficzny wykona później inna osoba. Produkt nosi zatwierdzoną nazwę KindSpot; folder i identyfikatory techniczne pozostają USpace. Konto testowe: Test Hackaton. CP-03 — lokalna sesja demo — przygotowany do weryfikacji; rzeczywiste uwierzytelnienie zależy od ustaleń/API.

## Zasada współpracy

Jeden checkpoint oznacza jeden konkretny, możliwy do obejrzenia rezultat. Cykl:

1. Użytkownik zleca rozpoczęcie checkpointu lub zatwierdza przejście do kolejnego.
2. Asystent odczytuje aktualny stan, ustala zakres etapu i wykonuje całą uzgodnioną pracę.
3. Asystent przeprowadza odpowiednie sprawdzenia, naprawia wykryte błędy i przygotowuje rezultat do oceny.
4. Asystent pokazuje użytkownikowi: co zmieniono, jak obejrzeć wynik, 3–5 konkretnych czynności do sprawdzenia, znane ograniczenia oraz proponowany następny etap.
5. Użytkownik odpowiada „Akceptuję CP-XX” / „Dalej” albo podaje poprawki. „Dalej” po odbiorze oznacza akceptację pokazanego etapu i zgodę na następny.
6. Poprawki wykonujemy w tym samym checkpoincie i ponownie oddajemy do oceny.
7. Dopiero po akceptacji zapisujemy checkpoint jako odebrany i rozpoczynamy kolejny. Milczenie lub upływ czasu nie oznacza akceptacji.

W trakcie aktywnego checkpointu asystent samodzielnie wykonuje rutynowe, odwracalne czynności potrzebne do jego ukończenia. Nie pyta o zatwierdzenie każdego pliku czy uruchomienia. Nie zaczyna funkcji następnego etapu przed odbiorem bieżącego. Dostępność i stany błędów są częścią każdego ekranu, nie ostatnią opcjonalną poprawką.

Nie ustalamy teraz zamkniętej listy funkcji, które muszą powstać przed prezentacją. Plan obejmuje docelową ścieżkę, ale zakres konkretnego pokazu ustalimy na podstawie odebranych checkpointów. Niewykonanych etapów nie oznaczamy jako ukończone. Rezygnacja lub odroczenie wymaga jawnej decyzji użytkownika.

## Checkpointy

### CP-00 — decyzje potrzebne do pierwszych ekranów

**Wykonuję:** proponuję rozmieszczenie mapy i pięciu sekcji, stałą kolejność karty miejsca, przykładową ankietę z odpowiedziami 1–5 / brak funkcji=0 / nie mogłem sprawdzić oraz scenariusze cofnięcia i zachowania szkicu. Wskazuję niejasności, nie wymyślam reguł.

**Pokazuję:** krótki opis przepływów i materiał do przeglądu. To planowanie, nie implementacja.

**Użytkownik sprawdza:** nawigację, kolejność informacji, zrozumiałość pytań i przykładowych odpowiedzi. Odbiór wymaga rozstrzygnięcia tylko decyzji potrzebnych do najbliższej pracy; szczegóły dalszych etapów mogą pozostać jawnie otwarte.

### CP-01 — uruchamialna baza projektu

**Wykonuję:** sprawdzam istniejący katalog mobile i zachowuję zastaną pracę; przygotowuję lub uzupełniam bazę Fluttera, podział warstw UI/logiki/danych oraz uruchomienie na uzgodnionym urządzeniu. Przed komendami Flutter aktywuję zapisany skrypt środowiska.

**Pokazuję:** działającą aplikację na emulatorze/telefonie, sposób uruchomienia i rzeczywisty wynik analizy/kompilacji. Nie uznaję istniejącego szablonu kontrolnego za KindSpot.

**Użytkownik sprawdza:** otwarcie aplikacji i to, czy uruchomiony projekt jest właściwym KindSpot.

### CP-02 — dostępność funkcjonalna (WCAG 2.2 A/AA)

**Decyzja użytkownika 2026-10-03:** funkcjonalność i dostępność teraz; końcowym wyglądem zajmie się pod koniec inna osoba. Obecny styl jest roboczy. Zmiana zakresu nie stanowi odbioru CP-02.

**Wykonuję:** porównanie wszystkich 55 kryteriów A/AA z istniejącymi ekranami, uwzględniając WCAG2ICT dla natywnego Fluttera; poprawki semantyki, obsługi czytnikiem, klawiaturą i przełącznikami, powiększenia tekstu, kontrastu, celów dotykowych, fokusu, alternatywy wobec gestów/mapy, komunikatów i błędów. Udokumentowane testy pełnych istniejących ścieżek i regresja. Kryteria niestosowalne mają uzasadnienie, dotyczące przyszłych funkcji przypisany późniejszy checkpoint.

**Materiał roboczy:** [KindSpot-CP02-WCAG.md](KindSpot-CP02-WCAG.md): kryterium → zakres → stan → dowód/test i lista poprawek. WCAG AA obejmuje także A; nie deklarujemy uniwersalnej obsługi wszystkich potrzeb wyłącznie na tej podstawie. Dodatkowo testy z użytkownikami o różnych i łączonych potrzebach.

**Pokazuję:** wykonanie głównej ścieżki bez interpretowania mapy, z dużym tekstem, klawiaturą/przełącznikami/czytnikiem, odczyt błędów oraz zachowane wybory. Dowody oddzielają obecność mechanizmu w kodzie od skuteczności na urządzeniu. Niewykonanych testów nie oznaczam jako zaliczone.

**Użytkownik sprawdza:** otwarcie miejsca z listy; nazwy i stany potrzeb/filtrów; czytelność przy 200%; przewidywalny powrót i potwierdzenia; zrozumiały błąd i ponowienie bez utraty wyborów. Testy TalkBack/Switch Access wykonujemy po uruchomieniu emulatora przez użytkownika lub na telefonie. iOS/VoiceOver wymagają odpowiedniego środowiska.

**Warunek odbioru:** naprawione problemy stosowalnych kryteriów i dowody testów dla jawnego zakresu/platformy. Przejście automatycznych testów nie stanowi pełnego audytu WCAG. Odroczenie testów musi być jawne i nie daje deklaracji pełnej zgodności. Ankieta i recenzje nadal odłożone; logowanie/backend nie są udawane jako działające.

**Późniejsza grafika:** końcowa stylistyka pozostaje poza obecnym odbiorem. Po zmianie przez osobę odpowiedzialną za grafikę ponownie sprawdzamy kontrast, skalowanie, cele dotykowe, fokus i semantykę. Dostępność jest nadal częścią każdego kolejnego checkpointu, z końcową regresją w CP-12.

### CP-03 — konto i wejście do aplikacji

**Wykonuję:** logowanie/rejestrację i stany formularza zgodnie z uzgodnionym modelem; wymóg konta, wylogowanie i podstawy sesji. Jeśli brak zatwierdzonego API, stosuję jawne konto demonstracyjne, nie pozoruję bezpiecznego produkcyjnego logowania.

**Pokazuję:** wejście z kontem, błędy formularza, wylogowanie i powrót do logowania. Tryb demonstracyjny jest widoczny.

**Użytkownik sprawdza:** brak wejścia jako gość, komunikaty i brak ujawniania prywatnych danych po wylogowaniu.

**Przed etapem rozstrzygamy:** mechanizm logowania/sesji i zakres demonstracyjny kontra rzeczywiste API.


**Dostępność przypisana do tego etapu:** 1.3.5/3.3.8 dla uzgodnionego logowania; 2.1.1, 2.4.3/7/11, 4.1.2 dla wejścia i fokusu; 2.2.1, 3.3.1/3/7 i 4.1.3 dla sesji, trwałych błędów i ponowienia. Teraz jawne demo bez haseł; rzeczywiste uwierzytelnienie pozostaje zależne od decyzji/API.

### CP-04 — mapa, lista i miasto

**Wykonuję:** podkład OSM z uzgodnionym dostawcą/atrybucją, listę tych samych miejsc, wybór miasta z lokalizacji i ręcznie, sekcję miejsc w okolicy. Dane demonstracyjne wyraźnie opisane.

**Pokazuję:** wybór miasta, przełączanie mapa/lista, wybór pinezki i odmowę lokalizacji.

**Użytkownik sprawdza:** zgodność wyników, zmianę miasta, listę bez mapy, brak wyników i komunikat przy niedostępności.

**Ustalono 2026-10-03:** okolica to całe miasto w happy case. Demonstrator korzysta z obecnego podkładu OSM z atrybucją. Produkcyjny dostawca/warunki i dane API pozostają do CP-11; nie wymagamy offline.


**Dostępność przypisana do tego etapu:** 1.1.1, 2.5.1/7: równoważna lista i obsługa bez gestów. 2.4.4/3.1.2: odnośnik i język atrybucji. 4.1.3: odczyt liczby wyników/błędu mapy, bez nadmiarowych ogłoszeń. Cele dotykowe pinezek/zoom 2.5.8.

### CP-05 — potrzeby, filtry i sortowanie

**Wykonuję:** potrzeby prywatne, presety, trzy poziomy ważności cech, ostatnio używany filtr, zapis/reset oraz sortowanie listy według liczby recenzji i od najlepszej oceny.

**Pokazuję:** ten sam zestaw danych przed i po zastosowaniu filtrów, z miejscem pasującym, niepasującym i z brakami informacji.

**Użytkownik sprawdza:** jeden klik presetu, edycję szczegółów, powrót do ostatniego filtra i czy brak wiedzy nie wygląda jak potwierdzona dostępność.

**Ustalono 2026-10-03:** średnia malejąco ma priorytet, remis rozstrzyga liczba recenzji malejąco; drugą opcją jest liczba recenzji malejąco. Demo pamięta wybór lokalnie, filtry/clear wymagają zapisu. Pierwsze użycie produktu, synchronizacja/zakres między miastami i cofnięcie szkicu nadal otwarte. Wynik rzeczywistego dopasowania pochodzi z backendu; demo nie udaje rzeczywistych ocen.


**Dostępność przypisana do tego etapu:** 1.3.1, 2.4.6, 4.1.2: odczyt konkretnej cechy i wybranej reguły/progu. 1.4.4/10: długie opcje przy dużym tekście. 3.3.1/3/7, 4.1.3: trwały błąd, zachowane wybory, ponowienie. Przed scenariuszem szkicu rozstrzygnąć cofnięcie.

### CP-06 — szczegóły i zapisane miejsca

**Wykonuję:** kartę miejsca w zatwierdzonej kolejności, różne wejścia, cechy, aktualność i utrudnienia, zapis/usunięcie miejsca oraz sekcję zapisanych.

**Pokazuję:** miejsce z dostępnym i niedostępnym wejściem, zepsutą windą i nieznaną cechą.

**Użytkownik sprawdza:** zrozumienie dostępności, kolejność informacji, zapis/odczyt/usunięcie i powrót na mapę.

**Przed etapem rozstrzygamy:** sposób zapisu i działania na liście zapisanych; model/API albo jawny demonstrator.


**Dostępność przypisana do tego etapu:** 1.4.3: poprawa potwierdzonego niskiego kontrastu opisów/dat na ciemnych kartach. 1.1.1/1.3.1, 4.1.2: nazwy kart i powiązania cech. 1.4.4/10 i 2.4.3/7/11: pełne szczegóły przy dużym tekście i fokusie. Odczyt potwierdzonego zapisu/usunięcia.

### CP-07 — ankieta i recenzja szczegółowa

**Wykonuję:** odebraną ankietę, warunkowe pola, 0 przy braku funkcji i null przy niewiedzy, przykładowe uzasadnienia, opcjonalną godzinę, datę, wejścia/elementy, utrudnienia, podsumowanie i szkic.

**Pokazuję:** krótką i rozszerzoną recenzję oraz brak odpowiedzi, niewiedzę, cofnięcie i błąd wysłania. Sugestia tekstu nie jest automatycznie publikowana jako obserwacja.

**Użytkownik sprawdza:** łatwość ankiety, obowiązkowe odpowiedzi, rozróżnienie 0/niewiedzy, zachowanie danych i wynik wysłania.

**Przed etapem rozstrzygamy:** publikację ankiety z samą niewiedzą, edycję własnej recenzji i zasady szkicu. QR wyłączone.


**Dostępność przypisana do tego etapu:** Etap nadal odłożony. Przy rozpoczęciu: 1.3.1, 2.4.6, 3.3.1/2/3/7, 4.1.2/3 — kontekst pytań, skala, błędy/szkic, wynik. 2.5.1/7/8 — odpowiedzi bez precyzyjnych gestów. Ponowna ocena 1.1.1/1.2 po dodaniu mediów.

### CP-08 — recenzje, głosy i zgłoszenia

**Wykonuję:** listę recenzji, statusy publikacji/weryfikacji, lajk/dislajk per obserwacja z opcjonalnym uzasadnieniem, blokadę własnego głosu i zgłaszanie treści.

**Pokazuję:** przeciwne głosy przy różnych cechach tej samej recenzji, oczekującą i wstrzymaną recenzję oraz wynik zgłoszenia.

**Użytkownik sprawdza:** znaczenie głosów, liczniki, statusy i brak obietnicy automatycznego usunięcia po zgłoszeniu.

**Przed etapem rozstrzygamy:** zmianę głosu, kwalifikację weryfikatorów, procenty oraz skutki głosów. Akceptacja bota może uruchomić punkty po stronie systemu; frontend sam ich nie przyznaje.


**Dostępność przypisana do tego etapu:** 4.1.2/3: nazwy i stany głosów dla obserwacji, odczyt wyniku zgłoszenia. 1.4.1: statusy bez samego koloru. 2.5.8: cele głosowania. Fokus i obsługa klawiaturą we wszystkich dialogach.

### CP-09 — profil, prywatność, karta i punkty

**Wykonuję:** profil i wygląd, Pomocnika, prywatność/podgląd publiczny, połączenie karty i Turystę dla miasta, saldo i historię punktów. Ukryta reputacja pozostaje niewidoczna.

**Pokazuję:** prywatne potrzeby, świadome upublicznienie, konto bez karty, statusy sprawdzania/błędu i punktów oczekujących/przyznanych.

**Użytkownik sprawdza:** widoczność informacji, etykiety, personalizację i zrozumiałość historii.

**Przed etapem rozstrzygamy:** integrację karty albo jawne demo, wagę recenzji turysty i wpływ na wynik, bez wymyślania współczynnika lub zmniejszania punktów.


**Dostępność przypisana do tego etapu:** 3.3.4: zrozumiałe potwierdzenia prywatności/usunięcia. 3.3.1/3/7 i 4.1.3: trwałe błędy i zachowane dane podczas operacji karty/profilu. 1.3.1/4.1.2: nazwane pola i stany. Nie ujawniać prywatnych danych po zakończeniu sesji.

### CP-10 — nagrody jako teoretyczny PoC

**Wykonuję:** katalog, koszt, potwierdzenie zakupu, moje nagrody, kod/instrukcję oraz stany przetwarzania, sukcesu i błędu. Na obecnym etapie przebieg pozostaje demonstracyjny/teoretyczny.

**Pokazuję:** normalny odbiór oraz brak punktów, niedostępną nagrodę, nieznany wynik i przywrócenie punktów po błędzie, z oznaczeniem symulacji.

**Użytkownik sprawdza:** jasność kosztu, odbioru i błędów. Pokaz nie wydaje prawdziwego biletu ani nie udaje realnej operacji na karcie.


**Dostępność przypisana do tego etapu:** 3.3.4: potwierdzenie kosztu i zapobieganie pomyłce zakupu. 2.2.1/3.3.3/4.1.3: bez presji czasu, ponowienie bez podwójnego zakupu, odczyt przetwarzania/wyniku. Kod i instrukcja jako tekst, dostępne do kopiowania. Cele dotykowe i fokus.

### CP-11 — połączenie z uzgodnionym backendem

**Wykonuję:** zastąpienie demonstracyjnego źródła danymi uzgodnionego API tam, gdzie jest dostępne; sprawdzenie zgodności payloadów, autoryzacji, statusów i błędów. Nie implementuję systemu backendowego należącego do innego członka zespołu.

**Pokazuję:** które funkcje rzeczywiście korzystają z API, które nadal są demo oraz jeden pełny przepływ zapisu i odczytu.

**Użytkownik sprawdza:** zgodność funkcji z wcześniejszym wyglądem i brak udawanych integracji.

**Warunek:** uzgodniony kontrakt i działające środowisko backendu. Jeśli ich brak, zgłaszamy zależność; użytkownik może jawnie odroczyć integrację i odebrać frontendowy PoC. Nie oznaczamy integracji jako ukończonej.


**Dostępność przypisana do tego etapu:** 3.3.8 i 1.3.5: rzeczywisty mechanizm konta i autofill po uzgodnieniu. 3.3.1/3/4/7 oraz 4.1.3: rozróżnienie błędów, bezpieczne ponowienie, zachowanie właściwego konta i odczyt statusu systemu. Nie zastępować odpowiedzi API domysłem.

### CP-12 — odbiór całości i przygotowanie pokazu

**Wykonuję:** przegląd wszystkich odebranych ścieżek, istotne testy całości, analizę i kompilację, regresję dostępności, czytnik ekranu, powiększony tekst, sześć motywów i listę bez mapy. Przygotowuję instrukcję uruchomienia, zakres demo oraz listę ograniczeń/odroczonych etapów.

**Pokazuję:** przejście konto → potrzeby → miejsce → recenzja → status → profil/punkty → demonstracyjna nagroda, w zakresie rzeczywiście przygotowanych funkcji.

**Użytkownik sprawdza:** pełny przepływ na emulatorze/telefonie i akceptuje zakres, z którym idziemy na pokaz. Dla niezaimplementowanych funkcji nie pokazujemy fałszywego sukcesu.


**Dostępność przypisana do tego etapu:** Pełna regresja wszystkich 55 pozycji z macierzy: TalkBack/Switch Access/klawiatura, VoiceOver dla iOS po uzyskaniu środowiska, pion/poziom, duży tekst, fokus, multimedia jeśli dodane, testy z użytkownikami. Osobna ponowna ocena po końcowej grafice; nie zaliczać brakujących testów.

## Format oddania checkpointu w chacie

> CP-XX gotowy do weryfikacji.
> Zrobione: [konkretne zachowanie].
> Wynik: [uruchomiona aplikacja / makieta / dokument i sposób obejrzenia].
> Sprawdziłem: [rzeczywiste wyniki; niewykonanych sprawdzeń nie deklarujemy].
> Sprawdź: [3–5 krótkich czynności i oczekiwane zachowanie].
> Ograniczenia/otwarte kwestie: [jeśli występują].
> Następny etap po akceptacji: CP-YY.
>
> Odpowiedz „Akceptuję CP-XX” albo podaj poprawki.

Nie żądamy od użytkownika oceny niewidocznych mechanizmów wewnętrznych. Techniczne sprawdzenia wykonuje asystent; użytkownik odbiera zachowanie i wygląd.

## Rejestr odbioru

Aktualizacja: 2026-10-03. Użytkownik zaakceptował CP-01 i zlecił dalszą pracę nad CP-02. Zlecenie najpierw szkieletu pozwoliło przygotować części kilku checkpointów równocześnie; nie oznacza to ukończenia ich pełnego zakresu.

| Checkpoint | Stan techniczny | Zrobione / pozostaje | Odbiór |
|---|---|---|---|
| CP-00 — decyzje | częściowo | Kolejność szczegółów i zapisane zatwierdzone; ankieta oraz API odłożone dla PoC. Zasady zmiany głosu/zera w rankingu nadal otwarte. | brak pełnego odbioru |
| CP-01 — baza projektu | odebrany | Flutter, podział UI/logika/dane, analiza, testy, APK i wcześniejsze uruchomienie Android; automatyczne konto Test Hackaton. | akceptacja użytkownika 2026-10-03 |
| CP-02 — dostępność funkcjonalna | częściowo zweryfikowany | Macierz 55 kryteriów, poprawiony kontrast kart; nowe dowody błędów/fokusu/skali. Ręczne testy czytnika/urządzenia pozostają. Końcowa grafika odłożona. | nieodebrany |
| CP-03 — konto | demo do weryfikacji; produkcyjne auth nierozpoczęte | Auto-start Test Hackaton, jawne wejście/wyjście, błędy i ponowienie, blokada powtórnej operacji, usunięcie prywatnych tras po zamknięciu; brak haseł i API auth. | oczekuje |
| CP-04 — mapa/lista/miasto | demo do weryfikacji | Mapa/lista tych samych wyników, miasta ręcznie i lokalizacja na żądanie, odmowa/błąd bez blokowania ręcznego wyboru, retry mapy/zapisu, odczyt wyników, Proponowane dla całego miasta. Dane fikcyjne; lokalizacja na urządzeniu i API pozostają. | oczekuje |
| CP-05 — potrzeby/filtry | demo do weryfikacji | Prywatne potrzeby/Pomocnik, presety, trzy ważności/progi, clear szkicu, trwały błąd/retry, blokada ponownego zapisu, zapis sortowania: średnia → liczba lub liczba. Brak synchronizacji API; szkic po cofnięciu otwarty. | oczekuje |
| CP-06 — szczegóły/zapisane | demo do weryfikacji | Zatwierdzona kolejność szczegółów, zapis/usuwanie/retry, lokalna lista od najnowszego, niezależna od miast i filtrów. | oczekuje |
| CP-07 — ankieta | odroczony decyzją użytkownika | Moduł tworzy inna osoba; opcjonalny SurveyBuilder i instrukcja przekazania gotowe. Brak ankiety zastępczej i publikacji. | odroczenie, nie odbiór |
| CP-08 — recenzje/głosy/zgłoszenia | demo częściowo do weryfikacji | Odczyt fikcyjnych recenzji, cech/wejść i niezależnych statusów; lokalne zgłoszenia. Głosy i ranking oczekują zasad zmiany oraz zera/remisów. | oczekuje; pytanie otwarte |
| CP-09 — profil/karta/punkty | demo do weryfikacji | Prywatność z potwierdzeniem, podgląd, Pomocnik, reset/retry; stany karty jako przykłady, brak API historii/salda odróżniony od zera. | oczekuje |
| CP-10 — nagrody | symulacja do weryfikacji | Interaktywny fikcyjny koszt, potwierdzenie, zmiana ceny, stany realizacji, nieznany wynik/retry, nieważny kod. Bez pobrania punktów i wydania benefitów. | oczekuje |
| CP-11 — backend | integracja odroczona dla PoC | Brak API potwierdzony przez użytkownika. Adapter transportu/health i testy lokalnego kontraktu przygotowane; aplikacja nie łączy się z API funkcjonalnym. | odroczenie, nie odbiór integracji |
| CP-12 — odbiór/pokaz | automatyczna regresja gotowa | Pełne ścieżki demo, reset/reload, Tab, poziom 200%, analiza i APK. Protokół ręczny gotowy; urządzenie/czytniki/iOS i odbiór użytkownika oczekują. | oczekuje |

Nie podajemy procentu ukończenia aplikacji: checkpointy mają różną wielkość, a ukończony szkielet nie oznacza ukończonych integracji. Użytkownik zlecił wszystkie pozostałe checkpointy równolegle; ankieta i rzeczywiste API pozostają odłożone zgodnie z późniejszymi odpowiedziami.
Stany: częściowo, poza bieżącym zakresem, nierozpoczęty, zaplanowany, w trakcie, do weryfikacji, poprawki, odebrany, odroczony decyzją użytkownika. Po odpowiedzi użytkownika aktualizujemy rejestr i pamięć projektu. Po przerwaniu rozmowy kontynuujemy bieżący etap, nie rozpoczynamy planu od nowa.

## Zasady pracy w repozytorium

- Pracujemy w D:\Github\KindSpot, na aktualnie uzgodnionym lokalnym branchu. Przed zmianami odczytujemy stan Git i instrukcje repozytorium. Nie nadpisujemy zastanej pracy.
- Commit, merge/rebase, push, publikacja brancha i wdrożenie nie wynikają automatycznie z odebrania ekranu. Wykonujemy je, gdy użytkownik zleci albo ustali dla nich stałą regułę.
- Frontend ma pozostać lokalny, jeśli użytkownik nie zmieni tej decyzji.
- Przed implementacją etapu czytamy wymagania, pamięć, środowisko i aktualny kontrakt; wymagania użytkownika są nadrzędne wobec niezatwierdzonych propozycji.
- Odpowiednie testy dobieramy do zmiany. Nie budujemy testów kopiujących kosmetyczne szczegóły interfejsu.
- Sekrety i rzeczywiste wrażliwe dane nie trafiają do dokumentacji ani danych demo.


Wynik kompilacji poprawki „Test Hackaton”: `flutter build apk --debug` zakończone sukcesem. Aktualne APK: `frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk`. Weryfikacja tej poprawki: analiza bez uwag, 15 testów przeszło, emulator nie był uruchamiany. Testy potwierdziły pominięcie wejścia, nazwę konta, zachowanie ustawień i start po resecie.

## Historyczne oddanie poprzedniego zakresu CP-02 — 2026-10-03

Gotowe do weryfikacji użytkownika; nie jest to odbiór CP-02. CP-01 zaakceptowany.

- Nazwa KindSpot w nagłówkach, komunikacie wyjścia i nazwie aplikacji Android/iOS. Identyfikator com.example.uspace, lokalny zapis i konto Test Hackaton pozostają.
- Menu adaptuje się do wąskiego ekranu i dużego tekstu; środkowa Mapa przywraca mapę i początek ekranu. Przełącznik Lista/Mapa jest nad mapą. Cofnięcie z sekcji oraz ustawień profilu i filtrów prowadzi na mapę; z mapy pytanie o wyjście.
- Wspólne statusy mają tekst i różne ikony; kolory pochodzą z bieżącego motywu. Nagłówki sekcji mają rolę nagłówka dla semantyki. Długie nagłówki ustawień zwiększają wysokość paska przy dużym tekście.
- Flutter analyze: bez uwag. 35 testów standardowych przeszło; z włączonym CAPTURE_CP02=true przeszło 36, w tym renderowanie podglądów. Kontrast sprawdzonych par tekst/tło co najmniej 4.5:1 w sześciu motywach, także przy podwyższonym kontraście. Testy UI obejmują ekran szerokości 320 i skalę 200%, rolę/etykiety i rozmiary przycisków nawigacji, powrót z ustawień i filtrów, przywrócenie mapy oraz dialog wyjścia.
- APK debug z końcowymi zmianami zbudowane poprawnie: frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk. Gradle heap 1536 MB, maksymalnie 2 workery. Emulator nie był uruchamiany, restartowany ani używany do instalacji przez asystenta.
- Podglądy Flutter bez urządzenia: frontend/mobile/build/cp02/profile-blue-light.png, profile-pink-dark-200.png, settings-pink-dark-200.png. W teście renderowania użyto fontów SDK i testowego adaptera katalogu cache; nie stanowi to testu integracji Android.

Do sprawdzenia przez użytkownika: sześć motywów; środkowa mapa po przejściu na listę; powrót z filtrów i ustawień; tekst 200%; odmowa wyjścia. Pełny TalkBack, integracja na urządzeniu i audyt WCAG pozostają niewykonane w tym etapie. Zapisane/proponowane/nagrody nadal jawnie niegotowe w zakresie wymagającym API/ustaleń. Ankieta odłożona. Po odbiorze CP-02 proponowany CP-03: konto i wejście, z zachowaniem automatycznego konta demo do testów i jawnym brakiem API.
## Zmiana zakresu CP-02 — decyzja użytkownika 2026-10-03

Wcześniejsze oddanie wyglądu nie zamyka nowego checkpointu dostępności. Przygotowano KindSpot-CP02-WCAG.md z 55 unikalnymi kryteriami (31 A i 24 AA), zastosowaniem do Fluttera, wynikami przeglądu i procedurami testów. Ponowiona regresja: 35 istniejących testów przeszło. Pomiar opisu PlaceCard w ciemnych motywach: 2.73:1–2.74:1, problem do poprawy. Emulator i testy czytnika nie były uruchamiane. Kod aplikacji/APK w ramach zmiany założeń nie został zmieniony; nie deklarujemy implementacji wszystkich udogodnień. CP-02 w trakcie; CP-03 nie rozpoczęty na podstawie tego odbioru. CP-01 pozostaje odebrany.
## Porządek plików — 2026-10-03

Cały frontend przeniesiono do frontend/: projekt Flutter do mobile/, dokumentację do docs/, narzędzia do scripts/. Ścieżki w tym dokumencie prowadzą od katalogu głównego repozytorium, jeśli nie podano inaczej. Komendy i indeks dokumentów: ../README.md. Nie zmieniono kodu aplikacji ani statusów checkpointów. Po przeniesieniu: flutter pub get — sukces, flutter analyze — bez uwag, flutter test --concurrency=1 — 35 testów przeszło. Launcher sprawdzono wyłącznie przez -Preview; emulator nie został uruchomiony. Obsidian zachowany lokalnie, usunięty tylko z wersjonowania. Nie wykonano commita ani push.

## Odzyskanie schowka i uporządkowanie dev — 2026-10-03

Źródła były w schowku GitHub Desktop; przywrócono je na dev. Rozwiązano konflikty .gitignore, README i spisu treści use case’ów, zachowując wymagania mobilne oraz istniejący backend, demo webowe i CI/CD zespołu. Lokalne pliki Obsidiana zachowano na dysku, usunięto z indeksu. Build/cache/APK i lokalne SDK ignorowane. Kod aplikacji nie został zmieniony; poprawiono jedynie nadmiarowe puste linie w konfiguracji Android/iOS.

Weryfikacja: flutter pub get — sukces, flutter analyze — bez uwag, 35 testów przeszło. Launcher sprawdzony przez -Preview bez uruchamiania emulatora. Nie oznacza to odbioru CP-02 ani pełnego audytu WCAG. Osobny szkielet webowy w frontend/ zachowany; mobilny projekt pozostaje w frontend/mobile/. Nie publikujemy zmian podczas porządkowania branchy.

## Przejście do CP-03 na polecenie użytkownika

Nowa struktura: frontend/mobile, frontend/docs, frontend/scripts. Użytkownik zlecił CP-03 oraz rozdzielenie braków macierzy do odpowiednich etapów. Nie oznacza to odbioru CP-02 ani pełnego WCAG. CP-03 realizowany jako lokalna sesja demonstracyjna: backend ma tylko health, nie ma operacji auth. Auto-start Test Hackaton pozostaje na początku uruchomienia; jawne zamknięcie sesji prowadzi do wejścia i ukrywa prywatne trasy do ponownego wejścia. Przy kolejnym starcie automatyczny tryb testowy wraca, ręczny wariant można włączyć flagą USPACE_AUTO_DEMO_LOGIN=false.

## CP-03 — wynik zakresu demonstracyjnego

Wdrożono: zamknięcie sesji także przy automatycznym starcie, wejście ponowne, usunięcie historii tras i fokusu poprzedniej sesji, trwałe błędy wejścia/wyjścia, przyciski zablokowane na czas zapisu. Ustawienia demo zachowane; po wyjściu nie są pokazywane w prywatnych ekranach. Auto-start wraca przy nowym uruchomieniu zgodnie z poleceniem testowym. To nie jest zabezpieczenie prawdziwego konta ani rejestracja w backendzie.

Analiza bez uwag; 41 testów przeszło, w tym 6 testów CP-03: wyjście i restart/manualna flaga, nieudany zapis wyjścia, ukrycie tras/cofnięcie, trwały błąd wejścia i Enter, blokada podwójnego wejścia, skala 200% przy szerokości 320. Kompilacja flutter build apk --debug zakończona sukcesem. Aktualne APK: frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk (Gradle heap 1536 MB, 2 workery). Emulator nie był uruchamiany. TalkBack/VoiceOver/Switch Access pozostają niezweryfikowane.

Odbiór CP-03 dotyczy przygotowanego zakresu demo: domyślny start Test Hackaton → Profil / Zamknij konto demonstracyjne → brak prywatnego profilu i powrotu do niego przez cofnięcie → dostępne ustawienia interfejsu → ponowne wejście. Produkcyjne auth pozostaje niewdrożone, nie jest częścią deklaracji sukcesu. Kolejny etap po odbiorze przygotowanego demo: CP-04 mapa/lista/miasto, z przypisanymi brakami dostępności.


## Decyzje CP-04 i CP-05 — 2026-10-03

Użytkownik zlecił równoległe wykonanie CP-04 i CP-05 z dodatkowym agentem. Nie oznacza to odbioru pełnego CP-02/WCAG ani produkcyjnego uwierzytelnienia CP-03.

- Najlepsze miejsca: średnia ocen malejąco ma bezwzględny priorytet; przy tej samej średniej wyżej jest więcej recenzji. Osobna opcja „Najwięcej recenzji” sortuje liczbę malejąco. Nie wyliczamy średniej miejsca ze średnich cech.
- Na potrzeby happy case okolica obejmuje całe wybrane miasto. Proponowane miejsca stosują zapisane filtry i wybraną kolejność, bez dodatkowego promienia ani potwierdzania wizyty.
- Komentarze: użytkownik wskazał największy stosunek lajków do dislajków. Implementacja należy do CP-08; zero dislajków, remisy i powiązanie z głosami per obserwacja nadal wymagają doprecyzowania. Nie zmieniamy teraz jednostki głosowania ani nie tworzymy komentarzy.
- Demo ma jawnie fikcyjne średnie i liczby recenzji; brak średniej/licznika pozostaje brakiem danych. Domyślna kolejność demo to najlepsza ocena, ostatni wybór jest zapisany lokalnie. Dla sortowania liczby techniczny remis rozstrzyga średnia, potem nazwa/ID; ostatnie klucze nie stanowią nowej reguły produktu.
- Miasto można ustalić po wybraniu „Użyj lokalizacji telefonu”. Demo rozpoznaje systemową nazwę miejscowości dla Krakowa/Warszawy w Polsce; nie zgaduje najbliższego miasta. Odmowa, wyłączona usługa, brak rozpoznania i inne miasta pozostawiają ręczny wybór. Zapisujemy tylko identyfikator miasta, bez współrzędnych/śledzenia w tle. Geokodowanie systemowe może użyć sieci.
- Potrzeby/filtry: zapis dopiero przyciskiem, czyszczenie zmienia szkic i wyłącza dołączenie braków danych; bez zapisu potwierdzone filtry pozostają. Trwały błąd zachowuje wybory. Presety oraz sugestie cech pozostają przykładami PoC, nie zatwierdzoną klasyfikacją potrzeb. Potrzeby prywatne domyślnie.

Operator produkcyjnej mapy, dane API i zakres agregacji recenzji dla średniej nadal należą do kontraktu CP-11. Synchronizacja filtrów i scenariusz szkicu po cofnięciu pozostają otwarte. Wyniki automatyczne nie zastępują testów lokalizacji/TalkBack na urządzeniu; emulator uruchamia tylko użytkownik. Szczegóły odbioru: KindSpot-CP04-CP05.md.

CP-04/05 — sprawdzenia końcowe: flutter analyze bez uwag, 80 testów standardowych, APK debug zbudowane poprawnie (Gradle 1536 MB, 2 workery). Odbiór: KindSpot-CP04-CP05.md. Brak uruchomienia emulatora i ręcznych testów lokalizacji/czytnika; dane i statystyki pozostają demo.

## Pozostałe checkpointy — decyzje użytkownika 2026-10-03

Użytkownik zlecił równoległą pracę nad pozostałymi etapami, po jednym agencie na checkpoint i z pytaniami przy niepewności. Etapy powstają w falach z uwagi na dostępne sloty i zależności; integracja wspólnych modeli i testy końcowe należą do agenta głównego. Nie wymaga się kolejnego odbioru każdego poprzednika przed przygotowaniem tych jawnie zleconych etapów; ukończenie techniczne nadal nie oznacza odbioru użytkownika.

- CP-06 zatwierdzony przebieg: nazwa/adres i dopasowanie → utrudnienia i aktualność → wejścia → cechy → recenzje. Przycisk Zapisz miejsce/Usuń z zapisanych w szczegółach; lokalna lista demo od ostatnio zapisanego. Lista zapisanych pozostaje niezależna od wyszukiwanych miast/filtrów; wpis bez danych katalogowych jest jawnie niedostępny i można go usunąć. Dostępność wejścia nie jest domyślnie dostępnością całego miejsca.
- CP-07 pozostaje odłożony: ankietę przygotowuje inna osoba we Flutterze. Nie tworzymy zastępczej ankiety ani formularza publikacji. Przygotowujemy sposób przekazania/włączenia modułu oraz wymagania dostępności i danych, bez narzucania niezatwierdzonych pytań.
- CP-11: użytkownik potwierdził brak API i przewiduje jego brak dla PoC. Rzeczywista integracja jest jawnie odroczona na potrzeby PoC. Można przygotować adaptery i testy kontraktu; ich istnienie nie oznacza połączenia aplikacji z backendem. Backend pozostaje odpowiedzialnością innego członka zespołu.
- CP-08/09/10 obejmują zatwierdzone prezentacje i jawne przebiegi demo. Nie tworzymy prawdziwych potwierdzeń karty, punktów, nagród ani skutków moderacji w kliencie. Potrzeby nadal prywatne domyślnie. Pytania o zmianę głosu i szczegóły rankingu zapisujemy oddzielnie.
- CP-12: testy automatyczne i przygotowanie APK/przebiegu pokazu w rzeczywistym zakresie. Urządzenie/czytnik oraz iOS pozostają niewykonane do uzyskania rzeczywistych dowodów. Emulator uruchamia wyłącznie użytkownik.

## CP-06–12 — końcowe sprawdzenie PoC

Analiza bez uwag; 131 testów przeszło; APK debug zbudowane (189263704 bajtów, 2026-10-03 21:59:03). Emulator nie był uruchamiany. Raport: KindSpot-CP06-CP12.md. Ankieta odłożona i przygotowany SurveyBuilder, brak API dla PoC, głosy/ranking oczekują odpowiedzi. CP-02 i odbiór ręczny CP-12 niezamknięte.

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

## Integracja Flutter i FastAPI — decyzje 2026-10-04

Ten zapis zastępuje wcześniejsze odłożenie ankiety/API oraz reset konta przy starcie. Użytkownik zlecił połączenie istniejącej ankiety i backendu. Główne wejście aplikacji korzysta z API, wymaga adresu serwera i logowania; dane konta, zapisane miejsca, punkty i zakupy są trwałe po stronie serwera. Test Hackaton otrzymuje 1000 punktów oraz Ogród ciszy tylko przy przygotowaniu konta lub ręcznym resecie operatora. Restart aplikacji nie dodaje punktów. Reset zachowuje nazwane filtry i dostępność; recenzje/głosy społeczności nie są usuwane w resecie portfela.

Decyzja użytkownika: średnia całego miejsca wynika ze wszystkich pomniejszych ocen recenzji. Implementacja liczy wszystkie oceny wymiarów 1–5 zaakceptowanych widocznych recenzji, wyłączając absent/unknown i techniczne average_rating; osobne recommendation nie zastępuje średniej. Priorytet średniej i liczby recenzji przy remisie zachowany.

Włączono transport HTTP, sesję, profil/filtry, miejsca/listę/mapę/zapisane, istniejącą ankietę, recenzje/głosy/zgłoszenia, punkty/sklep/moje nagrody i stany weryfikacji. Katalog 12 istniejących pytań jest dostarczany przez API. Backend wymaga jawnej migracji 3. Punkty/publikacja/uprawnienia nie są nadawane przez klienta. Operator karty pozostaje jawnie demonstracyjny. Nie zmieniono reguł rankingu komentarzy przy zerowych dislajkach.

Sprawdzenia: 175 testów Flutter, analiza bez uwag; 32 testy backendu bez bazy i Ruff poprawne. Próba HTTP konfiguracji/OpenAPI/health oraz ochrony /me przeszła bez PostgreSQL. Pełny przebieg z bazą i urządzeniem pozostaje do wykonania: brak konfiguracji PostgreSQL i wskazanego adresu serwera. Nie uruchamiano emulatora. Zmiany lokalne Frontend, bez commita/push. Pełny zakres, polecenia i checklista: frontend/docs/KindSpot-integracja-FastAPI.md.

Integracja 2026-10-04 — kompilacje: APK debug sukces (189808058 bajtów, 06:32:17, Gradle1536MB/2workery); web release sukces w odizolowanej kopii z rusztowaniem web jak w CI. 175 testów Flutter i 32 bezbazowe backendu poprawne. Flutter analyze i Ruff poprawne. Test PostgreSQL/live backend nadal niewykonany. Raport frontend/docs/KindSpot-integracja-FastAPI.md. Bez emulatora/instalacji/publikacji/commita/push.


Weryfikacja zmiany społeczności/ikon 2026-10-04: 180 testów Flutter przeszło, flutter analyze bez uwag, 32 testy backendu bez bazy poprawne i Ruff bez uwag. Sprawdzono pytanie z zatwierdzoną ikoną przy 320 px i tekście 200%, zachowano etykietę i nagłówek czytnika. Usunięcie roli nie usuwa prywatnych potrzeb ani ustawień dostępności. Aktualne APK jest budowane; wynik należy potwierdzić osobno. Testy urządzenia/czytnika oraz PostgreSQL nadal niewykonane. Emulatora nie uruchamiano.

Końcowy build zmiany społeczności i ikon 2026-10-04: APK debug zbudowane poprawnie, 189814743 bajtów, godzina 07:05:18; frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk. Bez instalacji i uruchamiania emulatora.


## Personalizacja PoC za nagrody — 2026-10-04

Decyzja użytkownika przekazana przez chat współpracujący: dwa profilowe (Lemur/Kot), jedna obręcz z kokardą, zakupione motywy Odkrywca i Ogrodnik, tło profilu z motywu, kategorie sklepu i mała sekcja Osiągnięcia z wyborem potwierdzonego publicznego tytułu. Grafiki/motywy dostarcza osobny chat; warstwa działania używa KindSpotAvatar i KindSpotBackdrop. Brak osobnej roli Pomocnika.

Wdrożono kontrolę własności i rodzaju pola w API, katalog pięciu kosmetyków oraz natychmiastowe rozliczenie ich zakupów przez serwer (fulfilled/charged). Drugi zakup posiadanego/przetwarzanego kosmetyku blokowany; ponowienie tego samego Idempotency-Key bez drugiego obciążenia. Wyposażenie jest trwałe na koncie. Motywy explorer/gardener wymagają zakupu także przez PUT ui-settings. Ogrodnik włącza darkMode=true; użytkownik zachowuje możliwość zmiany wariantu, kontrastu i ułatwień.

Nie ustanowiono automatycznych reguł zdobywania osiągnięć. Tytuły przechowuje earned_titles, nadanie przez operatora po potwierdzeniu. Klient może wybrać tylko zdobyty tytuł lub zrezygnować z publicznego tytułu. Publiczny profil i review.author.title zawierają wyłącznie wybrany potwierdzony tytuł; prywatne potrzeby nie są ujawniane. Wymagana migracja4 i bootstrap uprawnień, w tym poprawione granty saved_places. Konto nie dostaje nowych punktów z klienta.

Raport, ceny PoC, polecenie operatora, zakres i testy: frontend/docs/KindSpot-personalizacja-PoC.md. Backend/PostgreSQL i urządzenie nadal niezweryfikowane w rzeczywistym środowisku; nie deklarować odbioru produkcyjnego. Bez APK/emulatora/commita/push w tym etapie — końcowa integracja w chacie graficznym.


Końcowa weryfikacja personalizacji PoC 2026-10-04: 185 testów Flutter i 39 bezbazowych backendu przeszło; Ruff poprawny, Python compileall poprawny. Analiza wspólnego repo: brak błędów/ostrzeżeń, dwie uwagi stylu w visual_api_graphics_test.dart pozostają autorowi tego testu. Warstwa personalizacji gotowa do końcowej integracji; marker KindSpot-UI-przekazanie.txt i raport KindSpot-personalizacja-PoC.md na dysku. API wymaga migracji4 i bootstrap; test PostgreSQL nie wykonany. Wybrany publiczny tytuł dostępny także w review.author.title. Bez APK/emulatora/commita/push w tym etapie.
