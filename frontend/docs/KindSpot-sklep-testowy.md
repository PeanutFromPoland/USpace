# KindSpot — testowy sklep, reset konta i filtry

Zaimplementowano po wznowieniu pracy 2026-10-03 na Frontend, po synchronizacji z dev. Ustalenia użytkownika są zapisane również w Teorii Aplikacji i use-cases. Ten raport zastępuje status niedokończonego sklepu WIP; nie zastępuje odbioru WCAG ani integracji API.

## Działający zakres

Nowy proces aplikacji otwiera Test Hackaton z 1000 testowych punktów, czystymi zakupami i Ogrodem ciszy w Zapisanych. Zachowane są nazwane filtry oraz kolor/ciemny motyw/wysoki kontrast/ograniczenie animacji. Inne dane konta resetują się. Przejście w tło, cofanie, zmiana zakładki lub ponowne wejście do konta w tym procesie nie odnawiają punktów. Hot reload nie jest nowym uruchomieniem; do sprawdzenia resetu zamknij proces i uruchom aplikację ponownie.

Nagrody: Sklep i Moje nagrody; wewnątrz Do odebrania i Historia zakupów. Potwierdzenie zakupu odejmuje saldo, blokuje ponowny zakup danego elementu i zapisuje pozycję w lokalnym portfelu sesji. Anulowanie niczego nie zmienia. Brak punktów blokuje zakup. Realizacja testowa usuwa nagrodę z oczekujących, zachowując historię. Poradnik punktów i mini regulamin są na osobnym ekranie. Stawki zdobywania punktów nie zostały wymyślone; saldo startowe jest testowe. Brak prawdziwego biletu/benefitu lub rozliczenia API.

Filtry: Jak działają filtry na górze; Zapisz filtr otwiera nazwę (1–60 znaków, bez powtórzeń), zapisuje definicję na następne uruchomienia i nie stosuje jej automatycznie. Użyj filtru stosuje bieżący wybór bez zapisu. Zapisany filtr można wczytać do formularza. Błąd zapisu zachowuje wybór i umożliwia ponowienie.

Profil: usunięto osobny baner demo, pozostała adnotacja konta. Awatar/Obramowanie/Tło profilu prowadzą do ekranów przygotowywanej personalizacji. Sesja i usunięcie danych są w Ustawieniach konta. Usunięcie wszystkich lokalnych danych jest osobnym, potwierdzanym działaniem i usuwa także trwałe preferencje oraz nazwane filtry.

Domyślny akcent to pastelowy zielony (#ADD8B4). Dostępne cztery kolory w trybie jasnym/ciemnym oraz wysoki kontrast. Poprzedni zapisany kolor pozostaje zachowany. Kolory interfejsu pochodzą z ColorScheme, zapewniającego odpowiednie zestawienia tekstu i tła.

Ankieta z dev zachowana jako osobny moduł; testuje się jej jawne włączenie przez SurveyBuilder. Domyślny ekran nadal nie otwiera ankiety. Rzeczywiste API pozostaje odłączone.

## Weryfikacja

- flutter analyze: bez uwag.
- flutter test --concurrency=1: 162 testy przeszły.
- Nowe testy: reset między procesami i zachowanie preferencji, brak odnawiania salda wewnątrz sesji, zakup/anulowanie/niewystarczające saldo/powtórny zakup/realizacja/historia, rozdzielenie zapisu i użycia filtru, błędy zapisu i ponowienie, nazwa oraz Enter w dialogu.
- Przebiegi sklepu i poradnika przy tekście 200%, 320×800 oraz 800×360. Cztery palety jasne/ciemne; kontrast także w trybie wysokiego kontrastu. Automatyczne kontrole sklepu: kontrast tekstu, etykiety i cele dotykowe Androida.
- TalkBack, VoiceOver, Switch Access, rzeczywiste urządzenie, iOS i badania użytkowników: niewykonane. Testy automatyczne nie oznaczają pełnej zgodności WCAG.
- Emulatora nie uruchamiano, aplikacji nie instalowano; zmian tej sesji nie commitowano ani nie wysyłano.

## Checklista ręczna

1. Uruchom nowe APK: Test Hackaton, saldo 1000, Ogród ciszy zapisany; nowy profil ma zielony motyw.
2. Anuluj zakup. Saldo nadal 1000. Kup muzeum za 200: saldo 800, pozycja w Moich nagrodach, ponowny zakup zablokowany. Element za 1200 niedostępny.
3. Zrealizuj nagrodę: znika z Do odebrania i pozostaje w historii. Cofnij, przełącz zakładki i wróć z tła: saldo nadal 800.
4. Otwórz poradnik punktów, przeczytaj zasady i wróć. Nie powinien zmienić salda.
5. Użyj filtru bez zapisu i sprawdź wyniki. Zapisz drugi filtr pod nazwą, wczytaj go do formularza i osobno użyj. Sprawdź pustą/powtórzoną nazwę.
6. Zmień dostępność i kolor, usuń Ogród ciszy, dodaj inne miejsce, zmień potrzeby. Zamknij proces aplikacji i uruchom ponownie: saldo 1000, oferta odnowiona, Ogród ciszy wrócił, inne dane konta zresetowane; nazwany filtr i dostępność zostały.
7. Sprawdź Profil: adnotacja przy koncie, trzy wejścia personalizacji i osobne Ustawienia konta. Sprawdź zamknięcie sesji i przycisk Wstecz.
8. Powtórz krytyczne ścieżki przy dużym tekście, poziomej orientacji, wysokim kontraście i z TalkBack. Zapisz faktyczne wyniki w protokole WCAG.
APK debug zbudowano pomyślnie: frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk; 189299930 bajtów, 2026-10-03 23:02:52. Gradle: limit 1536 MB i 2 workery.
