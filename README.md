# KindSpot

Mobilna aplikacja dla osób z potrzebami dostępności i ich bliskich, pomagająca znaleźć odpowiednie miejsca w mieście. Wcześniejsza nazwa: USpace.

## Frontend mobilny

Aplikacja Flutter znajduje się w `frontend/mobile`, dokumentacja w `frontend/docs`, a skrypty w `frontend/scripts`. Uruchomienie i ograniczenia PoC: [instrukcja frontendu](frontend/README.md).

- [Opis produktu](frontend/docs/Teoria%20Aplikacji.md)
- [Przypadki użycia](frontend/docs/use-cases.md)
- [Propozycja kontraktu frontend–backend](frontend/docs/KindSpot-kontrakt-frontend-backend-v0.1.md)
- [Plan i checkpointy](frontend/docs/KindSpot-checkpointy.md)

Mobilny PoC korzysta z danych i konta demonstracyjnego. Integracje z backendem, kartą miejską i nagrodami nie są podłączone. Instrukcje dla agentów: AGENTS.md.

## Backend, demo webowe i infrastruktura

Repozytorium zawiera także szkielet FastAPI oraz Docker Compose z PostgreSQL i pgvector. Osobny szkielet Fluttera bezpośrednio w `frontend/` jest używany przez istniejące demo webowe, Dockerfile i CI/CD. Nie jest mobilnym PoC w `frontend/mobile/`. Strona startowa i API pokazują gotowość infrastruktury; nie potwierdzają integracji funkcji produktu.

1. Skopiuj `.env.example` do `.env` i ustaw własne hasło bazy oraz nazwę modelu Ollama.
2. Uruchom `docker compose up --build -d`.
3. Pobierz wybrany model przez `docker compose exec ollama ollama pull <model>`.
4. Sprawdź `http://localhost:8000/health/ready`.

Proces CI/CD, konfiguracja VPS, sekrety i odzyskanie wdrożenia: [instrukcja infrastruktury](infra/README.md). Instrukcje generowania platform i budowania demo webowego: `.github/workflows/ci-cd.yml`.
