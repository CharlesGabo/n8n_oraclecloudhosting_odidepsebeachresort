[CmdletBinding()]
param(
    [string]$SourceDirectory = (Join-Path $env:USERPROFILE '.n8n'),
    [string]$BackupDirectory = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($BackupDirectory)) {
    $BackupDirectory = Join-Path $PSScriptRoot 'backups'
}

if (-not (Test-Path -LiteralPath $SourceDirectory -PathType Container)) {
    throw "n8n source directory not found: $SourceDirectory"
}

$nodeProcesses = Get-Process -Name node,n8n -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    throw 'A Node.js or n8n process is running. Stop local n8n and other Node.js processes before creating the SQLite backup.'
}

New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')
$archivePath = Join-Path $BackupDirectory "local-n8n-$timestamp.zip"
$checksumPath = "$archivePath.sha256"

Compress-Archive -LiteralPath $SourceDirectory -DestinationPath $archivePath -CompressionLevel Optimal
$hash = Get-FileHash -LiteralPath $archivePath -Algorithm SHA256
"$($hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($archivePath))" |
    Set-Content -LiteralPath $checksumPath -Encoding ascii

$archive = Get-Item -LiteralPath $archivePath
[pscustomobject]@{
    Archive = $archive.FullName
    Bytes = $archive.Length
    Sha256 = $hash.Hash.ToLowerInvariant()
    ChecksumFile = (Get-Item -LiteralPath $checksumPath).FullName
}

Write-Warning 'This backup contains the n8n database, credentials, and encryption configuration.'
Write-Warning 'Keep it private, encrypt it before off-device storage, and never commit it.'
