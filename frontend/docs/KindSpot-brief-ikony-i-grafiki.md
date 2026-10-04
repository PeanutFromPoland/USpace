# KindSpot — brief ikon i grafik do przekazania drugiemu chatowi

Data: 2026-10-03. Produkt: KindSpot, wcześniej USpace. Platforma: Flutter, przede wszystkim telefon. Język interfejsu: polski.

Ten dokument jest zamówieniem materiałów graficznych. Nie zmienia zasad działania aplikacji. Obejmuje obecne ekrany oraz przygotowanie zasobów dla funkcji planowanych. Materiałów oznaczonych „później” nie należy traktować jako zatwierdzenia nowej funkcji.

## 1. Polecenie dla wykonawcy

Przygotuj spójny zestaw ikon, ilustracji, grafik nagród i elementów identyfikacji dla KindSpot — aplikacji pomagającej osobom z potrzebami dostępności znaleźć odpowiednie miejsca.

**Wszystkie materiały mają mieć bardzo łagodny, spokojny i zaokrąglony styl.** Stosuj miękkie kontury, okrągłe zakończenia linii, obłe kształty i niewiele detali. Efekt ma być przyjazny i czytelny dla dorosłych. Unikaj ostrych krawędzi, agresywnych kontrastów dekoracyjnych, chaosu, infantylności i przeładowania. Łagodny wygląd nie może oznaczać słabej widoczności symboli.

**Materiały muszą działać z każdym kolorem aplikacji.** Nie projektuj osobnych, trwale pomarańczowych, różowych, niebieskich czy zielonych ikon. Dostarcz jeden neutralny zasób, któremu aplikacja przypisuje barwy z bieżącego motywu. Dodanie nowego akcentu nie może wymagać nowego pliku graficznego. Każdy symbol musi być rozpoznawalny także w jednym kolorze i w skali szarości.

Nie kopiuj logo, ikon ani ilustracji Google Maps. Inspiracja znanym układem mapy nie oznacza odtwarzania cudzej identyfikacji. Nie generuj kafelków mapy ani znaków OSM do zastępowania wymaganej atrybucji.

## 2. Kolory i uniwersalność

W aktualnym kodzie występują cztery kolory bazowe:

| Akcent | Kolor bazowy |
|---|---|
| Pastelowy pomarańczowy | `#F5B98F` |
| Pastelowy różowy | `#F1B6CA` |
| Jasnoniebieski | `#A7CBEF` |
| Pastelowy zielony — aktualny domyślny | `#ADD8B4` |

Powyższa paleta jest wyłącznie kontekstem obecnej aplikacji, nie listą wariantów do wykonania. **Dodanie dowolnego nowego koloru motywu ma wymagać tylko przypisania wartości kolorów w aplikacji — bez przerysowania, ponownego generowania, eksportowania lub wymiany grafik.** Te same zasoby muszą działać także na jasnych i ciemnych tłach oraz z ustawieniem wyższego kontrastu.

Podane kolory są bazą motywu, a nie nakazem używania ich jako koloru cienkiej ikony lub tekstu. Kolor funkcjonalnej ikony dobiera aplikacja do jej tła i stanu.

Wymagania:

- Ikony interfejsu: jeden kolor, przezroczyste tło, bez wpisanego na stałe pastelowego tła. W aplikacji kolor pochodzi z roli motywu, np. koloru ikon; zasób nie zna nazw orange/pink/blue/green ani listy dostępnych akcentów.
- Ilustracje: osobne role `foreground`, `accent`, `accentSoft`, `surface`, `outline`. Maksymalnie kilka ról na ilustrację; bez dziesiątek podobnych odcieni. Manifest i rozdzielone warstwy mają umożliwiać powiązanie każdej roli z motywem w czasie działania aplikacji. Dodając kolor, uzupełniamy te role w motywie; pliki grafiki pozostają identyczne.
- Kształt i obrys muszą pozwalać zmienić jasne wypełnienie na ciemne bez utraty znaczenia.
- Sukces, błąd i ostrzeżenie rozróżniaj kształtem, symbolem i etykietą; sama barwa nie wystarczy.
- Stany aktywne i wybrane rozróżniaj także wypełnieniem, dodatkowym znacznikiem lub obramowaniem.
- Dla każdej ilustracji dostarcz wersję monochromatyczną i prostszą wersję do trybu spokojnego/wyższego kontrastu.
- Nie umieszczaj napisów, liczb, cen, nazw miast ani ocen wewnątrz grafiki. Te treści dodaje interfejs.

