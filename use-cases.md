# Przypadki użycia

## Spis treści

[Use case 1 - ocenianie](#uc-01)

Aktorzy:
- System
- Turysta
- Mieszkaniec

## UC-01

- Aktorzy: 
- Warunki wstępne: 
- Cel: 

### Scenariusz główny

1. 
2. 

### Scenariusz alternatywny

1. 
2. 
3. 

## DRAFT

Smart City
zniżki za recenzje
CEL: turyści sami sprawdzają, czy miejsca są przystępne dla turystów i za to dostają zniżki do miejsc
dostępność dla niepełnosprawnych (aria labels)
Problemy
Wiarygodność recenzji
Z kodu QR w danym miejscu
AI analizuje patterny
Inni userzy mogą się nawzajem sprawdzać (za punkty)
Zaangażowana grupa docelowa - rodziny osób neuroatypowych
Połączona z krakowską kartą miejską / kartą dużej rodziny
CASE tylko o dostępności dla niepełnosprawnych i rodzin z wózkami
[Safe space + cisza]

USpace - aplikacja przeznaczona dla osób niepełnosprawnych

Lista potencjalnych 

- **Poruszam się na wózku**
- **Mam trudności z chodzeniem**
- **Nie mogę korzystać ze schodów**
- **Jestem niewidomy / słabowidzący**
- **Jestem głuchy / niedosłyszący**
- **Źle znoszę hałas**
- **Źle znoszę tłum**
- **Źle znoszę intensywne światło**
- **Potrzebuję spokojnych miejsc**
- **Mam trudności z orientacją**
- **Mam trudności z czytaniem skomplikowanych informacji**
- **Mam ograniczoną sprawność rąk**
- **Potrzebuję częstych miejsc odpoczynku**
- **Podróżuję z osobą wymagającą pomocy**
- **Podróżuję z dzieckiem / wózkiem dziecięcym**

Aplikacja powinna mieć przyjemne pastelowe kolory np. Pomarańczowy  albo jasnoniebieski

Aplikacja powinna mieć bardzo łatwe do ustawienia filtry ogólne i mocno przystosowane filtry
- Filtry są zapisywane na profilu żeby można było szybko do nich wracać 
- Filtry ogólne mają być bardzo szybkie do ustawienia, wręcz jednym kliknięciem - miejsca dostosowane dla osób na wózku
- Filtry szczegółowe rozdzielają każdy aspekt na 3 elementy
	- Warunek konieczny - Miejsce musi mieć daną cechę i użytkownik doprecyzowuje ile ma ona mieć gwiazdek
	- Preferencja - Element może wystąpić ale nie musi, ilość gwiazdek nie ma znaczena
	- Bez znaczenia - Element nie musi występować

Aplikacja powinna być połączona z OpenStreetMap aby pokazywać lokalizację o których mowa

Profil użytkownika jest prywanty odnośnie jego preferencji. Publiczne są elementy takie jak np.
- Jakieś opcjonalne osiągnięcia profilu potwierdzające jego autentyczność - ,,znany weryfikator"
- ilość weryfikacji i recenzji 
- Nagrody wizualne jakie odebrał - kolorowe pfp itd.

Aplikacja nie musi być offline

Aplikacja ma być na telefon

Aplikacja powinna posiadać konto użytkownika połączone z Kartą Miejską Miasta np. Krakowską z podstawową personalizacją konta w postaci ikon profili itd.

Recenzja w najbardziej podstawowej i szybkiej formie jest krótką ankietą która:
- Jest w formie krótkiej ankiety od 1 do 5 gdzie 1 to źle, 3 to nie mam zdania oraz 5 to idealnie. Istnieje również zaznaczenie że danego elementu nie ma (np. podjazdu dla wózków) lub pominięcia pytania w ankiecie jeśli nie wiem czy dany element był lub nie jestem w stanie go ocenić (czy miejsce jest dostosowane dla niewidomych - nie dam opini kiedy nie jestem niewidomy)
- Można napisać bardziej szczegółową recencję w której można opisać konkretnie każdy z podpunktów uzasadniając swoją opinię - 4 za podjazd dla wózków ponieważ był dobry jednak trochę za stromy. oraz w takiej recenzji wskazać na poszczególne elementy
- Każda recenzja automatycznie uznaje że była pisana w dniu wizyty chyba że użytkownik uzna inaczej
- W przypadku elementów aplikacji które dotyczą cech które mogą wystąpić w różnych miejsach budynku - np drzwi - jest również prośba o doprecyzowanie i dodanie dodatkowego elementu np. drzwi główne 5/5, dalej dopis od użytkownika ,,Drzwi od ulicy białej" 3/5, ,,drzwi od ulicy czarnej " brak udogodnienia
- W recenzji powinna zostać zawarta również godzina i czy była miejsce jest obecnie w naprawie np. ,,Brak podjazdu dla wózków bo go budują", ,,Brak windy bo się zepsuła"

Aplikacja MUSI zawierać system punktowy za recencję TZN:
- Samo napisanie recenzji nie przyznaje punktów - dostaje się je dopiero w momencie gdy zostanie to zweryfikowane przez
	- Boty w aplikacji 
	- Innych użytkowników
	- Moderację
- Inni użytkownicy za moderację również dostają benefity w postaci punktów
- Recenzje nie dostają punktów w zależności od tego czy jest negatywna czy pozytywna a czy jest konstruktywna. 

Proces weryfikacji wygląda następująco
- Najpierw aplikacja w formie bota sama sprawdza czy recenzja wygląda na wiarygodną np. Poprzez styl pisania, długość itd.
- Podejrzane recenzje trafiają do moderacji aplikacji oraz do weryfikacji użytkoników którzy byli w tamtym miejscu lub w miejsach w okolicy
- Istnieje ukryty system repuracji weryfikacji który rośnie za konstruktywne recenzje i sprawdzanie recenzji i spada za popełnianie błędów.
- Nie można weryfikować własnych recenzji

Za punkty w aplikacji można kupować
- Elementy w aplikacji - jakieś obramówki profilu i inne bajery
- Realne nagrody od miasta w którym aplikacja jest wdrożona - np. Bilety na komunikację miejską, bilety do muzeów lub miejsc organizowanych przez miasto
- Punktów nie można przekazywać innym roaz nie można zwracać zakupów

Na porzebny aplikacji zakładamy że API połączenia z kartą miejską zostało udostępnione

Aplikacja MUSI mieć wszelkie udogodonienia ponieważ służy głównie osobą z problemami. Jako cel przyjmujemy WCAG 2.2 AA oraz testy z użytkownikami.