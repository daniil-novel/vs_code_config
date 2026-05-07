param(
    [switch]$SkipExtensions,
    [switch]$ExtensionsOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$codeUserDir = Join-Path $env:APPDATA "Code\User"
$backupDir = Join-Path ([Environment]::GetFolderPath("Desktop")) ("vscode-config-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

function Get-CodeCommand {
    $commands = @(
        "code.cmd",
        "code",
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"),
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code Insiders\bin\code-insiders.cmd")
    )

    foreach ($candidate in $commands) {
        $resolved = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($resolved) {
            return $resolved.Source
        }

        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "VS Code CLI was not found. Install VS Code or add 'code' to PATH."
}

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
New-Item -ItemType Directory -Path $codeUserDir -Force | Out-Null

if (-not $ExtensionsOnly) {
    $snippetsDir = Join-Path $codeUserDir "snippets"
    New-Item -ItemType Directory -Path $snippetsDir -Force | Out-Null

    $filesToBackup = @("settings.json", "keybindings.json")
    foreach ($file in $filesToBackup) {
        $source = Join-Path $codeUserDir $file
        if (Test-Path $source) {
            Copy-Item -LiteralPath $source -Destination (Join-Path $backupDir $file) -Force
        }
    }

    if (Test-Path $snippetsDir) {
        Copy-Item -Path $snippetsDir -Destination (Join-Path $backupDir "snippets") -Recurse -Force
    }

    Copy-Item -LiteralPath (Join-Path $repoRoot "config\settings.json") -Destination (Join-Path $codeUserDir "settings.json") -Force
    Copy-Item -LiteralPath (Join-Path $repoRoot "config\keybindings.json") -Destination (Join-Path $codeUserDir "keybindings.json") -Force
    Copy-Item -Path (Join-Path $repoRoot "snippets\*") -Destination $snippetsDir -Force -ErrorAction SilentlyContinue
}

if (-not $SkipExtensions) {
    $code = Get-CodeCommand
    $extensionsFile = Join-Path $repoRoot "extensions\extensions.txt"
    $extensions = Get-Content $extensionsFile | Where-Object { $_ -and -not $_.StartsWith("#") } | Sort-Object -Unique

    foreach ($extension in $extensions) {
        Write-Host "Installing $extension"
        & $code --install-extension $extension --force
    }
}

Write-Host "Done. Backup: $backupDir"
