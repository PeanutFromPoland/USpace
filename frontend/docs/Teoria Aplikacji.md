# KindSpot — teoria wyglądu i działania frontendu

Nowa nazwa zatwierdzona 2026-10-03: KindSpot (wcześniej USpace). Starsze nazwy w dokumentacji i kontrakcie odnoszą się do tego samego projektu. Ankietę wznowiono 2026-10-03 (sekcja na końcu).


Notatka projektowa oparta na pliku „Teoria Aplikacji.md”. Zakres: to, co użytkownik widzi i robi w aplikacji. Sposób działania usług i reguły przetwarzania danych opisuje osobny kontrakt frontend–backend.

Aktualizacja decyzji użytkownika: 2026-10-03. Ustalenia zapisano poniżej; kwestie oznaczone „do ustalenia” nie są zatwierdzonymi regułami. Opis pozostaje teoretyczny, bez implementacji ekranów.

## A. Cel i odbiorcy

KindSpot to aplikacja mobilna pomagająca osobom z niepełnosprawnościami i innymi potrzebami dostępności znaleźć odpowiednie miejsca. Recenzowanie, weryfikowanie informacji i zdobywanie nagród łączą pomoc innym z elementami zabawy.

Użytkownik może wskazać kilka potrzeb jednocześnie:

| Obszar | Potrzeby użytkownika |
|---|---|
| Mobilność | Poruszam się na wózku; mam trudności z chodzeniem; nie mogę korzystać ze schodów; potrzebuję częstych miejsc odpoczynku |
| Wzrok i słuch | Jestem niewidomy / słabowidzący; jestem głuchy / niedosłyszący |
| Wrażliwość na otoczenie | Źle znoszę hałas, tłum lub intensywne światło; potrzebuję spokojnych miejsc |
| Orientacja i obsługa | Mam trudności z orientacją; mam trudności z czytaniem skomplikowanych informacji; mam ograniczoną sprawność rąk |
| Podróżowanie z innymi | Podróżuję z osobą wymagającą pomocy; podróżuję z dzieckiem / wózkiem dziecięcym; podróżuję z psem przewodnikiem / terapeutycznym |

Z aplikacji mogą korzystać również osoby bez wskazanych potrzeb, które chcą rozbudowywać informacje o miejscach. Mogą być oznaczane jako „Pomocnicy”.

Do doprecyzowania: czy oznaczenie Pomocnika może wybrać każdy użytkownik; czy pies przewodnik i pies terapeutyczny są osobnymi pozycjami.

### Zakres prezentacji PoC

Nie ustalamy teraz zamkniętej listy funkcji pierwszej wersji: pokazujemy tyle, ile uda się przygotować. Pokaz jawnie odróżnia działające elementy, dane demonstracyjne i teoretyczne przebiegi, zwłaszcza zakup i odbiór nagród.

## B. Platforma i interfejs

- Platforma: mobilna aplikacja Flutter (Dart), projektowana przede wszystkim na telefon, z układem dostosowującym się do ekranu.
- Działanie offline nie jest wymagane.
- Znany użytkownikom sposób korzystania z mapy, inspirowany Google Maps: mapa jako ekran główny i przyciski na dole, z wyróżnionym głównym przyciskiem pośrodku oraz dodatkowymi po lewej i prawej. Środkowy przycisk otwiera mapę.
- Główne sekcje: Zapisane miejsca, Filtry, Proponowane miejsca w okolicy, Nagrody, Profil.
- Cofnięcie z ekranu aplikacji wraca na mapę; cofnięcie z mapy wyświetla pytanie, czy wyjść z aplikacji. Obsługa cofnięcia podczas formularza, dialogu i klawiatury wymaga scenariuszy wyjątkowych; nie zakładamy utraty szkicu.
- Kolory akcentu do wyboru: pastelowy pomarańczowy, pastelowy różowy i jasnoniebieski. Każdy z motywem białym lub czarnym: łącznie sześć kombinacji.
- Cel: maksymalna łatwość obsługi dla osób z niepełnosprawnościami i ich bliskich, WCAG 2.2 AA oraz testy z użytkownikami. Każda kombinacja wymaga sprawdzenia kontrastu; pastelowy wygląd nie zastępuje dostępności.

Do ustalenia: rozmieszczenie pięciu sekcji względem środkowego przycisku mapy; motyw domyślny, dokładne kolory, typografia, ikony, rozmiary kontrolek i szczegółowy układ większych ekranów. Inspiracja Google Maps określa znajomy wzorzec, nie gotową makietę.

## C. Wyszukiwanie i personalizacja

Miasto jest wybierane na podstawie lokalizacji telefonu; użytkownik może je ręcznie zmienić na liście miast. Bez zgody na lokalizację pozostaje wybór ręczny.

Przy rozpoczęciu wyszukiwania używany jest ostatni filtr użytkownika. Filtry są zapisywane na profilu. Zachowanie przy pierwszym użyciu, gdy nie ma poprzedniego filtra, oraz zakres pamiętania filtra między miastami/urządzeniami pozostają do ustalenia.

