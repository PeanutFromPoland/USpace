# KindSpot — propozycje zmian kontraktu v0.1 z prac nad ankietą

Data: 2026-10-03. Źródła: [ankieta recenzji](KindSpot-ankieta-recenzji.md), [kontrakt v0.1](KindSpot-kontrakt-frontend-backend-v0.1.md), [przypadki użycia](use-cases.md), [Teoria aplikacji](Teoria%20Aplikacji.md).

| # | Zmiana | Status | Uzasadnienie |
|---|---|---|---|
| 1 | Pole `recommendation` (integer 1–5 lub null) w `ReviewCreate` i `Review`: „Czy polecisz to miejsce osobom z podobnymi potrzebami?” | **Decyzja użytkownika 2026-10-03, wpisane do kontraktu** | Ekran końcowy ankiety. Nie jest odpowiedzią o cechę i nie wpływa na `FeatureSummary` |
| 2 | Ocena 0 (`absent`, „Brak funkcji”) nie wlicza się do średniej oceny cechy | **Decyzja użytkownika 2026-10-03, wpisane do kontraktu** | Domyka punkt „wpływ 0 na ocenę zbiorczą” z Teorii aplikacji E |
| 3 | Pole `calmMode` (boolean) w `UiSettings`: tryb spokojny | Wstępnie przyjęte („może”), do potwierdzenia | Potrzeba osób w spektrum autyzmu i z nadwrażliwością sensoryczną |
| 4 | Atrybut cechy `isEnvironmental` w `Feature`: przy hałasie, tłumie i świetle brak opcji „0 – Brak funkcji” | Propozycja, zastosowana w PoC | Otoczenie zawsze „jest”; „brak hałasu” to ocena 5, nie brak funkcji |
| 5 | Rozszerzenie katalogu o 13 cech z pierwszej wersji ankiety | Propozycja | Lista w [mapowaniu pytań](KindSpot-mapowanie-pytan.md#propozycja-rozszerzenia-katalogu-do-odbioru) |
| 6 | Utrudnienie tymczasowe dozwolone także przy `absent` | Do potwierdzenia, zastosowane w PoC | Przykład z opisu produktu: „Brak podjazdu, bo go budują” |
| 7 | Zdjęcia z opisem w recenzji | Decyzja otwarta, poza PoC | Wymagałyby modelu załączników, przechowywania i moderacji obrazów |
