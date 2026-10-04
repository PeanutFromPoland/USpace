# KindSpot — uruchomienie aplikacji

[English](RUNNING.en.md) · [Strona projektu](../README.md)

Instrukcja dotyczy aplikacji mobilnej w `frontend/mobile` i API w `backend`. Polecenia używają ścieżek względem repozytorium; nie wymagają konkretnego dysku, nazwy użytkownika ani modelu komputera. Interfejs aplikacji jest obecnie w języku polskim.

KindSpot jest Proof of Concept. Główne wejście aplikacji wymaga działającego API i konta. Konto, punkty i zakupy zapisuje serwer. Integracja karty miejskiej i odbiór rzeczywistych nagród pozostają demonstracyjne. Sama kompilacja nie potwierdza działania całego systemu na urządzeniu.

## 1. Pobierz projekt

```sh
git clone https://github.com/PeanutFromPoland/USpace.git
cd USpace
```

Jeśli projekt jest już pobrany, otwórz terminal w jego głównym katalogu. Korzystaj z gałęzi zawierającej aktualny mobilny frontend i backend. Nie wymuszaj zmiany gałęzi przy niezapisanych zmianach. Historyczna nazwa repozytorium i pakietu `uspace` jest prawidłowa.

## 2. Przygotuj narzędzia

Do uruchomienia Androida potrzebujesz:

