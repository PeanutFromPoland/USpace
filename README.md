# USpace

Platforma dla osób o szczególnych potrzebach poszukujących miejsca dla siebie w metropoliach.

Repozytorium zawiera szkielet Fluttera, FastAPI oraz środowisko Docker Compose
z PostgreSQL i pgvector. Publiczne demo uruchamia wersję webową Fluttera, a
kod aplikacji pozostaje przeznaczony także dla urządzeń mobilnych. Strona
startowa i API pokazują wyłącznie gotowość infrastruktury; funkcje produktu
powstaną po uzgodnieniu zaktualizowanego kontraktu.

## Lokalnie

1. Skopiuj `.env.example` do `.env` i ustaw własne hasło bazy oraz nazwę
   modelu Ollama.
2. Uruchom `docker compose up --build -d`.
3. Pobierz wybrany model przez `docker compose exec ollama ollama pull <model>`.
4. Sprawdź `http://localhost:8000/health/ready`.
5. W katalogu `frontend` uruchom `flutter create --platforms=web,android
   --project-name=uspace_app .`, następnie `flutter run -d chrome` albo
   uruchom aplikację na urządzeniu Android.

Proces CI/CD, konfiguracja VPS, sekrety i sposób odzyskania wdrożenia są
opisane w [instrukcji infrastruktury](infra/README.md).
