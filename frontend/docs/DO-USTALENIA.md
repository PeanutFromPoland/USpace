# KindSpot — ustalenia przed kolejnymi etapami

Aktualizacja: 2026-10-03. Źródła: `Teoria Aplikacji.md` i `use-cases.md`. Ten plik rejestruje pytania, nie ustanawia nowych reguł.

## Obecny zakres zatwierdzony przez użytkownika

Najpierw szkielet i działanie aplikacji. Ankietę wznowiono 2026-10-03 (sekcja na końcu); dalsze procesy recenzji pozostają odłożone. Flutter; komunikacja i interfejs po polsku. Konto obowiązkowe w produkcie; szkielet ma wyraźnie oddzielone konto demonstracyjne, bez rzeczywistego uwierzytelniania. Na polecenie użytkownika z 2026-10-03 konto „Test Hackaton” otwiera się automatycznie na potrzeby testów. Nie jest to zmiana produkcyjnego wymagania konta.

## Pytania do wskazania w plikach źródłowych

1. Ostateczne rozmieszczenie pięciu sekcji i środkowego przycisku mapy. Obecny szkielet pokazuje Zapisane, Nagrody, Mapę, Filtry i Profil. Proponowane miejsca mają osobny dostęp z ekranu miejsc; okolica to całe miasto w happy case, ranking średnia → liczba recenzji wdrożony jako jawne demo.
2. Sposób dodawania/usuwania zapisanych miejsc (UC-18), sortowanie i niedostępne miejsce. Obecnie tylko sekcja informacyjna.
3. Rozstrzygnięto ranking: średnia malejąco → liczba recenzji malejąco; osobne sortowanie liczbą malejąco. Do kontraktu pozostaje zakres recenzji w agregacie/API. Nie zastępujemy średniej miejsca średnią cech klienta.
4. Pierwszy filtr, presety, znaczenie progów i skali cech. Obecne reguły i katalog są przykładami PoC. Zapis dotyczy urządzenia, bez synchronizacji z kontem. Wskazanie potrzeb nie powinno automatycznie nadpisywać szczegółowych reguł.
5. Stała kolejność informacji o miejscu i zestaw danych udostępnianych przez API.
6. Mechanizm logowania/rejestracji, sesji, odzyskania konta i API. Adres lokalnego callbacku OAuth przekazany w czacie nie jest kontraktem API; parametry uwierzytelniania nie są utrwalane.
7. Docelowe platformy, identyfikator aplikacji, podpisywanie i operator podkładu mapy. Obecny identyfikator `com.example.uspace` jest wyłącznie demonstracyjny.
8. W demo lokalizacja na żądanie z uprawnieniem podczas używania, tylko przybliżona na Androidzie; systemowa nazwa Krakowa/Warszawy w PL albo ręczny wybór. Bez współrzędnych w zapisie i bez śledzenia w tle. Produkcyjne dane miast i dostawca mapy pozostają do kontraktu; przebieg na urządzeniu do ręcznego sprawdzenia.
9. Cofnięcie z niezapisanych formularzy ustawień; obecny szkielet zapisuje dopiero przyciskiem. Cofnięcie zamyka edycję bez zmiany potwierdzonych ustawień.
10. Pies terapeutyczny jako osobna potrzeba.

## Odłożone — nie blokują szkieletu

Ankieta i jej pytania, szkice odpowiedzi, same odpowiedzi „Niewiedza”, publikacja, głosy i ich uzasadnienia/zmiana, kwalifikacja weryfikatorów, waga recenzji Turysty, punkty, ekonomia nagród, integracja kart i moderacja. Nie implementujemy własnych progów ani naliczania punktów.

## Kontrakt v0.1

Pozostaje propozycją. Przed podłączeniem API trzeba porównać go z aktualnymi źródłami: konto obowiązkowe, status Turysty per miasto, głosy per obserwacja, QR usunięte, sześć motywów, Zapisane miejsca, nawigacja i niezależne statusy publikacji/weryfikacji/punktów. Nie potwierdzono działającego backendu.


## Materiały KindSpot i dostępność — 2026-10-03

Zatwierdzone: KindSpot to nowa nazwa aplikacji, wcześniej USpace. Folder i techniczne identyfikatory nie są zmieniane w ramach analizy.

- Brak pełnego kindspot-instrukcja-dostepnosc.md; dostępne tylko podsumowanie oraz index.html i KindSpot-ankiety.docx. Potrzebny plik lub jego ścieżka do sprawdzenia wszystkich punktów.
- Załączniki są referencją, nie zastępują decyzji: 3 to ocena pośrednia, brak funkcji=0, niewiedza bez oceny jako „Nie mogłem sprawdzić”, godzina opcjonalna wpisywana samodzielnie.
- Jedno pytanie na ekran, zdjęcia, dyktowanie, filtrowany zestaw 24 pytań i badanie B wymagają osobnej decyzji. Ankieta i recenzje nadal odłożone.
- Operator i model publicznego/komercyjnego wdrożenia nieustalone: zakres deklaracji/PJM/ETR oraz licencje ilustracji wymagają ustalenia. Nie zakładamy PJM dla każdego ekranu.
- Przygotowano KindSpot-dostepnosc-checkpoint.md do weryfikacji; to analiza i propozycja, bez deklaracji audytu lub zakończonego wdrożenia.

