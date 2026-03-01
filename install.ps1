# install.ps1 — Skill Bridge universal installer for Windows
# One-liner: powershell -c "irm https://raw.githubusercontent.com/rubiconetic/skill-bridge/main/install.ps1 | iex"

$ErrorActionPreference = "Stop"

# Enforce TLS 1.2 for GitHub downloads (Fixes "connection was closed unexpectedly" in older PowerShell)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$REPO_URL = "https://github.com/rubiconetic/skill-bridge.git"
$INSTALL_BASE = "$HOME\.skill-bridge"
$BIN_DIR = "$INSTALL_BASE\bin"
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
if (!(Test-Path $BIN_DIR)) { New-Item -ItemType Directory -Path $BIN_DIR | Out-Null }

# jq
if (!(Get-Command jq -ErrorAction SilentlyContinue)) {
    Write-Info "Downloading jq..."
    $jqUrl = "https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe"
    Download-File $jqUrl "$BIN_DIR\jq.exe"
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

# 5. PATH Setup
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$BIN_DIR*") {
    Write-Info "Adding $BIN_DIR to User PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$BIN_DIR", "User")
    Write-Warn "Please restart your terminal for PATH changes to take effect."
}

Write-Host ""
Write-Info "✅ Skill Bridge successfully installed!"
Write-Info "Run 'sb help' to get started (after terminal restart)."
Write-Host ""