- Filtry ogólne: presety ustawiane jednym kliknięciem.
- Filtry szczegółowe: warunek konieczny (dla cech ocenialnych minimalne gwiazdki), preferencja bez progu gwiazdek, bez znaczenia.
- Mapa i równoważna lista prezentują miejsca z aktywnymi filtrami.
- Lista miejsc ma dwa sposoby sortowania: liczba recenzji malejąco oraz najlepsza średnia ocen malejąco, przy tej samej średniej liczba recenzji malejąco. Wyższa średnia ma priorytet niezależnie od liczby recenzji. Są to opcje sortowania, nie dodatkowe filtry dostępności.
- Dostępna jest sekcja proponowanych miejsc w okolicy oraz sekcja zapisanych miejsc.

Ustalono dla happy case: okolica to całe wybrane miasto; ranking według średniej, potem liczby recenzji. Do kontraktu: zakres recenzji uwzględnianych w średniej i źródło agregatu. Nadal do ustalenia: działania zapisywania/usuwania miejsca, szczegółowe zasady pamiętania/resetu i szkicu po cofnięciu.

### Szczegóły miejsca

Informacje mają być pokazywane zawsze w tej samej kolejności. Kolejność ustalimy w następnym kroku. Należy uwzględnić wejścia, cechy, daty i aktualność, utrudnienia, recenzje oraz brak danych; brak danych nie oznacza dostępności.

## D. Konto i prywatność

Konto jest obowiązkowe: nie przewidujemy korzystania z funkcji aplikacji jako gość. Ekrany logowania/rejestracji pozostają dostępne przed uwierzytelnieniem, podobnie jak niezbędne ułatwienia ich obsługi.

Konto bez połączonej i potwierdzonej karty dla wybranego miasta jest oznaczane „Turysta” w tym mieście. Recenzje turysty mają nieco mniejsze znaczenie. Dokładna waga oraz jej wpływ na ocenę, ranking i widoczne wyjaśnienie nie są jeszcze ustalone. Nie zakładamy, że oznacza to mniejszą liczbę punktów. Jest to etykieta produktu, nie dowód faktycznego miejsca zamieszkania.

Profil umożliwia połączenie karty i przedstawia potwierdzony status dla miasta. Potrzeby są domyślnie prywatne; użytkownik może je świadomie upublicznić. Publiczne mogą być opcjonalne osiągnięcia, statystyki oraz wybrany wygląd profilu. Pomocnik jest niezależny od statusu Turysta/Miejscowy i własnych potrzeb.

Do ustalenia: mechanizm logowania i sesji, odzyskiwanie dostępu, ekran prywatności, podgląd publicznego profilu oraz zachowanie przy sprawdzaniu, odrzuceniu i wygaśnięciu połączenia karty. Sam numer karty nie dowodzi tożsamości; sposób potwierdzenia pozostaje po stronie integracji.

## E. Recenzje i obserwacje

Użytkownik wypełnia wspólny formularz: krótką ankietę, którą można rozwinąć o komentarze i konkretne wejścia/elementy obiektu. Do każdego pytania przygotowujemy przykładowy szkic odpowiedzi, ułatwiający napisanie uzasadnienia; przykład nie powinien być publikowany jako obserwacja użytkownika bez jego świadomego użycia.

Ankieta rozdziela istnienie cechy (występuje / nie występuje / nie wiem), jakość 1–5 i stan działania, gdy cecha występuje i można taki stan ocenić. Ocena 3 nie oznacza braku zdania. Można opisać własne elementy i utrudnienia tymczasowe.

Każde pytanie ankiety wymaga odpowiedzi: 1–5 gwiazdek, „Brak funkcji” (traktowane jako 0 gwiazdek) albo „Niewiedza”. Ostatnia opcja jest publikowana jako „Nie mogłem sprawdzić” i nie otrzymuje oceny liczbowej. Brak funkcji i niewiedza pozostają odrębnymi stanami. Wymóg dotyczy każdego punktu prezentowanej ankiety; dokładny zestaw pytań ustalimy na przykładzie. Wpływ 0 na ocenę zbiorczą miejsca doprecyzujemy przy zasadach agregacji; niewiedza nie może być pokazana jako brak funkcji.

Data wizyty domyślnie bieżąca, z możliwością zmiany. Godzina opcjonalna i wpisywana samodzielnie. Przykładową ankietę przygotujemy w następnym kroku. Recenzję można zgłosić jako fałszywą/obraźliwą/spamową.

Do ustalenia: pytania i znaczenie skali, przykładowe odpowiedzi, kolejność formularza, podsumowanie, szkic po cofnięciu, edycja i komunikaty wysłania. QR zostało usunięte z zakresu. Opcjonalne pytania doprecyzowujące nie blokują poprawnej ankiety.

## F. Prezentacja weryfikacji recenzji

- Lajk/dislajk dotyczy konkretnego elementu cudzej recenzji i wskazanego wejścia, nie całej recenzji.
- Lajk oznacza „Zgadzam się”; dislajk oznacza „Nie zgadzam się”. Każdy może mieć opcjonalne uzasadnienie.
- W jednej recenzji można zgodzić się z opinią o podjeździe i nie zgodzić z opinią o udogodnieniach dla osób niewidomych.
- Autor nie może weryfikować własnej recenzji. Brak wiedzy nie wymusza głosu.
- Przy elementach pokazywane są głosy; sposób zbiorczego procentu recenzji pozostaje do ustalenia.
- Autor widzi osobno publikację, sprawdzanie i status punktów. Zwykła recenzja widoczna/oczekująca; spam może być wstrzymany z informacją dla autora.
- Akceptacja bota wystarcza do uruchomienia nagrodzenia po stronie systemu, ale nie stanowi gwarancji dostępności miejsca.

