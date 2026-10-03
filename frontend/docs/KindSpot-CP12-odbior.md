# KindSpot — CP-12: odbiór frontendowego PoC

Data: 2026-10-03. Zakres: Flutter w `frontend/mobile`, demonstracyjne konto „Test Hackaton”, Android jako przygotowane środowisko. Użytkownik zlecił osobnego agenta dla każdego pozostałego checkpointu. Emulator uruchamia wyłącznie użytkownik.

## Granice odbioru

- CP-07: ankieta i dodawanie recenzji nadal odłożone, formularz przygotowuje inna osoba we Flutterze. Punkt podłączenia nie stanowi implementacji ankiety.
- CP-11: użytkownik potwierdził brak API także dla PoC. Adaptery i lokalne testy kontraktu są przygotowaniem do przyszłej integracji, a nie działającym backendem.
- Głosowanie pozostaje niedostępne do rozstrzygnięcia reguł zmiany/cofnięcia głosu i rankingu przy zerowej liczbie dislajków. Brak zatwierdzenia nie uruchamia lokalnej operacji ani nie jest traktowany jako zgoda.
- Recenzje, miejsca, liczniki i przebiegi nagród są jawnie fikcyjne. Głosy i zgłoszenia demonstracyjne nie uruchamiają moderacji ani punktów. Nagrody nie wydają biletu, prawdziwego kodu ani benefitów.
- Potrzeby domyślnie prywatne. Podgląd publicznego profilu pozostaje lokalny; nie publikuje danych w sieci.
- CP-02 pozostaje nieodebrany. Macierz `KindSpot-CP02-WCAG.md` ma 55 kryteriów WCAG 2.2 A/AA, z oceną stosowalności według WCAG2ICT. Testy automatyczne konkretnych scenariuszy nie stanowią pełnego audytu dostępności.

## Automatyczna regresja CP-12

Plik `frontend/mobile/test/cp12_acceptance_test.dart` obejmuje pięć scenariuszy integracyjnych ponad testami poszczególnych modułów:

1. Lista → szczegóły → zapis → zapisane → ponowne otwarcie → recenzje → prywatny podgląd profilu → potwierdzona symulacja nagrody → zamknięcie sesji. Odczyty i symulacja nie zmieniają zapisanej konfiguracji; zamknięcie sesji usuwa otwarte trasy prywatne, a zapisy zachowują się zgodnie z opisem demo.
2. Usunięcie lokalnych danych: anulowanie zachowuje zapisy, zatwierdzenie usuwa zapisane miejsca i potrzeby oraz przywraca prywatność, także po ponownym odczycie repozytorium.
3. Tab w sekcji Nagrody nie trafia w ukryte pola mapy; samo przenoszenie fokusu nie otwiera trasy ani nie zapisuje danych.
4. Poziom 800×360, tekst 200%: nagroda, przewijanie do potwierdzenia, zamknięcie dialogu Escape i powrót pozostają osiągalne, bez błędów układu.

5. Poziom 800×360, tekst 200%: lista → szczegóły → zapis → recenzje → potwierdzenie udostępnienia potrzeb. Powrót i anulowanie dialogu Escape nie powodują ujawnienia potrzeb ani błędów układu.

**Wynik CP-12: 5/5 testów przeszło** na zintegrowanym kodzie 2026-10-03 (`flutter test test/cp12_acceptance_test.dart --concurrency=1`). Klawiatura w sekcji Nagrody nie odwiedza ukrytej mapy dzięki ExcludeFocus; dodatkowo wykluczono semantykę ukrytych sekcji. Funkcja testowa cofnięcia aktywuje BackButton zgodnie z polską lokalizacją, a recenzje zastępują trasę szczegółów, więc pojedyncze cofnięcie prowadzi do mapy. Pełną analizę, liczbę całej regresji i kompilację APK zapisuje integrator po zakończeniu wszystkich zmian.

## Odbiór ręczny do wykonania

