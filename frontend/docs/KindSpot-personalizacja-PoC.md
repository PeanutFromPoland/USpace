# KindSpot — personalizacja PoC, 2026-10-04

Warstwa działania przygotowana we wspólnym repo D:/Github/USpace. Grafiki, komponenty awatara/tła i theme.dart dostarczył drugi chat. Marker `KindSpot-UI-przekazanie.txt` potwierdza przekazanie api_app.dart/api_forms.dart do końcowej integracji wizualnej. Nie edytowałem SVG, graphics.dart, graphics_catalog.dart, theme.dart, logo ani launchera w ramach tej pracy. Nie uruchamiałem emulatora ani nie budowałem APK; końcową kompilację przejmuje chat integrujący grafiki.

## Działanie

- Sklep grupuje nagrody w Profilowe, Ramka, Motywy aplikacji, Nagrody miejskie oraz Pozostałe nagrody. Cena, uprawnienia i własność pochodzą z API. Historia i Moje nagrody pozostają wspólne z wcześniejszym przepływem.
- Po potwierdzonym zakupie można wybrać Lemura albo Kota jako profilowe. Awatar i obręcz z kokardą są osobnymi warstwami; ramkę można zdjąć. Domyślne profilowe jest ogólne, bez nadawania zakupionego kota/lemura.
- Motywy Odkrywca/Ogrodnik są wybierane z posiadanych kosmetyków; zapis w uiSettings.colorThemeId. Ogrodnik włącza darkMode=true, dając ciemnozielone tło. Użytkownik nadal może zmienić wariant jasny/ciemny, kontrast, skalę tekstu i ograniczenie animacji. Odkrywca nie wymusza zmiany pozostałych ustawień dostępności.
- Wybrane tło profilu korzysta z motywu aplikacji. Root używa KindSpotBackdrop; profile i wybory są na pełnych kartach. MediaQuery otrzymuje również aplikacyjne highContrast. Dekoracje nie zastępują etykiet i nie blokują dotyku.
- Wygląd konta pokazuje kategorie posiadanych elementów i cztery podstawowe bezpłatne kolory. Wybrane elementy są oznaczone i nie można ich ponownie „wyposażyć” tym samym przyciskiem. Przejście do sklepu pozostaje dostępne.
- Mała sekcja Osiągnięcia w profilu pokazuje tytuły potwierdzone przez serwer. Użytkownik wybiera jeden publiczny tytuł albo „Bez publicznego tytułu”. Pusta sekcja nie tworzy nagrody ani nie nazywa użytkownika nową rolą. Prywatne potrzeby nie są upubliczniane przy wyborze tytułu.
- Publiczny profil oraz backendowe review.author.title zawierają wyłącznie wybrany potwierdzony tytuł `{id,label}` albo null. Wyświetlenie tej etykiety przy recenzji przejmuje końcowa integracja wizualna drugiego chatu.

## Katalog i operacje serwera

| Nagroda | Przedmiot | Kategoria | Koszt PoC |
| --- | --- | --- | --- |
| reward_avatar_lemur | avatar_lemur | avatar | 100 pkt |
| reward_avatar_cat | avatar_cat | avatar | 100 pkt |
| reward_frame | frame_bow | frame | 5 pkt (dotychczasowy koszt backendu) |
| reward_theme_explorer | explorer | theme | 100 pkt |
| reward_theme_gardener | gardener | theme | 100 pkt |

Nowe ceny są konfiguracją PoC, nie nową zasadą zdobywania punktów. Nie eksponowano dawnego zestawu wielu awatarów/ramek jako dodatkowych nowych zakupów. Historyczne frame_reward jest nadal akceptowane jako alias tej samej kokardy, ale nowy katalog zwraca frame_bow.

GET /api/v1/rewards i szczegóły nagrody zawierają categoryId, owned i cosmetic; katalog wyposażenia GET /me/cosmetics zawiera tylko elementy domyślne, opłacone kosmetyki i potwierdzone tytuły. POST /me/redemptions rozlicza te pięć kosmetyków od razu w transakcji serwera: fulfilled/charged i jeden wpis reward_purchased. Nie wymagają operatora zewnętrznego ani workera. Pozostałe nagrody zachowują wcześniejsze przetwarzanie. Idempotency-Key zwraca ten sam zakup; drugi klucz nie pozwala ponownie pobrać punktów za posiadany/przetwarzany kosmetyk.

PATCH /me/profile sprawdza własność oraz rodzaj pola: ramki nie można użyć jako avatarId, a niezdobytego tytułu jako titleId. Profil jest blokowany w transakcji na czas zapisu. PUT /me/ui-settings wymaga własności motywów explorer/gardener również przy próbie obejścia przez ustawienia dostępności. Podstawowe kolory i ułatwienia pozostają bezpłatne.

Punkty i wyposażenie nie są nadawane przez klienta. Zamknięcie aplikacji nie resetuje zakupów; nowy kontroler odczytuje wygląd i motyw z serwera. Po potwierdzonym zakupie błąd dodatkowego odświeżenia profilu nie sugeruje ponownego kupowania. Szczegóły nagrody pokazują informację o posiadaniu i przejście do Wyglądu konta.