## Propozycja układu CP-02 — do odbioru

Dolne menu: Zapisane, Nagrody, Mapa pośrodku, Filtry, Profil. Proponowane miejsca dostępne z ekranu głównego. Przy wąskim ekranie lub dużym tekście boczne pozycje układają się w dwie linie, a Mapa pozostaje pośrodku. Ta poprawka nie ustala rankingu okolicy ani zasad zapisanych miejsc. Środkowy przycisk przywraca widok mapy i początek ekranu. Cofnięcie z sekcji, filtrów i ustawień otwieranych z profilu prowadzi na mapę. Cofnięcie niezapisanej edycji potrzeb/filtrów nadal pozostaje otwartym scenariuszem: zmiany zapisuje dopiero przycisk.

CP-01 zaakceptowany przez użytkownika 2026-10-03. CP-02 wymaga osobnego odbioru. Ankieta i tworzenie recenzji nadal odłożone. Nazwa KindSpot jest zatwierdzona w obu plikach źródłowych i uwzględniona w widocznym UI.
## CP-02 — dostępność funkcjonalna, nowy zakres

Zaakceptowana zmiana założeń: końcowy wygląd opracuje później inna osoba; teraz funkcjonalność i dostępność. Kryteria i dowody: KindSpot-CP02-WCAG.md. Nie oznacza to odbioru CP-02.

- Potwierdzona poprawka: stały muted na ciemnej karcie ma tylko 2.73:1–2.74:1. Testy dotychczas badały pary motywu, a nie każdą używaną barwę.
- Do sprawdzenia: pełna semantyka i kolejność, nazwy/stany pól filtrów, fokus i jego widoczność, trwałe błędy i odczyt wyniku, wszystkie ekrany/formularze/dialogi z dużym tekstem i w poziomie, cele dotykowe poza menu.
- Decyzja potrzebna przy poprawianiu niezapisanej edycji: potwierdzenie odrzucenia, szkic czy automatyczne zachowanie? Obecny zapis tylko przyciskiem pozostaje bez zmiany do rozstrzygnięcia.
- Testy TalkBack/Switch Access/klawiatury na Androidzie po ręcznym uruchomieniu urządzenia; VoiceOver przed deklaracją obsługi iOS. Brak środowiska/testu nie jest sukcesem kryterium.
- Pełny kindspot-instrukcja-dostepnosc.md dodano 2026-10-03. Ogólny przegląd A/AA wykonano według W3C; ewentualne dodatkowe zasady z brakującego pliku wymagają wskazania.

## Ankieta PoC — 2026-10-03

Decyzje użytkownika: wznowienie ankiety; 0 nie wlicza się do średniej; „Nie mogłem sprawdzić” zostaje; pole `recommendation` w kontrakcie; tryb spokojny wstępnie przyjęty; nazwa KindSpot we wszystkich tekstach. Dokumenty: KindSpot-ankieta-recenzji.md, KindSpot-mapowanie-pytan.md, KindSpot-kontrakt-propozycje-zmian.md, kindspot-instrukcja-dostepnosc.md.

Pytania otwarte (PoC zastosował propozycję, nie regułę):

1. Odbiór zestawu pytań. PoC używa tylko 12 cech istniejącego katalogu; 13 dodatkowych cech czeka na decyzję.
2. Cechy otoczenia (hałas, tłum, światło) bez opcji „0 – Brak funkcji” — do zatwierdzenia jako atrybut katalogu.
3. Szkic ankiety: PoC trzyma go w pamięci aplikacji, po jednym na miejsce; ginie po zamknięciu aplikacji. Trwały szkic i jego zakres do ustalenia.
4. Pytanie o polecenie miejsca w PoC jest opcjonalne; potwierdzić, czy ma być wymagane.
5. Etykiety potrzeb i „Nie mogłem sprawdzić” mają formy męskie; propozycja form neutralnych płciowo czeka na decyzję.
6. Tryb spokojny: zakres i pole `calmMode`. Zdjęcia w recenzji: decyzja otwarta.
7. Identyfikatory techniczne (pakiety, identyfikator aplikacji, skrypty, infrastruktura) nadal zawierają „uspace” — ewentualna zmiana wymaga osobnej decyzji ze względu na wdrożenie demo.

## Backend z dev (f771626) a ankieta i kontrakt — 2026-10-03