- Git oraz [Flutter SDK](https://docs.flutter.dev/install) dostępnego w `PATH`. Projekt sprawdzano na Flutter **3.47.6**; `pubspec.yaml` wymaga Dart **>=3.13.5 i <4.0.0**, dostarczanego razem z Flutterem.
- Narzędzi Android SDK i zgodnego JDK, np. instalowanych z Android Studio. Postępuj zgodnie z [instrukcją konfiguracji Androida dla Fluttera](https://docs.flutter.dev/platform-integration/android/setup).
- Telefonu z debugowaniem USB lub emulatora uruchomionego przez Ciebie. Wybierz obraz emulatora odpowiedni dla architektury komputera; jego zasoby dopasuj do swojego sprzętu.
- Połączenia z internetem do pobrania zależności i map.

Sprawdź środowisko:

```sh
flutter --version
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

Przed budową popraw problemy dotyczące wybranej platformy pokazane przez `flutter doctor`. Do Androida nie trzeba konfigurować narzędzi dla każdej pozostałej platformy.

**Windows — opcjonalny skrypt zespołu.** Jeżeli używasz `frontend/scripts/Use-USpaceEnvironment.ps1`, ustaw swoje katalogi w ignorowanym `frontend/.dev-tools.local.json` (pola `flutterSdk`, `androidSdk`, `javaHome`, opcjonalnie `gradleHome`). Następnie, z `frontend/mobile`, wykonaj:

```powershell
. ../scripts/Use-USpaceEnvironment.ps1
```

Skrypt nie instaluje narzędzi i ma domyślne ścieżki środowiska zespołu. Przy standardowej instalacji Fluttera w `PATH` nie jest potrzebny. Nie publikuj lokalnych ścieżek w repozytorium.

## 3. Wybierz backend

### A. Gotowy serwer zespołu

Uzyskaj adres API, np. `https://twoj-serwer.example/api/v1/`, oraz konto albo informację o dostępności rejestracji. Przejdź do kroku 4. Nie potrzebujesz wtedy Dockera, Pythona ani lokalnej bazy.

### B. Własny backend przez Docker Compose

Zainstaluj [Docker z Compose](https://docs.docker.com/compose/install/) i uruchom Docker Engine. Poniższe komendy wykonuj w głównym katalogu repozytorium.

Skopiuj `.env.example` do `.env`:

```powershell
# Windows PowerShell
Copy-Item .env.example .env
```

```sh
# macOS / Linux
cp .env.example .env
```

Jeśli `.env` już istnieje, uzupełnij go zamiast nadpisywać. Ustaw własne, różne wartości `POSTGRES_PASSWORD` i `APP_DB_PASSWORD`. Zachowaj oddzielne role `POSTGRES_USER` i `APP_DB_USER`. Wybierz `OLLAMA_MODEL`; nazwę modelu zostaw niepustą również wtedy, gdy na początku sprawdzasz tylko logowanie i mapę. Domyślnie `USE_CHATGPT_API=false`, więc klucz OpenAI nie jest wymagany. Nie dodawaj `.env` do Gita.

```sh
docker compose up -d --build api
docker compose ps -a
docker compose logs --tail=100 migrate api
```

Compose uruchamia PostgreSQL z pgvector, wykonuje `uspace_api.bootstrap` (aktualne migracje, dane przykładowe i uprawnienia roli API), a następnie API. Nie twórz tabel ręcznie. Numer migracji zależy od wersji kodu. Przy aktualizacji istniejącej instalacji wykonaj jawnie:

```sh
docker compose build migrate api
docker compose run --rm migrate
docker compose up -d api
```

Otwórz w przeglądarce:

- `http://localhost:8000/health/ready` — oczekiwany HTTP 200 i status `ok`;
- `http://localhost:8000/api/docs` — dokumentacja API.

Samo działanie `/health/live` nie potwierdza połączenia z bazą. Jeśli `/health/ready` zwraca 503, sprawdź logi bazy i migracji.

**Model do weryfikacji tekstowych recenzji — opcjonalny na etapie uruchamiania.** Logowanie, lista miejsc i profil nie wymagają pobrania modelu. Aby uruchomić klasyfikację tekstowych recenzji przez Ollama:

```sh
docker compose up -d ollama
docker compose exec ollama ollama pull NAZWA_MODELU
```

Zastąp `NAZWA_MODELU` wartością `OLLAMA_MODEL` z `.env`, dobraną do zasobów komputera. Brak działającego modelu może pozostawić tekstową recenzję w oczekiwaniu na weryfikację; nie oznacza przyznania punktów. Wariant OpenAI i wdrożenie publiczne opisuje [dokumentacja infrastruktury](../infra/README.md).

**Syntetyczne dane biznesowe.** Ustaw `KINDSPOT_ENABLE_DEMO_RESIDENTS=true` i własne hasło w `KINDSPOT_DEMO_ACCOUNT_PASSWORD` (12–256 znaków), a następnie uruchom usługę `migrate`. Powstaną cztery logowalne konta z końcówką `.invalid`: `anna.mieszkanka@kindspot.invalid`, `jan.mieszkaniec@kindspot.invalid`, `wygasla.karta@kindspot.invalid` i `turysta@kindspot.invalid`. Wszystkie używają ustawionego hasła. Operator karty jest osobną usługą demonstracyjną; jej token ustaw w `KINDSPOT_RESIDENT_API_TOKEN`. Numery kart, statusy i zdarzenia w bazie są fikcyjne.

Przygotowanie danych wypełnia tabele produktu: użytkowników, miejsc i części miejsc, recenzji i odpowiedzi, moderacji, problemów tymczasowych, wizyt, głosów, zgłoszeń, punktów, nagród i wymian, weryfikacji kart, zapisanych miejsc oraz tytułów. Obejmuje też przykładową sporną cechę i wygasłą kartę. Seeder można uruchomić ponownie: ma stałe identyfikatory i nie dubluje przykładowych zdarzeń. Ponowne przygotowanie kont aktualizuje ich hasło do wartości z konfiguracji; preferencje są uzupełniane tylko wtedy, gdy mają wartość domyślną. Seeder nie tworzy przykładowych sesji, prób logowania ani innych technicznych zapisów. Dane demonstracyjne służą do prezentacji; nie potwierdzają rzeczywistej dostępności miejsc ani statusu mieszkańca.

**Opcjonalne konto Test Hackaton.** Zwykłe konto można utworzyć przez aplikację. Do prezentacji portfela testowego przygotuj osobne konto syntetyczne:

```sh
docker compose run --rm --no-deps -e KINDSPOT_TEST_PASSWORD="REPLACE_WITH_YOUR_TEST_PASSWORD" migrate python -m uspace_api.test_account
```

Zastąp wartość własnym hasłem mającym co najmniej 12 znaków. Login: `hackaton@example.invalid`. Hasło nie ma wartości domyślnej. Przy pierwszym przygotowaniu konto otrzymuje 1000 punktów testowych i zapisany Ogród ciszy; restart aplikacji ich nie resetuje. Nie używaj `--reset` przy zwykłym uruchomieniu — to oddzielna operacja resetu portfela i zakupów testowego konta.

## 4. Uruchom aplikację Android

W drugim terminalu, z głównego katalogu repozytorium:

```sh
cd frontend/mobile
flutter pub get
flutter devices
```

W komendach poniżej zastąp `DEVICE_ID` identyfikatorem Androida z `flutter devices`.

### Serwer HTTPS

```sh
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=https://twoj-serwer.example/api/v1/
```

### Lokalny backend i Android Emulator

```sh
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=http://10.0.2.2:8000/api/v1/ --dart-define=KINDSPOT_LOCAL_HTTP=true
```

`10.0.2.2` oznacza komputer gospodarza dla standardowego Android Emulatora. `localhost` w emulatorze oznacza sam emulator. Inne środowiska emulatorów mogą mieć inne adresy; do lokalnego debugowania możesz zamiast tego użyć przekierowania ADB opisanego poniżej.

### Lokalny backend i telefon przez USB

Docker Compose udostępnia API na komputerze pod `127.0.0.1:8000`. Po podłączeniu telefonu i zaakceptowaniu debugowania USB przekieruj port:

```sh
adb -s DEVICE_ID reverse tcp:8000 tcp:8000
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=http://127.0.0.1:8000/api/v1/ --dart-define=KINDSPOT_LOCAL_HTTP=true
```

`adb` pochodzi z Android SDK Platform-Tools i musi być w `PATH`. Po ponownym podłączeniu telefonu przekierowanie może wymagać powtórzenia. Lokalne HTTP jest dostępne tylko w debug i tylko dla adresów dopuszczonych przez klienta. Adres HTTP komputera w sieci Wi-Fi nie jest obecnie dopuszczony; na telefonie użyj USB/ADB lub serwera HTTPS.

Możesz też uruchomić `flutter run -d DEVICE_ID` i wpisać adres na ekranie „Połącz KindSpot”. Dla lokalnego HTTP włącz przełącznik „Lokalny backend HTTP”. Adres musi kończyć się `/api/v1/`.

Przy pierwszym uruchomieniu wyświetlą się trzy slajdy. Można je pominąć albo przeglądać ręcznie. Następnie połącz się z API i zaloguj lub utwórz konto. Nie ma automatycznego logowania na konto testowe.

## 5. Budowa APK i testy

Z `frontend/mobile`:

```sh
flutter analyze
flutter test --concurrency=1
flutter build apk --debug
```

APK: `frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk`, licząc od głównego katalogu repozytorium. Plik powstaje lokalnie, jest ignorowany przez Git i nie jest automatycznie dostępny po sklonowaniu. Można wpisać adres API po uruchomieniu; flagi `--dart-define` są opcjonalne także podczas budowy. To paczka do testów, nie wydanie sklepowe.

Instalacja z katalogu `frontend/mobile`:

```sh
adb -s DEVICE_ID install -r build/app/outputs/flutter-apk/app-debug.apk
```

Przy lokalnym backendzie na telefonie nadal potrzebne jest przekierowanie `adb reverse`. Testy Fluttera nie wymagają uruchomienia emulatora. Testy backendu bez bazy, przy zainstalowanym Pythonie >=3.12 — zacznij ponownie w głównym katalogu repozytorium:

```sh
cd backend
python -m venv .venv
```

Aktywuj środowisko: Windows PowerShell `.venv\Scripts\Activate.ps1`, macOS/Linux `source .venv/bin/activate`. Następnie:

```sh
python -m pip install -e ".[dev]"
python -m pytest
```

Testy integracyjne PostgreSQL mają osobną [instrukcję](../backend/spec_tests/README.md). Nie uruchamiaj ich na bazie z danymi użytkowników.

## 6. Inne platformy i zakończenie pracy

iOS wymaga macOS, Xcode i konfiguracji podpisywania; nie był dotąd potwierdzony testem urządzenia. Webowy szkielet bezpośrednio w `frontend/` jest osobnym modułem i nie zastępuje mobilnego `frontend/mobile`. Ta instrukcja podaje sprawdzany tor Android + API, a nie gwarancję działania każdej platformy.

Backend zatrzymasz z głównego katalogu:

```sh
docker compose stop
```

To zachowuje dane w wolumenach. Nie używaj `docker compose down -v`, jeśli chcesz zachować konta i zakupy.

## Rozwiązywanie problemów

| Problem | Co sprawdzić |
| --- | --- |
| `flutter` nie istnieje lub Dart jest zbyt stary | Flutter SDK w `PATH`, `flutter --version`, wymaganie w `pubspec.yaml`. |
| Nie ma urządzenia | Debugowanie USB, zgoda telefonu, sterownik na Windows lub ręcznie uruchomiony emulator; `flutter devices`. |
| Błąd SDK/JDK/licencji | `flutter doctor -v`, Android SDK Manager i `flutter doctor --android-licenses`. Nie kopiuj cudzych `local.properties`. |
| Błąd adresu API | Końcówka `/api/v1/`, HTTPS albo debugowe lokalne HTTP. |
| Połączenie odrzucone | `docker compose ps -a`, gotowość API, prawidłowy adres emulatora lub `adb reverse`. |
| API działa, ale baza nie jest gotowa | `docker compose logs --tail=100 db migrate api`; hasła/role i udane migracje. Zmiana hasła w `.env` nie zmienia automatycznie hasła w już utworzonym wolumenie PostgreSQL. |
| Recenzja czeka na weryfikację | Proces worker, logi API i dostępność wybranego modelu. |
| Konto nie ma punktów testowych | Rejestracja zwykłego konta nie przygotowuje Test Hackaton; użyj osobnego polecenia przygotowania tego konta. |
| Brak miejsca lub pamięci podczas budowy | Zamknij zbędne programy, korzystaj z telefonu zamiast emulatora; nie zmieniaj plików projektu pod jeden komputer. |

Nie publikuj haseł, `.env`, lokalnych ustawień SDK ani katalogów `build`/`.dart_tool`. Instrukcja została sprawdzona względem kodu i Compose; nie zastępuje pełnego testu instalacji na świeżym komputerze ani audytu dostępności.