## Migracja i tytuły

Wymagana jawna migracja **4**: earned_titles (user_id, title_id, label, earned_at). API ma tylko SELECT do tej tabeli, a operator korzysta z roli migracyjnej. Przy okazji uzupełniono brakujące uprawnienia API SELECT/INSERT/DELETE do saved_places; bez nich wcześniejszy zapis miejsc nie działałby na odrębnej roli aplikacyjnej.

Przed próbą z serwerem uruchom `python -m uspace_api.bootstrap` ze skonfigurowaną PostgreSQL/APP_DB_*; polecenie migruje, dodaje nowe syntetyczne nagrody i nadaje uprawnienia. Nie uruchomiono go tutaj z powodu braku skonfigurowanej bazy. Nie zmienia salda ani istniejących zakupów.

Nie ustalono nowych automatycznych progów zdobywania osiągnięć. Tytuł może nadać operator po potwierdzeniu konkretnego osiągnięcia, poleceniem w katalogu backend:

```powershell
python -m uspace_api.grant_title --user-id $accountId --title-id $confirmedTitleId --label $confirmedTitleLabel
```

Zmienne oznaczają konkretny potwierdzony przez operatora wpis, nie przykładową nagrodę za wymyślone działanie. Identyfikator ma postać title_*, etykieta 1–60 znaków, title_default jest zarezerwowany. Powtórzenie nadania tej samej pary konto/tytuł nie tworzy drugiego wpisu i nie przyznaje punktów. Nie nadano żadnego tytułu rzeczywistemu kontu w tej sesji. Test E2E nadaje wyłącznie jawny tytuł testowy na odizolowanej bazie *_test.

Ręczny reset Test Hackaton usuwa zakupy/wyposażenie jak dotychczas. Jeśli aktywny kolor był zakupionym motywem, wraca do podstawowego zielonego; kontrast, tryb jasny/ciemny, skala i ograniczenie animacji pozostają. Nazwane filtry zachowane. Potwierdzone tytuły oraz recenzje/głosy nie są usuwane w resecie portfela, ale publiczny wybór tytułu jest resetowany do title_default.

## Sprawdzenia

- Backend: **39 testów bez PostgreSQL przeszło**, Ruff poprawny. Testy własności, rodzaju pola, tytułu bez potwierdzenia, obejścia motywu, drugiego zakupu i oczekującej realizacji.
- Nowe ekrany: **3 testy widgetowe personalizacji przeszły**. Wybór kota, kokardy, Odkrywcy i Ogrodnika/ciemnego wariantu, wybór potwierdzonego tytułu, odczyt przez nowy kontroler, pusta sekcja przy 320 px i tekście 200%, anulowanie zakupu, saldo z serwera, blokada drugiego zakupu. Ponadto wcześniejsze 3 testy UI integracji przeszły.
- Przygotowany `backend/spec_tests/test_personalization_e2e.py`: zakup/ponowienie/własność/wyposażenie/motyw/tytuł/publiczny profil/trwałość i saldo. **Nie uruchomiono** — PostgreSQL nadal nie jest skonfigurowana. Wymaga chronionej osobnej bazy *_test, nie danych użytkowników.
- **Pełna regresja Flutter: 185 testów przeszło** (`build/personalization-tests-current.log`). Aktualny snapshot obejmuje rejestr341 i nowe komponenty; wcześniejszy przebieg wykonany podczas równoległego zapisu grafik został powtórzony. Analiza całego projektu nie ma błędów ani ostrzeżeń; dwie uwagi curly_braces pozostają w `test/visual_api_graphics_test.dart` (linie80/82), którego autor zadeklarował samodzielną poprawkę. Nie zmieniałem jego testu. Zakres personalizacji nie ma uwag lint.
- Brak testów urządzenia/czytnika/PostgreSQL. Bez emulatora, instalacji, APK, commita/push/reset/stash.

## Pliki do integracji

Backend: uspace_api/personalization.py, grant_title.py, api.py, views.py, db.py, catalog.py, test_account.py; tests/test_personalization.py, spec_tests/test_personalization_e2e.py i dostosowane starsze testy zakupów (kosmetyk jest teraz fulfilled od razu).

Flutter: ui/api_personalization.dart, api_app.dart, api_forms.dart, api_extra.dart, data/product_api.dart i test/personalization_ui_test.dart. Nowe kody błędów ALREADY_OWNED/PURCHASE_PENDING mają komunikaty po polsku. api_app.dart/api_forms.dart przekazane grafikowi; dalsze poprawki wizualne należy zachować.

## Odbiór integracji graficznej
Po przekazaniu ekranów pierwszy chat ukończył ich integrację. Uwagi curly_braces w teście podglądów poprawiono; flutter analyze bez uwag. Pełna regresja po połączeniu: 185 testów poprawnych. Podglądy faktycznych widgetów profilu, wyboru kosmetyków i sklepu zapisano w design/graphics/previews; test podglądów używa danych kontrolowanych, nie rzeczywistej bazy.
