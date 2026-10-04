# KindSpot

Mobilna aplikacja dla osób z potrzebami dostępności i ich bliskich, pomagająca znaleźć odpowiednie miejsca w mieście. Wcześniejsza nazwa: USpace.

## Uruchomienie / Getting started

- [Polska instrukcja uruchomienia](docs/RUNNING.pl.md)
- [English setup and run guide](docs/RUNNING.en.md)

Instrukcje obejmują Androida, połączenie z gotowym API, lokalny backend Docker Compose, konta, budowę APK i rozwiązywanie problemów. Nie wymagają lokalnych ścieżek zespołu. / The guides cover Android, an existing API or a local Docker Compose backend, accounts, APK builds and troubleshooting without team-specific paths.

## Frontend mobilny

Aplikacja Flutter znajduje się w `frontend/mobile`, dokumentacja w `frontend/docs`, a skrypty w `frontend/scripts`. Uruchomienie i ograniczenia PoC: [instrukcja frontendu](frontend/README.md).

- [Opis produktu](frontend/docs/Teoria%20Aplikacji.md)
- [Przypadki użycia](frontend/docs/use-cases.md)
- [Propozycja kontraktu frontend–backend](frontend/docs/KindSpot-kontrakt-frontend-backend-v0.1.md)
- [Plan i checkpointy](frontend/docs/KindSpot-checkpointy.md)

Mobilny PoC korzysta z API FastAPI i wymaga konta. Dane konta, recenzje, punkty i zakupy przechowuje backend. Integracja karty miejskiej i realizacja rzeczywistych nagród pozostają demonstracyjne. Instrukcje dla agentów: AGENTS.md.

## Backend, demo webowe i infrastruktura

Repozytorium zawiera FastAPI oraz Docker Compose z PostgreSQL i pgvector. Usługa `migrate` przygotowuje bazę przed startem API. Własny backend uruchom według [instrukcji](docs/RUNNING.pl.md#b-własny-backend-przez-docker-compose).

Osobny szkielet Fluttera bezpośrednio w `frontend/` jest używany przez istniejące demo webowe, Dockerfile i CI/CD. Nie jest mobilnym projektem w `frontend/mobile/`.

Proces CI/CD, konfiguracja VPS, sekrety i odzyskanie wdrożenia: [instrukcja infrastruktury](infra/README.md). Instrukcje generowania platform i budowania demo webowego: `.github/workflows/ci-cd.yml`.
