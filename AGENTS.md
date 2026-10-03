# KindSpot

Przed każdą pracą nad funkcjami przeczytaj oba pliki: `frontend/docs/Teoria Aplikacji.md` oraz `frontend/docs/use-cases.md`. To stała instrukcja użytkownika. Sprawdzaj także `frontend/docs/DO-USTALENIA.md`; dopisuj niejasności, nie ustanawiaj brakujących reguł. Kontrakt v0.1 jest propozycją, nie dowodem działającego API.

Aktualny etap: działający szkielet Flutter. Ankietę i dodawanie recenzji odłożono 2026-10-03. Wszystkie przykłady i niedostępne integracje oznaczaj jawnie. Potrzeby prywatne domyślnie; brak danych nie oznacza dostępności; punkty i nagrody tylko z systemu. Konto obowiązkowe w produkcie, osobne konto demo nie jest implementacją logowania. Dostępność obejmuje każdy ekran. Nie zapisuj sekretów ani danych wrażliwych w dokumentacji.

Emulator uruchamia wyłącznie użytkownik. Nie uruchamiaj ani nie restartuj go zdalnie, także w celu testu skryptów. Do sprawdzeń launchera używaj wyłącznie -Preview lub analizy składni. Stały launcher: frontend/scripts/Start-USpaceEmulator.ps1; 1 vCPU i 1536 MB RAM Androida, bez snapshotów, próba priorytetu BelowNormal. Nie polecaj dla demo komendy flutter emulators --launch, która pomija te limity.

Stała decyzja użytkownika 2026-10-03: CP-02 dotyczy teraz dostępności funkcjonalnej według WCAG 2.2 A/AA i WCAG2ICT. Czytaj frontend/docs/KindSpot-CP02-WCAG.md przy pracy nad udogodnieniami. Końcową grafikę wykona później inna osoba; nie poświęcaj bieżącego etapu projektowaniu docelowej stylistyki. Wyniki częściowych testów nie są pełnym odbiorem WCAG; zachowuj statusy niewykonanych testów urządzenia.

Przed poleceniami Fluttera aktywuj frontend/scripts/Use-USpaceEnvironment.ps1. Projekt Flutter i pubspec.yaml znajdują się w frontend/mobile. Dokumentacja w frontend/docs. Przeniesienie katalogów nie zmienia reguł produktu ani stanu checkpointów.
