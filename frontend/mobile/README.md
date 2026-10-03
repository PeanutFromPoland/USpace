# KindSpot — szkielet Flutter

Interfejs po polsku. Źródła wymagań w `../docs`: `Teoria Aplikacji.md` i `use-cases.md`. Aktualny etap: szkielet aplikacji; ankieta jest odłożona na prośbę użytkownika.

## Działające elementy

- Automatyczny start na mapie z lokalnym kontem „Test Hackaton”. Nazwa konta widoczna w profilu i jego podglądzie; dane nadal oznaczone jako demonstracyjne. Zapisane potrzeby/filtry/motyw pozostają zachowane. Reset danych również wraca do trybu testowego.
- Mapa OSM i równoważna lista tych samych przykładowych miejsc; ręczny wybór Krakowa/Warszawy, wyszukiwanie, szczegóły i status braków danych.
- Nawigacja ze środkowym przyciskiem mapy; cofnięcie z sekcji wraca na mapę, z mapy pyta o wyjście.
- Potrzeby prywatne, niezależny Pomocnik, filtry konieczne/preferowane/bez znaczenia, lokalny zapis ustawień w secure storage.
- Akcent pomarańczowy/różowy/jasnoniebieski w jasnym i ciemnym motywie, wyższy kontrast i ograniczenie animacji; respektowane skalowanie tekstu telefonu.
- Profil i lokalny podgląd prywatności. Zapisane miejsca, proponowane miejsca oraz nagrody mają jawne stany wymagające ustaleń/API.

To PoC: fikcyjne miejsca i dane dostępności nie służą planowaniu rzeczywistych podróży. Rzeczywisty podkład OSM wymaga internetu; aplikacja nie obiecuje trybu offline. Tile URL można ustawić przez `--dart-define=MAP_TILE_URL=...`; produkcyjny dostawca pozostaje do wyboru. Atrybucja OSM jest widoczna na mapie. Backend KindSpot, logowanie, karty, ankieta, głosowanie, saldo i zakup nagród nie są podłączone.

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