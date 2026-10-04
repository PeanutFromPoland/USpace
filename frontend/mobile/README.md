# KindSpot — aplikacja mobilna / Mobile app

Projekt Flutter/Dart. Wszystkie polecenia Fluttera uruchamiaj w tym katalogu. / Run all Flutter commands from this directory.

## Uruchomienie / Getting started

- [Pełna instrukcja po polsku](../../docs/RUNNING.pl.md)
- [Complete English setup and run guide](../../docs/RUNNING.en.md)

Główne wejście korzysta z API i wymaga konta. Adres podaj na ekranie połączenia lub przez `KINDSPOT_API_URL`. Lokalne HTTP jest dopuszczone tylko w debug, dla wskazanych adresów lokalnych. / The main entry point uses the API and requires an account. Enter the URL on the connection screen or set `KINDSPOT_API_URL`. Local HTTP is restricted to debug builds and accepted local hosts.

## Struktura / Structure

- `lib/ui` — ekrany, motywy i komponenty / screens, themes and components.
- `lib/integration` — kontroler integracji API / API integration controller.
- `lib/data` — transport API, katalogi i historyczne dane demo / API transport, catalogs and historical demo data.
- `lib/domain` — modele / models.
- `assets/graphics` — grafiki SVG / SVG assets.
- `test` — testy Fluttera / Flutter tests.

Techniczna nazwa pakietu to `uspace`, identyfikator Androida to `com.example.uspace`. / The technical package name is `uspace`; the Android application ID is `com.example.uspace`.

## Dokumentacja / Documentation

Wymagania i historia decyzji: [teoria aplikacji](../docs/Teoria%20Aplikacji.md), [use case’y](../docs/use-cases.md), [otwarte decyzje](../docs/DO-USTALENIA.md), [checkpointy](../docs/KindSpot-checkpointy.md). Historyczne raporty opisują stan z daty ich powstania; dawne lokalne demo nie jest obecnym głównym wejściem aplikacji.

Dostępność jest częścią każdego ekranu. Automatyczne testy nie zastępują testów urządzenia, czytnika ani pełnego audytu. / Accessibility is part of every screen. Automated tests do not replace device, screen reader or full accessibility testing.
