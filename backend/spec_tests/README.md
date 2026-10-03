# Testy specyfikacyjne backendu

Testy jednostkowe i e2e obejmują ścieżki API `/api/v1` oraz zatwierdzone
decyzje po kontrakcie v0.1. E2E wymagają osobnej bazy PostgreSQL z pgvector,
której nazwa kończy się `_test`. Fixture odrzuca inną nazwę i czyści wyłącznie
tę bazę przed pełnym przebiegiem, po czym tworzy dane syntetyczne.

Wymagane zmienne połączenia: `POSTGRES_HOST`, `POSTGRES_PORT` (domyślnie 5432),
`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`. Gdy testowane jest osobne
konto aplikacyjne, ustaw także `APP_DB_USER` i `APP_DB_PASSWORD`, a wcześniej
uruchom `python -m uspace_api.bootstrap` z tymi zmiennymi. CI wykonuje oba
kroki automatycznie.

Uruchomienie z katalogu głównego po instalacji `backend[dev]`:

```text
python -m pytest backend/tests backend/spec_tests
```

Fixture tworzy konta do zaakceptowanej i ukrytej recenzji, konto z punktami,
demonstracyjne realizacje nagród oraz wpis potwierdzonej wizyty. Testy
sprawdzają też ujemne saldo po dislajku, serwerową flagę wizyty, sporne
obserwacje i jednokrotne naliczenie punktów. Nie korzystają z prawdziwych
numerów kart ani danych użytkowników.