Poniższe testy nie zostały wykonane przez agenta. Użytkownik uruchamia emulator z ograniczeniem zasobów przez `frontend/scripts/Start-USpaceEmulator.ps1` albo korzysta z telefonu. Nie łączyć bez potrzeby emulatora z ciężką kompilacją.

| Ścieżka / sprawdzenie | Warunki | Oczekiwany rezultat | Dowód |
|---|---|---|---|
| Główna ścieżka PoC | Telefon Android, internet; lista jako alternatywa mapy | Od wyszukania do zapisania i ponownego otwarcia; recenzje i powrót; fikcyjne treści czytelnie oznaczone | Oczekuje: urządzenie, wersja, wynik |
| Lokalizacja | Zezwolenie, odmowa, wyłączona usługa, inne miasto | Ręczny wybór nadal dostępny, brak zgadywania najbliższego miasta; zapis tylko identyfikatora miasta | Oczekuje |
| TalkBack | Bez opierania się na obrazie | Tytuł trasy, nazwa/rola/stan kontrolek, kontekst cech, odczyt trwałych błędów i zmian; powrót do kontrolki | Oczekuje |
| Switch Access | Wszystkie moduły istniejącego PoC | Możliwość wykonania ścieżki bez szczypania/przeciągania i trafiania w małą ikonę | Oczekuje |
| Klawiatura fizyczna | Tab/Shift+Tab, Enter/Space, strzałki, Escape | Widoczny i niezasłonięty fokus, brak pułapek; ukryte sekcje pomijane | Oczekuje |
| Sterowanie głosowe | Widoczne nazwy czynności | Nazwy zgodne z semantyką, dostęp do listy, formularzy i dialogów | Oczekuje |
| Powiększenie i orientacja | 200%, pion/poziom, klawiatura ekranowa | Brak utraty treści i przycisków; aktywne pole niecałkowicie zasłonięte | Oczekuje |
| Prywatność i usunięcie danych | TalkBack/klawiatura, anulowanie i zatwierdzenie | Świadoma zgoda, poprawny wynik, brak niezamierzonego zapisu | Oczekuje |
| Kolory i fokus | Wszystkie sześć motywów, wysoki kontrast | Tekst, granice i stany kontrolek oraz fokus rozpoznawalne; statusy niezależne od koloru | Oczekuje pełnych pomiarów |
| iOS / VoiceOver | macOS/Xcode oraz urządzenie iOS | Kompilacja i równoważne ścieżki; brak deklaracji tej platformy przed testem | Niewykonane: obecnie Windows |
| Testy z użytkownikami | Osoby z różnymi potrzebami | Rzeczywista wykonalność zadań, lista usterek i napraw; nie gwarancja „wszelkich niepełnosprawności” | Niewykonane |

## Przekazanie kolejnej osobie

Osoba przygotowująca grafikę i ankietę otrzymuje katalog cech, punkt podłączenia formularza, macierz WCAG oraz istniejące testy. Po zmianie układu/kolorów/treści ponownie sprawdzamy kontrast, skalowanie, cele dotykowe, kolejność i widoczność fokusu, odczyt czytnika oraz istotne dialogi. Wyniki poprzedniej grafiki nie odbierają kolejnej wersji.

Odbiór CP-12 w obecnym zakresie wymaga demonstracji użytkownika i jawnej oceny niewykonanych testów. Brak API i odłożona ankieta są zaakceptowanymi granicami PoC, a nie zaliczonymi funkcjami produkcyjnymi.




## CP-06–12 — końcowe sprawdzenie PoC

Analiza bez uwag; 131 testów przeszło; APK debug zbudowane (189263704 bajtów, 2026-10-03 21:59:03). Emulator nie był uruchamiany. Raport: KindSpot-CP06-CP12.md. Ankieta odłożona i przygotowany SurveyBuilder, brak API dla PoC, głosy/ranking oczekują odpowiedzi. CP-02 i odbiór ręczny CP-12 niezamknięte.