## 3. Priorytety

- **P1:** podstawowa nawigacja, mapa, potrzeby, 12 obecnych cech, filtry, konto, stany i ankieta. Pierwsza paczka do integracji.
- **P2:** sklep, nagrody, odznaki, ilustracje pustych ekranów i Ogród ciszy.
- **P3:** przyszłe rozszerzenia cech, dodatkowe kategorie miejsc, onboarding i materiały promocyjne. Przygotowanie na później.

Priorytety dotyczą grafiki, nie kolejności wdrażania funkcji. Zasób wspólny tworzymy raz, nawet gdy występuje w kilku sekcjach.

## 4. Ikony nawigacji i wspólnych działań — P1

| ID pliku / grupa | Symbol i zastosowanie |
|---|---|
| `nav_map` | Mapa; środkowy przycisk dolnej nawigacji |
| `nav_saved` | Zakładka; zapisane miejsca |
| `nav_rewards` | Prezent; nagrody i sklep |
| `nav_filters` | Zaokrąglone suwaki; filtry |
| `nav_profile` | Neutralna sylwetka; profil |
| `places_nearby` | Pinezka z delikatnym otoczeniem; proponowane miejsca |
| `view_list` | Lista z krótkimi liniami; alternatywa dla mapy |
| `search`, `search_clear` | Lupa; wyczyszczenie wyszukiwania |
| `back`, `forward`, `chevron_down`, `chevron_up` | Nawigacja i rozwijanie sekcji; bez ozdobników |
| `close`, `add`, `remove` | Zamknięcie, dodanie i usunięcie elementu |
| `edit`, `delete`, `save` | Edycja, kosz i zapis; odrębne od zapisania miejsca |
| `refresh`, `retry` | Odświeżenie i ponowienie; można współdzielić jeden symbol |
| `settings`, `more`, `help`, `info` | Ustawienia, dodatkowe działania, pomoc, informacja |
| `calendar`, `clock`, `history` | Data wizyty, godzina i historia |
| `copy` | Kopiowanie kodu nagrody |
| `exit`, `logout` | Wyjście z aplikacji i zakończenie sesji; z opisami tekstowymi |

Nawigacja główna: wariant obrysowy oraz pełny/wybrany. Symbol mapy musi pozostać czytelny także w większym okrągłym przycisku.

## 5. Mapa, miejsce i kategorie — P1 / P3

| ID | Symbol i zastosowanie |
|---|---|
| `map_pin` | Podstawowa pinezka miejsca |
| `map_pin_selected` | Wybrana pinezka; wyróżnienie kształtem/obrysem |
| `map_cluster` | Podstawa grupy pinezek; liczbę dodaje aplikacja |
| `current_location` | Pozycja użytkownika; nie mylić z miejscem |
| `recenter`, `zoom_in`, `zoom_out` | Wyśrodkowanie mapy i sterowanie przyciskami |
| `city`, `address` | Wybór miasta i adres |
| `place_building` | Neutralna ikona miejsca i zastępnik zdjęcia |
| `entrance`, `entrance_side`, `building_part` | Wejście główne, inne wejście, część obiektu |
| `place_closed`, `temporary_works` | Zamknięcie i utrudnienie czasowe |
| `category_park`, `category_cafe`, `category_restaurant` | Park, kawiarnia, restauracja — dodatkowy zestaw kategorii |
| `category_museum`, `category_cinema`, `category_library` | Muzeum, kino, biblioteka — P3 |
| `category_office`, `category_health`, `category_shop`, `category_transit` | Urząd, placówka zdrowia, sklep i transport — P3 |

Nie koduj całkowitej dostępności obiektu zieloną pinezką ani pojedynczym symbolem wózka. Znacznik pokazuje miejsce; rzeczywiste dopasowanie wymaga opisu cech. Pinezka bez danych nie może wyglądać jak potwierdzona dostępność.

## 6. Potrzeby użytkownika — P1

Potrzeby to preferencje prywatnego profilu. Nie tworzymy obowiązkowych publicznych odznak „rodzaju niepełnosprawności”. Symbole mają opisywać potrzeby, bez oceniania użytkownika.

