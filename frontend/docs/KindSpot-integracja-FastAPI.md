# KindSpot — integracja Flutter i FastAPI, 2026-10-04

Główne wejście aplikacji (`main.dart`) korzysta teraz z API. Ekrany nie zastępują błędu serwera danymi lokalnego demo. Historyczne ekrany demo pozostają w kodzie i testach. Zmiany są lokalne na gałęzi Frontend; nie opublikowano serwera ani repozytorium.

## Decyzje użytkownika

- Backend i istniejąca ankieta Flutter mają zostać połączone. Dawne odłożenie CP-07/11 nie obowiązuje dla tej pracy.
- Konto Test Hackaton otrzymuje 1000 punktów i zapisany Ogród ciszy przy przygotowaniu konta na serwerze. Uruchomienie aplikacji, logowanie i restart telefonu nie resetują konta. Reset jest ręczną operacją operatora.
- Reset zachowuje nazwane filtry i ustawienia dostępności. Usuwa zakupy, saldo zastępuje startowymi 1000 punktami, odtwarza zapisane miejsce oraz domyślne potrzeby, prywatność i wygląd. Recenzje i głosy społeczności pozostają, aby nie zmieniać cudzych wyników; reset nie jest usunięciem całej historii aktywności.
- Średnia całego miejsca wynika ze wszystkich pomniejszych ocen recenzji. Backend liczy średnią arytmetyczną wszystkich wymiarów ocen zaakceptowanych, widocznych recenzji; każda pomniejsza ocena ma taką samą wagę. Brak funkcji i brak sprawdzenia nie trafiają do średniej. Pole techniczne `average_rating` nie jest drugą oceną. Odpowiedź „Czy polecisz to miejsce?” jest osobnym polem i nie zastępuje średniej.
- Najlepsze miejsca: średnia malejąco, przy tej samej średniej liczba recenzji malejąco. Osobne sortowanie po liczbie recenzji jest dostępne. Brak ocen pozostaje brakiem danych.

## Połączone ekrany i trasy

Wszystkie ścieżki poniżej mają prefiks `/api/v1`.

| Funkcja | Trasy |
| --- | --- |
| Konfiguracja pytań, potrzeb, miast i motywów | GET `/configuration` |
| Rejestracja, logowanie, wylogowanie | POST `/auth/register`, `/auth/login`, `/auth/logout` |
| Profil, nazwa, personalizacja | GET `/me`, PATCH `/me/profile`, GET `/me/cosmetics` |
| Potrzeby, filtry i nazwane filtry | PUT `/me/preferences` |
| Prywatność i dostępność | PATCH `/me/privacy`, PUT `/me/ui-settings` |
| Wyniki listy i mapy | POST `/places/search` |
| Szczegóły miejsca | GET `/places/{id}` |
| Zapisane miejsca | GET `/me/saved-places`, PUT/DELETE `/me/saved-places/{id}` |
| Ankieta i recenzje | POST/GET `/places/{id}/reviews`, GET `/reviews/{id}` |
| Głosy i zgłoszenia | POST `/reviews/{id}/answers/{answerId}/votes`, POST `/reviews/{id}/reports` |
| Zadania weryfikacji i publiczny profil | GET `/me/verification-tasks`, GET `/users/{id}/public-profile` |
| Punkty i historia | GET `/me/points`, GET `/me/points/history` |
| Sklep i szczegóły nagrody | GET `/rewards`, GET `/rewards/{id}` |
| Zakup i moje nagrody | POST/GET `/me/redemptions`, GET `/me/redemptions/{id}` |
| Weryfikacja karty (operator demonstracyjny) | POST `/me/card-verifications`, GET `/me/card-verifications/{id}` |

Wspomaganie ankiety `/review-assistance` istnieje po stronie backendu, ale nie jest nowym ekranem tej integracji. Moduł ankiety pobiera istniejący katalog 12 pytań z konfiguracji i dobiera pytania do potrzeb. Nie dodano 13 nowych proponowanych pytań. Backend zachowuje własne identyfikatory (`elevator`, `quiet_environment` itd.) oraz flagi możliwości pytania. Ocena liczbowa istniejącego modułu Flutter jest tłumaczona na obiekt `{"overall": N, "average_rating": N}`; dla absent/unknown wysyłane jest null. To adapter pojedynczej skali, a nie nowa klasyfikacja wymiarów potrzeb.

