# USpace — tworzenie aplikacji przez checkpointy

Data: 2026-10-03. Folder projektu: D:\Github\USpace. Platforma: Flutter (Dart). Komunikacja i UI: polski.
Status: CP-01 odebrany przez użytkownika („Akcpetuje, Dawaj dalej”, 2026-10-03). CP-02 — dostępność funkcjonalna — w trakcie po zmianie zakresu przez użytkownika. Końcowy projekt graficzny wykona później inna osoba. Produkt nosi zatwierdzoną nazwę KindSpot; folder i identyfikatory techniczne pozostają USpace. Konto testowe: Test Hackaton.

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

**Pokazuję:** działającą aplikację na emulatorze/telefonie, sposób uruchomienia i rzeczywisty wynik analizy/kompilacji. Nie uznaję istniejącego szablonu kontrolnego za USpace.

**Użytkownik sprawdza:** otwarcie aplikacji i to, czy uruchomiony projekt jest właściwym USpace.

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

### CP-04 — mapa, lista i miasto

**Wykonuję:** podkład OSM z uzgodnionym dostawcą/atrybucją, listę tych samych miejsc, wybór miasta z lokalizacji i ręcznie, sekcję miejsc w okolicy. Dane demonstracyjne wyraźnie opisane.

**Pokazuję:** wybór miasta, przełączanie mapa/lista, wybór pinezki i odmowę lokalizacji.

**Użytkownik sprawdza:** zgodność wyników, zmianę miasta, listę bez mapy, brak wyników i komunikat przy niedostępności.

**Przed etapem rozstrzygamy:** dostawcę mapy i warunki korzystania, dane miejsc oraz znaczenie okolicy. Nie wymagamy offline.

### CP-05 — potrzeby, filtry i sortowanie

**Wykonuję:** potrzeby prywatne, presety, trzy poziomy ważności cech, ostatnio używany filtr, zapis/reset oraz sortowanie listy według liczby recenzji i od najlepszej oceny.

**Pokazuję:** ten sam zestaw danych przed i po zastosowaniu filtrów, z miejscem pasującym, niepasującym i z brakami informacji.

**Użytkownik sprawdza:** jeden klik presetu, edycję szczegółów, powrót do ostatniego filtra i czy brak wiedzy nie wygląda jak potwierdzona dostępność.

**Przed etapem rozstrzygamy:** pierwsze użycie, znaczenie oceny do sortowania, reset/zapis oraz zakres pamiętania filtra. Wynik rzeczywistego dopasowania pochodzi z backendu; demo nie udaje rzeczywistych ocen.

### CP-06 — szczegóły i zapisane miejsca

**Wykonuję:** kartę miejsca w zatwierdzonej kolejności, różne wejścia, cechy, aktualność i utrudnienia, zapis/usunięcie miejsca oraz sekcję zapisanych.

**Pokazuję:** miejsce z dostępnym i niedostępnym wejściem, zepsutą windą i nieznaną cechą.

**Użytkownik sprawdza:** zrozumienie dostępności, kolejność informacji, zapis/odczyt/usunięcie i powrót na mapę.

**Przed etapem rozstrzygamy:** sposób zapisu i działania na liście zapisanych; model/API albo jawny demonstrator.

### CP-07 — ankieta i recenzja szczegółowa

**Wykonuję:** odebraną ankietę, warunkowe pola, 0 przy braku funkcji i null przy niewiedzy, przykładowe uzasadnienia, opcjonalną godzinę, datę, wejścia/elementy, utrudnienia, podsumowanie i szkic.

**Pokazuję:** krótką i rozszerzoną recenzję oraz brak odpowiedzi, niewiedzę, cofnięcie i błąd wysłania. Sugestia tekstu nie jest automatycznie publikowana jako obserwacja.

**Użytkownik sprawdza:** łatwość ankiety, obowiązkowe odpowiedzi, rozróżnienie 0/niewiedzy, zachowanie danych i wynik wysłania.

