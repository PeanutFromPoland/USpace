# KindSpot — checkpoint dostępności szkieletu

Data: 2026-10-03. KindSpot to zatwierdzona nowa nazwa produktu, wcześniej USpace. Folder i identyfikatory techniczne pozostają na razie bez zmian.
Status: analiza materiałów i propozycja zakresu do weryfikacji użytkownika; brak implementacji w tym checkpoincie.

## Materiały i granice

Przeczytano treść i tabele KindSpot-ankiety.docx oraz kod index.html z Downloads. HTML jest oddzielnym prototypem dwóch ankiet, nie frontendem Flutter. Nie wykonywano wizualnego audytu dokumentu ani pełnego testu prototypu w przeglądarce.

Nie otrzymano pełnego kindspot-instrukcja-dostepnosc.md; nie znaleziono go w Downloads ani repozytorium. Wklejone podsumowanie nie pozwala sprawdzić wszystkich oznaczeń KONIECZNE/ZALECANE. Nie deklarujemy wglądu w płatną część ISO ani zgodności z nią.

Aktualny zakres pozostaje: szkielet i jego działanie; ankieta wznowiona 2026-10-03 jako PoC bez wysyłania do systemu. Emulator uruchamia wyłącznie użytkownik. Ten checkpoint przygotowuje zasady i odbiór dostępności, nie uruchamia urządzenia.

## Klasyfikacja zasad

1. Cel projektu: WCAG 2.2 A/AA, z odniesieniem do platformy Flutter i testów na urządzeniu; to nie deklaracja już osiągniętej zgodności.
2. Zasady produktu: lista równoważna mapie, prywatne potrzeby, sześć motywów, prosty język i spokojne korzystanie.
3. Dodatkowe rekomendacje: osobny ETR, rozbudowany tryb spokojny, „Przygotuj wizytę”, PJM i większe cele dotykowe ponad minimum. Nie stają się automatycznie zatwierdzonym zakresem.
4. Wymogi wdrożenia przez podmiot publiczny: oddzielna analiza zależna od operatora i umowy. Nie utożsamiamy WCAG 2.2 AA z całą polską ustawą.

## Proponowany bieżący zakres do odbioru

| Obszar | Co przygotować/sprawdzić | Odbiór |
|---|---|---|
| Teksty | Krótkie zdania, jedna informacja na komunikat, nazwy czynności, bez żargonu | Użytkownik wie, co się stało i co zrobić dalej |
| Kontrast | Tekst, ikony, obramowania i stany we wszystkich sześciu motywach | Zmierzone pary kolorów; brak statusu przekazanego samym kolorem |
| Skala | Powiększony tekst i systemowe skalowanie, bez blokowania preferencji telefonu | Brak utraty podstawowych działań i obciętych tekstów |
| Kontrolki | Widoczne etykiety, sensowne nazwy, role i stany dla TalkBack; większe obszary trafienia | Czytnik przekazuje znaczenie i stan; przyciski łatwe do wybrania |
| Nawigacja | Kolejność, fokus, dialog wyjścia i powrót, lista zamiast mapy | Główna ścieżka działa bez interpretowania mapy |
| Komunikaty | Błąd przy polu, odczyt statusu, zachowanie danych | Błąd możliwy do poprawienia; sukces nie wymaga patrzenia na toast |
| Demo | Widoczne oznaczenia danych, konta, integracji i niedostępnych funkcji | Brak pozornego logowania, recenzji czy prawdziwej nagrody |

Limit 15 słów traktujemy jako pomocniczy cel redakcyjny, nie kryterium WCAG ani dowód zrozumiałości. Prosty język stosujemy w całym UI. ETR jest osobną adaptacją wymagającą sprawdzenia z odbiorcami; samo skrócenie zdań nie tworzy ETR.

W webowym WCAG 2.2 kryterium 2.5.8 AA określa minimum 24×24 CSS px z wyjątkami, a 44×44 dotyczy 2.5.5 AAA. Dla aplikacji Flutter proponujemy co najmniej 48×48 jednostek logicznych dla głównych dotykowych kontrolek jako praktyczny cel projektowy, nie jako dosłowny wymóg WCAG AA.

Usuwanie lub możliwość zatrzymania niektórych ruchomych treści i ograniczenie błysków może wynikać już z A. Nie klasyfikujemy wszystkich animacji jako wyłącznie AAA; ograniczenie animacji interakcji z 2.3.3 jest osobnym kryterium AAA.

## Rozbieżności materiałów z zatwierdzonymi decyzjami

| Materiał | Dotychczasowa decyzja użytkownika / sposób postępowania |
|---|---|
| DOCX: 3 = „Nie mam zdania” | 3 jest oceną pośrednią. Brak wiedzy to „Nie mogłem sprawdzić”, bez oceny liczbowej |
| DOCX: brak elementu bez oceny | „Brak funkcji” jest 0 gwiazdek; istnienie pozostaje osobnym polem |
| HTML/DOCX: „Pomiń” i brak odpowiedzi | Obowiązkowa odpowiedź może być niewiedzą; publikujemy „Nie mogłem sprawdzić”, nie usuwamy informacji o niewiedzy |
| DOCX/HTML: domyślnie „Dziś, teraz” | Domyślnie dzień; godzina opcjonalna i podana przez użytkownika, bez automatycznej godziny wysłania |
| Ankieta po jednym pytaniu, 5–8 z 24, zdjęcia, dyktowanie | Ankieta po jednym pytaniu wdrożona w PoC (2026-10-03) na 12 cechach katalogu; zestaw 24 pytań, zdjęcia i dyktowanie nadal do decyzji |
| Ankieta B — badanie potrzeb | Oddzielne badanie, nie ankieta recenzji i nie część obowiązkowego konta aplikacji; publikacja/rekrutacja nie jest zlecona |

