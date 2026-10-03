# Infrastruktura USpace

Ten dokument opisuje stan konfiguracji w repozytorium. Publiczne demo nie jest
jeszcze uruchomione: nie ma skonfigurowanego VPS, domeny ani sekretów wdrożenia.
Instrukcja przygotowania serwera znajduje się w [infra/README.md](infra/README.md).

## Architektura

```text
Użytkownik → HTTPS / Caddy → Flutter web (demo)
                         → FastAPI (/api/*, /health/*)
FastAPI → PostgreSQL 17 z pgvector
        → Ollama w prywatnej sieci Docker
        → API OpenAI po włączeniu flagi i dodaniu klucza
```

Kod interfejsu znajduje się w `frontend/`. Jest napisany we Flutterze; wersja
webowa służy do publicznego pokazu, a projekt przewiduje także uruchomienie na
Androidzie. Obecny ekran jest szkieletem informującym o stanie demo. Nie
implementuje jeszcze ścieżek użytkownika z `use-cases.md`.

Backend w `backend/` to asynchroniczna aplikacja FastAPI z trasami produktu
`/api/v1`, sondą `/health/live` i wewnętrzną `/health/ready`. Druga sonda
sprawdza bazę oraz rozszerzenie `vector`. Konto API ma ograniczone uprawnienia;
oddzielna usługa `migrate` używa konta administracyjnego do utworzenia schematu
i danych syntetycznych. Kontrakt v0.1 zawiera wcześniejsze propozycje, a
zatwierdzone zmiany są dopisane w jego aktualizacji implementacyjnej.

## Środowisko lokalne

`compose.yaml` uruchamia `db`, `ollama`, `migrate` i `api`. Baza używa obrazu
`pgvector/pgvector:pg17`. Plik `infra/initdb/01-vector.sql` tworzy rozszerzenie
`vector` przy pierwszym utworzeniu wolumenu bazy. Dane PostgreSQL i modele
Ollama są przechowywane w osobnych wolumenach Docker. API jest dostępne tylko
pod `127.0.0.1:8000`; porty bazy i Ollama nie są publikowane na komputerze.

Wartości konfiguracyjne są opisane w `.env.example`. Lokalny plik `.env` jest
ignorowany przez Git. Wybrany model trzeba pobrać do Ollama osobno. Backend
używa Ollama domyślnie. Po ustawieniu `USE_CHATGPT_API=true` i
`OPENAI_API_KEY` wybiera API OpenAI; nazwę modelu można zmienić przez
`OPENAI_MODEL`. Klucz pozostaje po stronie backendu i nie trafia do Fluttera.
Adapter dostawcy jest używany przez worker moderacji. Zewnętrzne przetwarzanie
tekstu recenzji wymaga dodatkowej flagi
`USPACE_ALLOW_EXTERNAL_REVIEW_CONTENT=true`; domyślnie jest zablokowane.
Worker korzysta z pgvector do sygnału podobieństwa obserwacji tego samego
miejsca, cechy i wejścia w ciągu 48 godzin od wysłania.

## Konfiguracja demo na VPS

`infra/compose.demo.yaml` opisuje bazę, Ollama, API, kontener serwujący
zbudowaną wersję Flutter web i Caddy. Tylko Caddy publikuje porty 80 i 443.
Przekazuje ścieżki
`/api/*` i publiczne `/health/live` do FastAPI, a pozostałe żądania do Flutter web.
Szczegółowa `/health/ready` jest dostępna tylko wewnątrz sieci usług.
PostgreSQL, Ollama, API i kontener webowy komunikują się przez prywatną sieć
Docker. Caddy ma trwałe wolumeny na dane certyfikatów i konfigurację.

Na serwerze plik `/opt/uspace/.env` będzie przechowywał domenę, osobne hasła
administratora bazy i konta API oraz
ustawienia dostawcy LLM. Nie jest częścią repozytorium. Obrazy API i web są
oznaczane identyfikatorem commita. `infra/deploy.sh` zapisuje ich wersje w
`release.env`, zachowuje poprzednią w `release.previous.env` i przy błędzie
uruchomienia przywraca wcześniejszą wersję. Przed pierwszym wdrożeniem nie ma
wersji, do której można wrócić.

## CI i CD

Workflow `.github/workflows/ci-cd.yml` uruchamia się dla PR do `master` oraz
po zmianie w `master`, także po scaleniu PR.

| Etap | Wykonywane kontrole |
| --- | --- |
| Backend | Ruff, testy jednostkowe i e2e Pythona na osobnej bazie PostgreSQL z pgvector |
| Flutter | Analiza kodu, test widżetu i kompilacja wersji webowej |
| Compose | Sprawdzenie obu definicji usług |
| Obrazy | Budowa obrazów API i web; po zmianie w `master` publikacja w GHCR z tagiem commita |
| Wdrożenie | Po ustawieniu `DEMO_DEPLOY_ENABLED=true`: połączenie SSH, aktualizacja Compose, kontrola gotowości i kontrola publicznego adresu |

Wdrożenie jest przygotowane do automatycznego wykonania po scaleniu PR do
`master`, ale pozostaje wyłączone do czasu przygotowania VPS. Workflow wymaga
zmiennej `DEMO_URL` oraz sekretów SSH w środowisku GitHub `demo`. Serwer musi
mieć dostęp do obrazów GHCR. Wymagane ustawienia opisuje
[infra/README.md](infra/README.md).

## Stan i ograniczenia

- Nie ma jeszcze działającej instancji dostępnej w sieci.
- Schemat produktu i syntetyczne dane demonstracyjne są inicjalizowane przez
  usługę `migrate`; nadal nie ma integracji z operatorem karty ani zewnętrznym
  wydawcą benefitów.
- Worker moderacji i realizacji nagród działa demonstracyjnie. Rzeczywiste
  dane użytkowników wymagają osobnej decyzji o prywatności, kopiach zapasowych
  i zasadach operacyjnych.
- Kopie zapasowe, miejsce ich przechowywania, retencja i test odtwarzania
  wymagają wskazania serwera oraz magazynu kopii przed użyciem prawdziwych danych.
- Flutter nadal wymaga podłączenia ekranów do API.
