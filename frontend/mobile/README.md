# KindSpot — szkielet Flutter

Interfejs po polsku. Źródła wymagań w `../docs`: `Teoria Aplikacji.md` i `use-cases.md`. Aktualny etap: szkielet aplikacji i przykładowa ankieta recenzji (wznowiona 2026-10-03).

## Działające elementy

- Automatyczny start na mapie z lokalnym kontem „Test Hackaton”. Nazwa konta widoczna w profilu i jego podglądzie; dane nadal oznaczone jako demonstracyjne. Zapisane potrzeby/filtry/motyw pozostają zachowane. Reset danych również wraca do trybu testowego.
- Mapa OSM i równoważna lista tych samych przykładowych miejsc; ręczny wybór Krakowa/Warszawy oraz lokalizacja na żądanie z ręcznym fallbackiem, wyszukiwanie, szczegóły i status braków danych.
- Nawigacja ze środkowym przyciskiem mapy; cofnięcie z sekcji wraca na mapę, z mapy pyta o wyjście.
- Potrzeby prywatne, niezależny Pomocnik, filtry konieczne/preferowane/bez znaczenia, lokalny zapis ustawień w secure storage.
- Akcent pomarańczowy/różowy/jasnoniebieski w jasnym i ciemnym motywie, wyższy kontrast i ograniczenie animacji; respektowane skalowanie tekstu telefonu.
- Profil i lokalny podgląd prywatności. Proponowane miejsca obejmują całe wybrane miasto, ze wspólnymi filtrami/rankingiem demo. Zapisane miejsca i nagrody nadal mają jawne stany wymagające ustaleń/API.

To PoC: fikcyjne miejsca i dane dostępności nie służą planowaniu rzeczywistych podróży. Rzeczywisty podkład OSM wymaga internetu; aplikacja nie obiecuje trybu offline. Tile URL można ustawić przez `--dart-define=MAP_TILE_URL=...`; produkcyjny dostawca pozostaje do wyboru. Atrybucja OSM jest widoczna pod mapą, dostępna również przy błędzie podkładu. Backend KindSpot, logowanie, karty, ankieta, głosowanie, saldo i zakup nagród nie są podłączone.

## Uruchomienie na przygotowanym Windows

Domyślnie testowy start jest włączony (`USPACE_AUTO_DEMO_LOGIN=true`). Nie jest to sesja backendu ani konto gościa. Do przeglądu wcześniejszego ekranu wejścia: `flutter run --dart-define=USPACE_AUTO_DEMO_LOGIN=false -d emulator-5554` (ustawienie zapisanej personalizacji nie jest wtedy kasowane).

Najlżejszy przegląd: użyj gotowego APK, bez kompilacji i bez jednoczesnego uruchamiania Android Studio. Emulator uruchamia użytkownik; nie uruchamiamy go zdalnie po zgłoszonym zawieszeniu komputera.

```powershell
cd D:\Github\USpace\frontend\mobile
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
. ..\scripts\Use-USpaceEnvironment.ps1
```

Emulator uruchamia wyłącznie użytkownik. Stała komenda z ograniczonymi zasobami:

```powershell
..\scripts\Start-USpaceEmulator.ps1 -Restart
```

Skrypt zawsze przekazuje 1 vCPU i 1536 MB RAM Androida, wyłącza snapshoty/animację startową/dźwięk oraz próbuje ustawić priorytet procesów emulatora i QEMU na BelowNormal. Pamięć hosta obejmuje także dodatkowe koszty emulatora i grafiki; 1536 MB to pamięć urządzenia, nie limit całego procesu Windows. Uruchamianie będzie wolniejsze przy jednym rdzeniu.

`-Restart` zamyka istniejący emulator KindSpot na porcie 5554 przed uruchomieniem nowego. Bez tej opcji skrypt odmawia uruchomienia, jeśli KindSpot już działa. Nie otwiera drugiej instancji i nie kompiluje aplikacji. `-Preview` pokazuje ustawienia bez uruchamiania.

Nie używaj wcześniejszego `flutter emulators --launch` do tego demo — ta komenda pomija limity skryptu. Sprawdzono składnię i tryb Preview w Windows PowerShell 5; nie wykonano uruchomienia ani restartu emulatora.
Poczekaj na pulpit Androida. Zainstaluj aktualną wersję:

