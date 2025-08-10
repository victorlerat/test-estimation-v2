#requires -Version 5.1

param(
    [switch]$CI
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host $msg -ForegroundColor Green }
function Write-Fail($msg) { Write-Host $msg -ForegroundColor Red }

function Set-Or-Update-KeyInFile($Path, $Key, $Value) {
    if (-not (Test-Path $Path)) {
        $dir = Split-Path -Parent $Path
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        New-Item -ItemType File -Path $Path | Out-Null
    }
    $content = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if (-not $content) { $content = "" }
    $pattern = "(?m)^" + [regex]::Escape($Key) + "=.*$"
    $line = "$Key=$Value"
    if ([regex]::IsMatch($content, $pattern)) {
        $new = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $line })
    } else {
        if ($content -and -not $content.TrimEnd().EndsWith("`n")) { $content += "`r`n" }
        $new = $content + $line + "`r`n"
    }
    Set-Content -LiteralPath $Path -Value $new -NoNewline
}

function Ensure-PhpUnit-AppKey($KeyValue) {
    $phpunitPath = Join-Path $PSScriptRoot "phpunit.xml"
    if (-not (Test-Path $phpunitPath)) { return }
    try {
        [xml]$xml = Get-Content $phpunitPath -Raw
        $phpNode = $xml.phpunit.php
        if (-not $phpNode) {
            $phpNode = $xml.CreateElement('php')
            $xml.phpunit.AppendChild($phpNode) | Out-Null
        }
        $existing = $phpNode.env | Where-Object { $_.name -eq 'APP_KEY' }
        if ($existing) {
            if (-not $existing.value) { $existing.SetAttribute('value', $KeyValue) }
        } else {
            $envNode = $xml.CreateElement('env')
            $envNode.SetAttribute('name','APP_KEY') | Out-Null
            $envNode.SetAttribute('value',$KeyValue) | Out-Null
            $phpNode.AppendChild($envNode) | Out-Null
        }
        $xml.Save($phpunitPath)
    } catch {
        # best effort; ignore if xml parsing fails
    }
}

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Ensure-File($path) {
    $dir = Split-Path -Parent $path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path | Out-Null }
}

function Get-EnvPath() {
    return Join-Path -Path $PSScriptRoot -ChildPath ".env"
}

function Set-Or-Update-Env($Key, $Value) {
    $envPath = Get-EnvPath
    if (-not (Test-Path $envPath)) { throw ".env not found at $envPath" }
    $content = Get-Content $envPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { $content = "" }
    $pattern = "(?m)^(" + [regex]::Escape($Key) + ")=.*$"
    if ($Value -eq $null) { $Value = "" }
    $line = "$Key=$Value"
    if ([regex]::IsMatch($content, $pattern)) {
        $new = [regex]::Replace($content, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $line })
    } else {
        if ($content -and -not $content.TrimEnd().EndsWith("`n")) { $content += "`r`n" }
        $new = $content + $line + "`r`n"
    }
    Set-Content -LiteralPath $envPath -Value $new -NoNewline
}

function Ensure-Env-Placeholder($Key) {
    $envPath = Get-EnvPath
    $content = Get-Content $envPath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { $content = "" }
    $comment = "# TODO: set $Key="
    if ($content -notmatch "(?m)^#\s*TODO:\s*set\s+" + [regex]::Escape($Key) + "=") {
        if ($content -and -not $content.TrimEnd().EndsWith("`n")) { $content += "`r`n" }
        $content += $comment + "`r`n"
        Set-Content -LiteralPath $envPath -Value $content -NoNewline
    }
}

function Get-EnvValue($Key) {
    $envPath = Get-EnvPath
    if (-not (Test-Path $envPath)) { return $null }
    $pattern = "(?m)^$([regex]::Escape($Key))=(.*)$"
    $line = (Select-String -Path $envPath -Pattern $pattern -AllMatches).Matches | Select-Object -First 1
    if ($line) { return $line.Groups[1].Value.Trim() }
    return $null
}

function Prompt-Secret($Label, $EnvKey) {
    Write-Info ("$Label (press Enter to skip)")
    $secure = Read-Host -AsSecureString -Prompt "$EnvKey"
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    }
    if ($plain) {
        Set-Or-Update-Env -Key $EnvKey -Value $plain
        Write-Success ("Saved $EnvKey")
    } else {
        $existing = Get-EnvValue -Key $EnvKey
        if ($existing) {
            Write-Info ("Kept existing $EnvKey")
        } else {
            Ensure-Env-Placeholder -Key $EnvKey
            Write-Info ("Skipped $EnvKey (placeholder added)")
        }
    }
}

# 1) Detect PHP / Composer / npm
Write-Info "Checking prerequisites..."
$hasPhp = Test-Command php
$hasComposer = Test-Command composer
$hasNpm = Test-Command npm
if (-not $hasPhp) { Write-Fail "PHP not found. Please install Laravel Herd and ensure PHP is in PATH."; exit 1 }
if (-not $hasComposer) { Write-Fail "Composer not found. Please install Laravel Herd (Composer bundled) or install Composer separately."; exit 1 }
if (-not $hasNpm) { Write-Info "npm not found. Frontend build will be skipped. You can install Node.js later. Basic Livewire pages still work." }

