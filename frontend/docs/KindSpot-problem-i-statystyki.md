# Problem i statystyki

Stan na 3 października 2026. Uzasadnienie tezy: osoby z niepełnosprawnościami, osoby neuroróżnorodne i ich bliscy potrzebują wiarygodnych informacji o dostępności miejsc, opartych na doświadczeniach ludzi o podobnych potrzebach. Istniejące narzędzia ich nie dają.

## Kogo to dotyczy

| Fakt | Źródło |
|---|---|
| Prawie co czwarta osoba w wieku 16+ w UE (23,9%) ma niepełnosprawność (2024) | [Eurostat – Population with disability](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Population_with_disability) |
| W Polsce 5,4 mln osób z niepełnosprawnościami, 14,3% ludności (NSP 2021) | [Biuro Pełnomocnika Rządu ds. Osób Niepełnosprawnych](https://niepelnosprawni.gov.pl/baza-wiedzy/niepelnosprawnosc-w-liczbach/dane-demograficzne/) |
| Autyzm: około 1 na 89 dzieci w Europie (projekt ASDEU, według interpelacji w PE) | [Parlament Europejski E-003097/2021](https://www.europarl.europa.eu/doceo/document/E-9-2021-003097_EN.html) |

## Istniejące narzędzia nie dają tych informacji

| Fakt | Źródło |
|---|---|
| Google Maps ma 8 atrybutów dostępności: 5 dla wózków, 3 dla słuchu. Brak atrybutów dla osób niewidomych, hałasu, tłoku, światła i spektrum autyzmu | [Google Business Profile Help](https://support.google.com/business/answer/9049526?hl=en) |
| OpenStreetMap, Polska: 87% restauracji (22 542), 89% gabinetów lekarskich (7 715) i 78% kawiarni (5 839) nie ma żadnej informacji o dostępności dla wózków | taginfo Geofabrik: [restauracje](https://taginfo.geofabrik.de/europe:poland/tags/amenity=restaurant#combinations), [lekarze](https://taginfo.geofabrik.de/europe:poland/tags/amenity=doctors#combinations), [kawiarnie](https://taginfo.geofabrik.de/europe:poland/tags/amenity=cafe#combinations) |
| OpenStreetMap, świat: informację o dostępnej toalecie ma 1,8% restauracji | [taginfo](https://taginfo.openstreetmap.org/tags/amenity=restaurant#combinations) |
| Znacznik `sensory_friendly` ma 141 obiektów na całym świecie | [taginfo](https://taginfo.openstreetmap.org/keys/sensory_friendly) |
| Osoby z niepełnosprawnościami potrzebują wiedzy o dostępności „dostarczanej i weryfikowanej przez osoby z niepełnosprawnościami”; dziś szukają jej w grupach na Facebooku (s. 167–168) | [Raport PFRON 2024](https://www.pfron.org.pl/fileadmin/Badania_i_analizy/2024/2024-08-07_Raport_koncowy/Raport_koncowy_Badanie_potrzeb_ON_w_Polsce_2024.pdf) |

**Metoda dla OpenStreetMap:** na stronie znacznika (np. `amenity=restaurant`) zakładka „Combinations”, wiersz `wheelchair` bez wartości, czyli udział obiektów z jakąkolwiek informacją (`yes`, `limited`, `no`). Udział bez informacji = 100% minus ten procent. Dane zmieniają się codziennie.

## Dostępne w teorii, niedostępne w praktyce

| Fakt | Źródło |
|---|---|
| W ponad 87% skontrolowanych jednostek samorządu (14 z 16) stwierdzono niespełnianie minimalnych warunków dostępności architektonicznej (2026) | [NIK 2026](https://www.nik.gov.pl/aktualnosci/dostepnosc-architektoniczna-cyfrowa-i-informacyjno-komunikacyjna-w-samorzadach.html) |
| 110 ze 121 nowych lub przebudowanych obiektów (90,9%) nie było odpowiednio przygotowanych; nadzór „bezkrytycznie akceptował wadliwe projekty” | [NIK – budynki użyteczności publicznej](https://www.nik.gov.pl/aktualnosci/administracja/nik-o-dostepnosci-budynkow-uzytecznosci-publicznej-dla-niepelnosprawnych.html) |
| Żaden z 94 obiektów w 24 gminach nie był wolny od barier; 63% gmin nie konsultowało zmian z osobami z niepełnosprawnościami i seniorami (2018) | [NIK 2018](https://www.nik.gov.pl/aktualnosci/sprawy-spoleczne/miejsca-powszechnie-dostepne-wciaz-niedostepne.html) |
| Respondenci mówią o „fasadowości” rozwiązań: nieczynne windy, brak klucza, zamknięte toalety (s. 8–9, 155) | [Raport PFRON 2024](https://www.pfron.org.pl/fileadmin/Badania_i_analizy/2024/2024-08-07_Raport_koncowy/Raport_koncowy_Badanie_potrzeb_ON_w_Polsce_2024.pdf) |

## Konsekwencje

| Fakt | Źródło |
|---|---|
| Bariery w przestrzeni publicznej: komunikacyjne 56%, architektoniczne 42,5% (83,6% wśród osób z niepełnosprawnością ruchu), w transporcie 40,8% badanych (s. 153–155) | [Raport PFRON 2024](https://www.pfron.org.pl/fileadmin/Badania_i_analizy/2024/2024-08-07_Raport_koncowy/Raport_koncowy_Badanie_potrzeb_ON_w_Polsce_2024.pdf) |
| 67,4% osób w spektrum autyzmu zgłasza bariery komunikacyjne w przestrzeni publicznej (s. 153) | jw. |
| 51,5% badanych potrzebuje sprzętu lub asystenta, żeby się poruszać (s. 152–153) | jw. |
| We wszystkich krajach UE osoby z niepełnosprawnością rzadziej uczestniczą w kulturze i wydarzeniach sportowych | [Eurostat – leisure and social participation](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Disability_statistics_-_leisure_and_social_participation) |

## Prawo i normy

- [Europejski Akt o Dostępności, dyrektywa 2019/882](https://eur-lex.europa.eu/eli/dir/2019/882/oj) i [Polski Akt o Dostępności, Dz.U. 2024 poz. 731](https://isap.sejm.gov.pl/isap.nsf/download.xsp/WDU20240000731/T/D20240731L.pdf), oba obowiązują od 28 czerwca 2025.
- [Ustawa o zapewnianiu dostępności osobom ze szczególnymi potrzebami (2019)](https://eli.gov.pl/eli/DU/2019/1696/ogl) i [ustawa o dostępności cyfrowej (2019)](https://isap.sejm.gov.pl/isap.nsf/DocDetails.xsp?id=WDU20190000848).
- Normy: [EN 17210:2021](https://www.cencenelec.eu/news-events/news/2021/eninthespotlight/2021-03-18-en-17210-2021-accessible-and-usable-built-environment/) (środowisko zbudowane), EN 301 549 (ICT), [WCAG 2.2](https://www.w3.org/TR/WCAG22/), [ISO 24495-1:2023](https://www.iso.org/standard/78907.html) (prosty język).

Liczby z Eurostatu, NIK i Biura Pełnomocnika potwierdzono dosłownie na stronach źródłowych 3.10.2026; dane PFRON odczytano z pełnego tekstu raportu. Interpelacja w PE nie była dostępna do automatycznego odczytu.
