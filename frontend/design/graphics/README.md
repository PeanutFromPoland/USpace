# KindSpot — poprawione wektory v3

Jeden zestaw dla dowolnego nowego koloru. Ikony: jeden kolor z motywu. Ilustracje: role foreground/accent/accentSoft/surface/outline; kolory techniczne z palette-roles.json zastępuje mapper aplikacji. Nowy akcent nie wymaga ponownego eksportu SVG.

Poprawiono konstrukcję filtrów, znaczenie psa i wejścia, gęste stany nagród, dłonie, ustawienia, marginesy i krąg oddechu. Uzupełniono wszystkie polskie znaczenia manifestu i udokumentowano współdzielenie geometrii. Dodano ilustracje, awatary, ramki, odznaki, miniatury, spokojny ogród, propozycje marki i materiały P3. Marka jest propozycją wizualną, nie zmienia automatycznie launchera telefonu. Dodatkowe materiały nie uruchamiają nowych funkcji produktu.

Statusy zachowują etykiety tekstowe; kolor nie zastępuje informacji. Elementy personalizacji są materiałami, nie automatycznie zdobytymi nagrodami. Bez QR, rzeczywistych biletów, certyfikatów i obowiązkowej animacji. Istotna widoczność grafik zależy od kontrastu motywu.

SVG są edytowalnym źródłem. source/ zawiera generator, oryginalne ikony wejściowe i inventory.json; uruchomienie source/build_corrected.py tworzy poprawiony zestaw w source/kindspot-graphics-corrected; runtime nie wymaga Pythona. Nie redystrybuujemy fontów. Manifest jawnie odróżnia materiał użytkownika od nowych własnych wektorów; informacja użytkownika o prawach do oryginalnego zestawu nie jest niezależną weryfikacją jego pochodzenia.

## Zawartość i użycie

337 SVG: 213 ikon bazowych (39 poprawionych), 55 nowych zasobów i 69 wariantów monochromatycznych/spokojnych. PNG w previews/ to podglądy, nie pliki do zmieniania kolorów. Aplikacja używa SVG z manifestu.

Ramki awatarów mają przezroczysty środek i należy nakładać je nad zdjęciem w Stack. Ilustracje pokazuj w stanach pustych lub pomocniczych, nie zamiast treści. Przy małym rozmiarze używaj ikon 24/32 px, nie całych ilustracji. Dla informacji obowiązuje ikona + tekst. Nowy kolor wdrażaj przez ColorScheme; role techniczne mają zostać w źródłowym SVG.