```powershell
adb -s emulator-5554 install -r ".\build\app\outputs\flutter-apk\app-debug.apk"
adb -s emulator-5554 shell am force-stop com.example.uspace
adb -s emulator-5554 shell am start -n com.example.uspace/.MainActivity
```

Sprawdzanie kodu i ewentualna przebudowa, najlepiej przy zamkniętym emulatorze:

```powershell
flutter analyze
flutter test --concurrency=1
$env:GRADLE_OPTS='-Dorg.gradle.jvmargs=-Xmx1536m -Dorg.gradle.workers.max=2'
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`. Wersja debug do przeglądu, nie do publikacji w sklepie. Android wcześniej uruchomiono na emulatorze; bieżąca zmiana jest sprawdzana bez ponownego otwierania emulatora. iOS wymaga macOS oraz konfiguracji podpisywania/keychain. SDK domyślnie w `%USERPROFILE%\develop`; lokalne ścieżki można nadpisać w ignorowanym `.dev-tools.local.json`.
## Struktura

`lib/ui`: ekrany i wspólne kontrolki. `lib/domain`: modele i demonstracyjne dopasowanie. `lib/data`: katalog przykładów i lokalne repozytorium. `app_controller.dart`: potwierdzony stan i zapis. To nie są DTO zatwierdzonego API. Przyszły adapter backendu musi opierać statusy i uprawnienia na odpowiedziach systemu.

Otwarte decyzje: `../docs/DO-USTALENIA.md`. Nie deklarujemy zgodności WCAG 2.2 AA na podstawie samego szkieletu; pozostają testy czytnika, urządzeń i z użytkownikami.

## Weryfikacja szkieletu — 2026-10-03

- `flutter analyze`: bez uwag.
- `flutter test`: 14 testów przeszło (braki danych i warunki filtrów, trwałość/błąd zapisu, uszkodzony zapis, dostępność przed wejściem demo, 6 motywów przy skali tekstu 200%, preset, cofnięcie do mapy i dialog wyjścia).
- `flutter build apk --debug`: sukces; APK w `build/app/outputs/flutter-apk/app-debug.apk`.
- Android API36 emulator: uruchomienie, realny podkład OSM i pinezki, przejście na konto demo/ustawienia, ciemny motyw, tekst 200%, ponowne uruchomienie zachowujące ustawienia. Skalę urządzenia przywrócono do 100%.
- Niewykonane: testy iOS, pełny audyt TalkBack/WCAG i testy z użytkownikami. Rzeczywiste logowanie i integracje nadal niepodłączone.


## Aktualizacja testowego startu — 2026-10-03

- Automatycznie otwierane konto „Test Hackaton”; po odczycie lokalnych danych od razu mapa.
- Test potwierdza świeży start, nazwę w profilu, zachowanie ustawień po ponownym odczycie oraz automatyczny start po resecie. Ręczny ekran wejścia nadal można sprawdzić po wyłączeniu flagi testowej.
- `flutter analyze`: bez uwag. `flutter test --concurrency=1`: 15 testów przeszło.
- Bieżącej poprawki nie uruchamiano na emulatorze po zgłoszeniu zawieszenia komputera; sprawdzenie UI odbyło się w testach widgetowych.

Aktualne APK z automatycznym kontem „Test Hackaton” zbudowano poprawnie (`flutter build apk --debug`, Gradle heap 1536 MB, maksymalnie 2 workery). Aby zobaczyć zmianę, ponownie zainstaluj APK przez `adb install -r`, zatrzymaj aplikację i uruchom ją ponownie. Nie trzeba kasować danych aplikacji ani robić nowej kompilacji.


## CP-02 — wygląd i nawigacja, 2026-10-03

Produkt: KindSpot, wcześniej USpace. Techniczny folder i identyfikator pakietu pozostają. CP-01 odebrany; CP-02 gotowy do weryfikacji użytkownika, oczekuje akceptacji.

Zmiany: adaptacyjne menu (Zapisane/Nagrody/Mapa/Filtry/Profil), Mapa pośrodku przywraca podkład i początek ekranu; Lista/Mapa nad podkładem; powrót z ustawień profilu i filtrów na mapę; czytelne statusy tekst/ikona we wszystkich motywach; nagłówki dostosowane do dużego tekstu. Nazwa KindSpot w UI oraz nazwie aplikacji na telefonie. Konto Test Hackaton otwiera się automatycznie.