# 2) Prepare .env
$envExample = Join-Path $PSScriptRoot ".env.example"
$envPath = Get-EnvPath
if (-not (Test-Path $envPath)) {
    Write-Info "Creating .env from .env.example..."
    Copy-Item -Path $envExample -Destination $envPath -Force
}

# Ensure SQLite settings present for local
$desiredDbPath = "./database/database.sqlite"
$existingConn = Get-EnvValue -Key "DB_CONNECTION"
if (-not $existingConn) { Set-Or-Update-Env -Key "DB_CONNECTION" -Value "sqlite" }
Set-Or-Update-Env -Key "DB_DATABASE" -Value $desiredDbPath

# 3) APP_KEY will be generated after Composer install

# 4) Ensure SQLite file
$dbDir = Join-Path $PSScriptRoot "database"
$dbFile = Join-Path $dbDir "database.sqlite"
if (-not (Test-Path $dbDir)) { New-Item -ItemType Directory -Path $dbDir | Out-Null }
if (-not (Test-Path $dbFile)) { Write-Info "Creating SQLite database file..."; New-Item -ItemType File -Path $dbFile | Out-Null }

# 5) Composer install
Write-Info "Installing PHP dependencies (composer install)..."
composer install --no-interaction --prefer-dist | Out-Null

# Generate APP_KEY after dependencies are installed
$appKey = Get-EnvValue -Key "APP_KEY"
if (-not $appKey) {
    Write-Info "Generating APP_KEY..."
    php artisan key:generate --ansi | Out-Null
    # Clear caches to ensure the new key is used
    php artisan optimize:clear | Out-Null
}

# Ensure tests have an APP_KEY as well
$appKey = Get-EnvValue -Key "APP_KEY"
if ($appKey) {
    $envTesting = Join-Path $PSScriptRoot ".env.testing"
    Set-Or-Update-KeyInFile -Path $envTesting -Key "APP_KEY" -Value $appKey
    Ensure-PhpUnit-AppKey -KeyValue $appKey
}

# 6) Node install + build (best-effort)
if ($hasNpm) {
    if (Test-Path (Join-Path $PSScriptRoot "package-lock.json")) {
        Write-Info "Installing Node dependencies (npm ci)..."
        npm ci
    } else {
        Write-Info "Installing Node dependencies (npm install)..."
        npm install
    }
    try {
        Write-Info "Building frontend (npm run build)..."
        npm run build
    } catch {
        Write-Info "Frontend build failed or not required yet. You can retry with 'npm run build' later."
    }
}

# 7) Prompt secrets (skip in CI)
if (-not $CI) {
    Write-Info "Configure optional services (press Enter to skip any):"
    # Mail settings
    $currentMailer = Get-EnvValue -Key "MAIL_MAILER"; if (-not $currentMailer) { Set-Or-Update-Env -Key "MAIL_MAILER" -Value "smtp" }
    $mailPrompts = @(
        @{ Label = "Mail host"; Key = "MAIL_HOST" },
        @{ Label = "Mail port"; Key = "MAIL_PORT" },
        @{ Label = "Mail username"; Key = "MAIL_USERNAME" },
        @{ Label = "Mail password"; Key = "MAIL_PASSWORD" },
        @{ Label = "Mail encryption (tls/ssl)"; Key = "MAIL_ENCRYPTION" },
        @{ Label = "Mail from address"; Key = "MAIL_FROM_ADDRESS" }
    )
    foreach ($p in $mailPrompts) { Prompt-Secret -Label $p.Label -EnvKey $p.Key }

    # Stripe (optional)
    Prompt-Secret -Label "Stripe Secret" -EnvKey "STRIPE_SECRET"
    # OpenAI (optional)
    Prompt-Secret -Label "OpenAI API Key" -EnvKey "OPENAI_API_KEY"
}

# 8) Run migrations
Write-Info "Running database migrations..."
try {
    php artisan migrate --force
} catch {
    Write-Fail "Migrations failed. Check that '$dbFile' exists and is writeable. Try: 'php artisan optimize:clear' then re-run this script."; exit 1
}

# 9) Run tests (skip in CI)
if (-not $CI) {
    Write-Info "Running tests (php artisan test)..."
    try {
        php artisan test
    } catch {
        Write-Fail "Tests failed. Try: 'php artisan optimize:clear' then re-run. You can also run 'php artisan test --stop-on-failure' to debug."; exit 1
    }
}

# 10) Final message
Write-Success "✅ Setup complete"
$projectName = Split-Path $PSScriptRoot -Leaf
$herdUrl = "http://$projectName.test"
Write-Info "Herd serves this project at: $herdUrl"
if (-not $CI) {
    Write-Info "Open that URL in your browser. If it doesn't resolve yet, open the Herd app to ensure DNS is active."
}
