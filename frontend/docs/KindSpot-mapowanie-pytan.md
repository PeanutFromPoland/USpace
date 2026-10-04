# KindSpot — mapowanie pytań ankiety na potrzeby i cechy

Wersja: 2, 2026-10-03. Identyfikatory potrzeb i cech pochodzą z katalogu w kodzie (`frontend/mobile/lib/data/catalog.dart`). Status: propozycja danych katalogu do odbioru; kontrakt v0.1 pozostaje propozycją.

## Co działa w PoC

Ankieta w aplikacji (`frontend/mobile/lib/data/survey_catalog.dart`) używa **tylko 12 cech istniejącego katalogu**. Pytania są dobierane według potrzeb z profilu: każda potrzeba wskazuje cechy (`NeedDefinition.features`). Bez wskazanych potrzeb, np. u Pomocnika, ankieta pokazuje wszystkie pytania. Przełącznik „Pokaż wszystkie pytania” dodaje pytania spoza potrzeb.

| ID cechy | Pytanie w ankiecie | Ocena 1–5 | Stan działania | Kilka części | Otoczenie |
|---|---|---|---|---|---|
| `step_free_entrance` | Czy da się wejść bez schodów? | tak | nie | tak | nie |
| `ramp` | Jak oceniasz podjazd? | tak | tak | tak | nie |
| `lift` | Jak oceniasz windę? | tak | tak | tak | nie |
| `accessible_toilet` | Jak oceniasz toaletę dla osób z niepełnosprawnościami? | tak | tak | tak | nie |
| `rest` | Czy są miejsca, żeby usiąść i odpocząć? | tak | nie | nie | nie |
| `quiet` | Jak głośno było? | tak | nie | nie | tak |
| `low_crowd` | Jak tłoczno było? | tak | nie | nie | tak |
| `gentle_light` | Jakie było światło? | tak | nie | nie | tak |
| `guide_dog` | Czy można wejść z psem przewodnikiem? | nie („Tak, jest”) | nie | nie | nie |
| `orientation` | Czy łatwo się zorientować? | tak | nie | nie | nie |
| `hearing_loop` | Jak oceniasz pętlę indukcyjną? | tak | tak | nie | nie |
| `easy_controls` | Czy klamki, przyciski i terminal da się obsłużyć bez wysiłku? | tak | nie | nie | nie |

Etykiety ocen 1–5 są w katalogu (`ratingLabels`); dla cech otoczenia 5 znaczy „dobrze dla mnie”, np. `quiet`: 1 „Bardzo głośno” … 5 „Bardzo cicho”.

**Otoczenie:** hałas, tłum i światło zawsze „są”, więc ankieta nie pokazuje przy nich opcji „0 – Brak funkcji”. To propozycja do odbioru (atrybut `isEnvironmental` w katalogu).

## Potrzeby (katalog)

| ID | Etykieta w aplikacji | Cechy w ankiecie |
|---|---|---|
| `wheelchair` | Poruszam się na wózku | step_free_entrance, accessible_toilet |
| `walking` | Mam trudności z chodzeniem | step_free_entrance, rest |
| `stairs` | Nie mogę korzystać ze schodów | step_free_entrance |
| `rest` | Potrzebuję częstego odpoczynku | rest |
| `vision` | Jestem niewidomy / słabowidzący | orientation |
| `hearing` | Jestem głuchy / niedosłyszący | hearing_loop |
| `noise` | Źle znoszę hałas | quiet |
| `crowd` | Źle znoszę tłum | low_crowd |
| `light` | Źle znoszę intensywne światło | gentle_light |
| `calm` | Potrzebuję spokojnych miejsc | quiet |
| `orientation` | Mam trudności z orientacją | orientation |
| `reading` | Potrzebuję prostych informacji | orientation |
| `hands` | Mam ograniczoną sprawność rąk | easy_controls |
| `companion` | Podróżuję z osobą wymagającą pomocy | – (ankieta pokaże wszystkie pytania) |
| `child` | Podróżuję z dzieckiem / wózkiem | step_free_entrance, rest |
| `dog` | Podróżuję z psem przewodnikiem | guide_dog |

Etykiety potrzeb pochodzą z Teorii aplikacji i nie zostały zmienione. Propozycja do decyzji: formy neutralne płciowo, np. „Nie widzę lub słabo widzę” zamiast „Jestem niewidomy / słabowidzący” (DO-USTALENIA).

## Propozycja rozszerzenia katalogu (do odbioru)

Cechy z pierwszej wersji ankiety (24 pytania), których nie ma w katalogu. Nie są używane w aplikacji, dopóki zespół ich nie zatwierdzi.

| Proponowane ID | Pytanie | Potrzeby | Ocena | Stan | Kilka części |
|---|---|---|---|---|---|
| `approach_path` | Jak oceniasz drogę do wejścia? Chodnik, krawężniki, nawierzchnia. | wheelchair, walking, stairs, child | tak | nie | nie |
| `accessible_door` | Czy drzwi łatwo otworzyć i przez nie przejść? | wheelchair, hands, child | tak | tak | tak |
| `interior_circulation` | Czy w środku łatwo się poruszać? Miejsce, progi, przejścia. | wheelchair, walking, child | tak | nie | nie |
| `accessible_parking` | Czy są miejsca parkingowe dla osób z niepełnosprawnościami? | wheelchair, walking, companion | tak | nie | nie |
| `contrast_markings` | Czy schody, szklane drzwi i przeszkody są wyraźnie oznaczone? | vision | tak | nie | nie |
| `tactile_braille` | Czy są ścieżki dotykowe albo napisy w brajlu? | vision | tak | nie | nie |
| `staff_orientation_help` | Czy personel pomaga w orientacji, np. czyta menu? | vision | tak | nie | nie |
| `non_verbal_communication` | Czy z personelem można się porozumieć bez mówienia? Pisanie, tablet, PJM. | hearing | tak | nie | nie |
| `visual_information` | Czy ważne informacje są też na ekranie? Kolejka, komunikaty, alarm. | hearing | tak | tak | nie |
| `quiet_room` | Czy jest ciche miejsce, żeby się wyciszyć? | noise, crowd, calm | tak | nie | nie |
| `simple_information` | Czy informacje są proste? Menu, cennik, oznaczenia z obrazkami. | reading, orientation | tak | nie | nie |
| `baby_changing` | Czy jest przewijak i miejsce na wózek dziecięcy? | child | tak | nie | nie |
| `helpful_staff` | Czy personel był cierpliwy i pomocny? | wszystkie | tak | nie | nie (otoczenie) |
