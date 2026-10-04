# KindSpot — integracja ikon i oprawy graficznej, 2026-10-04

## Zapisany kontekst
Skrócony stan i podział pracy: KindSpot-checkpoint-wspolpracy.md. Dwa chaty pracują w tym samym repo, więc nie przenosimy zmian między osobnymi katalogami ani nie robimy dodatkowego rebase. Podział: grafika/motywy i funkcjonalność nagród/personalizacji.

## Grafika
- 341 zarejestrowanych SVG, każdy z opisem w manifest.json oraz polskim CSV. Katalog bazowy zachowany; nowe elementy personalizacji to avatar_lemur, avatar_cat, frame_bow, thumbnail_explorer, thumbnail_gardener.
- Logo i zasoby marki nie są zmieniane ani wdrażane. Nie eksponujemy starych wariantów awatarów i ramek jako nowych przedmiotów w sklepie.
- KindSpotAvatar oddziela rysunek, kołowe tło i ramkę z kokardą. Domyślny awatar jest ogólnym symbolem, nie niezakupionym kosmetykiem. Komponent nie nadaje własności przedmiotu.
- KindSpotBackdrop wykorzystuje tę samą mapę i lupę albo liść i kwiat co pozostała ikonografia. Wzór statyczny i nieinteraktywny, z kryciem 4,5%, bez semantyki. Wyższy kontrast, ograniczenie bodźców i nawigacja dostępności wyłączają wzory. Karty i okna zachowują pełne tło.
- Odkrywca: pergaminowa powierzchnia, brązowy akcent; Ogrodnik: ciemnozielony akcent, warianty jasny/ciemny zachowują ustawienia dostępności. Brak nowych eksportów dla kolorów.
- Uzupełniono mapowanie wszystkich symboli Material używanych przed personalizacją. Nowe symbole wybieramy przez rejestr SVG, tekst pozostaje etykietą.
- KindSpotNeedIcon obsługuje identyfikatory potrzeb z katalogu API; KindSpotFeatureIcon także aliasy i dostępne cechy rozszerzone. KindSpotCategoryIcon zachowuje neutralny symbol przy nieznanej kategorii.
- Stany puste zapisanych miejsc i recenzji otrzymały ilustracje z instrukcją w tekście. Nie zastępujemy braków danych potwierdzeniem dostępności.

## Źródła
frontend/mobile/assets/graphics jest katalogiem runtime, graphics_catalog.dart jest rejestrem, graphics.dart zawiera komponenty. Generatory w frontend/design/graphics/source odtwarzają nowe wektory. Materiały nieużywane przez obecne funkcje (np. prezentacje/P3 i historyczne propozycje marki) pozostają źródłem, a nie nowymi ekranami lub uprawnieniami.

## Weryfikacja części graficznej
26 testów istniejących ekranów/filtrów/recenzji/zasobów oraz 2 testy motywów i interakcji poprawne. Kontrast tekstu >=4,5:1 dla powierzchni, podstawowych przycisków i paneli w obu motywach, z/bez wysokiego kontrastu. Testy obejmują 320 px i 200% tekstu, ramkę nad awatarem oraz brak przechwytywania kliknięć przez wzór. Podglądy reward-theme-explorer.png i reward-theme-gardener.png pokazują rzeczywiste widgety, ale są podglądem materiałów — nie dowodem zakupu tych elementów.

Końcowa integracja z API i ekranami personalizacji została zakończona. Ikony kategorii, potrzeb i cech są używane także w aktywnych ekranach API; stany puste i błąd połączenia mają ilustracje i tekst. Tytuł autora wyświetla się przy recenzji, gdy został potwierdzony przez serwer.

Po połączeniu zmian: **185 testów Flutter przeszło**, **flutter analyze bez uwag**, git diff --check poprawny. Dodatkowy test renderowania czterech rzeczywistych ekranów API z kontrolowanymi odpowiedziami testowymi przeszedł. Zrzuty profile-explorer, profile-gardener, cosmetics-explorer i shop-categories są w frontend/design/graphics/previews. Dane konta i własności na podglądach są testowe.

Drugi chat potwierdził 39 testów backendu bez PostgreSQL. Testy PostgreSQL i urządzenia nie są potwierdzone tą weryfikacją. API wymaga migracji 4 opisanej w KindSpot-personalizacja-PoC.md.
Końcowa paczka Android zbudowana poprawnie: frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk. Emulatora nie uruchamiano; instalacja i odbiór na urządzeniu należą do użytkownika. Bez commita i push.