| ID | Potrzeba / kierunek symbolu |
|---|---|
| `need_wheelchair` | Wózek; neutralna, aktywna sylwetka |
| `need_walking` | Trudności z chodzeniem; osoba z laską lub podparciem |
| `need_no_stairs` | Omijanie schodów; stopnie z czytelnym przekreśleniem |
| `need_rest` | Częsty odpoczynek; ławka |
| `need_vision` | Wzrok; oko jako ogólny symbol, bez nieczytelnych detali |
| `need_hearing` | Słuch; ucho |
| `need_low_noise` | Ograniczony hałas; głośnik z małą liczbą fal |
| `need_low_crowd` | Mniej tłumu; mała grupa z przestrzenią |
| `need_gentle_light` | Łagodne światło; lampa z krótkimi, miękkimi promieniami |
| `need_calm` | Spokojne miejsce; liść lub spokojny zakątek |
| `need_orientation` | Łatwiejsza orientacja; drogowskaz |
| `need_simple_information` | Proste informacje; dokument z kilkoma dużymi liniami |
| `need_hand_mobility` | Ograniczona sprawność rąk; dłoń i łatwy przycisk |
| `need_companion` | Podróż z osobą potrzebującą pomocy; dwie równorzędne sylwetki |
| `need_child_stroller` | Dziecko lub wózek dziecięcy |
| `need_guide_dog` | Pies przewodnik z uprzężą |
| `helper` | Pomocnik; wspierające dłonie lub dwie sylwetki, bez symboliki litości |
| `need_therapy_dog` | Osobny pies terapeutyczny — P3, rozdzielenie potrzeb wymaga decyzji zespołu |

Nie zakładaj, że jedno przekreślone oko czy ucho bez etykiety będzie zrozumiałe dla każdego. Wszystkie potrzeby otrzymują podpis w aplikacji. Można współdzielić grafikę potrzeby i cechy, jeśli znaczenie pozostaje jednoznaczne.

## 7. Obecne cechy miejsca — P1

Nazwy bazowe odpowiadają 12 cechom używanym w kodzie i ankiecie. To identyfikatory plików; nie zmieniaj identyfikatorów danych aplikacji.

| ID grafiki | Cecha danych | Symbol |
|---|---|---|
| `feature_step_free_entrance` | `step_free_entrance` | Płaskie wejście bez stopni |
| `feature_ramp` | `ramp` | Czytelny podjazd; odróżniony od schodów |
| `feature_lift` | `lift` | Winda z drzwiami i strzałkami |
| `feature_accessible_toilet` | `accessible_toilet` | Toaleta i dostępna przestrzeń; czytelny prosty znak |
| `feature_rest` | `rest` | Ławka; można użyć `need_rest` |
| `feature_quiet` | `quiet` | Spokojne warunki akustyczne |
| `feature_low_crowd` | `low_crowd` | Osoby z odstępem |
| `feature_gentle_light` | `gentle_light` | Łagodne oświetlenie |
| `feature_guide_dog` | `guide_dog` | Pies przewodnik z uprzężą |
| `feature_orientation` | `orientation` | Czytelny drogowskaz |
| `feature_hearing_loop` | `hearing_loop` | Pętla indukcyjna; zachować rozpoznawalność symbolu |
| `feature_easy_controls` | `easy_controls` | Dłoń przy dużym przycisku / łatwa obsługa |

### Możliwe rozszerzenia — P3

`feature_approach_path` — dojście/chodnik; `feature_accessible_door` — szerokie, łatwe drzwi; `feature_interior_circulation` — przestronne przejście; `feature_accessible_parking` — parking; `feature_contrast_markings` — oznaczone przeszkody; `feature_tactile_braille` — elementy dotykowe/brajl; `feature_staff_orientation_help` — pomoc w orientacji; `feature_non_verbal_communication` — pisanie/komunikacja bez mówienia; `feature_visual_information` — ekran z informacją; `feature_quiet_room` — cicha strefa; `feature_simple_information` — prosty dokument; `feature_baby_changing` — przewijak; `feature_helpful_staff` — pomocny personel.

To propozycje rozszerzenia katalogu. Ikona komunikacji bez mówienia nie może sugerować gwarantowanej obsługi w PJM. Nie rysuj przypadkowych układów dłoni jako rzekomych znaków PJM ani przypadkowych kropek jako treści brajlowskiej.

## 8. Filtry i sortowanie — P1