Anonimowości badania nie zapewnia sama deklaracja ani brak pola imienia. HTML zachowuje odpowiedzi w localStorage i pobiera zewnętrzną czcionkę. Przed rzeczywistym badaniem trzeba ustalić środowisko, retencję, logi, dostęp do odpowiedzi, administratora i zgody. Nie usuwamy ani nie publikujemy załączników.

## Co wynika z oficjalnych źródeł publicznych

- gov.pl zaleca krótkie zdania (10–15 słów), naturalny szyk i najważniejszą informację na początku. 15 słów nie jest sztywnym limitem prawnym ani normą dostępności.
- Wytyczne Warszawy rozróżniają prosty język i ETR. Źródło jest materiałem odniesienia, nie deklaracją automatycznego obowiązku ETR na każdym ekranie.
- Art. 6 pkt 3 lit. c ustawy o zapewnianiu dostępności dotyczy informacji o działalności podmiotu na jego stronie: tekst maszynowo odczytywalny, PJM i tekst łatwy do czytania. Nie wynika z tego automatycznie obowiązek nagrania każdego ekranu aplikacji w PJM.
- Aplikacja mobilna podmiotu publicznego wymaga deklaracji dostępności; miejsce publikacji i link określają przepisy/wytyczne. Model wdrożenia KindSpot jest nieustalony.
- Nie używamy ARASAAC bez sprawdzenia aktualnej licencji i zgodności z modelem wdrożenia. W tym etapie nie dodajemy piktogramów ani nie potwierdzamy licencji z drugiej ręki.

## Wstępne obserwacje kodu szkieletu

- Są już polskie lokalizacje, komunikaty demo, odczyt profilu z etykietą semantyczną i komunikaty Snackbar z liveRegion.
- Kod uwzględnia systemowe disableAnimations i ustawienie reduceMotion. To częściowy mechanizm, nie pełny audyt animacji.
- Są tekstowe etykiety statusów; sam kolor nie jest jedyną informacją.
- Widoczne nazwy w app.dart nadal brzmią KindSpot: zmiana na KindSpot jest następną poprawką interfejsu, nie wykonano jej w tej analizie.
- Nie sprawdzono wszystkich kontrastów, wymiarów, kolejności TalkBack ani skalowania na aktualnej wersji. Te pozycje mają status „do sprawdzenia”, nie „spełnione”.

## Oddanie checkpointu

Przygotowano analizę i proponowaną checklistę. Do weryfikacji użytkownika: zakres dla szkieletu, rozdzielenie A/AA od rekomendacji i zachowanie wcześniejszych zasad ankiety. Po odbiorze możemy poprawić teksty/oznaczenia KindSpot i podstawowe komponenty, a następnie oddać ich działanie do następnej weryfikacji. Testy TalkBack na emulatorze dopiero po uruchomieniu urządzenia przez użytkownika. Nie deklarujemy odbioru checkpointu ani audytu WCAG.

## Źródła

- [WCAG 2.2 — kryteria](https://www.w3.org/WAI/WCAG22/quickref/)
- [Flutter — dostępność](https://docs.flutter.dev/ui/accessibility)
- [gov.pl — prosty język](https://www.gov.pl/web/redakcyjne-abc/najwazniejsze-zasady-prostego-jezyka)
- [Warszawa — prosty język i ETR](https://wsparcie.um.warszawa.pl/documents/67381/63310733/Jak%2Bprzygotowywa%C4%87%2Bdokumenty%2Bw%2Bprostym%2Bj%C4%99zyku%2Bi%2BETR%2B-%2Bwytyczne.pdf/cf2a52ea-5a4c-6f6b-789d-9cdd4076f266?t=1666081703665)
- [Ustawa o zapewnianiu dostępności — art. 6](https://eli.gov.pl/api/acts/DU/2024/1411/text.html)
- [gov.pl — deklaracja aplikacji mobilnej](https://www.gov.pl/web/dostepnosc-cyfrowa/deklaracja-dostepnosci-w-aplikacjach-mobilnych)

## Aktualizacja zakresu CP-02 — 2026-10-03

Użytkownik odłożył końcową grafikę do późniejszej pracy innej osoby i zlecił sprawdzanie funkcjonalnych udogodnień względem WCAG. Aktualna pełna macierz A/AA i przegląd szkieletu: KindSpot-CP02-WCAG.md. Wcześniejsza analiza pozostaje materiałem odniesienia; CP-02 nie jest odebrany i wymaga poprawek oraz testów. Ankieta nadal odłożona.


2026-10-04: nowe ekrany API sprawdzono testami logowania przy 200% tekstu i ankiety z zachowaniem odpowiedzi po błędzie. 175 testów Flutter przeszło. To częściowa weryfikacja; czytniki, urządzenie, klawiatura całego nowego przebiegu i pełny odbiór WCAG pozostają niewykonane. Raport KindSpot-integracja-FastAPI.md.


Weryfikacja zmiany społeczności/ikon 2026-10-04: 180 testów Flutter przeszło, flutter analyze bez uwag, 32 testy backendu bez bazy poprawne i Ruff bez uwag. Sprawdzono pytanie z zatwierdzoną ikoną przy 320 px i tekście 200%, zachowano etykietę i nagłówek czytnika. Usunięcie roli nie usuwa prywatnych potrzeb ani ustawień dostępności. Aktualne APK jest budowane; wynik należy potwierdzić osobno. Testy urządzenia/czytnika oraz PostgreSQL nadal niewykonane. Emulatora nie uruchamiano.
