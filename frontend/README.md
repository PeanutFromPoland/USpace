# KindSpot — frontend

## Struktura

```text
frontend/
├── mobile/                 # projekt Flutter; tutaj uruchamiamy flutter
│   ├── lib/
│   │   ├── ui/             # ekrany, motywy i wspólne kontrolki
│   │   ├── domain/         # modele i reguły dopasowania demonstracyjnego
│   │   └── data/           # dane demonstracyjne i lokalne repozytorium
│   ├── test/               # testy
│   ├── android/            # konfiguracja platformy Android
│   ├── ios/                # konfiguracja platformy iOS
│   └── pubspec.yaml        # zależności i konfiguracja Fluttera
├── docs/                   # wymagania, use case’y, kontrakt, checkpointy
└── scripts/                # środowisko i launcher emulatora
```

Dokumentacja:

- [Teoria aplikacji](docs/Teoria%20Aplikacji.md) i [przypadki użycia](docs/use-cases.md) — przeczytaj przed zmianami funkcji.
- [Otwarte decyzje](docs/DO-USTALENIA.md).
- [Kontrakt frontend–backend v0.1](docs/KindSpot-kontrakt-frontend-backend-v0.1.md) — propozycja, nie potwierdzenie działającego API.
- [Checkpointy](docs/KindSpot-checkpointy.md).
- [Macierz WCAG](docs/KindSpot-CP02-WCAG.md), [materiały dostępności](docs/KindSpot-dostepnosc-checkpoint.md) i [instrukcja dostępności](docs/kindspot-instrukcja-dostepnosc.md).
- [Ankieta recenzji](docs/KindSpot-ankieta-recenzji.md), [mapowanie pytań](docs/KindSpot-mapowanie-pytan.md), [badanie potrzeb](docs/KindSpot-badanie-potrzeb.md) i [propozycje zmian kontraktu](docs/KindSpot-kontrakt-propozycje-zmian.md).
- [Problem i statystyki](docs/KindSpot-problem-i-statystyki.md) oraz [istniejące rozwiązania](docs/KindSpot-konkurencja.md).
- [Szczegółowa instrukcja aplikacji](mobile/README.md).

## Polecenia na Windows

```powershell
cd D:\Github\KindSpot\frontend\mobile
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
. ..\scripts\Use-USpaceEnvironment.ps1
flutter pub get
flutter analyze
flutter test --concurrency=1
```

Skrypt środowiska domyślnie korzysta z narzędzi w `%USERPROFILE%\develop`. Własne ścieżki można podać w ignorowanym `frontend/.dev-tools.local.json` (flutterSdk, androidSdk, javaHome, opcjonalnie gradleHome). Nie zapisuj ustawień konkretnego komputera w repozytorium.

Emulator uruchamia wyłącznie użytkownik. Z katalogu `frontend/mobile`:

```powershell
..\scripts\Start-USpaceEmulator.ps1 -Preview
# Uruchomienie lub restart wykonuje użytkownik:
..\scripts\Start-USpaceEmulator.ps1 -Restart
```

Launcher zachowuje 1 vCPU i 1536 MB RAM Androida. Aktualne APK po kompilacji znajduje się w `mobile/build/app/outputs/flutter-apk/app-debug.apk`.

## Co trafia do Gita

Kod, testy, konfiguracja platform, dokumentacja, skrypty i `pubspec.lock`. Lokalne ustawienia Obsidiana/IDE, `.dart_tool`, katalogi `build`, logi oraz lokalna konfiguracja narzędzi są ignorowane. Nie dodawaj ignorowanych plików przez `git add -f`.

Przeniesienie katalogów nie zmienia reguł aplikacji ani stanu checkpointów. Ankieta recenzji działa w wersji demonstracyjnej, bez wysyłania do systemu. Dane i konto testowe są demonstracyjne; backend i nagrody nie są zintegrowane.

## Istniejące demo webowe zespołu

Pliki lib/, test/, web/, pubspec.yaml, Dockerfile i nginx.conf bezpośrednio w frontend/ należą do osobnego szkieletu demo webowego z dev. Zostały zachowane wraz z CI/CD. Rozwijana aplikacja mobilna znajduje się w mobile/.
