param(
    [string]$Python = 'python',
    [ValidateSet('127.0.0.1', '0.0.0.0')][string]$BindAddress = '127.0.0.1',
    [ValidateRange(1024, 65535)][int]$Port = 8000,
    [switch]$SetupDatabase,
    [switch]$SeedTestAccount,
    [switch]$ResetTestAccount,
    [switch]$Workers
)
$ErrorActionPreference = 'Stop'
if ($ResetTestAccount -and -not $SeedTestAccount) {
    throw 'ResetTestAccount wymaga SeedTestAccount. Reset jest ręcznym działaniem.'
}
foreach ($name in @('POSTGRES_HOST', 'POSTGRES_USER', 'POSTGRES_PASSWORD', 'POSTGRES_DB')) {
    if (-not [Environment]::GetEnvironmentVariable($name)) { throw "Brak zmiennej $name. Skonfiguruj backend bez zapisywania sekretów w repo." }
}
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$backendRoot = Join-Path $repoRoot 'backend'
Push-Location -LiteralPath $backendRoot
try {
    if ($SetupDatabase) {
        & $Python -m uspace_api.bootstrap
        if ($LASTEXITCODE -ne 0) { throw 'Migracja lub dane startowe nie zostały przygotowane.' }
    }
    if ($SeedTestAccount) {
        $previousTestPassword = $env:KINDSPOT_TEST_PASSWORD
        try {
            if (-not $env:KINDSPOT_TEST_PASSWORD) {
                $secret = Read-Host 'Hasło konta testowego (co najmniej 12 znaków)' -AsSecureString
                $buffer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
                try { $env:KINDSPOT_TEST_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($buffer) }
                finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($buffer) }
            }
            if ($ResetTestAccount) { & $Python -m uspace_api.test_account --reset }
            else { & $Python -m uspace_api.test_account }
            if ($LASTEXITCODE -ne 0) { throw 'Przygotowanie konta testowego nie powiodło się.' }
        } finally { $env:KINDSPOT_TEST_PASSWORD = $previousTestPassword }
    }
    $env:USPACE_RUN_WORKERS = if ($Workers) { 'true' } else { 'false' }
    Write-Host "FastAPI: http://$BindAddress`:$Port/api/v1/"
    Write-Host "Dokumentacja tras: http://127.0.0.1:$Port/api/docs"
    & $Python -m uvicorn uspace_api.main:app --host $BindAddress --port $Port
    if ($LASTEXITCODE -ne 0) { throw 'FastAPI zakończył pracę z błędem. Sprawdź konfigurację LLM i bazy.' }
} finally { Pop-Location }