Backend zespołu nie jest jeszcze zgodny z kontraktem v0.1 ani z decyzjami o ankiecie. Frontend nie jest do niego podłączony; ankieta PoC wysyła dane tylko lokalnie. Do uzgodnienia z zespołem backendu:

1. `Answer.rating` w backendzie to obiekt wymiarów 1–5; kontrakt i Teoria aplikacji: liczba 1–5, a dla `absent` ocena 0.
2. Backend odrzuca ocenę przy `absent`; decyzja: „Brak funkcji” = 0, bez wliczania do średniej.
3. Backend wymaga co najmniej jednej odpowiedzi innej niż `unknown`; Teoria aplikacji uznaje to za nieustalone.
4. Brak pola `recommendation` w backendzie.
5. Różne identyfikatory: backend `elevator`, `quiet_environment`, `walking_difficulty`, `no_stairs`, `low_vision`, `crowds`, `simple_text`, `hand_mobility`, `assisted_travel`, `child_stroller`; frontend `lift`, `quiet`, `walking`, `stairs`, `vision`, `crowd`, `reading`, `hands`, `companion`, `child`. Backend ma 5 cech, frontend 12.

- Pełnego kindspot-instrukcja-dostepnosc.md nadal nie otrzymano. Ogólny przegląd A/AA wykonano według W3C; ewentualne dodatkowe zasady z brakującego pliku wymagają wskazania.
## CP-03 — zależności i granice

Użytkownik zlecił przejście do CP-03 i rozdzielenie macierzy, bez odbioru pełnego WCAG. Obecny backend ma jedynie health; rzeczywisty mechanizm uwierzytelnienia, wymagane dane, rejestracja, odnowienie/wygaśnięcie i odzyskanie dostępu nadal wymagają ustalenia. Propozycja email/hasło w kontrakcie nie jest decyzją. Wdrożono wyłącznie lokalny przebieg Test Hackaton, bez haseł. Auto-start jest funkcją testową: po jawnym zamknięciu sesji pozostaje wejście do końca uruchomienia; po restarcie auto-start wraca. Dane demo pozostają na urządzeniu; nie jest to ochrona kont wielu użytkowników.

Braki dostępności przeniesiono do adekwatnych checkpointów i kolumny macierzy. Kontrast opisów kart pozostaje zadaniem CP-06 / wspólnego motywu CP-02; nie został poprawiony w ramach sesji CP-03. Testy ręczne nadal wymagają urządzenia uruchomionego przez użytkownika.


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
## CP-08 — oczekujące doprecyzowanie

Pytanie przekazane użytkownikowi: czy głos demo można cofnąć/zmienić oraz jak traktować 0 dislajków, 0/0 i remisy stosunku lajków do dislajków? Do odpowiedzi głosy w aplikacji pozostają niedostępne; kolejność przykładów nie jest rankingiem najlepszych komentarzy. Nie dopisujemy niezatwierdzonej reguły. Lokalne zgłoszenie jest tylko zapisanym przykładem z powodem, bez wysyłania do moderatora i ukrycia recenzji.

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

Oczekujące: adres działającego backendu; konfiguracja PostgreSQL i sprawdzenie migracji 3 oraz pełnej integracji; formuła progów filtrów dla wielowymiarowych ocen; potwierdzenie flag katalogu (wejście bez skali/toaleta bez wielu obiektów). Przygotowany test E2E wymaga osobnej bazy *_test. Nie uznawać testów bez bazy za odbiór integracji wdrożonej.


## Wspólna społeczność i czytelność ankiety — 2026-10-04

Decyzja użytkownika zastępuje wcześniejszy zamysł Pomocnika: każdy może wyszukiwać miejsca, recenzować i weryfikować niezależnie od potrzeb. Usunięto przełączniki, oznaczenie oraz pole roli z modeli klienta i kontraktu konta API. Historyczna kolumna helper_opt_in w bazie pozostaje nieużywana dla zgodności danych; nie ma znaczenia dla uprawnień. Brak potrzeb nie nadaje osobnej roli. Nazwa obramowania zmieniona na „Wspólna przestrzeń”.

Usunięto powtarzane banery wersji demonstracyjnej z ikoną kolby. Adnotacja konta testowego w profilu pozostaje. Informacje o rzeczywistych ograniczeniach operacji (nieważny kod/testowy operator karty/lokalny zapis) pozostają przy tych operacjach; nie oznacza to wdrożenia produkcyjnego.

Pytania ankiety używają zatwierdzonych SVG cech (12 pytań; aliasy elevator/lift oraz quiet_environment/quiet). Ikona uzupełnia tekst, nie zastępuje etykiety. Kolory wynikają z motywu, ikony dekoracyjne nie powtarzają treści czytnikowi; nagłówek zawija się przy powiększonym tekście. Dane i punktacja ankiety bez zmian.
