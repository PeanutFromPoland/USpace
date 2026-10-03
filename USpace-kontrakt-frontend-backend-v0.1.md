# USpace — kontrakt frontend–backend v0.1

Status: propozycja do uzgodnienia w zespole, nie opis istniejącego API.
Zakres: dane i zachowania potrzebne frontendowi mobilnemu/responsywnemu PoC. Bez projektu bazy, algorytmów moderacji, reputacji ani integracji z operatorem karty.
Źródła: aktualny opis produktu oraz dostarczone UC-01–UC-12. Rozbieżności są wskazane w sekcji 10; nie traktujemy ich jako uzgodnionych.

## 1. Podział odpowiedzialności

Frontend: ekrany, nawigacja, dostępność, formularze, walidacja pomocnicza, wyświetlanie wyników i stanów, zachowanie szkicu po błędzie, mapa/lista, potwierdzenia zakupów.

Backend: autoryzacja i walidacja ostateczna, zapis danych, wyszukiwanie i dopasowanie, statusy recenzji, możliwość weryfikacji, naliczanie punktów, dostępność i wydawanie nagród, komunikacja z API karty.

Frontend nie wylicza wiarygodności, nie przyznaje punktów i nie uznaje lokalnej zmiany salda za potwierdzenie zakupu. Ukryta reputacja nie jest zwracana klientowi. Bot sprawdza jakość/ryzyko nadużycia; pozytywna analiza tekstu nie jest dowodem dostępności miejsca.

OSM jest podkładem/źródłem danych geograficznych. Frontend otrzymuje miejsca i informacje USpace z naszego API, z trwałym identyfikatorem USpace. Nie pobiera prywatnych danych ani recenzji z OSM. Dostawca mapy i atrybucja pozostają osobnym uzgodnieniem.

## 2. Wspólne zasady API

- Propozycja: JSON REST, prefiks `/api/v1`, nazwy pól camelCase, identyfikatory jako nieprzezroczyste stringi.
- Publiczne odczyty: katalog konfiguracji, miejsca i publiczne recenzje/profile. Zapis, prywatny profil, punkty i nagrody użytkownika wymagają logowania. Przeglądanie bez konta jest propozycją do zatwierdzenia.
- Propozycja logowania PoC: email i hasło, access token przesyłany jako `Authorization: Bearer ...`. Mechanizm odnowienia/sesji należy zatwierdzić przed implementacją; aplikacja webowa i natywna mogą wymagać innego sposobu przechowywania sesji.
- Znaczniki systemowe: ISO 8601 z offsetem lub `Z`. Wizyta: `visitedOn` jako `YYYY-MM-DD`, `visitedAtLocalTime` jako `HH:mm` lub null, `timeZone` jako identyfikator IANA. Backend zwraca dane bez utraty znaczenia lokalnej godziny.
- Brak wartości: null; brak cechy w miejscu i brak informacji o niej mają różne statusy.
- Listy: `{ "items": [...], "nextCursor": null }`. Proponowany `limit`: domyślnie 20, maksymalnie 100. Kursor jest nieprzezroczysty i ważny tylko dla niezmienionego zapytania.
- `201`: utworzenie zasobu; `202`: rozpoczęcie procesu, którego status trzeba odczytać; `204`: brak odpowiedzi. Pozostałe sukcesy: `200`.
- Frontend pokazuje komunikaty po polsku na podstawie kodów i etykiet. Nazwy techniczne enumów nie trafiają bezpośrednio do UI.
- Backend zwraca `allowedActions` i ograniczenia do zbudowania UI, ale niezależnie sprawdza uprawnienia przy każdym zapisie.
- Powtórzenie POST recenzji, weryfikacji lub zakupu z tym samym `Idempotency-Key` i tym samym payloadem zwraca ten sam rezultat bez duplikacji. Ten sam klucz z innym payloadem: `409 IDEMPOTENCY_CONFLICT`. Proponowany okres pamiętania: minimum 24 h; dokładny okres do uzgodnienia. Po niejednoznacznym błędzie sieci klient ponawia ten sam klucz.
- Status procesu w tle jest odczytywany po powrocie na ekran, na żądanie użytkownika lub okresowo, gdy ekran jest aktywny. WebSocket/push nie jest wymagany do PoC. Frontend odświeża profil, punkty i recenzję po potwierdzonej zmianie.

