# KindSpot — running the app

[Polski](RUNNING.pl.md) · [Project home](../README.md)

This guide covers the mobile app in `frontend/mobile` and the API in `backend`. Commands use repository-relative paths and do not depend on a specific drive, username or computer model. The app interface is currently in Polish.

KindSpot is a Proof of Concept. The main app requires a running API and an account. The server stores accounts, points and purchases. City card integration and redemption of real rewards remain demonstrations. A successful build alone does not verify the entire system on a device.

## 1. Get the project

```sh
git clone https://github.com/PeanutFromPoland/USpace.git
cd USpace
```

If you already have a checkout, open a terminal at its root. Use a branch containing the current mobile frontend and backend. Do not force a branch switch with unsaved changes. The historical repository name and `uspace` package name are intentional.

## 2. Set up your tools

For Android, you need:

- Git and the [Flutter SDK](https://docs.flutter.dev/install) on your `PATH`. The project was checked with Flutter **3.47.6**; `pubspec.yaml` requires Dart **>=3.13.5 and <4.0.0**, bundled with Flutter.
- Android SDK tools and a compatible JDK, for example through Android Studio. Follow the [Flutter Android setup guide](https://docs.flutter.dev/platform-integration/android/setup).
- An Android phone with USB debugging enabled, or an emulator that you start yourself. Choose an emulator image matching your computer architecture and allocate resources suitable for your hardware.
- Internet access to download dependencies and map tiles.

Check your setup:

```sh
flutter --version
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

Fix the issues reported for your target platform before building. Android development does not require configuring every other platform.

**Windows — optional team environment script.** If you use `frontend/scripts/Use-USpaceEnvironment.ps1`, configure your own directories in the ignored `frontend/.dev-tools.local.json` file (`flutterSdk`, `androidSdk`, `javaHome`, optionally `gradleHome`). From `frontend/mobile`, run:

```powershell
. ../scripts/Use-USpaceEnvironment.ps1
```

The script does not install tools and defaults to the team's local directory layout. It is unnecessary with a standard Flutter installation on `PATH`. Do not commit local tool paths.

## 3. Choose a backend

### A. An existing team server

Get the API URL, such as `https://your-server.example/api/v1/`, and account credentials or confirmation that registration is available. Continue to step 4. You do not need Docker, Python or a local database for this option.

### B. Your own backend with Docker Compose

Install [Docker with Compose](https://docs.docker.com/compose/install/) and start Docker Engine. Run the following commands at the repository root.

Copy `.env.example` to `.env`:

```powershell
# Windows PowerShell
Copy-Item .env.example .env
```

```sh
# macOS / Linux
cp .env.example .env
```

If `.env` already exists, update it instead of overwriting it. Set your own distinct `POSTGRES_PASSWORD` and `APP_DB_PASSWORD` values. Keep `POSTGRES_USER` and `APP_DB_USER` as separate roles. Set `OLLAMA_MODEL`; keep this model name nonempty even if you initially only test login and the map. The default `USE_CHATGPT_API=false` does not require an OpenAI key. Do not commit `.env`.

```sh
docker compose up -d --build api
docker compose ps -a
docker compose logs --tail=100 migrate api
```

Compose starts PostgreSQL with pgvector, runs `uspace_api.bootstrap` (current migrations, sample data and API role permissions), then starts the API. Do not create tables manually. The migration version depends on the checked-out code. When upgrading an existing installation, run explicitly:

```sh
docker compose build migrate api
docker compose run --rm migrate
docker compose up -d api
```

Open these URLs in a browser:

- `http://localhost:8000/health/ready` — expect HTTP 200 and an `ok` status;
- `http://localhost:8000/api/docs` — API documentation.

`/health/live` alone does not confirm database connectivity. If `/health/ready` returns 503, inspect database and migration logs.

**Model for checking text reviews — optional during initial setup.** Login, place browsing and the profile do not require downloading a model. To enable text review classification through Ollama:

```sh
docker compose up -d ollama
docker compose exec ollama ollama pull MODEL_NAME
```

Replace `MODEL_NAME` with the `OLLAMA_MODEL` value from `.env`, choosing a model suitable for your hardware. Without a working model, a text review may remain pending verification; this does not award points. See the [infrastructure guide](../infra/README.md) for the OpenAI option and public deployment.

**Optional Test Hackaton account.** You can register a regular account through the app. To demonstrate the test wallet, prepare a separate synthetic account:

```sh
docker compose run --rm --no-deps -e KINDSPOT_TEST_PASSWORD="REPLACE_WITH_YOUR_TEST_PASSWORD" migrate python -m uspace_api.test_account
```

Replace the value with your own password of at least 12 characters. Login: `hackaton@example.invalid`. There is no default password. Initial preparation gives this account 1000 test points and a saved Ogród ciszy place; restarting the app does not reset them. Do not add `--reset` for normal startup: it is a separate operation that resets the test account's wallet and purchases.

## 4. Run the Android app

In a second terminal, starting at the repository root:

```sh
cd frontend/mobile
flutter pub get
flutter devices
```

Replace `DEVICE_ID` below with the Android device identifier reported by `flutter devices`.

### HTTPS server

```sh
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=https://your-server.example/api/v1/
```

### Local backend and Android Emulator

```sh
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=http://10.0.2.2:8000/api/v1/ --dart-define=KINDSPOT_LOCAL_HTTP=true
```

`10.0.2.2` refers to the host computer in the standard Android Emulator. `localhost` inside an emulator refers to the emulator itself. Other emulator environments may use different addresses; for local debugging, you can use the ADB forwarding option below instead.

### Local backend and a phone over USB

Docker Compose exposes the API at `127.0.0.1:8000` on the computer. Connect your phone, authorize USB debugging and forward the port:

```sh
adb -s DEVICE_ID reverse tcp:8000 tcp:8000
flutter run -d DEVICE_ID --dart-define=KINDSPOT_API_URL=http://127.0.0.1:8000/api/v1/ --dart-define=KINDSPOT_LOCAL_HTTP=true
```

`adb` is provided by Android SDK Platform-Tools and must be on `PATH`. You may need to repeat the forwarding command after reconnecting your phone. Local HTTP is allowed only in debug builds and for hosts explicitly accepted by the client. A computer's plain HTTP Wi-Fi address is currently rejected; use USB/ADB or an HTTPS server on a phone.

You can also run `flutter run -d DEVICE_ID` and enter the URL on the “Połącz KindSpot” screen. For local HTTP, enable “Lokalny backend HTTP”. The URL must end in `/api/v1/`.

Three introduction slides appear on first launch. You can skip them or navigate manually. Then connect to the API and sign in or register. The test account is not signed in automatically.

## 5. Build an APK and run tests

From `frontend/mobile`:

```sh
flutter analyze
flutter test --concurrency=1
flutter build apk --debug
```

The APK is at `frontend/mobile/build/app/outputs/flutter-apk/app-debug.apk`, relative to the repository root. It is generated locally, ignored by Git and not automatically included in a clone. You can enter the API URL after launch; `--dart-define` options are also optional when building. This is a testing package, not an app store release.

Install it from `frontend/mobile`:

```sh
adb -s DEVICE_ID install -r build/app/outputs/flutter-apk/app-debug.apk
```

A phone connecting to a local backend still needs `adb reverse`. Flutter tests do not require a running emulator. For backend tests without a database, install Python >=3.12 and run from the repository root:

```sh
cd backend
python -m venv .venv
```

Activate the environment: Windows PowerShell `.venv\Scripts\Activate.ps1`, macOS/Linux `source .venv/bin/activate`. Then run:

```sh
python -m pip install -e ".[dev]"
python -m pytest
```

PostgreSQL integration tests have a separate [guide](../backend/spec_tests/README.md). Do not run them against a database containing user data.

## 6. Other platforms and stopping services

iOS requires macOS, Xcode and signing configuration; it has not yet been verified on a device. The web scaffold directly in `frontend/` is a separate module and does not replace the mobile project in `frontend/mobile`. This guide covers the Android + API development path, not guaranteed support for every platform.

Stop the backend from the repository root:

```sh
docker compose stop
```

This preserves data in volumes. Do not use `docker compose down -v` if you want to keep accounts and purchases.

## Troubleshooting

| Problem | What to check |
| --- | --- |
| `flutter` is missing or Dart is too old | Flutter SDK on `PATH`, `flutter --version`, and the constraint in `pubspec.yaml`. |
| No device detected | USB debugging, phone authorization, a Windows USB driver or a manually started emulator; `flutter devices`. |
| SDK/JDK/license error | `flutter doctor -v`, Android SDK Manager and `flutter doctor --android-licenses`. Do not copy someone else's `local.properties`. |
| Invalid API URL | `/api/v1/` suffix, HTTPS or debug-only local HTTP. |
| Connection refused | `docker compose ps -a`, API readiness, emulator host address or `adb reverse`. |
| API is running but the database is not ready | `docker compose logs --tail=100 db migrate api`; credentials, roles and successful migrations. Editing a password in `.env` does not automatically change the password in an existing PostgreSQL volume. |
| Review is pending verification | Worker process, API logs and availability of the configured model. |
| No test points | Regular registration does not prepare Test Hackaton; use the dedicated account preparation command. |
| Build runs out of disk space or memory | Close unnecessary programs or use a phone instead of an emulator; avoid changing project files for one computer. |

Do not commit passwords, `.env`, local SDK settings or `build`/`.dart_tool` directories. This guide was checked against the source code and Compose configuration; it does not replace a complete clean-machine installation test or an accessibility audit.
