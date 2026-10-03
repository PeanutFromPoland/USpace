# Uruchamianie emulatora KindSpot z niezmiennymi limitami zasobów.
[CmdletBinding()]
param(
    [switch]$Restart,
    [switch]$Preview
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Use-USpaceEnvironment.ps1')
$uspaceEmulatorExe = Join-Path $env:ANDROID_HOME 'emulator\emulator.exe'
$uspaceAdbExe = Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe'
$uspaceEmulatorArgs = '-avd USpace_API_36 -port 5554 -memory 1536 -cores 1 -no-snapshot -no-boot-anim -no-audio -gpu auto'

if (-not (Test-Path -LiteralPath $uspaceEmulatorExe)) {
    throw "Brak emulatora: $uspaceEmulatorExe"
}
if ($Preview) {
    Write-Output "Emulator: $uspaceEmulatorExe"
    Write-Output "Parametry: $uspaceEmulatorArgs"
    Write-Output 'Priorytet Windows: BelowNormal. Tryb podglądu — emulator nie został uruchomiony.'
    return
}

function Get-USpaceEmulatorProcesses {
    Get-CimInstance Win32_Process | Where-Object {
        $_.Name -match '^(emulator|qemu-system-x86_64(?:-headless)?)\.exe$' -and
        $_.CommandLine -match '(?:^|\s)-avd\s+"?USpace_API_36"?(?:\s|$)'
    }
}

$uspaceExisting = @(Get-USpaceEmulatorProcesses)
if ($uspaceExisting.Count -gt 0) {
    if (-not $Restart) {
        throw 'Emulator KindSpot już działa. Aby uruchomić go ponownie z limitami, użyj: ..\scripts\Start-USpaceEmulator.ps1 -Restart. Nie uruchomiono drugiej instancji.'
    }
    if (-not ($uspaceExisting | Where-Object { $_.CommandLine -match '(?:^|\s)-port\s+5554(?:\s|$)' })) {
        throw 'Istniejący emulator KindSpot ma inny port. Zamknij jego okno, a następnie ponów komendę. Nie zatrzymano innego urządzenia.'
    }
    Write-Host 'Zamykam poprzednią instancję KindSpot...'
    & $uspaceAdbExe -s emulator-5554 emu kill
    if ($LASTEXITCODE -ne 0) {
        throw 'Nie udało się zamknąć poprzedniej instancji. Zamknij jej okno i ponów komendę.'
    }
    $uspaceShutdownDeadline = [DateTime]::UtcNow.AddSeconds(25)
    while (@(Get-USpaceEmulatorProcesses).Count -gt 0) {
        if ([DateTime]::UtcNow -gt $uspaceShutdownDeadline) {
            throw 'Poprzedni emulator nadal się zamyka. Poczekaj na zamknięcie jego okna i ponów komendę.'
        }
        Start-Sleep -Milliseconds 500
    }
}

Write-Host 'Uruchamiam KindSpot: 1 vCPU, 1536 MB RAM Androida, bez snapshotów.'
$uspaceEmulatorProcess = Start-Process -FilePath $uspaceEmulatorExe `
    -ArgumentList $uspaceEmulatorArgs -WindowStyle Normal -PassThru
try {
    $uspaceEmulatorProcess.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
} catch {
    Write-Warning 'Nie udało się obniżyć priorytetu launchera; limity Androida nadal są ustawione.'
}

# Emulator uruchamia QEMU jako osobny proces; obniż jego priorytet również.
$uspaceChildDeadline = [DateTime]::UtcNow.AddSeconds(8)
$uspaceQemuFound = $false
while (-not $uspaceQemuFound -and [DateTime]::UtcNow -lt $uspaceChildDeadline) {
    foreach ($uspaceChild in @(Get-USpaceEmulatorProcesses | Where-Object {
        $_.Name -like 'qemu-*' -and $_.CommandLine -match '(?:^|\s)-port\s+5554(?:\s|$)'
    })) {
        try {
            $uspaceChildProcess = Get-Process -Id $uspaceChild.ProcessId
            $uspaceChildProcess.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::BelowNormal
            $uspaceQemuFound = $true
        } catch {
            Write-Warning 'Nie udało się obniżyć priorytetu QEMU; limity Androida nadal są ustawione.'
            $uspaceQemuFound = $true
        }
    }
    if (-not $uspaceQemuFound) { Start-Sleep -Milliseconds 500 }
}
if (-not $uspaceQemuFound) {
    Write-Warning 'Nie wykryto procesu QEMU. Sprawdź okno emulatora; nie uruchamiaj kolejnej instancji.'
}
Write-Host 'Poczekaj na pulpit Androida, następnie zainstaluj APK i otwórz demo zgodnie z README.'
