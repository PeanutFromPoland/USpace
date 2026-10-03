# KindSpot — CP-11: granice integracji i przygotowanie kontraktu

Data: 2026-10-03. Status: **integracja produktowa odroczona decyzją użytkownika**. Na potrzeby PoC API nie ma i nie będzie; aplikacja używa jawnych danych demonstracyjnych. Adapter poniżej nie jest podłączony do aplikacji i nie uruchamia serwera.

## Co istnieje w repozytorium

`backend/uspace_api/main.py` deklaruje wyłącznie GET `/health/live` z odpowiedzią `{"status":"ok"}` oraz GET `/health/ready` z odpowiedzią `{"status":"ok","database":"ready","pgvector":"ready"}`. Readiness sprawdza PostgreSQL/pgvector i przy błędzie zwraca HTTP 503. Health nie potwierdza usług produktu.

To analiza kodu, nie dowód uruchomionego środowiska. Nie wysyłano żądań do faktycznego backendu ani nie sprawdzano bazy. Brakuje endpointów logowania, konfiguracji, profilu, filtrów, miejsc, recenzji, głosów, karty, punktów i nagród. Kontrakt v0.1 pozostaje propozycją; callback OAuth nie jest adresem API produktu.

## Przygotowanie Fluttera

`api_transport.dart` udostępnia wymienny interfejs JSON i natywny adapter bez dodatkowych zależności. `api_health_repository.dart` zna tylko dwa istniejące endpointy. Aplikacja pozostaje na repozytorium demo; transport nie jest importowany przez jej ekrany/kontroler.

Adres wymaga HTTPS. HTTP dopuszczony wyłącznie po jawnym włączeniu dla loopback; `10.0.2.2` nie jest loopback i wymaga przyszłej świadomej konfiguracji developerskiej. Brak adresu domyślnego, tokenów, logów danych i wyłączania weryfikacji TLS. Ścieżka relatywna nie zmienia hosta/prefiksu. Brak automatycznych przekierowań i ponowień.

Timeout całego odczytu 10 s i limit 64 KiB to robocze ograniczenia adaptera health, nie limity przyszłych danych miejsc. Błędy rozdzielają timeout, sieć, 401, 403, 429, 5xx, inne HTTP i niepoprawną odpowiedź. Wyjątki nie zawierają treści serwera ani sekretów. Natywny adapter `dart:io` nie obsługuje przeglądarki; cel web wymaga innego transportu. Testy używają wyłącznie kontrolowanego serwera loopback.

Źródła: [Dart HttpClient](https://api.dart.dev/dart-io/HttpClient-class.html), [wyłączenie przekierowań](https://api.dart.dev/dart-io/HttpClientRequest/followRedirects.html). SDK rekomenduje bibliotekę wyższego poziomu dla szerszej obsługi platform; obecny adapter służy przygotowaniu health w natywnym PoC i pozostaje wymienny.

## Lista przyszłego kontraktu — niezatwierdzone API

1. Adres testowy, OpenAPI, wspólne fixture'y, wersjonowanie i platformy. Raport nie ustanawia endpointów produktu.
2. Obowiązkowe konto, sesja/odnowienie/wygaśnięcie, odzyskanie dostępu i status karty per miasto. Prywatny profil osobno od publicznego; potrzeby prywatne domyślnie; ukryta reputacja w systemie.
3. Konfiguracja miast, operator mapy, trwałe ID cech i opisane oceny. Brak danych, brak cechy, stan działania i jakość osobno.
4. Wyszukiwanie w całym mieście dla happy case; filtry, paginacja i równoważna mapa/lista. Ranking: średnia malejąco → liczba recenzji malejąco. Zakres recenzji w agregacie, waga Turysty i wpływ oceny 0 wymagają ustalenia. Klient nie wyprowadza oceny miejsca ze średnich cech.
5. Zapisane miejsca i synchronizacja preferencji, potwierdzenie zapisu, błędy i konflikt aktualizacji. Lokalny PoC nie synchronizuje konta.
6. Ankieta i tworzenie recenzji pozostają odłożone. Rozdzielić publikację, weryfikację i punkty; głosy per obserwacja/element/wejście. System egzekwuje zakaz własnej weryfikacji. Ranking komentarzy według lajków/dislajków wymaga reguł zerowego mianownika i remisów.
7. Saldo i wydanie nagrody autorytatywne w systemie: koszt/uprawnienia, idempotencja, processing/failed, zwolnienie punktów po awarii i odczyt niejednoznacznego wyniku. Klient nie emituje prawdziwego kodu ani biletu.
8. Strukturalne błędy, czytelne statusy, zachowanie formularzy, nieaktualność danych i bezpieczne ponowienie. Błąd techniczny nie oznacza pustej listy ani dostępności miejsca.

CP-11 nie oznacza odbioru integracji, auth ani WCAG. Po dostarczeniu API zatwierdzić kontrakt, podłączyć repozytoria produktu i wykonać testy integracyjne.

Weryfikacja automatyczna: 12 testów CP-11 przeszło (walidacja adresu, ścieżki health, JSON, statusy HTTP, przekierowanie, rozmiar i timeout). Nie są to testy rzeczywistego backendu.