| ID | Zastosowanie |
|---|---|
| `filter_required` | Warunek konieczny; kłódka lub wyraźny znacznik |
| `filter_preferred` | Preferencja; serce, odróżnione od gwiazdki oceny |
| `filter_any` | Bez znaczenia; neutralne pominięcie, nie znak awarii |
| `filter_preset` | Gotowy zestaw filtrów |
| `filter_saved` | Zapisany nazwany filtr |
| `filter_reset` | Reset filtrów |
| `sort` | Wybór sortowania |
| `sort_rating` | Sortowanie według oceny |
| `sort_review_count` | Sortowanie według liczby recenzji |

Zapis miejsca (`nav_saved`), zapis filtra i zapis formularza powinny mieć odpowiednie etykiety nawet wtedy, gdy współdzielą rodzinę symboli.

## 9. Ankieta, recenzje i weryfikacja — P1

| ID | Zastosowanie / warianty |
|---|---|
| `review`, `review_add`, `comment` | Recenzje, wystawienie recenzji, uzasadnienie |
| `survey`, `survey_summary` | Ankieta i podsumowanie |
| `star_outline`, `star_filled` | Ocena 1–5; opcjonalna połówka tylko dla wyświetlania średniej |
| `feature_absent` | Brak funkcji; osobny znak, bez sugerowania niewiedzy |
| `unknown`, `not_checked` | Brak danych oraz „Nie mogłem sprawdzić”; zawsze z właściwą etykietą |
| `operational`, `not_operational`, `limited_availability` | Działa, nie działa, ograniczona dostępność |
| `thumb_up`, `thumb_down` | „Zgadzam się” / „Nie zgadzam się”, po wariancie neutralnym i wybranym |
| `report` | Zgłoszenie treści; flaga |
| `verification_pending`, `verification_accepted`, `verification_rejected` | Oczekuje, przyjęta, odrzucona; można współdzielić bazowe statusy |
| `published`, `hidden`, `draft` | Opublikowana, ukryta, szkic |
| `temporary_failure`, `construction` | Awaria i prace budowlane |
| `recommend` | Polecenie miejsca, bez utożsamiania z weryfikacją |

Gwiazdki nie są samodzielnym zamiennikiem tekstu „4 na 5”. Brak funkcji, niewiedza, awaria i słaba ocena muszą pozostać czterema różnymi informacjami. Stan ankiety i rozliczanie punktów określa aplikacja; grafika nie wprowadza nowych reguł.

Zdjęcia/załączniki: `camera`, `image_add`, `image_remove` — P3, do użycia dopiero po zatwierdzeniu tej funkcji.

## 10. Konto, prywatność i dostępność — P1

| ID / grupa | Zastosowanie |
|---|---|
| `account`, `account_settings` | Konto i ustawienia; można użyć sylwetki profilu |
| `email`, `password`, `password_show`, `password_hide` | Dane logowania i widoczność hasła |
| `privacy`, `private`, `public` | Prywatność, kłódka, publiczny profil |
| `city_card`, `card_link`, `card_unlinked`, `card_pending` | Karta miejska i stany jej powiązania |
| `tourist`, `local_status` | Turysta i potwierdzony status dla miasta; neutralne, równorzędne wizualnie |
| `accessibility` | Ogólne ustawienia dostępności; nie tylko symbol wózka |
| `palette`, `theme_light`, `theme_dark` | Kolor oraz jasny/ciemny motyw |
| `high_contrast`, `text_size` | Wyższy kontrast i większy tekst |
| `reduce_motion`, `calm_mode` | Ograniczenie animacji i spokojny tryb |
| `screen_reader` | Pomoc dotycząca czytnika — P3, nie oznaczać jako istniejący osobny przełącznik |

Nie używaj godła miasta ani imitacji oficjalnej Karty Miejskiej bez materiałów dostarczonych przez zespół. Odznaka statusu nie jest gwarancją wiarygodności recenzji.

## 11. Punkty, sklep, nagrody i personalizacja — P2