Końcowe sprawdzenie: analiza bez uwag, 35 testów standardowych, 36 testów z renderowaniem podglądów, build APK debug zakończony sukcesem. Sprawdzone pary tekst/tło co najmniej 4.5:1 we wszystkich motywach. UI testowane przy szerokości 320 i tekście 200%. Nie wykonywano uruchomienia emulatora ani instalacji aplikacji. Pełny TalkBack i audyt WCAG pozostają do wykonania.

Podglądy z Fluttera, bez urządzenia: build/cp02/*.png. Regeneracja opcjonalna: flutter test test/visual_capture_test.dart --dart-define=CAPTURE_CP02=true --concurrency=1. Potrzebny FLUTTER_ROOT ustawiony skryptem środowiska; test używa fontów SDK i mocka katalogu cache, nie testuje integracji Android.

Aktualne APK zawiera końcowe poprawki CP-02. Użytkownik z działającym emulatorem instaluje je ponownie komendami adb install -r, force-stop i am start podanymi wyżej; nie kasuje ustawień. Ankieta i tworzenie recenzji nadal odłożone; niedostępne funkcje są opisane jawnie.

## Ankieta recenzji — 2026-10-03

Na karcie miejsca przycisk „Dodaj recenzję” otwiera ankietę (`lib/ui/review_survey.dart`). Pytania wynikają z potrzeb w profilu (`lib/data/survey_catalog.dart`), jedno na ekran; każde wymaga odpowiedzi: 1–5, „0 – Brak funkcji” albo „Nie mogłem sprawdzić”. Szczegóły: uzasadnienie, utrudnienie tymczasowe, konkretne wejście lub nowa część. Dane zamienia na `ReviewCreate` z kontraktu `lib/domain/review.dart`.

Wersja demonstracyjna: recenzja nie jest wysyłana; ekran wyniku pokazuje statusy jako niedostępne i dane w formacie kontraktu. Szkic jest w pamięci aplikacji.

Sprawdzenie 2026-10-03 (Flutter 3.47.6): `flutter analyze` bez uwag, `flutter test --concurrency=1` — 46 testów przeszło (11 nowych: model, przebieg ankiety, zachowanie szkicu, wytyczne dostępności Fluttera, 320 px i tekst 200%). Bez emulatora, TalkBack i testów z użytkownikami. APK nie przebudowano.

## CP-03 — lokalne wejście i wyjście demo

Aktualny projekt: D:\Github\USpace\frontend\mobile. Środowisko: . ..\scripts\Use-USpaceEnvironment.ps1. Domyślnie auto-start Test Hackaton pozostaje włączony. Profil → Zamknij konto demonstracyjne prowadzi do wejścia; prywatne trasy i ich historia są usuwane. Ustawienia demo pozostają w lokalnym magazynie. Ponowne wejście używa tego samego demo, nowy start aplikacji ponownie uruchamia auto-konto. Ręczny wariant od startu: USPACE_AUTO_DEMO_LOGIN=false.

Błędy wejścia/wyjścia są trwałe i dostępne do odczytu; można ponowić. Błąd wyjścia pozostawia otwartą sesję i informuje o tym. Podczas zapisu wejście/wyjście jest zablokowane. Konto jest lokalną demonstracją; nie ma produkcyjnego logowania/rejestracji ani endpointów auth w backendzie. Nie należy podawać rzeczywistych poświadczeń.

Weryfikacja: analiza bez uwag, 41 testów (6 nowych testów sesji). Nie uruchomiono emulatora, nie wykonano TalkBack/VoiceOver/Switch Access. Kompilacja końcowego APK debug zakończona sukcesem; aktualne APK znajduje się w build/app/outputs/flutter-apk/app-debug.apk; instalację wykonuje użytkownik według instrukcji powyżej. Pełna macierz i przydział braków: ../docs/KindSpot-CP02-WCAG.md oraz ../docs/KindSpot-checkpointy.md.

## CP-04 i CP-05 — równoległe wdrożenie

Ranking miejsc: najlepsza średnia malejąco, przy remisie najwięcej recenzji; osobny tryb liczby recenzji malejąco. Przełącznik „Kolejność miejsc” zapisuje ostatni wybór na urządzeniu. Demo pokazuje fikcyjne średnie/liczniki; brak średniej nie jest zerem ani dowodem dostępności. Proponowane miejsca obejmują całe miasto i zapisane filtry, bez dodatkowego promienia.

Lokalizacja tylko po wybraniu przycisku; Android prosi o przybliżoną lokalizację podczas używania. Odmowa, wyłączona usługa, timeout, nierozpoznane/nieobsługiwane miasto pozostawiają ręczny wybór. Usługa geokodowania systemu może korzystać z internetu. Aplikacja zapisuje miasto, bez współrzędnych i bez śledzenia w tle. Wybór ręczny unieważnia spóźniony wynik GPS. Błąd zapisu zachowuje wybór do ponowienia; lista używa ostatniego potwierdzonego miasta/sortu.

Potrzeby i filtry mają trwałe błędy z zachowaniem szkicu, retry i blokadę podwójnej operacji. „Wyczyść” zmienia szkic reguł i includeUnknown; zastosowanie dopiero przyciskiem zapisu. Presety są przykładami demo. Semantyka wartości/progu wskazuje konkretną cechę. Ankieta i dodawanie recenzji nadal odłożone.

Przegląd: ../docs/KindSpot-CP04-CP05.md. Lokalizację systemową, TalkBack/Switch Access i link systemowy sprawdza użytkownik na urządzeniu; nie uruchamiano emulatora. iOS nadal niezweryfikowany na Windows.

Dokumentacja adaptera: [geolocator](https://pub.dev/packages/geolocator), [geocoding](https://pub.dev/packages/geocoding). Pakiety wykorzystują lokalizację i geokodowanie systemów Android/iOS; są adapterem miasta, nie integracją rekomendacji z backendem.

CP-04/05 — sprawdzenia końcowe: flutter analyze bez uwag, 80 testów standardowych, APK debug zbudowane poprawnie (Gradle 1536 MB, 2 workery). Odbiór: KindSpot-CP04-CP05.md. Brak uruchomienia emulatora i ręcznych testów lokalizacji/czytnika; dane i statystyki pozostają demo.


## CP-06–12 — końcowe sprawdzenie PoC

Analiza bez uwag; 131 testów przeszło; APK debug zbudowane (189263704 bajtów, 2026-10-03 21:59:03). Emulator nie był uruchamiany. Raport: ../docs/KindSpot-CP06-CP12.md. Ankieta odłożona i przygotowany SurveyBuilder, brak API dla PoC, głosy/ranking oczekują odpowiedzi. CP-02 i odbiór ręczny CP-12 niezamknięte.

## Stan po połączeniu Frontend z dev — 2026-10-03

Na dev dostępne są teraz backend i niezależny moduł ankiety z dokumentami (review_survey.dart, review.dart, survey_catalog.dart). Zachowano ich kod, metody szkicu w kontrolerze oraz testy. Zachowano lokalne CP-04–12 i nieukończony sklep/filtry. Konflikt szczegółów rozstrzygnięto na rzecz nowego ekranu CP-06 z opcjonalnym SurveyBuilder; moduł ankiety można podłączyć przez ten punkt po wznowieniu pracy. Nie zintegrowano rzeczywistego API. Zapisy historyczne o braku kodu backendu/ankiety dotyczą wcześniejszego stanu, nie obecnego repozytorium.

Zachowano nazwę KindSpotApp z dev oraz alias USpaceApp dla wcześniejszych testów. Fizyczny folder to D:\Github\USpace, pakiet Dart uspace i identyfikator com.example.uspace pozostają bez zmian. Nazwy dokumentów zmienione na KindSpot-checkpointy.md i KindSpot-kontrakt-frontend-backend-v0.1.md. Nazwa produktu: KindSpot.

Aktualny commit jest WIP. Znane błędy parsowania kontrolera i nieukończone testy sklepu/filtrów pozostają do dokończenia po synchronizacji Git. Rebase nie jest dowodem działającej kompilacji i nie zmienia wcześniejszego APK.

## Aktualne wejście API (2026-10-04)

main.dart uruchamia ConnectKindSpot. Native: ustaw KINDSPOT_API_URL z końcówką /api/v1/ albo wpisz adres na ekranie. Web: domyślnie /api/v1/ na tym samym origin. HTTPS; lokalny HTTP tylko debug z KINDSPOT_LOCAL_HTTP=true. Konto i saldo pochodzą z serwera i nie resetują się przy starcie. Backend wymaga migracji 3. Polecenia PowerShell, przygotowanie Test Hackaton i checklista: ../docs/KindSpot-integracja-FastAPI.md. Przed flutter aktywuj ../scripts/Use-USpaceEnvironment.ps1. Emulator uruchamia wyłącznie użytkownik.