**Przed etapem rozstrzygamy:** publikację ankiety z samą niewiedzą, edycję własnej recenzji i zasady szkicu. QR wyłączone.

### CP-08 — recenzje, głosy i zgłoszenia

**Wykonuję:** listę recenzji, statusy publikacji/weryfikacji, lajk/dislajk per obserwacja z opcjonalnym uzasadnieniem, blokadę własnego głosu i zgłaszanie treści.

**Pokazuję:** przeciwne głosy przy różnych cechach tej samej recenzji, oczekującą i wstrzymaną recenzję oraz wynik zgłoszenia.

**Użytkownik sprawdza:** znaczenie głosów, liczniki, statusy i brak obietnicy automatycznego usunięcia po zgłoszeniu.

**Przed etapem rozstrzygamy:** zmianę głosu, kwalifikację weryfikatorów, procenty oraz skutki głosów. Akceptacja bota może uruchomić punkty po stronie systemu; frontend sam ich nie przyznaje.

### CP-09 — profil, prywatność, karta i punkty

**Wykonuję:** profil i wygląd, Pomocnika, prywatność/podgląd publiczny, połączenie karty i Turystę dla miasta, saldo i historię punktów. Ukryta reputacja pozostaje niewidoczna.

**Pokazuję:** prywatne potrzeby, świadome upublicznienie, konto bez karty, statusy sprawdzania/błędu i punktów oczekujących/przyznanych.

**Użytkownik sprawdza:** widoczność informacji, etykiety, personalizację i zrozumiałość historii.

**Przed etapem rozstrzygamy:** integrację karty albo jawne demo, wagę recenzji turysty i wpływ na wynik, bez wymyślania współczynnika lub zmniejszania punktów.

### CP-10 — nagrody jako teoretyczny PoC

**Wykonuję:** katalog, koszt, potwierdzenie zakupu, moje nagrody, kod/instrukcję oraz stany przetwarzania, sukcesu i błędu. Na obecnym etapie przebieg pozostaje demonstracyjny/teoretyczny.

**Pokazuję:** normalny odbiór oraz brak punktów, niedostępną nagrodę, nieznany wynik i przywrócenie punktów po błędzie, z oznaczeniem symulacji.

**Użytkownik sprawdza:** jasność kosztu, odbioru i błędów. Pokaz nie wydaje prawdziwego biletu ani nie udaje realnej operacji na karcie.

### CP-11 — połączenie z uzgodnionym backendem

**Wykonuję:** zastąpienie demonstracyjnego źródła danymi uzgodnionego API tam, gdzie jest dostępne; sprawdzenie zgodności payloadów, autoryzacji, statusów i błędów. Nie implementuję systemu backendowego należącego do innego członka zespołu.

**Pokazuję:** które funkcje rzeczywiście korzystają z API, które nadal są demo oraz jeden pełny przepływ zapisu i odczytu.

**Użytkownik sprawdza:** zgodność funkcji z wcześniejszym wyglądem i brak udawanych integracji.

**Warunek:** uzgodniony kontrakt i działające środowisko backendu. Jeśli ich brak, zgłaszamy zależność; użytkownik może jawnie odroczyć integrację i odebrać frontendowy PoC. Nie oznaczamy integracji jako ukończonej.

### CP-12 — odbiór całości i przygotowanie pokazu

**Wykonuję:** przegląd wszystkich odebranych ścieżek, istotne testy całości, analizę i kompilację, regresję dostępności, czytnik ekranu, powiększony tekst, sześć motywów i listę bez mapy. Przygotowuję instrukcję uruchomienia, zakres demo oraz listę ograniczeń/odroczonych etapów.

**Pokazuję:** przejście konto → potrzeby → miejsce → recenzja → status → profil/punkty → demonstracyjna nagroda, w zakresie rzeczywiście przygotowanych funkcji.

