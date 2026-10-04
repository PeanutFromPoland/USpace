# KindSpot

Przed każdą pracą nad funkcjami przeczytaj oba pliki: `frontend/docs/Teoria Aplikacji.md` oraz `frontend/docs/use-cases.md`. To stała instrukcja użytkownika. Sprawdzaj także `frontend/docs/DO-USTALENIA.md`; dopisuj niejasności, nie ustanawiaj brakujących reguł. Kontrakt v0.1 jest propozycją, nie dowodem działającego API.

Aktualny etap: działający szkielet Flutter. Ankietę wznowiono 2026-10-03 na polecenie użytkownika: przykładowa ankieta PoC (frontend/docs/KindSpot-ankieta-recenzji.md), bez wysyłania do systemu. Przy pracy nad udogodnieniami czytaj też frontend/docs/kindspot-instrukcja-dostepnosc.md. Wszystkie przykłady i niedostępne integracje oznaczaj jawnie. Potrzeby prywatne domyślnie; brak danych nie oznacza dostępności; punkty i nagrody tylko z systemu. Konto obowiązkowe w produkcie, osobne konto demo nie jest implementacją logowania. Dostępność obejmuje każdy ekran. Nie zapisuj sekretów ani danych wrażliwych w dokumentacji.

Emulator uruchamia wyłącznie użytkownik. Nie uruchamiaj ani nie restartuj go zdalnie, także w celu testu skryptów. Do sprawdzeń launchera używaj wyłącznie -Preview lub analizy składni. Stały launcher: frontend/scripts/Start-USpaceEmulator.ps1; 1 vCPU i 1536 MB RAM Androida, bez snapshotów, próba priorytetu BelowNormal. Nie polecaj dla demo komendy flutter emulators --launch, która pomija te limity.

Stała decyzja użytkownika 2026-10-03: CP-02 dotyczy teraz dostępności funkcjonalnej według WCAG 2.2 A/AA i WCAG2ICT. Czytaj frontend/docs/KindSpot-CP02-WCAG.md przy pracy nad udogodnieniami. Końcową grafikę wykona później inna osoba; nie poświęcaj bieżącego etapu projektowaniu docelowej stylistyki. Wyniki częściowych testów nie są pełnym odbiorem WCAG; zachowuj statusy niewykonanych testów urządzenia.

Przed poleceniami Fluttera aktywuj frontend/scripts/Use-USpaceEnvironment.ps1. Projekt Flutter i pubspec.yaml znajdują się w frontend/mobile. Dokumentacja w frontend/docs. Przeniesienie katalogów nie zmienia reguł produktu ani stanu checkpointów.

Użytkownik 2026-10-03 zlecił agentów dla pozostałych CP-06–12. CP-07 nadal odłożony do modułu Flutter innej osoby; bez tworzenia ankiety/dodawania recenzji. CP-06 zapis/usuń z lokalną listą latest-first zatwierdzony. API na PoC nie będzie: CP-11 rzeczywista integracja odroczona, pozostałe prezentacje/symulacje jawne. Nie nadaje to uprawnień do emulatora, publikacji Git ani naliczania prawdziwych punktów/nagród.


Decyzja użytkownika po wznowieniu: testowy sklep lokalny ma 1000 pkt na każdy nowy proces aplikacji, reset zakupów i konta; zachowuje nazwane filtry oraz dostępność, dodaje Ogród ciszy. To jawne upoważnienie do lokalnego portfela PoC, nie do prawdziwych punktów/nagród. Nowy domyślny akcent pastelowy zielony #ADD8B4; zachowuj wcześniejszy zapisany kolor. Aktualne decyzje: frontend/docs/KindSpot-sklep-testowy.md.


## Integracja Flutter i FastAPI — decyzje 2026-10-04

Ten zapis zastępuje wcześniejsze odłożenie ankiety/API oraz reset konta przy starcie. Użytkownik zlecił połączenie istniejącej ankiety i backendu. Główne wejście aplikacji korzysta z API, wymaga adresu serwera i logowania; dane konta, zapisane miejsca, punkty i zakupy są trwałe po stronie serwera. Test Hackaton otrzymuje 1000 punktów oraz Ogród ciszy tylko przy przygotowaniu konta lub ręcznym resecie operatora. Restart aplikacji nie dodaje punktów. Reset zachowuje nazwane filtry i dostępność; recenzje/głosy społeczności nie są usuwane w resecie portfela.

Decyzja użytkownika: średnia całego miejsca wynika ze wszystkich pomniejszych ocen recenzji. Implementacja liczy wszystkie oceny wymiarów 1–5 zaakceptowanych widocznych recenzji, wyłączając absent/unknown i techniczne average_rating; osobne recommendation nie zastępuje średniej. Priorytet średniej i liczby recenzji przy remisie zachowany.

Włączono transport HTTP, sesję, profil/filtry, miejsca/listę/mapę/zapisane, istniejącą ankietę, recenzje/głosy/zgłoszenia, punkty/sklep/moje nagrody i stany weryfikacji. Katalog 12 istniejących pytań jest dostarczany przez API. Backend wymaga jawnej migracji 3. Punkty/publikacja/uprawnienia nie są nadawane przez klienta. Operator karty pozostaje jawnie demonstracyjny. Nie zmieniono reguł rankingu komentarzy przy zerowych dislajkach.

Sprawdzenia: 175 testów Flutter, analiza bez uwag; 32 testy backendu bez bazy i Ruff poprawne. Próba HTTP konfiguracji/OpenAPI/health oraz ochrony /me przeszła bez PostgreSQL. Pełny przebieg z bazą i urządzeniem pozostaje do wykonania: brak konfiguracji PostgreSQL i wskazanego adresu serwera. Nie uruchamiano emulatora. Zmiany lokalne Frontend, bez commita/push. Pełny zakres, polecenia i checklista: frontend/docs/KindSpot-integracja-FastAPI.md.

Aktualne instrukcje mają pierwszeństwo przed historycznymi zapisami o WIP, braku API i odłożonej ankiecie. Przed zmianami nadal czytaj oba dokumenty źródłowe. Zachowaj równoległą integrację grafik innego chatu. Emulator uruchamia tylko użytkownik.
