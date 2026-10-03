# KindSpot — ustalenia przed kolejnymi etapami

Aktualizacja: 2026-10-03. Źródła: `Teoria Aplikacji.md` i `use-cases.md`. Ten plik rejestruje pytania, nie ustanawia nowych reguł.

## Obecny zakres zatwierdzony przez użytkownika

Najpierw szkielet i działanie aplikacji. Ankietę wznowiono 2026-10-03 (sekcja na końcu); dalsze procesy recenzji pozostają odłożone. Flutter; komunikacja i interfejs po polsku. Konto obowiązkowe w produkcie; szkielet ma wyraźnie oddzielone konto demonstracyjne, bez rzeczywistego uwierzytelniania. Na polecenie użytkownika z 2026-10-03 konto „Test Hackaton” otwiera się automatycznie na potrzeby testów. Nie jest to zmiana produkcyjnego wymagania konta.

## Pytania do wskazania w plikach źródłowych

1. Ostateczne rozmieszczenie pięciu sekcji i środkowego przycisku mapy. Obecny szkielet pokazuje Zapisane, Nagrody, Mapę, Filtry i Profil. Proponowane miejsca mają osobny dostęp z ekranu miejsc; ranking i promień nie są implementowane.
2. Sposób dodawania/usuwania zapisanych miejsc (UC-18), sortowanie i niedostępne miejsce. Obecnie tylko sekcja informacyjna.
3. Sortowanie po najlepszej ocenie: jaka agregacja? Kierunek sortowania po liczbie recenzji? Brak zatwierdzonej agregacji nie jest zastąpiony średnią wymyśloną przez klienta.
4. Pierwszy filtr, presety, znaczenie progów i skali cech. Obecne reguły i katalog są przykładami PoC. Zapis dotyczy urządzenia, bez synchronizacji z kontem. Wskazanie potrzeb nie powinno automatycznie nadpisywać szczegółowych reguł.
5. Stała kolejność informacji o miejscu i zestaw danych udostępnianych przez API.
6. Mechanizm logowania/rejestracji, sesji, odzyskania konta i API. Adres lokalnego callbacku OAuth przekazany w czacie nie jest kontraktem API; parametry uwierzytelniania nie są utrwalane.
7. Docelowe platformy, identyfikator aplikacji, podpisywanie i operator podkładu mapy. Obecny identyfikator `com.example.uspace` jest wyłącznie demonstracyjny.
8. Lokalizacja urządzenia: uprawnienia i wybór miasta. Obecna wersja ma ręczny wybór, bez pytania o lokalizację.
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
