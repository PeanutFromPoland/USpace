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

## Uruchomienie

- [Instrukcja po polsku](../docs/RUNNING.pl.md)
- [English setup and run guide](../docs/RUNNING.en.md)

Instrukcje są niezależne od lokalnych ścieżek i obejmują wymagania, backend, emulator/telefon, budowę APK i testy. Polecenia Fluttera wykonuj w `frontend/mobile`. Windowsowy skrypt `scripts/Use-USpaceEnvironment.ps1` jest opcjonalny; konfigurację konkretnego komputera zapisuj w ignorowanym `.dev-tools.local.json`.

## Co trafia do Gita

Kod, testy, konfiguracja platform, dokumentacja, skrypty i `pubspec.lock`. Lokalne ustawienia Obsidiana/IDE, `.dart_tool`, katalogi `build`, logi oraz lokalna konfiguracja narzędzi są ignorowane. Nie dodawaj ignorowanych plików przez `git add -f`.

Aktywne wejście mobilnej aplikacji korzysta z API i logowania. Ankieta wysyła recenzję do backendu; punkty i zakupy są stanem serwera. Konto syntetyczne przygotowuje operator, a restart nie resetuje portfela. Karta miejska i rzeczywista realizacja nagród pozostają demonstracyjne. Historyczne ustalenia w raportach należy czytać z uwzględnieniem późniejszych decyzji.

## Istniejące demo webowe zespołu

Pliki lib/, test/, web/, pubspec.yaml, Dockerfile i nginx.conf bezpośrednio w frontend/ należą do osobnego szkieletu demo webowego z dev. Zostały zachowane wraz z CI/CD. Rozwijana aplikacja mobilna znajduje się w mobile/.