Do ustalenia: zmiana/cofnięcie głosu, procenty i sortowanie recenzji, kwalifikacja weryfikatorów oraz wpływ głosów na akceptację/ukrywanie/usuwanie. Nie przyjmujemy nieustalonych progów ani samodzielnego przyznawania punktów w interfejsie.

## G. Punkty i nagrody

Użytkownik widzi saldo oraz katalog elementów wizualnych i miejskich benefitów. Nagroda ma opis, koszt i sposób odbioru: na koncie, kod lub informację o zapisaniu na karcie. Punkty nieprzekazywalne, dobrowolne zwroty wyłączone.

Potwierdzenie zakupu i odbioru przygotowujemy na razie teoretycznie jako część PoC. Prezentacja nie sugeruje faktycznego pobrania punktów lub wydania biletu, jeśli nie zostało to zrealizowane. Zachowujemy zaplanowane stany przetwarzania i błędu oraz przywrócenia punktów po nieudanej realizacji.

Do ustalenia: wygląd katalogu, „Moje nagrody”, dialog kosztu, instrukcja i ważność kodu, historia punktów oraz dokładne komunikaty. Mechanizm ekonomii punktów nie jest wyliczany wyłącznie w kliencie.

## H. Usprawnienia dotyczące dostępności — propozycja

- Równoważna lista miejsc pozwala korzystać z głównych funkcji bez mapy.
- Przyciski, filtry, gwiazdki i pola mają czytelne etykiety, także dla czytnika ekranu.
- Statusy i błędy mają opis tekstowy; kolor nie jest jedynym nośnikiem informacji.
- Interfejs zachowuje czytelność po powiększeniu tekstu i dostosowuje układ do ekranu.
- Nawigacja jest przewidywalna, a fokus widoczny i niezasłonięty.
- Podstawowe czynności nie wymagają wyłącznie przeciągania lub złożonych gestów.
- Kontrolki są łatwe do wybrania, a formularze nie wymagają precyzyjnego trafiania w małe gwiazdki.
- Błędy wskazują pole i sposób poprawy, zachowując wprowadzone dane.
- Komunikaty o wysłaniu, błędzie i zmianie statusu są dostępne dla czytnika ekranu.
- Teksty są krótkie, a działania jednoznacznie nazwane.
- Efekty grywalizacji można ograniczyć; nie stosujemy migających dekoracji.
- Ustawienia dostępności można otworzyć przed logowaniem, niezależnie od deklarowania potrzeb.
- Logowanie pozwala korzystać z menedżera haseł i wklejać dane.

Cel WCAG 2.2 AA wymaga późniejszego sprawdzenia ekranów i ścieżek. Ta lista nie jest deklaracją osiągniętej zgodności. Część punktów jest dodatkowym założeniem użyteczności.

