# install.ps1 — Skill Bridge universal installer for Windows
# One-liner: powershell -c "irm https://raw.githubusercontent.com/rubiconetic/skill-bridge/main/install.ps1 | iex"

$ErrorActionPreference = "Stop"

# Enforce TLS 1.2 for GitHub downloads (Fixes "connection was closed unexpectedly" in older PowerShell)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$REPO_URL = "https://github.com/rubiconetic/skill-bridge.git"
$INSTALL_BASE = "$HOME\.skill-bridge"
$BIN_DIR = "$INSTALL_BASE\bin"
# SHIM_DIR is a clean Windows-only directory (no extensionless bash scripts)
# to avoid PowerShell file-association conflicts
$SHIM_DIR = "$HOME\.skillbridge\bin"
$VERSION = "0.1.0"


function Write-Info($msg) { Write-Host "[install] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[install] $msg" -ForegroundColor Yellow }
function Write-Error-Custom($msg) { Write-Host "[install] $msg" -ForegroundColor Red }

# Header
Write-Host @"
   _____ __   _ ________       _     __         
  / ___// /__(_) / / __ )_____(_)___/ /___ ____ 
  \__ \/ //_/ / / / __  / ___/ / __  / __ `/ _ \
 ___/ / ,< / / / / /_/ / /  / / /_/ / /_/ /  __/
/____/_/|_/_/_/_/_____/_/  /_/\__,_/\__, /\___/ 
                                   /____/      
"@ -ForegroundColor Green

Write-Info "Starting Skill Bridge installation v$VERSION..."

# 1. Dependency Check: Git
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Git not found. Please install Git for Windows: https://git-scm.com/download/win"
    exit 1
}

# 2. Bootstrap (Repo check)
if (!(Test-Path "$INSTALL_BASE\.git")) {
    Write-Info "Cloning Skill Bridge to $INSTALL_BASE..."
    if (Test-Path $INSTALL_BASE) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        Write-Warn "Destination $INSTALL_BASE exists but is not a git repo. Renaming..."
        Rename-Item -Path $INSTALL_BASE -NewName "${INSTALL_BASE}_old_$timestamp"
    }
    git clone $REPO_URL $INSTALL_BASE
} else {
    Write-Info "Existing installation found at $INSTALL_BASE. Updating..."
    Set-Location $INSTALL_BASE
    git pull
}

# Download Helper (Uses BITS for robust downloading, falls back to WebClient)
function Download-File($url, $dest) {
    Try {
        Write-Info "Downloading via BITS ($url)..."
        Import-Module BitsTransfer -ErrorAction SilentlyContinue
        Start-BitsTransfer -Source $url -Destination $dest -ErrorAction Stop
    } Catch {
        Write-Warn "BITS transfer failed. Falling back to WebClient..."
        try {
            $client = New-Object System.Net.WebClient
            $client.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
            $client.DownloadFile($url, $dest)
        } catch {
            Write-Error-Custom "All download methods failed. Error: $_"
            exit 1
        }
    }
}

# 3. Dependencies: jq & qmd
if (!(Test-Path $SHIM_DIR)) { New-Item -ItemType Directory -Path $SHIM_DIR | Out-Null }

# jq
if (!(Get-Command jq -ErrorAction SilentlyContinue)) {
    Write-Info "Downloading jq..."
    $jqUrl = "https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe"
    Download-File $jqUrl "$SHIM_DIR\jq.exe"
}

# qmd
if (!(Get-Command qmd -ErrorAction SilentlyContinue)) {
    Write-Info "Installing qmd..."
    if (Get-Command bun -ErrorAction SilentlyContinue) {
        Write-Info "Found bun! Installing via bun..."
        bun install -g @tobilu/qmd
    } elseif (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Info "Found npm. Installing via npm..."
        npm install -g @tobilu/qmd
    } else {
        Write-Error-Custom "Neither bun nor npm were found. Please install Bun (https://bun.sh) or Node.js (https://nodejs.org) and run this script again."
        exit 1
    }
}

# Create sb.cmd wrapper in the clean SHIM_DIR (separate from extensionless bash scripts)
$sbWrapper = "$SHIM_DIR\sb.cmd"
$sbScript  = "$INSTALL_BASE\bin\sb"
Write-Info "Creating sb.cmd wrapper at $sbWrapper..."

# Find bash — prefers Git for Windows, falls back to whatever is on PATH
$bashExe = $null
$candidatePaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe"
)
foreach ($p in $candidatePaths) {
    if (Test-Path $p) { $bashExe = $p; break }
}
if (!$bashExe) {
    $bashCmd = Get-Command bash -ErrorAction SilentlyContinue
    if ($bashCmd) { $bashExe = $bashCmd.Source }
}
if (!$bashExe) {
    Write-Warn "bash not found. 'sb' will not work until Git for Windows is installed."
    $bashExe = "bash"  # best-effort fallback
}

# Convert Windows path to Unix-style for bash
$sbScriptUnix = $sbScript -replace '\\', '/'

$cmdContent = "@echo off`r`n`"$bashExe`" `"$sbScriptUnix`" %*"
[System.IO.File]::WriteAllText($sbWrapper, $cmdContent, [System.Text.Encoding]::ASCII)

# 4. Global Config
$globalConfig = "$HOME\.skillbridge"
if (!(Test-Path $globalConfig)) { New-Item -ItemType Directory -Path $globalConfig | Out-Null }
$configFile = "$globalConfig\config.json"
if (!(Test-Path $configFile)) {
    $configJson = @"
{
  "version": "$VERSION",
  "default_ide": "antigravity",
  "context_max_tokens": 2000
}
"@
    $configJson | Out-File -FilePath $configFile -Encoding utf8
    Write-Info "Created global config at $configFile"
}

# 5. PATH Setup — add SHIM_DIR (clean Windows dir) and bun bin
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $currentPath

# Remove old BIN_DIR from PATH if present (it contains the extensionless sb file)
if ($newPath -like "*$BIN_DIR*") {
    Write-Info "Removing old $BIN_DIR from PATH (replaced by $SHIM_DIR)..."
    $newPath = ($newPath -split ';' | Where-Object { $_ -ne $BIN_DIR }) -join ';'
}

# Add shim dir (contains sb.cmd + jq.exe)
if ($newPath -notlike "*$SHIM_DIR*") {
    Write-Info "Adding $SHIM_DIR to User PATH..."
    $newPath = "$newPath;$SHIM_DIR"
}

# Add bun global bin so qmd is available after restart
$bunBin = "$HOME\.bun\bin"
if ((Test-Path $bunBin) -and ($newPath -notlike "*$bunBin*")) {
    Write-Info "Adding bun bin ($bunBin) to User PATH..."
    $newPath = "$newPath;$bunBin"
}

if ($newPath -ne $currentPath) {
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Warn "Please restart your terminal for PATH changes to take effect."
}

Write-Host ""
Write-Info "✅ Skill Bridge successfully installed!"
Write-Info "Run 'sb help' to get started (after terminal restart)."
Write-Host ""