**Użytkownik sprawdza:** pełny przepływ na emulatorze/telefonie i akceptuje zakres, z którym idziemy na pokaz. Dla niezaimplementowanych funkcji nie pokazujemy fałszywego sukcesu.

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
| CP-00 — decyzje | częściowo | Niejasności zebrane w DO-USTALENIA.md; układ nawigacji i kolejność szczegółów są propozycjami. Ankieta odłożona. | brak |
| CP-01 — baza projektu | odebrany | Flutter, podział UI/logika/dane, analiza, testy, APK i wcześniejsze uruchomienie Android; automatyczne konto Test Hackaton. | akceptacja użytkownika 2026-10-03 |
| CP-02 — dostępność funkcjonalna | w trakcie, nowy zakres | Macierz 55 kryteriów A/AA i przegląd szkieletu; wykryty słaby kontrast ciemnych kart, niepełne dowody błędów/fokusu/czytnika. Poprawki i testy ręczne pozostają. Końcowa grafika odłożona. | nieodebrany |
| CP-03 — konto | częściowo, demo | Automatycznie otwierane lokalne konto Test Hackaton na potrzeby testów; bez uwierzytelniania, rejestracji i sesji backendu. Manualne wejście dostępne po wyłączeniu flagi testowej. | brak |
| CP-04 — mapa/lista/miasto | częściowo | OSM, równoważna lista, pinezki, wyszukiwanie, miasta ręcznie, komunikat błędu podkładu. Brak geolokalizacji, rekomendacji okolicy i danych API. | brak |
| CP-05 — potrzeby/filtry | częściowo | Prywatne potrzeby, Pomocnik, presety i reguły filtrów, braki danych, lokalny zapis. Brak uzgodnionego sortowania i synchronizacji API. | brak |
| CP-06 — szczegóły/zapisane | częściowo | Szczegóły, wejścia, cechy, aktualność i utrudnienia demo. Zapisane to ekran informacyjny; brak dodawania/usuwania. | brak |
| CP-07 — ankieta | odroczony decyzją użytkownika | Prośba o pominięcie ankiety na etapie szkieletu; niezaimplementowana w aplikacji. | odroczenie, nie odbiór |
| CP-08 — recenzje/głosy/zgłoszenia | poza bieżącym zakresem | Niezaimplementowane. | brak |
| CP-09 — profil/karta/punkty | częściowo | Profil, Pomocnik, prywatność i lokalny podgląd. Brak integracji karty, salda i historii z systemu. | brak |
| CP-10 — nagrody | częściowo, widok informacyjny | Przykładowy katalog i komunikaty zależności API; brak pełnego przebiegu zakupu/odbioru. | brak |
| CP-11 — backend | nierozpoczęty | Potrzebny uzgodniony kontrakt i działające API. | brak |
| CP-12 — odbiór/pokaz | nierozpoczęty w pełnym zakresie | Są testy szkieletu, APK i instrukcja; brak odbioru, pełnej ścieżki, testów czytnika/iOS i z użytkownikami. | brak |

Nie podajemy procentu ukończenia aplikacji: checkpointy mają różną wielkość, a ukończony szkielet nie oznacza ukończonych integracji. Kolejna praca funkcjonalna wymaga wskazania najbliższego zakresu; ankieta pozostaje odłożona.
Stany: częściowo, poza bieżącym zakresem, nierozpoczęty, zaplanowany, w trakcie, do weryfikacji, poprawki, odebrany, odroczony decyzją użytkownika. Po odpowiedzi użytkownika aktualizujemy rejestr i pamięć projektu. Po przerwaniu rozmowy kontynuujemy bieżący etap, nie rozpoczynamy planu od nowa.

## Zasady pracy w repozytorium

- Pracujemy w D:\Github\USpace, na aktualnie uzgodnionym lokalnym branchu. Przed zmianami odczytujemy stan Git i instrukcje repozytorium. Nie nadpisujemy zastanej pracy.
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