Źródło kryteriów: [WCAG 2.2 — lista wymagań](https://www.w3.org/WAI/WCAG22/quickref/).

## I. Czego jeszcze brakuje do frontendowego PoC

### Najbliższe ustalenia

1. Ostateczne rozmieszczenie pięciu sekcji wokół środkowego przycisku mapy.
2. Stała kolejność informacji na karcie miejsca.
3. Przykładowa ankieta, etykiety skali i szkice odpowiedzi. Zasada odpowiedzi jest ustalona: 1–5, brak funkcji=0 albo niewiedza bez oceny.
4. Stany wyjątkowe — przygotujemy je w kolejnym kroku, w tym cofnięcie z formularza i wygaśnięcie sesji.
5. Ranking miejsc rozstrzygnięto w CP-04/05: średnia, potem liczba recenzji; okolica = całe miasto dla happy case. Zakres agregacji API oraz zapis i usuwanie miejsc nadal otwarte.
6. Pierwsze użycie bez poprzedniego filtra, zapis/reset i zachowanie przy zmianie miasta.
7. Waga recenzji turysty; skutki głosów, zmiana głosu i kwalifikowanie weryfikatorów.
8. Szczegóły konta/sesji oraz sześciu motywów (paleta, kontrast, typografia, ikony).

### Materiały przed implementacją poszczególnych ścieżek

Makiety, nawigacja, wspólne komponenty i przykładowe dane. Zakres demonstracji pozostaje elastyczny: pokazujemy przygotowaną część, jawnie oznaczając symulacje. Nie przyjmujemy, że cała planowana lista musi powstać przed pokazem.

### Stany do przygotowania

Ładowanie i brak wyników; brak danych dostępności; odmowa lokalizacji; błąd mapy/połączenia; szkic formularza i nieznany wynik wysłania; zgłoszona/ukryta recenzja; głos niedostępny; punkty oczekujące; nagroda niedostępna i realizacja w toku/błąd. Nie są jeszcze rozpisanymi scenariuszami.

### Pozostałe rozszerzenia

Powiadomienia i panel moderatora pozostają do ustalenia. Zapisane miejsca są zatwierdzoną sekcją, nie opcjonalnym pomysłem; QR jest wyłączone.

## J. Zakres usunięty z notatki

Usunięto opis działania bota, zmiany ukrytej reputacji, doboru weryfikatorów na podstawie pobytu, progów moderacji, mechanizmu naliczania punktów oraz technicznego wykorzystania API karty i nagród.

Zachowano ich skutki widoczne w interfejsie: statusy, ograniczenia dostępnych działań, informacje o punktach i sposobach odbioru nagród. Szczegóły komunikacji pozostają w osobnym dokumencie KindSpot-kontrakt-frontend-backend-v0.1.md. Decyzje użytkownika aktualizują także use-cases.md i odpowiednie założenia kontraktu; nie potwierdzają istnienia działającego API.


## Decyzja użytkownika — funkcjonalność i dostępność CP-02, 2026-10-03

Końcowy projekt graficzny wykona później inna osoba. Teraz rozwijamy działanie aplikacji i dostępność; aktualny wygląd jest roboczy. CP-02 zmieniono na dostępność funkcjonalną, ze sprawdzeniem wszystkich kryteriów WCAG 2.2 A/AA oraz zastosowania do Fluttera według WCAG2ICT. Kryteria, wyniki i wymagane dowody: KindSpot-CP02-WCAG.md. CP-02 pozostaje w trakcie; wcześniejsze oddanie sześciu motywów nie jest odbiorem całości udogodnień.

Czytnik, duży tekst/kontrast, klawiatura/przełączniki, obsługa bez złożonych gestów, przewidywalne cofanie, czytelne trwałe błędy i zachowanie wyborów muszą być sprawdzane w istniejących ścieżkach. Brak informacji przekazywanej wyłącznie dźwiękiem, kolorem lub wymagającej mówienia. Nie wymagamy deklaracji niepełnosprawności dla ustawień dostępności. Kontrast i rozmiary/fokus są wymaganiami funkcjonalnymi również przed grafiką.

Nie deklarujemy „wszystkich potrzeb wszystkich osób obsłużonych” na podstawie samych testów automatycznych. Testy urządzenia/czytnika i z użytkownikami pozostają potrzebne. Brakujące funkcje mają późniejsze checkpointy, nie fikcyjny wynik zgodności. Ankieta i recenzje nadal odłożone. Emulator uruchamia wyłącznie użytkownik. Po zmianie grafiki ponownie sprawdzamy dostępność.

## Decyzja użytkownika — ankieta, 2026-10-03

Prace nad ankietą wznowiono. Przykładowa ankieta PoC: KindSpot-ankieta-recenzji.md, pytania i cechy: KindSpot-mapowanie-pytan.md. Recenzja w PoC nie jest wysyłana do systemu.

- Ocena 0 („Brak funkcji”) nie wlicza się do średniej oceny cechy.
- Etykieta niewiedzy pozostaje „Nie mogłem sprawdzić”.
- Ekran „Czy polecisz to miejsce osobom z podobnymi potrzebami?” zostaje; pole `recommendation` dopisano do kontraktu.
- Tryb spokojny (`calmMode`) wstępnie przyjęty; zdjęcia w recenzji pozostają decyzją otwartą.
- Nazwa KindSpot obowiązuje we wszystkich tekstach; identyfikatory techniczne bez zmian.

## Przejście do CP-03 i rozdzielenie kryteriów dostępności

Użytkownik zlecił rozpoczęcie CP-03 po zmianie struktury: projekt Flutter frontend/mobile, dokumenty frontend/docs, skrypty frontend/scripts. Brakujące kryteria macierzy mają właścicieli w odpowiednich checkpointach, a ich wymagania dopisano bezpośrednio w tych etapach. CP-02 nie jest automatycznie odebrany; przejście dalej jest jawnie zlecone. CP-12 ponownie sprawdza całe ścieżki oraz końcową grafikę.

Implementacja CP-03 przy obecnym backendzie obejmuje wyłącznie jawne lokalne konto demo. Backend uspace_api/main.py udostępnia health, bez endpointów auth. Nie wprowadzono wymagań hasła/email, czasu sesji ani fikcyjnej rejestracji. Test Hackaton otwiera się domyślnie przy starcie; zamknięcie sesji prowadzi do wejścia demo i usuwa prywatne trasy z historii. Ponowne wejście zachowuje ustawienia lokalnego demo. Następne uruchomienie wraca do automatycznego testowego startu, chyba że wyłączono USPACE_AUTO_DEMO_LOGIN. Błąd zapisu wyjścia pozostawia konto otwarte z wyraźną informacją, bez fałszywego sukcesu. Mechanizm produkcyjny nadal wymaga ustalenia i API.

## Decyzje CP-04 i CP-05 — 2026-10-03

Użytkownik zlecił równoległe wykonanie CP-04 i CP-05 z dodatkowym agentem. Nie oznacza to odbioru pełnego CP-02/WCAG ani produkcyjnego uwierzytelnienia CP-03.

- Najlepsze miejsca: średnia ocen malejąco ma bezwzględny priorytet; przy tej samej średniej wyżej jest więcej recenzji. Osobna opcja „Najwięcej recenzji” sortuje liczbę malejąco. Nie wyliczamy średniej miejsca ze średnich cech.
- Na potrzeby happy case okolica obejmuje całe wybrane miasto. Proponowane miejsca stosują zapisane filtry i wybraną kolejność, bez dodatkowego promienia ani potwierdzania wizyty.
- Komentarze: użytkownik wskazał największy stosunek lajków do dislajków. Implementacja należy do CP-08; zero dislajków, remisy i powiązanie z głosami per obserwacja nadal wymagają doprecyzowania. Nie zmieniamy teraz jednostki głosowania ani nie tworzymy komentarzy.
- Demo ma jawnie fikcyjne średnie i liczby recenzji; brak średniej/licznika pozostaje brakiem danych. Domyślna kolejność demo to najlepsza ocena, ostatni wybór jest zapisany lokalnie. Dla sortowania liczby techniczny remis rozstrzyga średnia, potem nazwa/ID; ostatnie klucze nie stanowią nowej reguły produktu.
- Miasto można ustalić po wybraniu „Użyj lokalizacji telefonu”. Demo rozpoznaje systemową nazwę miejscowości dla Krakowa/Warszawy w Polsce; nie zgaduje najbliższego miasta. Odmowa, wyłączona usługa, brak rozpoznania i inne miasta pozostawiają ręczny wybór. Zapisujemy tylko identyfikator miasta, bez współrzędnych/śledzenia w tle. Geokodowanie systemowe może użyć sieci.
- Potrzeby/filtry: zapis dopiero przyciskiem, czyszczenie zmienia szkic i wyłącza dołączenie braków danych; bez zapisu potwierdzone filtry pozostają. Trwały błąd zachowuje wybory. Presety oraz sugestie cech pozostają przykładami PoC, nie zatwierdzoną klasyfikacją potrzeb. Potrzeby prywatne domyślnie.

Operator produkcyjnej mapy, dane API i zakres agregacji recenzji dla średniej nadal należą do kontraktu CP-11. Synchronizacja filtrów i scenariusz szkicu po cofnięciu pozostają otwarte. Wyniki automatyczne nie zastępują testów lokalizacji/TalkBack na urządzeniu; emulator uruchamia tylko użytkownik. Szczegóły odbioru: KindSpot-CP04-CP05.md.
## Pozostałe checkpointy — decyzje użytkownika 2026-10-03

Użytkownik zlecił równoległą pracę nad pozostałymi etapami, po jednym agencie na checkpoint i z pytaniami przy niepewności. Etapy powstają w falach z uwagi na dostępne sloty i zależności; integracja wspólnych modeli i testy końcowe należą do agenta głównego. Nie wymaga się kolejnego odbioru każdego poprzednika przed przygotowaniem tych jawnie zleconych etapów; ukończenie techniczne nadal nie oznacza odbioru użytkownika.

- CP-06 zatwierdzony przebieg: nazwa/adres i dopasowanie → utrudnienia i aktualność → wejścia → cechy → recenzje. Przycisk Zapisz miejsce/Usuń z zapisanych w szczegółach; lokalna lista demo od ostatnio zapisanego. Lista zapisanych pozostaje niezależna od wyszukiwanych miast/filtrów; wpis bez danych katalogowych jest jawnie niedostępny i można go usunąć. Dostępność wejścia nie jest domyślnie dostępnością całego miejsca.
- CP-07 pozostaje odłożony: ankietę przygotowuje inna osoba we Flutterze. Nie tworzymy zastępczej ankiety ani formularza publikacji. Przygotowujemy sposób przekazania/włączenia modułu oraz wymagania dostępności i danych, bez narzucania niezatwierdzonych pytań.
- CP-11: użytkownik potwierdził brak API i przewiduje jego brak dla PoC. Rzeczywista integracja jest jawnie odroczona na potrzeby PoC. Można przygotować adaptery i testy kontraktu; ich istnienie nie oznacza połączenia aplikacji z backendem. Backend pozostaje odpowiedzialnością innego członka zespołu.
- CP-08/09/10 obejmują zatwierdzone prezentacje i jawne przebiegi demo. Nie tworzymy prawdziwych potwierdzeń karty, punktów, nagród ani skutków moderacji w kliencie. Potrzeby nadal prywatne domyślnie. Pytania o zmianę głosu i szczegóły rankingu zapisujemy oddzielnie.
- CP-12: testy automatyczne i przygotowanie APK/przebiegu pokazu w rzeczywistym zakresie. Urządzenie/czytnik oraz iOS pozostają niewykonane do uzyskania rzeczywistych dowodów. Emulator uruchamia wyłącznie użytkownik.
## Zmiana testowego konta i sklepu — praca w toku

Decyzja użytkownika 2026-10-03: przy nowym uruchomieniu saldo testowe 1000 pkt, zakupy i pozostałe dane konta od nowa; nazwane filtry i ustawienia dostępności zachowane. Przykładowy Ogród ciszy wraca w Zapisanych przy każdym starcie. Sklep ma odejmować punkty testowe, Moje nagrody obejmują niezrealizowane nagrody oraz historię zakupów. Poradnik punktów i mini regulamin na osobnym ekranie. Filtry: pomoc na górze, Zapisz filtr z nazwą oraz Użyj filtru tylko w sesji. Profil: pojedyncza adnotacja konta testowego, wejścia do przyszłej personalizacji; zarządzanie sesją i danymi na osobnym ekranie.

Użytkownik następnie przerwał implementację dla commita Frontend i rebase względem dev. To stan WIP: ostatnia analiza ma błędy parsowania app_controller.dart i uwagi lint; zmienione ścieżki wymagają dalszej implementacji oraz testów. Wynik 131 testów i istniejące APK dotyczą wcześniejszego stanu CP-06–12, nie aktualnych niedokończonych zmian. Ankieta i nowe moduły z dev nie są automatycznie podłączane przez rebase.

## Stan po połączeniu Frontend z dev — 2026-10-03

Na dev dostępne są teraz backend i niezależny moduł ankiety z dokumentami (review_survey.dart, review.dart, survey_catalog.dart). Zachowano ich kod, metody szkicu w kontrolerze oraz testy. Zachowano lokalne CP-04–12 i nieukończony sklep/filtry. Konflikt szczegółów rozstrzygnięto na rzecz nowego ekranu CP-06 z opcjonalnym SurveyBuilder; moduł ankiety można podłączyć przez ten punkt po wznowieniu pracy. Nie zintegrowano rzeczywistego API. Zapisy historyczne o braku kodu backendu/ankiety dotyczą wcześniejszego stanu, nie obecnego repozytorium.

Zachowano nazwę KindSpotApp z dev oraz alias USpaceApp dla wcześniejszych testów. Fizyczny folder to D:\Github\USpace, pakiet Dart uspace i identyfikator com.example.uspace pozostają bez zmian. Nazwy dokumentów zmienione na KindSpot-checkpointy.md i KindSpot-kontrakt-frontend-backend-v0.1.md. Nazwa produktu: KindSpot.

Aktualny commit jest WIP. Znane błędy parsowania kontrolera i nieukończone testy sklepu/filtrów pozostają do dokończenia po synchronizacji Git. Rebase nie jest dowodem działającej kompilacji i nie zmienia wcześniejszego APK.
## Wznowienie sklepu, filtrów i profilu — 2026-10-03

Ten zapis zastępuje wcześniejszy status WIP sklepu oraz dawny przebieg nagród bez pobierania punktów. Zgodnie z decyzją użytkownika lokalne PoC ma testowy portfel 1000 pkt; nie nadaje prawdziwych korzyści i nie zastępuje systemowego rozliczania produkcyjnego.

- Nowy proces aplikacji resetuje konto, zakupy i saldo do 1000 pkt. Zachowuje nazwane filtry oraz ustawienia dostępności (kolor, tryb ciemny, wysoki kontrast, ograniczenie animacji). Cofanie, przełączanie zakładek, powrót z tła i ponowne wejście do konta w tym samym procesie nie odnawiają salda.
- Ogród ciszy jest zapisany na start; usunięty w tej sesji wraca przy następnym uruchomieniu. Pozostałe zapisane miejsca i potrzeby resetują się.
- Zakup wymaga potwierdzenia, odejmuje punkty i blokuje ponowny zakup tego elementu do nowego startu. Niewystarczające saldo blokuje zakup. Moje nagrody w Nagrodach zawierają Do odebrania oraz Historię zakupów; realizacja testowa pozostawia wpis w historii. Poradnik punktów i mini regulamin mają osobny ekran. Nie ustalamy niezatwierdzonych stawek zdobywania punktów.
- Jak działają filtry znajduje się na górze filtrów. Zapisz filtr zapisuje nazwaną definicję bez jej automatycznego zastosowania. Użyj filtru stosuje wybór w bieżącej sesji bez zapisu na przyszłość. Nazwa 1–60 znaków; powtórzona nazwa wymaga zmiany. Błąd zapisu pozwala spróbować ponownie.
- Profil ma adnotację przy koncie, wejścia Awatar, Obramowanie, Tło profilu (funkcje przygotowywane) oraz Ustawienia konta z zarządzaniem sesją i usuwaniem lokalnych danych. Celowe usunięcie danych usuwa także zachowane filtry i ustawienia.
- Nowy domyślny akcent: pastelowy zielony, kolor bazowy #ADD8B4. Cztery akcenty w jasnym/ciemnym motywie; wcześniejszy zapisany wybór koloru zachowany zgodnie z decyzją o dostępności.
- Niezależny moduł ankiety z dev zachowany. Test integracji przekazuje go przez opcjonalny SurveyBuilder; domyślne PoC nadal go nie włącza. API nie jest podłączone.

Szczegóły i protokół sprawdzeń: KindSpot-sklep-testowy.md. Historyczne raporty i APK przed wznowieniem nie są wynikiem nowych zmian. Emulator uruchamia tylko użytkownik.

## Integracja Flutter i FastAPI — decyzje 2026-10-04

Ten zapis zastępuje wcześniejsze odłożenie ankiety/API oraz reset konta przy starcie. Użytkownik zlecił połączenie istniejącej ankiety i backendu. Główne wejście aplikacji korzysta z API, wymaga adresu serwera i logowania; dane konta, zapisane miejsca, punkty i zakupy są trwałe po stronie serwera. Test Hackaton otrzymuje 1000 punktów oraz Ogród ciszy tylko przy przygotowaniu konta lub ręcznym resecie operatora. Restart aplikacji nie dodaje punktów. Reset zachowuje nazwane filtry i dostępność; recenzje/głosy społeczności nie są usuwane w resecie portfela.

Decyzja użytkownika: średnia całego miejsca wynika ze wszystkich pomniejszych ocen recenzji. Implementacja liczy wszystkie oceny wymiarów 1–5 zaakceptowanych widocznych recenzji, wyłączając absent/unknown i techniczne average_rating; osobne recommendation nie zastępuje średniej. Priorytet średniej i liczby recenzji przy remisie zachowany.

Włączono transport HTTP, sesję, profil/filtry, miejsca/listę/mapę/zapisane, istniejącą ankietę, recenzje/głosy/zgłoszenia, punkty/sklep/moje nagrody i stany weryfikacji. Katalog 12 istniejących pytań jest dostarczany przez API. Backend wymaga jawnej migracji 3. Punkty/publikacja/uprawnienia nie są nadawane przez klienta. Operator karty pozostaje jawnie demonstracyjny. Nie zmieniono reguł rankingu komentarzy przy zerowych dislajkach.

Sprawdzenia: 175 testów Flutter, analiza bez uwag; 32 testy backendu bez bazy i Ruff poprawne. Próba HTTP konfiguracji/OpenAPI/health oraz ochrony /me przeszła bez PostgreSQL. Pełny przebieg z bazą i urządzeniem pozostaje do wykonania: brak konfiguracji PostgreSQL i wskazanego adresu serwera. Nie uruchamiano emulatora. Zmiany lokalne Frontend, bez commita/push. Pełny zakres, polecenia i checklista: frontend/docs/KindSpot-integracja-FastAPI.md.

## Wprowadzenie przy pierwszym uruchomieniu — 2026-10-04

Decyzja użytkownika: krótkie wprowadzenie do PoC z trzema automatycznie przewijanymi slajdami i analogicznymi grafikami. Treści: znajdowanie miejsc dla swoich potrzeb; pomoc przez recenzowanie dostępności; punkty za szczery i rzetelny wkład. Użyto istniejących SVG onboarding_places, onboarding_reviews oraz illustration_reward_received z kolorami motywu. Slajd punktowy wyjaśnia, że punkty są po weryfikacji; intro samo ich nie przyznaje.

Wprowadzenie poprzedza połączenie z API i logowanie; nie wymaga serwera. Slajdy co 5 sekund z łagodnym przejściem 300 ms, po trzecim wejście do aplikacji. Można pominąć, zatrzymać/wznowić lub przejść ręcznie Wstecz/Dalej/Zaczynamy. Ręczna zmiana zatrzymuje automat. Tło aplikacji zatrzymuje zegar; powrót rozpoczyna pełny czas slajdu. Czytnik ekranu lub systemowe ograniczenie animacji wyłącza automatyczne przejścia i animację.

Ukończenie lub pominięcie zapisywane niezależnie od konta/backendu, w lokalnym kluczu kindspot.introduction.seen.v1. Kolejne starty pomijają intro; przerwanie przed ukończeniem nie zapisuje flagi. Błąd zapisu pokazuje ponowienie lub Kontynuuj bez zapisu (wtedy możliwe ponowne intro przy następnym starcie). Nie zmienia sesji ani danych konta.

Sprawdzenie: 4 testy nowych scenariuszy, 179 testów całej aplikacji poprawnych, flutter analyze bez uwag; podglądy trzech slajdów z widgetów Flutter. Testy obejmują ręczny tryb dostępności, 320 px i tekst 200%, tło, pominięcie, trwałą flagę i awarię zapisu. Testy na urządzeniu/czytniku nadal wymagają użytkownika; emulatora nie uruchamiano.


## Wspólna społeczność i czytelność ankiety — 2026-10-04

Decyzja użytkownika zastępuje wcześniejszy zamysł Pomocnika: każdy może wyszukiwać miejsca, recenzować i weryfikować niezależnie od potrzeb. Usunięto przełączniki, oznaczenie oraz pole roli z modeli klienta i kontraktu konta API. Historyczna kolumna helper_opt_in w bazie pozostaje nieużywana dla zgodności danych; nie ma znaczenia dla uprawnień. Brak potrzeb nie nadaje osobnej roli. Nazwa obramowania zmieniona na „Wspólna przestrzeń”.

Usunięto powtarzane banery wersji demonstracyjnej z ikoną kolby. Adnotacja konta testowego w profilu pozostaje. Informacje o rzeczywistych ograniczeniach operacji (nieważny kod/testowy operator karty/lokalny zapis) pozostają przy tych operacjach; nie oznacza to wdrożenia produkcyjnego.

Pytania ankiety używają zatwierdzonych SVG cech (12 pytań; aliasy elevator/lift oraz quiet_environment/quiet). Ikona uzupełnia tekst, nie zastępuje etykiety. Kolory wynikają z motywu, ikony dekoracyjne nie powtarzają treści czytnikowi; nagłówek zawija się przy powiększonym tekście. Dane i punktacja ankiety bez zmian.

## Dopracowanie ilustracji wprowadzenia — 2026-10-04

Na prośbę użytkownika symbole w kafelkach zastąpiono małymi ilustracjami scen w stylu dostarczonego przykładu: mapa z zakładką i roślinami, ankieta z ołówkiem, prezent z punktami. Obszar grafiki 256 × 176 px. Usunięto tło-kafelek widgetu oraz biały panel z grafiki nagrody; SVG mają transparentną przestrzeń wokół sceny. Kolory i delikatne wypełnienia nadal wynikają z ról motywu; nie wymagają kolejnych eksportów przy dodaniu koloru. Zachowano warianty spokojne i monochromatyczne. Źródło scen: frontend/design/graphics/source/refresh_introduction_art.py.

Zachowanie pierwszego uruchomienia, automatyka, flaga ukończenia i punktacja bez zmian. Sprawdzenie: 8 testów wprowadzenia, zasobów i podglądu poprawnych; flutter analyze bez uwag. Oceniono rzeczywiste zrzuty trzech slajdów Flutter. Testy na urządzeniu nadal wymagają użytkownika; emulatora nie uruchamiano.


## Personalizacja PoC za nagrody — 2026-10-04

Decyzja użytkownika przekazana przez chat współpracujący: dwa profilowe (Lemur/Kot), jedna obręcz z kokardą, zakupione motywy Odkrywca i Ogrodnik, tło profilu z motywu, kategorie sklepu i mała sekcja Osiągnięcia z wyborem potwierdzonego publicznego tytułu. Grafiki/motywy dostarcza osobny chat; warstwa działania używa KindSpotAvatar i KindSpotBackdrop. Brak osobnej roli Pomocnika.

Wdrożono kontrolę własności i rodzaju pola w API, katalog pięciu kosmetyków oraz natychmiastowe rozliczenie ich zakupów przez serwer (fulfilled/charged). Drugi zakup posiadanego/przetwarzanego kosmetyku blokowany; ponowienie tego samego Idempotency-Key bez drugiego obciążenia. Wyposażenie jest trwałe na koncie. Motywy explorer/gardener wymagają zakupu także przez PUT ui-settings. Ogrodnik włącza darkMode=true; użytkownik zachowuje możliwość zmiany wariantu, kontrastu i ułatwień.

Nie ustanowiono automatycznych reguł zdobywania osiągnięć. Tytuły przechowuje earned_titles, nadanie przez operatora po potwierdzeniu. Klient może wybrać tylko zdobyty tytuł lub zrezygnować z publicznego tytułu. Publiczny profil i review.author.title zawierają wyłącznie wybrany potwierdzony tytuł; prywatne potrzeby nie są ujawniane. Wymagana migracja4 i bootstrap uprawnień, w tym poprawione granty saved_places. Konto nie dostaje nowych punktów z klienta.

Raport, ceny PoC, polecenie operatora, zakres i testy: frontend/docs/KindSpot-personalizacja-PoC.md. Backend/PostgreSQL i urządzenie nadal niezweryfikowane w rzeczywistym środowisku; nie deklarować odbioru produkcyjnego. Bez APK/emulatora/commita/push w tym etapie — końcowa integracja w chacie graficznym.

## Ankieta i zakres publikacji — decyzja 2026-10-04
Odpowiedzi binarne ankiety: „Tak”, „Nie”, „Nie mogłem sprawdzić”. Przy ocenach 1–5 etykieta braku funkcji brzmi „Nie”; pytanie easy_controls (klamki, przyciski i terminal) nie oferuje odpowiedzi absent/0. Skale 1–5 i brak możliwości sprawdzenia pozostają. Bez zmiany kontraktu wysyłania i zasad naliczania punktów.
Błąd wysyłania recenzji pozostaje bez naprawy na polecenie użytkownika. Logi API: POST /places/place_krakow_cafe/reviews zwraca 422. Zrzut pokazuje dwie obserwacje step_free_entrance dla całego miejsca; backend odrzuca duplikaty (featureId,targetId). To prawdopodobna przyczyna; logi nie zawierają szczegółów odpowiedzi 422.
Nie publikować wszystkich obecnych zmian backendu: models.py, personalization.py, test_personalization.py, backend/scripts/Start-KindSpotBackend.ps1, ani lokalnego raportu frontend/docs/KindSpot-backend-lokalny.md i bieżących zmian docs/RUNNING.pl.md oraz docs/RUNNING.en.md. Pozostają lokalnie; nowe pliki wykluczono w .git/info/exclude, nie w współdzielonym .gitignore. Bez commita/push. Nagrody odtwarza inna osoba; nie przywracać ich w tej pracy.
## Automatyczne ładowanie sklepu i tła motywów — 2026-10-04
Korekta użytkownika: nagrody nie zostały usunięte; sklep wymagał odświeżenia. Nie ma zadania odtwarzania katalogu przez inną osobę. Rozdzielono stan zakładek ApiHome przez KeyedSubtree z kluczem selected, dzięki czemu Zapisane/Nagrody nie współdzielą stanu RemotePage, a sklep pobiera swój katalog przy wejściu, również ponownym. Test regresji odwiedza Zapisane → Nagrody dwukrotnie i sprawdza pobranie oraz widoczną nagrodę bez odświeżania.
Dekoracje Odkrywcy/Ogrodnika: opacity 0.045 → 0.16, rozmiar 32 → 44 px; karty pozostają pełne. Dekoracje nadal wyłączane przez tryby dostępności, wysokiego kontrastu i ograniczenia animacji. Podglądy rzeczywistych widgetów sprawdzone wizualnie: frontend/mobile/build/cp02/reward-theme-explorer.png i reward-theme-gardener.png.
Sprawdzenie: 6 testów integracji UI/grafik oraz 1 test podglądów poprawnych, flutter analyze bez uwag. Bez zmiany backendu, naprawy wysyłania recenzji, emulatora, commita/push. Wcześniejsze wykluczenie lokalnych zmian backendu z publikacji pozostaje.