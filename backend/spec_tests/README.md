# Testy specyfikacyjne backendu

Ten katalog jest celowo oddzielony od `backend/tests`, które CI uruchamia
obecnie przez `pytest backend/tests`. Testy tutaj są czerwone, ponieważ
endpointy i modele produktu nie zostały jeszcze zaimplementowane.

Uruchamianie z katalogu głównego projektu po zainstalowaniu `backend[dev]`:

```text
python -m pytest backend/tests
python -m pytest backend/spec_tests
```

`test_review_model_units.py` określa walidację przyszłego `ReviewCreate`.
Import modelu jest w jednym helperze, aby po ustaleniu struktury pakietu zmienić
wyłącznie miejsce podłączenia. `rating_template.py` jest tymczasowym modelem
odpowiedzi: wymiarów nie ogranicza do przykładowych `blinds`, `asd` i `adhd`;
nie wylicza średniej, bo reguła nie została ustalona.

`test_api_e2e.py` wykonuje żądania przez pełną aplikację ASGI. Po dodaniu
warstwy produktu potrzebuje izolowanej bazy testowej z katalogiem potrzeb,
cech, miast, przykładowymi miejscami i nagrodami z sekcji 8 kontraktu.
Test karty wymaga syntetycznego poprawnego numeru przekazanego przez zmienną
`USPACE_E2E_VALID_CARD_NUMBER`; nie należy używać numeru prawdziwej karty.
Test pozytywnego głosu wymaga syntetycznego konta zakwalifikowanego przez
backend do co najmniej jednej obserwacji. Jego dane logowania przekazuje się
przez `USPACE_E2E_QUALIFIED_EMAIL` i `USPACE_E2E_QUALIFIED_PASSWORD`. Samo
założenie konta nie nadaje tego uprawnienia. Baza testowa musi być resetowana
między pełnymi uruchomieniami, aby dostępne zadanie i oczekiwane liczniki były
powtarzalne.

`test_seeded_transitions_e2e.py` wymaga przygotowanych syntetycznych stanów
po decyzji bota i realizacji nagród. Zmienne środowiskowe `USPACE_E2E_ACCEPTED_AUTHOR_*`,
`USPACE_E2E_ACCEPTED_REVIEW_ID`, `USPACE_E2E_HIDDEN_AUTHOR_*`,
`USPACE_E2E_HIDDEN_REVIEW_ID`, `USPACE_E2E_FUNDED_USER_*`,
`USPACE_E2E_READY_REDEMPTION_ID` i `USPACE_E2E_FAILED_REDEMPTION_ID` wskazują
te dane. Sufiksy `*_EMAIL` i `*_PASSWORD` dotyczą tylko kont testowych.
Fixture powinny być odtwarzane w izolowanej bazie przed każdym uruchomieniem.

Testy te nie modyfikują konfiguracji infrastruktury ani CI. W przyszłości
przed włączeniem czerwonego zestawu do bramki CI trzeba uzgodnić moment
wdrożenia funkcji produktu i stabilne dane testowe.
