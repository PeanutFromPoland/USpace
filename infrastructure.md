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

Backend w `backend/` to aplikacja FastAPI. Udostępnia obecnie tylko
`/health/live` i `/health/ready`. Drugi adres sprawdza połączenie z bazą oraz
obecność rozszerzenia `vector`. Trasy produktu pod `/api/v1` nie zostały jeszcze
zaimplementowane. Kontrakt v0.1 jest propozycją i wymaga aktualizacji do
zmienionych przypadków użycia, między innymi dla głosowania na pojedyncze cechy
i modelu sesji.

## Środowisko lokalne

`compose.yaml` uruchamia trzy usługi: `db`, `ollama` i `api`. Baza używa obrazu
`pgvector/pgvector:pg17`. Plik `infra/initdb/01-vector.sql` tworzy rozszerzenie
`vector` przy pierwszym utworzeniu wolumenu bazy. Dane PostgreSQL i modele
Ollama są przechowywane w osobnych wolumenach Docker. API jest dostępne tylko
pod `127.0.0.1:8000`; porty bazy i Ollama nie są publikowane na komputerze.

Wartości konfiguracyjne są opisane w `.env.example`. Lokalny plik `.env` jest
ignorowany przez Git. Wybrany model trzeba pobrać do Ollama osobno. Backend
używa Ollama domyślnie. Po ustawieniu `USE_CHATGPT_API=true` i
`OPENAI_API_KEY` wybiera API OpenAI; nazwę modelu można zmienić przez
`OPENAI_MODEL`. Klucz pozostaje po stronie backendu i nie trafia do Fluttera.
Adapter dostawcy jest przygotowany, lecz nie jest jeszcze podłączony do trasy
produktu.

## Konfiguracja demo na VPS

`infra/compose.demo.yaml` opisuje bazę, Ollama, API, kontener serwujący
zbudowaną wersję Flutter web i Caddy. Tylko Caddy publikuje porty 80 i 443.
Przekazuje ścieżki
`/api/*` oraz `/health/*` do FastAPI, a pozostałe żądania do Flutter web.
PostgreSQL, Ollama, API i kontener webowy komunikują się przez prywatną sieć
Docker. Caddy ma trwałe wolumeny na dane certyfikatów i konfigurację.

Na serwerze plik `/opt/uspace/.env` będzie przechowywał domenę, hasło bazy i
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
| Backend | Ruff, testy Pythona i test połączenia z PostgreSQL oraz pgvector |
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
- Nie ma schematu danych produktu ani migracji; skonfigurowano jedynie silnik
  PostgreSQL i rozszerzenie pgvector.
- Nie ma funkcji aplikacji, integracji z kartą miejską ani modelu moderacji.
- Kopie zapasowe, miejsce ich przechowywania, retencja i test odtwarzania
  wymagają wskazania serwera oraz magazynu kopii przed użyciem prawdziwych danych.
- Aktualizacja kontraktu API do `use-cases.md` jest konieczna przed implementacją
  ścieżek produktu.