Punkty, uprawnienia do zakupu, saldo, publikacja i stany nagród pochodzą z serwera. Ponowienie identycznej ankiety lub zakupu zachowuje Idempotency-Key; zmiana danych tworzy nową operację. Nieudana ankieta zachowuje odpowiedzi. Wygaśnięcie sesji usuwa prywatne dane i zamyka prywatne ekrany. Token jest przechowywany w magazynie systemowym z przypisaniem do adresu serwera; nie trafia do dokumentacji ani komunikatów.

## Przygotowanie backendu

Wymagane: Python i zależności `backend[dev]`, PostgreSQL z pgvector, konfiguracja POSTGRES_HOST/PORT/DB/USER/PASSWORD oraz APP_DB_USER/APP_DB_PASSWORD. Konfiguracja LLM zgodnie z backendem: OLLAMA_MODEL albo jawnie skonfigurowany wariant API. Nie wpisuj sekretów w pliki śledzone przez Git. W tym środowisku przygotowano interpreter:

`C:\Users\igork\Documents\ChatGPT\Hackyeah 2026\.venv-integration\Scripts\python.exe`

Po ustawieniu konfiguracji bazy, w PowerShell:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
cd D:\Github\USpace
.\frontend\scripts\Start-KindSpotApi.ps1 -Python 'C:\Users\igork\Documents\ChatGPT\Hackyeah 2026\.venv-integration\Scripts\python.exe' -SetupDatabase -SeedTestAccount
```

Skrypt zapyta o hasło testowego konta, jeżeli nie ustawiono KINDSPOT_TEST_PASSWORD. Domyślny adres konta to `hackaton@example.invalid`, nazwa Test Hackaton. Hasło ma minimum 12 znaków. Ponowne przygotowanie istniejącego konta nie dodaje punktów i nie zmienia jego hasła. Inny adres testowy musi mieć domenę `example.invalid`.

`-SetupDatabase` wykonuje jawną migrację do wersji 3 (recommendation i saved_places), dane syntetyczne i uprawnienia roli aplikacyjnej. Migracja nie odbywa się przy żądaniu z Fluttera. `-Workers` uruchamia zadania backendu; bez nich recenzje/weryfikacje/zakupy wymagające przetwarzania mogą pozostać oczekujące. Istniejący operator karty jest demonstracyjny.

Ręczny reset: zatrzymaj lokalny serwer i uruchom ten sam skrypt z `-SeedTestAccount -ResetTestAccount`. Reset unieważnia sesje testowego konta; zaloguj się ponownie. Nie uruchamiaj resetu automatycznie przy starcie aplikacji.

Dokumentacja tras: `http://127.0.0.1:8000/api/docs`, specyfikacja `/api/openapi.json`. Przy wersji web na innym origin serwer wymaga jawnej listy KINDSPOT_CORS_ORIGINS; w hostingu Caddy web korzysta z tego samego origin i `/api/v1/`.

## Uruchomienie aplikacji

