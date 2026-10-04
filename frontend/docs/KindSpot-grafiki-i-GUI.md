# KindSpot — grafiki i wygodniejsze GUI

Stan: 2026-10-04. Realizacja prośby o poprawienie ikon, uzupełnienie materiałów i przygotowanie frontendu. Nie zmienia zasad kont, recenzji, weryfikacji ani nagród.

## Poprawiony zestaw

337 SVG: 213 ikon bazowych, 55 nowych zasobów i 69 dodatkowych wariantów (53 monochromatyczne i 16 spokojnych). Poprawiono 39 ikon: m.in. filtry, psa przewodnika, drzwi, podjazd, dłonie, ustawienia, gęste stany zakupów i nagród oraz bilety. Rozdzielono nakładające się obrysy i uproszczono szczegóły w małych rozmiarach. Poprawiono kamień ogrodu, symbole obsługi i opisy znaczenia. Manifest CSV/JSON ma polskie opisy wszystkich elementów.

Uzupełnienia: 16 ilustracji stanów i pomocy, 8 awatarów, 6 ramek, 3 odznaki, 4 miniatury nagród, scena ogrodu, 10 propozycji marki, 3 plansze wprowadzenia i 4 grafiki prezentacyjne. Ramki mają przezroczyste wnętrze. Wersje monochromatyczne zachowują obrys zamiast zamieniać duże panele w jednolitą plamę. Warianty spokojne mają mniej dekoracji.

Ikony mają łagodne obrysy i zaokrąglone zakończenia. Zalecany rozmiar ikon to 24–32 px, pole dotykowe co najmniej 48 px. Ilustracje mają osobne, większe pole i nie powinny zastępować tekstu. Rozpoznawalność specjalistycznych symboli należy jeszcze ocenić z użytkownikami; symbol psa, pętli indukcyjnej czy komunikacji zawsze otrzymuje czytelną etykietę.

## Pliki i motywy

- `frontend/mobile/assets/graphics/` — źródłowe SVG i manifest używany przez aplikację.
- `frontend/mobile/lib/ui/graphics_catalog.dart` — identyfikatory i ścieżki 337 zasobów.
- `frontend/mobile/lib/ui/graphics.dart` — komponenty KindSpotSymbol oraz KindSpotGraphic i mapper kolorów.
- `frontend/design/graphics/` — instrukcja, manifest i podglądy do pracy projektowej.

Jednokolorowe ikony pobierają kolor z motywu. Pozostałe SVG mają role foreground, accent, accentSoft, surface i outline, oznaczone technicznymi kolorami z palette-roles.json. Mapper zastępuje je odpowiednimi rolami ColorScheme. Dodanie nowego akcentu wymaga konfiguracji motywu, a nie nowego eksportu grafik. W teście użyto też fioletu spoza obecnej palety, w jasnym i ciemnym motywie.

KindSpotSymbol zachowuje rozmiary i semantykę ikon oraz używa gotowych SVG dla rozpoznanych symboli. Niezmapowane symbole pozostają obsługiwane przez Material Icons. Wybrana zakładka ma odpowiedni wariant pełny, obramowanie i etykietę. KindSpotGraphic obsługuje wariant monochromatyczny i spokojny; dekoracje bez etykiety są wyłączone z odczytu czytnika ekranu. Implementacja korzysta z [flutter_svg](https://pub.dev/packages/flutter_svg).

Grafiki personalizacji oraz propozycje znaku i launchera są przygotowane do dalszego użycia. Ich dostarczenie nie nadaje nagród użytkownikowi, nie podmienia zdjęć ani nie zatwierdza automatycznie nowego logo. Pliki SVG są źródłem; PNG w previews służą tylko do oceny wyglądu.

## Wprowadzone poprawki GUI

| Element | Zmiana i zastosowanie |
|---|---|
| Karty i okna | Zaokrąglone ramki, czytelny obrys, łagodne powierzchnie z motywu. Obramowania są rysowane przez Flutter, więc dopasowują się do treści i skali tekstu. |
| Formularze | Mocniejsza ramka aktywnego pola oraz osobne obramowanie błędu. |
| Komunikaty | Panel z odstępami, ramką, ikoną i tekstem; osobne role tła i tekstu dla informacji, sukcesu, ostrzeżenia i błędu. |
| Przełączniki | Zaokrąglenia i obrys. Zachowano dziedziczenie kroju tekstu, usuwając czarne prostokąty ujawnione w podglądzie. |
| Sklep demonstracyjny | Miniatura kategorii, wyróżniony koszt na pastelowym tle i osobny przycisk zakupu. |
| Lista i szczegóły miejsc | Ikony, tła oznaczeń zgodne z motywem, ilustracja braku wyników i symbole cech przy opisach. |
| Nawigacja | Spójne ikony i wyraźny stan wybranej zakładki; główna mapa pozostaje pośrodku. |

Zmiany wspólnego motywu, nawigacji i komponentów są dostępne także dla interfejsu podłączonego do API. Podglądy sklepu i listy przedstawiają istniejący tryb demonstracyjny. Pojedyncze dodatkowe ekrany tworzone równolegle przez inne osoby mogą nadal używać standardowych ikon Material.

## Kolejne usprawnienia do oceny przy checkpointach

1. Grupowanie szczegółów miejsca w krótkie sekcje z nagłówkiem i jednym subtelnym panelem: wejście, poruszanie się, informacje, otoczenie. Nie kolorować każdej linijki tekstu osobno.
2. Podsumowanie aktywnych filtrów w krótkich znacznikach z tekstem i przyciskiem usunięcia; odróżnić warunek konieczny od preferencji także słowami.
3. Stałe oznaczenie aktualności danych przy informacji o awarii lub utrudnieniu; niewiedzę prezentować jako brak danych.
4. Wykorzystanie ramek i awatarów dopiero w istniejącym przepływie wyboru personalizacji, z podglądem oraz tekstową nazwą.
5. Dobór propozycji znaku, plansz wprowadzenia i launchera podczas weryfikacji użytkownika.

Te punkty są propozycjami kolejnych checkpointów, nie nowymi regułami biznesowymi ani potwierdzeniem, że wszystkie ekrany już je stosują.

## Weryfikacja

- Wszystkie 337 SVG dekodują się i rysują widoczne piksele w silniku Flutter. Usunięto prefiksy namespace, które powodowały ignorowanie części grafiki przez ten silnik.
- Końcowa regresja: 174 testy zakończone powodzeniem; test podglądów ekranów uruchomiony dodatkowo zakończył się powodzeniem.
- Sprawdzono podglądy rzeczywistych widgetów Flutter: sklep, lista, profil i ustawienia; jasny motyw oraz ciemny z tekstem 200%. Test komponentów obejmuje też szerokość 320 px.
- Analiza statyczna bez błędów i ostrzeżeń, z dwoma uwagami stylistycznymi o nawiasach w równolegle dodawanym product_api_ui_test.dart (stan ostatniego sprawdzenia).
- Testy mapy nie pobierają rzeczywistych kafelków; podgląd nie jest weryfikacją usług mapowych. Emulator nie był uruchamiany.

To kontrola techniczna i wizualna, a nie pełny audyt WCAG lub test na urządzeniu. Przed zaakceptowaniem checkpointu potrzebna jest ocena użytkownika, następnie testy rozpoznawalności i obsługi z odbiorcami aplikacji.