| ID / grupa | Zastosowanie |
|---|---|
| `points` | Jeden znak punktów używany wszędzie; odróżniony od gwiazdki oceny i waluty |
| `points_history`, `points_pending` | Historia i oczekujące rozliczenie |
| `shop`, `my_rewards` | Katalog i posiadane nagrody |
| `reward_ticket_transit` | Bilet transportu miejskiego |
| `reward_ticket_museum` | Bilet do muzeum |
| `reward_ticket_event` | Bilet na wydarzenie; do przyszłego katalogu |
| `reward_avatar`, `reward_frame`, `reward_title` | Awatar, ramka i tytuł profilu |
| `reward_code`, `reward_on_card`, `reward_pickup` | Kod odbioru, zapis na karcie, odbiór w punkcie |
| `purchase_confirm`, `purchase_pending`, `purchase_failed` | Potwierdzenie, przetwarzanie, błąd |
| `reward_available`, `reward_used`, `reward_expired`, `reward_unavailable` | Dostępna, wykorzystana, wygasła, niedostępna |
| `achievement`, `achievement_helper`, `achievement_verifier` | Osiągnięcie, Pomocnik, znany weryfikator; opcjonalne odznaki |

Dodatkowe grafiki do sklepu:

- **8 neutralnych awatarów startowych:** liść, kwiat, chmura, słońce, ptak, kot, pies, abstrakcyjna przyjazna postać. Bez przypisywania niepełnosprawności ani płci.
- **6 ramek profilu:** prosta zaokrąglona, podwójny obrys, liście, drobne kwiaty, miękkie chmury, delikatne punkty. Wszystkie z przezroczystym środkiem, dobrze wyglądające po okrągłym przycięciu awatara.
- **3 podstawy odznak:** Pomocnik, weryfikator, autor konstruktywnych recenzji. Nazwa/poziom jako tekst poza grafiką. Nie ustalaj samodzielnie progów zdobywania.
- **4 miniatury kategorii nagród:** transport, kultura, awatary, ramki. Bez cen i ważności w obrazie.

Nie generuj działających kodów, QR ani barkodów. QR jest poza obecnym zakresem. Przykładowe bilety mają być abstrakcyjnymi miniaturami, bez wyglądu rzeczywistego dokumentu uprawniającego do przejazdu. Oznaczenie „demo” dodaje interfejs.

## 12. Wspólne stany interfejsu — P1

`status_info` — informacja; `status_success` — sukces; `status_warning` — ostrzeżenie; `status_error` — błąd; `status_pending` — oczekiwanie; `status_unavailable` — niedostępne; `network_offline` — brak połączenia; `location_denied` — lokalizacja niedostępna; `session_expired` — sesja zakończona; `demo` — dane demonstracyjne.

Sukces, ostrzeżenie i błąd muszą różnić się wewnętrznym znakiem i sylwetką. Animowany spinner nie wymaga rysowania wielu klatek: wystarczy neutralna baza oraz statyczny wariant oczekiwania. Nie projektuj migania, pulsowania alarmowego ani presji czasowej.

## 13. Ilustracje ekranów i komunikatów — P2

| ID | Treść ilustracji |
|---|---|
| `illustration_welcome` | Spokojne miasto, przyjazna pinezka i różne osoby |
| `illustration_empty_results` | Mapa z lupą; brak dopasowań, bez sugerowania błędu użytkownika |
| `illustration_empty_saved` | Pusta zakładka na spokojnym tle mapy |
| `illustration_empty_reviews` | Pusta karta recenzji |
| `illustration_empty_rewards` | Proste pudełko/prezent bez presji na zakupy |
| `illustration_unknown_accessibility` | Miejsce i znak zapytania; brak potwierdzonych danych |
| `illustration_no_location` | Pinezka i wybór miasta; pokazuje możliwość wyboru ręcznego |
| `illustration_connection_problem` | Spokojny symbol przerwanego połączenia |
| `illustration_map_problem` | Niewczytana mapa i lista jako alternatywa |
| `illustration_temporary_works` | Delikatna bariera remontowa; bez dramatycznej sceny |
| `illustration_review_saved` | Ankieta i potwierdzenie lokalnego zapisania; bez znaku sugerującego publikację |
| `illustration_waiting_verification` | Karta i zegar; oczekiwanie bez presji |
| `illustration_reward_received` | Prezent/bilet i potwierdzenie; celebracja spokojna, bez konfetti wymagającego animacji |
| `illustration_session_ended` | Konto i spokojny powrót do wejścia |
| `illustration_privacy` | Profil i osłona prywatności |
| `illustration_helping` | Współpraca dwóch osób; równe role, bez narracji „ratowania” |

Dla ilustracji: podstawowy format roboczy 320 × 220, kompozycja dająca się zmniejszyć do około 160 × 110. Tło przezroczyste. Treść komunikatu i przycisków pozostaje poza ilustracją. Ilustracja dekoracyjna nie może dublować długiego komunikatu dla czytnika ekranu.

