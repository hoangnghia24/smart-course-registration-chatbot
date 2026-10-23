
# scripts/load-env.ps1
# Load environment variables from .env

$ErrorActionPreference = "Stop"

# Locate .env in server directory or repository root
$serverDir = Split-Path -Parent $PSScriptRoot
$repoDir = Split-Path -Parent $serverDir

$envFile = Join-Path $serverDir ".env"

if (-not (Test-Path -LiteralPath $envFile)) {
    $envFile = Join-Path $repoDir ".env"
}

if (-not (Test-Path -LiteralPath $envFile)) {
    throw "Cannot find .env. Create it from .env.example first."
}

Write-Host "Loading environment from $envFile"

foreach ($line in Get-Content -LiteralPath $envFile -Encoding UTF8) {
    $line = $line.Trim()

    # Ignore empty lines and comments
    if (-not $line -or $line.StartsWith("#")) {
        continue
    }

    # Parse KEY=VALUE
    if ($line -match '^([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)$') {
        $name = $matches[1]
        $value = $matches[2].Trim()

        # Remove surrounding quotes
        if ($value.Length -ge 2) {
            if (
                ($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))
            ) {
                $value = $value.Substring(1, $value.Length - 2)
            }
        }

        [Environment]::SetEnvironmentVariable(
            $name,
            $value,
            "Process"
        )

        Write-Host "Loaded: $name"
    }
}

# Use PostgreSQL password for Serverpod if not separately set
if (-not $env:SERVERPOD_PASSWORD_database -and $env:POSTGRES_PASSWORD) {
    $env:SERVERPOD_PASSWORD_database = $env:POSTGRES_PASSWORD
    Write-Host "Loaded: SERVERPOD_PASSWORD_database"
}

Write-Host "Environment loaded successfully."
