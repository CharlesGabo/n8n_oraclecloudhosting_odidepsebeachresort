[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Destination,

    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?$')]
    [string]$Domain,

    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string]$N8nVersion,

    [Parameter(Mandatory)]
    [ValidatePattern('^[^@\s]+@[^@\s]+\.[^@\s]+$')]
    [string]$AcmeEmail,

    [string]$Timezone = 'Asia/Manila'
)

$ErrorActionPreference = 'Stop'
$sourceRoot = $PSScriptRoot

if ($Domain -notmatch '\.') {
    throw 'Domain must be a fully qualified hostname, such as n8n.example.com.'
}

$destinationPath = [IO.Path]::GetFullPath($Destination)
$sourcePath = [IO.Path]::GetFullPath($sourceRoot)
if ($destinationPath.TrimEnd('\') -eq $sourcePath.TrimEnd('\')) {
    throw 'Destination must be a different directory from the template source.'
}

if (Test-Path -LiteralPath $destinationPath) {
    $existing = @(Get-ChildItem -LiteralPath $destinationPath -Force)
    if ($existing.Count -gt 0) {
        throw "Destination is not empty; refusing to overwrite files: $destinationPath"
    }
} else {
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
}

$copyFiles = @(
    '.gitattributes',
    '.gitignore',
    'AGENTS.md',
    'Caddyfile',
    'DEPLOYMENT_PLAN.md',
    'docker-compose.yml',
    'keepalive.sh',
    'setup-vm.sh',
    'verify-deployment.sh',
    'backup-n8n.sh',
    'restore-n8n.sh',
    'backup-local-n8n.ps1'
)

foreach ($file in $copyFiles) {
    $sourceFile = Join-Path $sourceRoot $file
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Required template source file is missing: $sourceFile"
    }
    Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $destinationPath $file)
}

Copy-Item -LiteralPath (Join-Path $sourceRoot 'templates\MIGRATION_INVENTORY.md') `
    -Destination (Join-Path $destinationPath 'MIGRATION_INVENTORY.md')

$envTemplate = @"
# Copy this file to .env on the OCI VM. Never commit the populated .env file.
N8N_DOMAIN=$Domain
ACME_EMAIL=$AcmeEmail

# Match the source n8n version first; upgrade only after the migration is verified.
N8N_VERSION=$N8nVersion
CADDY_VERSION=2-alpine

# Generate once on the VM: openssl rand -hex 32
# Preserve this value in encrypted/off-host backups.
N8N_ENCRYPTION_KEY=replace-with-a-long-random-secret

GENERIC_TIMEZONE=$Timezone
EXECUTIONS_DATA_MAX_AGE=336
"@
Set-Content -LiteralPath (Join-Path $destinationPath '.env.example') `
    -Value $envTemplate -Encoding utf8

foreach ($relativePath in @('AGENTS.md', 'DEPLOYMENT_PLAN.md')) {
    $target = Join-Path $destinationPath $relativePath
    $content = Get-Content -Raw -LiteralPath $target
    $content = $content.Replace('n8n.example.com', $Domain)
    Set-Content -LiteralPath $target -Value $content -Encoding utf8
}

New-Item -ItemType Directory -Path (Join-Path $destinationPath 'backups') | Out-Null
New-Item -ItemType Directory -Path (Join-Path $destinationPath 'exports\workflows') | Out-Null

[pscustomobject]@{
    ProjectDirectory = $destinationPath
    Domain = $Domain
    N8nVersion = $N8nVersion
    Timezone = $Timezone
    FilesCreated = $copyFiles.Count + 2
}

Write-Host 'Template created. Complete MIGRATION_INVENTORY.md before provisioning OCI.'
Write-Host 'Do not copy .env.example to .env until you are on the target VM.'