## 14. Ogród ciszy — P2

Przygotuj statyczną kompozycję spokojnego ogrodu oraz elementy: `garden_leaf`, `garden_flower`, `garden_tree`, `garden_cloud`, `garden_sun`, `garden_stone`, `garden_pond`, `garden_bench`, `garden_breath_circle`.

Styl: dużo wolnej przestrzeni, niewiele elementów, brak intensywnego światła i szczegółowych tekstur. Elementy powinny działać osobno i na prostym tle. Krąg oddechu ma być gładką bazą wektorową, którą interfejs może skalować; nie dostarczaj nagrania z wymuszonym tempem oddychania. Bez deklaracji efektu medycznego.

Ewentualna animacja tylko jako dodatek: wersja statyczna zawsze dostępna, bez błysków, bez obowiązkowego dźwięku. Ikony sterowania można współdzielić z ogólnymi: `play`, `pause`, `stop`, `sound_on`, `sound_off` — zamówić tylko dla zatwierdzonych kontrolek Ogrodu ciszy.

## 15. Identyfikacja aplikacji i przyszłe materiały — P1 / P3

- **Znak KindSpot — P1:** 2–3 propozycje, np. przyjazna pinezka z liściem lub zaokrąglona pinezka z otwartą przestrzenią. Rozpoznawalny jako mały znak bez tekstu; bez deklaracji „miejsce w pełni dostępne”.
- **Logotyp — P1:** znak i osobny napis KindSpot; układ poziomy oraz kompaktowy. Plik z napisem w krzywych i źródło umożliwiające edycję. Podać nazwę/licencję fontu, jeśli użyty.
- **Ikona aplikacji — P1:** źródło wektorowe, kwadratowy eksport 1024 × 1024, osobny pierwszy plan i tło do adaptacyjnej ikony Androida. Nie wypalać okrągłego przycięcia; eksporty platformowe przygotować podczas wdrożenia według masek platform.
- **Ekran startowy — P1:** prosty znak do wyśrodkowania na jasnym/ciemnym tle; bez obowiązkowej animacji i bez napisów w grafice.
- **Onboarding — P3:** 3 ilustracje „Wskaż potrzeby”, „Znajdź miejsce”, „Pomóż innym recenzją”. Nie jest to decyzja o dodaniu obowiązkowego onboardingu.
- **Materiały prezentacyjne — P3:** neutralne tło slajdu, grafika otwierająca i 3 sceny korzyści produktu. Bez wyświetlania fikcyjnych certyfikatów czy osiągniętej zgodności WCAG.

Nie projektujemy teraz zdjęć prawdziwych miejsc, kompletnych makiet ekranów ani materiałów udających oficjalne nagrody miejskie. Takie zasoby wymagają osobnego briefu.

## 16. Format, konstrukcja i dostarczenie

### Ikony

- Preferowany materiał wdrożeniowy: **SVG**, przezroczyste tło, jedna ikona w jednym pliku.
- Siatka 24 × 24; obrys bazowo 2 jednostki, zaokrąglone zakończenia i łączenia. Wyrównanie optyczne i spójny margines. Sprawdzić czytelność przy 20, 24, 32 i 48 jednostkach.
- Wersje outline/filled tylko tam, gdzie rzeczywiście przedstawiają stan lub wybór. Nie mnożyć dwóch wersji każdej ikony bez potrzeby.
- Jednokolorowy SVG może mieć neutralne wypełnienie `#000000`; całość ma dać się przemalować jednym kolorem. Nie polegać wyłącznie na obsłudze `currentColor`, CSS ani zmiennych przez renderer Fluttera.
- Bez zewnętrznych fontów, osadzonych zdjęć, skryptów, zewnętrznych odwołań i złożonych filtrów. Tekst nie może być wymagany do wyświetlenia SVG.
- PNG z przezroczystością jedynie jako podgląd lub świadomy fallback. Sama grafika rastrowa nie spełnia wymagania dowolnego przemalowania i ostrego skalowania ikon.

### Ilustracje, nagrody i logo

- SVG oraz edytowalny plik źródłowy. Elementy kolorów pogrupowane według ról z sekcji 2.
- Dla ilustracji wielokolorowej dostarczyć także wersję z rozdzielonymi warstwami SVG i manifest kolorów. Jednolity filtr koloru przemalowuje całość i nie wystarcza do niezależnej zmiany kilku ról.
- Podglądy PNG dla jasnego i ciemnego motywu; bez białego prostokąta pod grafiką.
- Każdy element ma nazwę i krótki opis znaczenia po polsku. Nazwy plików: małe litery, ASCII, snake_case.
- Lista pochodzenia i praw do każdego zewnętrznego fontu/elementu. Preferuj własne zasoby; nie wykorzystuj gotowych zestawów bez informacji o licencji.

