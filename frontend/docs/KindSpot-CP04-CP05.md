# KindSpot — odbiór CP-04 i CP-05

Data: 2026-10-03. Projekt: `D:\Github\USpace\frontend\mobile`. **Stan: demo do weryfikacji użytkownika; nie jest to odbiór pełnego WCAG ani integracji API.** Etapy wykonano równolegle z dodatkowym agentem na wyraźne zlecenie użytkownika. Emulatora nie uruchamiano ani nie restartowano; instalację APK wykonuje użytkownik.

## Ustalenia użytkownika

Najlepsze miejsca: średnia ocen malejąco, przy tej samej średniej liczba recenzji malejąco. Wyższa średnia ma priorytet niezależnie od liczby recenzji innego miejsca. Druga opcja listy: najwięcej recenzji. W happy case okolica obejmuje całe wybrane miasto. Ranking komentarzy według stosunku lajków do dislajków zapisano do CP-08, bez implementacji komentarzy teraz; zero dislajków i relacja z głosami per obserwacja wymagają doprecyzowania.

## CP-04 — wynik

- Mapa i lista korzystają z tych samych wyników miasta, tekstu i filtrów. Pinezka i karta otwierają szczegóły; lista pozwala działać bez mapy.
- Ręczny wybór Krakowa/Warszawy i ustalenie miasta z lokalizacji na żądanie. Android ma tylko uprawnienie przybliżonej lokalizacji, bez śledzenia w tle. Współrzędne nie są zapisane w profilu ani wysyłane do naszego backendu; systemowy geokoder może korzystać z internetu.
- Odmowa, trwała blokada, wyłączona lokalizacja, timeout, brak rozpoznania i inne miasta nie blokują ręcznego wyboru. Demo przyjmuje tylko rozpoznaną nazwę miasta w Polsce; nie zgaduje najbliższego miasta. Ręczny wybór unieważnia późniejszy wynik GPS.
- Błąd zapisu miasta zachowuje wybrane miasto do ponowienia; lista nadal używa potwierdzonego profilu. Mapa ma trwały komunikat błędu, listę zastępczą i ponowienie. Spóźniony błąd poprzedniej próby nie psuje nowej.
- Wynik wyszukiwania ma liveRegion z odroczeniem odczytu o 600 ms ciszy. Czyszczenie tekstu przywraca fokus pola. Polska atrybucja pod mapą pozostaje dostępna przy błędzie, a nieudane otwarcie linku pokazuje adres.
- Proponowane miejsca obejmują całe wybrane miasto, stosują zapisane filtry i kolejność; statystyki są jawnie fikcyjne.

## CP-05 — wynik

- Potrzeby prywatne domyślnie, wybór wielu potrzeb i niezależny Pomocnik. Presety/sugestie cech są opisane jako przykłady demo.
- Trzy ważności: Wymagam (warunek konieczny z opcjonalnym progiem), Preferencja (bez progu), Bez znaczenia. Semantyka wartości/progu zawiera konkretną nazwę cechy.
- Zapis potrzeb/filtrów ma trwały błąd, zachowane wybory i ponowienie także klawiszem Enter. Podczas operacji blokowane są edycja i powtórny zapis. Wyczyść zmienia wyłącznie szkic reguł i includeUnknown; zastosowanie po zapisie.
- Kolejność miejsc ma dwie opcje i zapis na urządzeniu. Błąd nie przestawia potwierdzonej listy; wybór pozostaje do ponowienia. Przy zmianie miasta filtr/sort demo pozostaje zapisany; reguły synchronizacji produktu nadal wymagają decyzji.
- Średnie i liczniki pochodzą z jawnie fikcyjnych pól katalogu demo, a nie wyliczenia ocen cech. Brak średniej/licznika to brak danych, nie zero. Dodatkowe remisy nazwa/ID oraz średnia przy sortowaniu liczbą są techniczną deterministyczną kolejnością demo, do uzgodnienia w API.
- Ranking nie zmienia zbioru wyników ani nie zastępuje statusu dostępności. Nieznane dane nie stają się potwierdzoną dostępnością; znane niespełnienie nadal wyklucza miejsce mimo includeUnknown.

## Weryfikacja

- `flutter analyze`: bez uwag.
- `flutter test --concurrency=1`: **80 testów przeszło** (41 wcześniejszych + 12 CP-04 + 13 mapa/kontrast + 8 formularze + 6 sortowanie).
- `flutter build apk --debug`: sukces, z ograniczeniem Gradle do 1536 MB i 2 workerów. APK: `D:\Github\USpace\frontend\mobile\build\app\outputs\flutter-apk\app-debug.apk`.
- Sprawdzone: priorytet średniej i remisy, nullable statystyki, ten sam zbiór przy zmianie sortu, pamięć po restarcie/błąd zapisu, brak odczytu pozycji po odmowie, brak samoczynnej lokalizacji, ręczny wybór wygrywający z późnym GPS, mapa/lista i wejście w szczegóły, brak wyników, odroczona semantyka, callbacki retry mapy, kontrolki pinezek/zoom ≥48.
- Formularze potrzeb/filtrów oraz pełna ścieżka kontroli odkrywania przy 320 px i tekście 200%. Rzeczywiste kolory opisów/dat kart mają kontrast ≥4,5:1 w sześciu motywach i ich wariantach wyższego kontrastu.
- Niewykonane: rzeczywisty GPS/geokoder, systemowy link/uprawnienia, TalkBack/Switch Access/klawiatura sprzętowa na Androidzie, VoiceOver/iOS i testy z użytkownikami. Testy adaptera i widżetów nie oznaczają sprawdzenia tych integracji na urządzeniu.

## Co sprawdzić na urządzeniu

1. Wybierz Warszawę, przełącz Mapa/Lista i otwórz miejsce — wyniki powinny być spójne, cofnięcie prowadzi na ekran miejsc.
2. Wybierz Użyj lokalizacji telefonu i odmów — pozostaje ręczny wybór miasta. Zgoda działa tylko dla rozpoznanego Krakowa/Warszawy; inne miasta mają jasny komunikat.
3. W filtrach wybierz Na wózku, zmień regułę/prog i zapisz — lista uwzględnia wybór, a brak danych nadal jest oznaczony. Wyczyść bez zapisania nie zmienia potwierdzonych filtrów.
4. Porównaj Najlepszą średnią ocen z Najwięcej recenzji — kolejność może się zmienić, zbiór miejsc pozostaje ten sam. Proponowane miejsca obejmują całe wybrane miasto. Restart pamięta zapisany sort/filtry.
5. Ustaw tekst 200% i przejdź potrzeby → filtry → lista → miejsce; sprawdź osiągalność kontrolek oraz ich nazwy czytnikiem.

Instrukcja instalacji: `../mobile/README.md`. Produkcyjny dostawca mapy i agregaty API, synchronizacja profilu i szkic po cofnięciu nadal otwarte w `DO-USTALENIA.md`. Ankieta i dodawanie recenzji pozostają odłożone. Po odbiorze CP-04/05 następny etap to CP-06: szczegóły i zapisane miejsca, po ustaleniu zasad dodawania/usuwania.