Emulator uruchamia wyłącznie użytkownik, przez istniejący launcher z ograniczeniami. Te polecenia nie uruchamiają emulatora. Jeśli emulator już działa i lokalny backend jest przygotowany:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
cd D:\Github\USpace\frontend\mobile
. ..\scripts\Use-USpaceEnvironment.ps1
flutter run -d emulator-5554 --dart-define=KINDSPOT_API_URL=http://10.0.2.2:8000/api/v1/ --dart-define=KINDSPOT_LOCAL_HTTP=true
```

10.0.2.2 to adres hosta widziany z emulatora Android. Dla zewnętrznego serwera użyj jego HTTPS URL kończącego się `/api/v1/`, bez flagi lokalnego HTTP. Na fizycznym telefonie 10.0.2.2 nie wskazuje komputera.

Bez zdefiniowanego URL aplikacja natywna pokaże formularz adresu. Lokalny HTTP jest dozwolony wyłącznie w debug dla adresów lokalnych; release wymaga HTTPS. Wersja web bez jawnego URL używa `/api/v1/` na swoim origin. Na ekranie logowania można zmienić adres serwera. Konto wymaga rzeczywistego logowania.

## Sprawdzenia

- Flutter: 175 testów przeszło; analiza bez uwag. Testy HTTP z kontrolowanym transportem obejmują sesję, trwałe saldo, idempotencję i konwersję ankiety. Testy ekranów obejmują logowanie przy 200% tekstu, zachowanie odpowiedzi po błędzie, ponowienie i pytania dobrane do potrzeb.
- Backend: 32 testy bez bazy przeszły; Ruff bez uwag. Testy sprawdzają trasowanie, katalog, modele, średnią i kolejność miejsc.
- Krótka próba rzeczywistego HTTP FastAPI: health/live, konfiguracja, OpenAPI i odmowa dostępu do /me bez tokenu przeszły. Nie korzystała z bazy danych.
- Przygotowano test pełnego przebiegu Flutter/API w `backend/spec_tests/test_flutter_journey_e2e.py`. Nie wykonano go: brak skonfigurowanej PostgreSQL i adresu działającego backendu. Testy integracyjne wymagają osobnej bazy z końcówką `_test`; nie kierować ich na dane demo/użytkowników.
- TalkBack/VoiceOver, fizyczne urządzenie i iOS pozostają do sprawdzenia przez użytkownika. Wyniki automatyczne nie są odbiorem pełnego WCAG.

Kompilacja Android debug zakończona sukcesem: `frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk`, 189 808 058 bajtów, 2026-10-04 06:32:17. Gradle: 1536 MB, dwa workery. Nie instalowano APK ani nie uruchamiano emulatora.

Kompilacja web release zakończona sukcesem (również Wasm dry run). Projekt generuje rusztowanie web w CI; lokalnie sprawdzono osobną kopię źródeł w `C:/Users/igork/Documents/ChatGPT/Hackyeah 2026/artifacts/integration/web-check`, wynik `build/web`. Nie nadpisano konfiguracji Androida. Lokalny Flutter ma teraz włączoną obsługę web. Nie opublikowano strony ani nie wykonywano testu przeglądarki z rzeczywistym serwerem.

## Checklista próby z serwerem

- [ ] Migracja 3 i przygotowanie Test Hackaton wykonane na docelowej bazie; API /configuration działa.
- [ ] Logowanie pokazuje 1000 punktów i Ogród ciszy; po wydaniu punktów restart nie odnawia salda.
- [ ] Lista/mapa używają tych samych wyników. Brak danych dostępności jest opisany; średnia i liczba recenzji pochodzą z API.
- [ ] Zapisz/usuń miejsce, zamknij aplikację i sprawdź trwałość. Nazwany filtr zachowuje się po ponownym wejściu; Użyj filtru nie zapisuje szkicu.
- [ ] Ankieta dobiera pytania do potrzeb, Pokaż wszystkie rozszerza katalog. Wyślij; błąd sieci zachowuje odpowiedzi, ponowienie nie tworzy drugiej recenzji.
- [ ] Po pracy workerów odśwież recenzję, średnią i punkty; status oczekujący nie jest prezentowany jako przyznana nagroda.
- [ ] Anulowanie zakupu nie pokazuje sukcesu. Potwierdzony zakup rozlicza serwer; Do odebrania i Historia pokazują właściwe stany.
- [ ] Sprawdź prywatność potrzeb, publiczny profil, zmianę nazwy, dostępne kosmetyki oraz ustawienia dostępności przy powiększeniu tekstu.
- [ ] Wylogowanie/wygaśnięcie sesji usuwa prywatne ekrany. Zmiana serwera nie przenosi tokenu.
- [ ] Ręczny reset odtwarza 1000 punktów i ogród; zachowuje nazwane filtry/dostępność; wymaga ponownego logowania.

## Pozostałe ustalenia i ograniczenia

Potrzebny jest adres rzeczywistego serwera i konfiguracja operatora do próby z bazą. Nie uzyskano jeszcze dowodu działania migracji i całego przebiegu na PostgreSQL. Obecne dopasowanie progów filtrów do wielowymiarowych ocen backendu jest zachowawcze; sposób agregowania wymiarów/obserwacji dla progów wymaga uzgodnienia. Brak dopasowania nie jest automatycznie dostępnością. Ranking komentarzy przy zerowych dislajkach i zasady zmiany głosu pozostają wcześniejszym otwartym pytaniem; klient respektuje allowedActions backendu.

Katalog serwera zachowuje flagi step_free_entrance bez skali i accessible_toilet bez wielu obiektów. Ewentualne ujednolicenie tych możliwości z wcześniejszym katalogiem lokalnym wymaga decyzji produktu, nie samego podłączenia transportu.