Proponowana paczka przekazania — katalog roboczy, nie automatyczne dodanie wszystkiego do aplikacji:

```text
kindspot-graphics/
  icons/navigation/
  icons/actions/
  icons/map/
  icons/needs/
  icons/features/
  icons/filters/
  icons/reviews/
  icons/account/
  icons/rewards/
  icons/status/
  illustrations/
  avatars/
  frames/
  badges/
  garden/
  brand/
  source/
  previews/
  manifest.csv
  README.md
```

Manifest: `id`, `plik`, `kategoria`, `priorytet`, `znaczenie_pl`, `wariant`, `role_kolorow`, `wspoldzielone_uzycie`, `zrodlo_licencja`. Podgląd całości: arkusz ikon z ID i kontakty ilustracji. Do runtime Fluttera trafią wybrane zasoby w `frontend/mobile/assets/graphics/`; źródła i podglądy nie powinny niepotrzebnie zwiększać paczki aplikacji. Rejestrację zasobów wykonamy podczas integracji.

## 17. Warunki odbioru i sposób pracy w drugim chacie

1. Najpierw wykonaj próbkę stylu: mapa, profil, podjazd, potrzeba słuchu, gwiazdka, znak zapytania, prezent oraz jedna ilustracja pustej listy.
2. Pokaż te same pliki z przykładowym obecnym akcentem na jasnym i ciemnym tle, także jednokolorowo i w wyższym kontraście. Następnie pokaż je z dowolnym dodatkowym kolorem spoza obecnej palety, zmieniając wyłącznie wartości ról kolorów — bez edycji i ponownego eksportu zasobów. To test możliwości dodania nowego motywu. Zaczekaj na weryfikację użytkownika przed wykonaniem całej paczki.
3. Po akceptacji przygotuj P1; pokaż arkusz i sprawdź spójność symboli.
4. Po odbiorze P1 przygotuj P2. P3 wykonuj jako osobną paczkę, po potwierdzeniu zakresu.
5. Zweryfikuj SVG w docelowym rendererze Fluttera podczas integracji. Podgląd w przeglądarce nie gwarantuje zgodności renderowania.

Przyjmujemy jako wymagania projektowe:

- Funkcjonalne ikony i istotne obrysy: kontrast co najmniej 3:1 do sąsiedniego tła. Tekst dodany przez interfejs: zwykle co najmniej 4,5:1. Ocena na rzeczywistych tłach, nie samych bazach pastelowych.
- Spokojny, łagodny styl, spójna grubość linii, brak małych ozdobników potrzebnych do rozpoznania symbolu.
- Brak informacji przekazywanej wyłącznie kolorem, położeniem, animacją lub ilustracją.
- Dotykowy obszar kontrolki ustala aplikacja; mała ikona nie uzasadnia małego przycisku. Cel naszego interfejsu: około 48 × 48 jednostek logicznych dla przycisków.
- Ikony otrzymują podpisy i opisy dla czytnika podczas wdrożenia; grafika sama nie zapewnia dostępności. Dekoracje są pomijane przez czytnik.
- Brak ikon sugerujących stuprocentową dostępność, oficjalny certyfikat lub wyższość jednej grupy użytkowników nad inną.
- Wszystkie materiały mają pozwalać dodawać dowolne nowe kolory motywu. Nie zamawiamy określonej liczby kombinacji kolorystycznych. Jeden zestaw ikon i ilustracji obsługuje obecną oraz przyszłą paletę; zmienia się konfiguracja kolorów, nie grafika.

## 18. Podstawa zakresu

Przeczytano Teorię aplikacji, use case’y, otwarte decyzje, instrukcję dostępności, mapowanie pytań oraz obecne ekrany i katalog cech. Kolory sprawdzono w `frontend/mobile/lib/ui/theme.dart`. Aktualne lokalne zmiany innych prac zostały zachowane. Nie zmieniono kodu, reguł punktów, ankiety ani checkpointów. Dokument nie jest deklaracją ukończenia dostępności i nie zleca publikacji ani integracji.
