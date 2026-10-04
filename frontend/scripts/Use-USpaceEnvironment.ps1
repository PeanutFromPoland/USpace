# Uruchom przez dot-sourcing: . ..\scripts\Use-USpaceEnvironment.ps1
$ErrorActionPreference = 'Stop'
$uspaceToolsRoot = Join-Path $env:USERPROFILE 'develop'
$uspaceFlutterRoot = Join-Path $uspaceToolsRoot 'flutter'
$uspaceAndroidRoot = Join-Path $uspaceToolsRoot 'android-sdk'
$uspaceJavaRoot = Join-Path $uspaceToolsRoot 'android-studio\jbr'
$uspaceGradleRoot = Join-Path $uspaceToolsRoot 'uspace-gradle-cache'
$uspaceLocalConfigPath = Join-Path (Split-Path $PSScriptRoot -Parent) '.dev-tools.local.json'
if (Test-Path -LiteralPath $uspaceLocalConfigPath) {
    $uspaceConfig = Get-Content -LiteralPath $uspaceLocalConfigPath -Raw | ConvertFrom-Json
    $uspaceFlutterRoot = $uspaceConfig.flutterSdk
    $uspaceAndroidRoot = $uspaceConfig.androidSdk
    $uspaceJavaRoot = $uspaceConfig.javaHome
    if ($uspaceConfig.gradleHome) { $uspaceGradleRoot = $uspaceConfig.gradleHome }
}
foreach ($uspaceRequiredFile in @(
    (Join-Path $uspaceFlutterRoot 'bin\flutter.bat'),
    (Join-Path $uspaceAndroidRoot 'cmdline-tools\latest\bin\sdkmanager.bat'),
    (Join-Path $uspaceJavaRoot 'bin\java.exe')
)) {
    if (-not (Test-Path -LiteralPath $uspaceRequiredFile)) {
        throw "Brak narzędzia: $uspaceRequiredFile. Sprawdź frontend/README.md."
    }
}
$env:FLUTTER_ROOT = $uspaceFlutterRoot
$env:ANDROID_HOME = $uspaceAndroidRoot
$env:ANDROID_SDK_ROOT = $uspaceAndroidRoot
$env:JAVA_HOME = $uspaceJavaRoot
$env:GRADLE_USER_HOME = $uspaceGradleRoot
$uspacePathEntries = @(
    (Join-Path $uspaceFlutterRoot 'bin'),
    (Join-Path $uspaceAndroidRoot 'platform-tools'),
    (Join-Path $uspaceAndroidRoot 'emulator'),
    (Join-Path $uspaceAndroidRoot 'cmdline-tools\latest\bin'),
    (Join-Path $uspaceJavaRoot 'bin')
)
$uspaceOptionalBins = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Git\cmd'),
    (Join-Path $env:ProgramFiles 'Git\cmd')
)
$uspacePathEntries += $uspaceOptionalBins | Where-Object { Test-Path -LiteralPath $_ }
$env:PATH = (($uspacePathEntries + ($env:PATH -split ';')) | Select-Object -Unique) -join ';'