### Format błędu

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Sprawdź zaznaczone pola.",
    "fieldErrors": [
      { "path": "answers[0].rating", "code": "OUT_OF_RANGE" }
    ],
    "retryable": false,
    "requestId": "req_123"
  }
}
```

Kody HTTP: 400 błędna struktura; 401 brak/wygasła sesja; 403 brak uprawnień; 404 brak zasobu; 409 konflikt/stara cena/duplikat; 422 niepoprawne wartości biznesowe; 429 limit; 503 czasowa niedostępność. Przy 429 respektujemy `Retry-After`.

Kody wymagane w UI: `EMAIL_TAKEN`, `INVALID_CREDENTIALS`, `SESSION_EXPIRED`, `VALIDATION_ERROR`, `CARD_INVALID`, `CARD_OWNERSHIP_NOT_CONFIRMED`, `CARD_PROVIDER_UNAVAILABLE`, `SELF_VERIFICATION_NOT_ALLOWED`, `ALREADY_VERIFIED`, `REVIEW_NOT_AVAILABLE`, `INSUFFICIENT_POINTS`, `REWARD_UNAVAILABLE`, `NOT_ELIGIBLE`, `PRICE_CHANGED`, `IDEMPOTENCY_CONFLICT`, `SERVICE_UNAVAILABLE`.

Brak wyników to sukces z pustą listą, nie błąd integracji. Błąd kafelków mapy nie ukrywa dostępnej listy miejsc.

## 3. Modele danych widoczne dla frontendu

### Użytkownik i preferencje

`Me`: `id`, `displayName`, `appearance {avatarId, frameId, titleId}`, `helperOptIn`, `memberships[]`, `stats {reviewCount, verificationCount}`, `achievements[]`, `pointsBalance`, `preferences`, `uiSettings`, `privacy`.

`Membership`: `cityId`, `status` (`unverified | pending | verified | expired | rejected`), `validUntil` (null dozwolone), `cardMasked` (null dozwolone). API nie zwraca pełnego numeru karty. Status jest zależny od miasta. Pomocnik jest niezależny od członkostwa.

`Preferences`: `needIds[]`, `presetIds[]`, `rules[]`. Reguła: `{featureId, importance, minRating}`; importance: `required | preferred | ignored`. `minRating` to 1–5 lub null, występuje tylko dla ocenialnej cechy z `required`. Propozycja: brak reguły oznacza `ignored`; preset jest rozwijany do reguł, jawna reguła szczegółowa ma pierwszeństwo. UI pokazuje użytkownikowi rzeczywiste, efektywne reguły.

`Privacy`: `needsVisibility` (`private | public`, domyślnie private). Publiczne API nie ujawnia prywatnych potrzeb, historii lokalizacji, salda ani danych karty.

`UiSettings`: `colorThemeId`, `highContrast`, `reduceMotion`, `textScale`, `simpleLanguage`. Dopuszczalne wartości skal i motywów zwraca konfiguracja. Ustawienia UI są niezależne od filtrów miejsc, dostępne też lokalnie przed logowaniem.

### Katalog potrzeb i cech

`Need`: `id`, `label`, `description`, `suggestedPresetIds[]`.
`Feature`: `id`, `label`, `description`, `categoryId`, `supportsRating`, `supportsOperationalState`, `supportsMultipleTargets`, `ratingLabels` (etykiety 1–5, jeśli dotyczy).
`Preset`: `id`, `label`, `rules[]`.

Frontend korzysta z identyfikatorów katalogu. Lista potrzeb obejmuje także podróż z psem przewodnikiem; osobna potrzeba psa terapeutycznego pozostaje do uzgodnienia.

### Miejsce i jego części

`PlaceSummary`: `id`, `name`, `categoryId`, `cityId`, `address`, `location {lat, lon}`, `match`, `activeIssueCount`, `lastVerifiedAt`.

`Match`: `status` (`matches | does_not_match | insufficient_data | not_evaluated`), `reasons[] {featureId, targetId, code, label}`, `unknownFeatureIds[]`. Propozycja: wymagania konieczne muszą być potwierdzone i aktualnie spełnione; preferencje porządkują wyniki. Frontend nie obiecuje dostępności przy brakujących danych.

`PlaceDetail`: pola podsumowania oraz `parts[]`, `features[]`, `temporaryIssues[]`, `allowedActions[]`.

`Part`: `id`, `kind` (`entrance | other`), `name`, `description`, `location` (opcjonalna).

`FeatureSummary`: `featureId`, `targetId` (null dla całego obiektu), `presence` (`present | absent | unknown | disputed`), `operationalState` (`working | not_working | limited | unknown` lub null), `rating` (liczba lub null), `ratingCount`, `observedAt` (null dozwolone), `lastVerifiedAt` (null dozwolone), `sourceLabel`. Sposób agregacji jest odpowiedzialnością backendu.

`TemporaryIssue`: `id`, `featureId`, `targetId`, `kind` (`construction | outage | other`), `description`, `status` (`active | resolved | needs_recheck`), `reportedAt`.

### Recenzja i jej statusy

`Review`: `id`, `placeId`, `author {id, displayName, appearance, badges[]}`, `visitedOn`, `visitedAtLocalTime`, `timeZone`, `createdAt`, `mode` (`quick | detailed`), `answers[]`, `temporaryIssues[]`, `publicationStatus`, `verificationStatus`, `communitySummary`, `allowedActions[]`.

`Answer`: `featureId`, `targetId`, `presence` (`present | absent | unknown`), `operationalState` (jak wyżej lub null), `rating` (integer 1–5 lub null), `comment` (string lub null).

- `rating = 3` jest oceną pośrednią zgodną z etykietą danej cechy, nie brakiem zdania.
- `unknown` i pominięcie pytania nie są oceną 3.
- Pytanie pominięte nie występuje w `answers`; jawne „nie wiem” ma presence unknown.
- Przy absent/unknown: rating i operationalState są null. Przy unknown komentarz może być opcjonalny.
- Minimum jedna merytoryczna odpowiedź (present albo absent), aby wysłać recenzję. Dokładne granice długości pól zwraca konfiguracja.
- Działająca/zepsuta cecha i jakość są osobne; ankieta nie wymusza gwiazdek, gdy jakości nie można ocenić.
- Data nie może być przyszła względem strefy wizyty; godzina jest opcjonalna, bez automatycznego wpisywania godziny wysłania.

`publicationStatus`: `visible | hidden_pending_moderation | removed`.
`verificationStatus`: `pending | needs_community | under_moderation | accepted | rejected`.
Widoczna recenzja może nadal oczekiwać na weryfikację. Accepted nie oznacza gwarancji dostępności miejsca. Propozycja: zwykłe zgłoszenie nie usuwa recenzji; decyzję publikuje backend.

`communitySummary`: `confirmedCount`, `disputedCount`, `unableToAssessCount`, `agreementPercent` (null przy braku głosów merytorycznych). Proponowany mianownik procentu: confirmed + disputed, bez unableToAssess. Frontend pokazuje liczby razem z procentem.

Dla autora osobno: `pointAward {status: pending | granted | not_granted | reversed, amount, reasonCode}`. Zmiana oceny społeczności nie powoduje samodzielnej aktualizacji punktów przez frontend.

### Weryfikacja, punkty i nagrody

`Verification`: `id`, `reviewId`, `verdict` (`confirm | dispute | unable_to_assess`), `reason` (opcjonalny), `createdAt`, `pointAward`. Propozycja v0.1: głos dotyczy całej recenzji; weryfikacja per odpowiedź wymaga rozszerzenia kontraktu.

`PointsEntry`: `id`, `delta` (signed integer), `reasonCode`, `relatedReviewId` (null dozwolone), `relatedVerificationId` (null dozwolone), `relatedRedemptionId` (null dozwolone), `createdAt`. Oczekujące punkty nie są częścią salda do wydania.

`Reward`: `id`, `name`, `description`, `kind` (`cosmetic | city_benefit`), `costPoints`, `cityId` (null dozwolone), `availability` (`available | sold_out | inactive`), `eligibility {eligible, reasonCode}`, `deliveryMethods[]` (`account_item | pickup_code | city_card`), `imageUrl` (null dozwolone).

`Redemption`: `id`, `rewardId`, `rewardName`, `costPoints`, `deliveryMethod`, `status` (`processing | ready | fulfilled | failed`), `createdAt`, `code` (null dozwolone), `expiresAt` (null dozwolone), `instructions` (null dozwolone), `failureCode` (null dozwolone), `pointsStatus` (`reserved | charged | released`). ready oznacza gotową nagrodę/kod; fulfilled oznacza odebranie albo zastosowanie benefitów.

Dobrowolny zwrot nie jest funkcją PoC. Błąd wydania musi jednak skutkować zwolnieniem/zwróceniem punktów przez backend i odpowiednim komunikatem. Przy processing frontend nie pokazuje sukcesu odbioru.

## 4. Operacje API i powiązania z UC

Tabela określa payload i rezultat; modele są zdefiniowane w sekcji 3. Odpowiedzi list są stronicowane według sekcji 2.

| UC | Metoda i ścieżka | Wejście | Wynik / zastosowanie UI |
|---|---|---|---|
| 01 | POST `/auth/register` | email, password, displayName | 201: userId; przejście do logowania. Domyślny wygląd |
| 01 | POST `/auth/login` | email, password | accessToken, expiresAt, Me |
| 01 | POST `/auth/logout` | brak | 204; zakończenie sesji |
| 01–03 | GET `/me` | brak | Me |
| 01 | PATCH `/me/profile` | displayName i/lub appearance z identyfikatorami posiadanych elementów, helperOptIn | Me; serwer odrzuca nieposiadane elementy |
| 01 | GET `/me/cosmetics` | cursor, limit | posiadane elementy i elementy domyślne: id, kind, label, imageUrl |
| 02 | POST `/me/card-verifications` | cityId, cardTypeId, cardNumber | 202: id, status pending |
| 02 | GET `/me/card-verifications/{id}` | brak | id, cityId, status pending/verified/rejected/failed, validUntil, reasonCode |
| 03, 12 | GET `/configuration` | brak | needs, features, presets, cities, cardTypes, uiOptions, limits |
| 03 | PUT `/me/preferences` | pełne Preferences | zapisane Preferences i effectiveRules |
| 03 | PATCH `/me/privacy` | needsVisibility | zapisane Privacy |
| 12 | PUT `/me/ui-settings` | pełne UiSettings | zapisane UiSettings |
| 04 | POST `/places/search` | q?, cityId?, bbox?, rules[], includeUnknownRequired, sort, cursor?, limit? | lista PlaceSummary |
| 04 | GET `/places/{id}` | brak | PlaceDetail |
| 04, 08–09 | GET `/places/{id}/reviews` | sort, cursor, limit | lista Review; sort community/newest |
| 05 | POST `/place-links/resolve` | token z własnego QR USpace | placeId, targetId lub 404; nie dowodzi obecności |
| 05–06 | POST `/places/{id}/reviews` | ReviewCreate; Idempotency-Key | 201: Review z faktycznymi statusami i pointAward autora |
| 07 | POST `/review-assistance` | placeId, draft: ReviewCreate | suggestions[]: id, answerClientId?, field, question, required:false |
| 08–10 | GET `/reviews/{id}` | brak | Review; pointAward tylko dla autora |
| 09 | GET `/me/verification-tasks` | cursor, limit | zadania: id, review, allowedActions; bez historii lokalizacji innych osób |
| 09 | POST `/reviews/{id}/verifications` | verdict, reason?; Idempotency-Key | 201: Verification i communitySummary |
| uzupełnienie | POST `/reviews/{id}/reports` | reasonCode, description? | 201: reportId, status received |
| 10 | GET `/me/points` | brak | balance, pendingAmount (null jeśli nieustalone) |
| 10 | GET `/me/points/history` | cursor, limit | lista PointsEntry |
| 11 | GET `/rewards` | cityId?, cursor, limit | lista Reward |
| 11 | GET `/rewards/{id}` | brak | Reward |
| 11 | POST `/me/redemptions` | rewardId, expectedCostPoints, deliveryMethod; Idempotency-Key | 201: Redemption oraz pointsBalance; processing jest dozwolone |
| 11 | GET `/me/redemptions` | cursor, limit | lista Redemption |
| 11 | GET `/me/redemptions/{id}` | brak | Redemption i pointsBalance |
| uzupełnienie | GET `/users/{id}/public-profile` | brak | id, displayName, appearance, publiczne badges i stats; needs tylko gdy jawnie publiczne |

`configuration.limits`: maxReviewAnswers, maxNewParts, maxCommentLength, maxPartNameLength, maxReportDescriptionLength, maxSearchLimit. `cities`: id, label, center, timeZone. `cardTypes`: id, cityId, label, formatHint. `uiOptions`: themeIds, textScales oraz etykiety. Frontend nie zgaduje ograniczeń.

Propozycja wyszukiwania: bbox `{west,south,east,north}` w stopniach, współrzędne WGS84; cityId i bbox mogą występować razem i wtedy zawężają się łącznie. Jeśli brak obu, serwer wymaga q albo zwraca VALIDATION_ERROR. sort: `recommended | name`; odległość poza v0.1. q szuka nazwy/adresu w podanym obszarze. Wyniki są ograniczone i stronicowane; frontend nie zakłada, że jeden fetch pokrywa wszystkie pinezki.

`includeUnknownRequired=false` domyślnie wyklucza miejsca bez danych dla wymagań koniecznych. true dopuszcza je z match insufficient_data, nadal wykluczając znane niespełnienie. matches zawsze przed insufficient_data. Bez reguł: not_evaluated. Ranking i agregacja po stronie backendu. UI wyraźnie oddziela wyniki niepotwierdzone od spełniających wymagania.

`GET /places/{id}` opisuje cechy, ale nie oblicza dopasowania do niezapisanych filtrów. Karta używa wyniku search; po zmianie filtrów frontend ponawia search i aktualizuje match.

Raporty: reasonCode `suspected_false | offensive | spam | other`. Zgłoszenie i głos dispute to różne akcje. Status zgłoszenia nie musi zmieniać publikacji. Moderator UI i API moderatora są poza frontendowym PoC użytkownika.

## 5. Przykłady payloadów

### Wyszukiwanie

```json
{
  "cityId": "city_krakow",
  "bbox": {"west": 19.9, "south": 50.0, "east": 20.1, "north": 50.1},
  "rules": [
    {"featureId": "step_free_entrance", "importance": "required", "minRating": null},
    {"featureId": "quiet_environment", "importance": "preferred", "minRating": null}
  ],
  "includeUnknownRequired": false,
  "sort": "recommended",
  "limit": 20
}
```

### ReviewCreate: jedna struktura dla krótkiej i szczegółowej recenzji

```json
{
  "mode": "detailed",
  "visitedOn": "2026-10-03",
  "visitedAtLocalTime": "14:30",
  "timeZone": "Europe/Warsaw",
  "newParts": [
    {"clientId": "part_local_1", "kind": "entrance", "name": "Wejście od ulicy Białej", "description": null}
  ],
  "answers": [
    {
      "clientId": "answer_local_1",
      "featureId": "ramp",
      "targetId": null,
      "targetClientId": "part_local_1",
      "presence": "present",
      "operationalState": "working",
      "rating": 4,
      "comment": "Podjazd dostępny, ale trudno było wjechać samodzielnie."
    }
  ],
  "temporaryIssues": []
}
```

`newParts` i `temporaryIssues` mogą być puste. `clientId` odpowiedzi służy wiązaniu pytań UC-07 i błędów z formularzem. Dla istniejącej części podajemy targetId; dla nowej targetClientId; dla całego miejsca oba null. Nie wolno wskazać obu naraz. Backend zapisuje części razem z recenzją, zwraca ich trwałe ID i rozwiązuje duplikaty. `temporaryIssues` w ReviewCreate zawiera featureId, targetId/targetClientId, kind i description; serwer nadaje id/status/reportedAt.

Przykład odpowiedzi po utworzeniu: Review z `publicationStatus=visible`, `verificationStatus=pending`, `pointAward.status=pending`, `communitySummary` z zerowymi licznikami i null procentu. Status nie jest zaszyty na stałe: treść zatrzymana przez moderację może mieć hidden_pending_moderation.

UC-07 nie modyfikuje szkicu automatycznie. Frontend pokazuje opcjonalne pytanie, użytkownik edytuje wskazane pole i wysyła zaktualizowany szkic. Odpowiedź pomocy nie zapisuje recenzji. Błąd pomocy nie blokuje poprawnej ankiety. Frontend ignoruje odpowiedzi dotyczące starszej wersji edytowanego szkicu.

## 6. Minimalne stany UI

| Obszar | Stany wymagane w PoC |
|---|---|
| Sesja | niezalogowany, zalogowany, wygasła sesja; zachowanie szkicu przy ponownym logowaniu |
| Mapa/lista | ładowanie, wyniki, brak wyników, dane niepełne, błąd API, niedostępna mapa, brak zgody na lokalizację; ręczny wybór miasta |
| Filtry | zapisane, lokalnie zmienione, zapis w toku, błąd zapisu; nie gubimy wyborów |
| Recenzja | szkic, błędy pól, wysyłanie, wysłana/pending, ukryta, sprawdzana, zaakceptowana, odrzucona |
| Weryfikacja | możliwa, własna recenzja/niedozwolona, już wykonana, nie wiem, wysyłanie, sukces, błąd |
| Karta | niepodpięta, sprawdzana, potwierdzona, odrzucona, wygasła, błąd operatora |
| Punkty | saldo do wydania, oczekujące działanie, przyznane, nieprzyznane; kwota oczekująca nie musi być znana |
| Nagrody | dostępna, brak punktów, brak uprawnienia, wyczerpana, zmiana ceny, zakup w toku, przetwarzanie, kod gotowy, benefit wydany, błąd i zwolnienie punktów |

Błędy sieci zachowują dane. Po niejednoznacznym wyniku zakupu klient nie proponuje nowego zakupu, dopóki nie rozstrzygnie poprzedniego przez ten sam klucz lub odczyt statusu. Frontend pyta o potwierdzenie kosztu; po PRICE_CHANGED pokazuje nową cenę i wymaga nowego potwierdzenia.

## 7. Dostępność — granica kontraktu

UC-12 jest przede wszystkim odpowiedzialnością frontendu: semantyczne kontrolki, etykiety, fokus, skalowanie, kontrast, alternatywa dla mapy, proste komunikaty i ograniczenie animacji. Backend dostarcza etykiety katalogu, strukturalne błędy pól oraz rozróżnialne statusy. Nie dostarcza arbitralnego HTML do formularzy. Każdy kod statusu ma zdefiniowany odpowiednik tekstowy w UI.

Zmiana potrzeb nie zmienia automatycznie ustawień dostępności interfejsu. Przeglądanie mapy i zaznaczanie filtrów nie wymagają ujawnienia niepełnosprawności.

## 8. Minimalny zakres kontraktu do PoC

Wymagane: konfiguracja; sesja/profil; filtry; lista/mapa i szczegóły miejsca; oba warianty recenzji; odczyt statusów; głos i zgłoszenie; saldo; katalog i odbiór nagrody.

Do uzgodnienia jako rozszerzenia: QR (nowość UC-05), dynamiczne dopytywanie UC-07, publiczny profil, dodatkowe motywy/osiągnięcia. Integracja karty i automatyczna moderacja mogą być symulowane przez backend PoC przy zachowaniu identycznego kontraktu i jawnym oznaczeniu demonstracyjnego charakteru. Nie deklarujemy faktycznej integracji bez jej realizacji.

Przykładowe dane powinny obejmować: miejsce dopasowane, niespełniające warunku, z brakami danych, zepsutą windę, różne wejścia, recenzję oczekującą i ukrytą, własną recenzję bez możliwości głosowania, nagrodę niedostępną, processing i failed.

## 9. Warunki wspólnego odbioru kontraktu

1. Frontend może zbudować wszystkie ekrany bez analizowania tekstu recenzji w celu ustalenia jej statusu.
2. Każda merytoryczna cecha ma trwały identyfikator i etykietę; istnienie, stan, jakość i brak danych są rozdzielone.
3. Nieudane żądanie nie wymusza ponownego wpisywania formularza; ponowienie nie tworzy drugiej recenzji/nagrody.
4. Saldo i stan nagrody są autorytatywne po stronie backendu; zakup pending nie udaje wydanej nagrody.
5. Prywatny i publiczny profil mają odrębne odpowiedzi; ukryta reputacja nie opuszcza backendu.
6. Błędy pól i stanów integracji można odwzorować na dostępne, zrozumiałe komunikaty.
7. Wspólnie ustalone przykładowe odpowiedzi API obejmują sukcesy, puste wyniki i istotne wyjątki.

## 10. Rozbieżności use case’ów i decyzje do zatwierdzenia

| UC / obszar | Rozbieżność lub luka | Propozycja v0.1 / decyzja |
|---|---|---|
| UC-01/02 | Turysta jest domyślny; karta ma automatycznie dowodzić bycia mieszkańcem | Zwracać status weryfikacji powiązany z miastem; etykieta Turysta do uzgodnienia. Sam ważny numer nie potwierdza posiadacza ani zamieszkania. Backend zapewnia potwierdzenie zgodne z przyjętym założeniem API |
| UC-02 | Typy kart wymienione jakby dawały identyczne uprawnienia | Backend zwraca obsługiwane cardTypes i eligibility nagród; frontend nie zakłada rzeczywistych uprawnień tych kart |
| UC-03 | Brak Pomocnika, psa przewodnika i jawnego upublicznienia potrzeb | Uzupełnić katalog, niezależny helperOptIn i privacy; psa terapeutycznego uzgodnić osobno |
| UC-04 | Tylko mapa, brak ręcznego obszaru i rozróżnienia błędu OSM od pustej listy | Lista równoważna mapie; dane USpace z API; miasto/obszar wybrane ręcznie; brak wyników nie jest awarią |
| UC-05 | 3 = brak zdania | Wycofać; 3 jest oceną pośrednią, unknown/pominięcie to osobne odpowiedzi |
| UC-05 | QR nie było w ostatnim opisie | Oznaczyć jako opcjonalne rozszerzenie; QR identyfikuje miejsce, nie potwierdza wizyty |
| UC-06 | Obowiązkowa godzina i możliwe obowiązkowe gwiazdki | Godzina opcjonalna; ocena tylko gdy możliwa; formularz wspólny z ankietą |
| UC-07 | Nowa funkcja analizująca szkic | Osobna opcjonalna operacja; sugestie nie blokują wysłania i nie dowodzą wiarygodności |
| UC-08 | Bot akceptuje i przyznaje punkty na podstawie analizy | Backend zwraca niezależne statusy publikacji/weryfikacji/punktów; decyzję o wystarczalności bota trzeba zatwierdzić produktowo |
| UC-08 / opis | Publikacja od razu kontra blokada spamu | Zwykła recenzja visible/pending; wyjątek hidden_pending_moderation. Jawne powiadomienie autora |
| UC-09 / opis | Społeczność akceptuje/odrzuca kontra głosy jako sugestie | Propozycja: głosy aktualizują liczniki; nie usuwają same recenzji. Ostateczna polityka wymaga decyzji zespołu |
| UC-09 | Weryfikacja całości kontra pojedynczych cech | v0.1: cała recenzja z unable_to_assess. Jeśli potrzebne głosy per cecha, rozszerzyć model przed wdrożeniem |
| UC-09 | Wybór osób na podstawie pobytu | Backend zwraca zadania/uprawnienia. Sposób kwalifikacji i zgód nie jest zadaniem frontendu; bez pozorowania, że QR czy okolica potwierdzają znajomość cechy |
| UC-10 | Reputacja i punkty mogą być mylone | Ukryta reputacja niewidoczna; saldo i pointAward jawne; brak automatycznej nagrody za sam głos |
| UC-11 | Brak nieudanej realizacji po pobraniu punktów | Dodać processing/failed i pointsStatus; brak dobrowolnych zwrotów nie oznacza utraty punktów po awarii |
| UC-12 | WCAG jako deklaracja bez scenariuszy | Frontend opisuje i sprawdza konkretne ścieżki, w tym bez mapy, z czytnikiem i powiększeniem tekstu |
| Brak UC | Zgłaszanie recenzji, historia punktów, moje nagrody, prywatność | Dodać przypadki użycia albo jawnie uwzględnić jako alternatywne ścieżki istniejących UC |
| Auth / platforma | Brak logowania, wygasłej sesji, odnowienia i typu aplikacji | Potwierdzić aplikacja webowa/natywna i pełny model sesji przed implementacją |

Po uzgodnieniu decyzji kontrakt można zamienić na OpenAPI i zestaw wspólnych fixture’ów. Ten dokument nie definiuje implementacji backendu ani nie wysyła wiadomości do członków zespołu.
