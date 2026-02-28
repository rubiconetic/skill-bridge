# install.ps1 — Skill Bridge universal installer for Windows
# One-liner: powershell -c "irm https://raw.githubusercontent.com/rubiconetic/skill-bridge/main/install.ps1 | iex"

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/rubiconetic/skill-bridge.git"
$INSTALL_BASE = "$HOME\.skill-bridge"
$BIN_DIR = "$INSTALL_BASE\bin"
$VERSION = "0.1.0"

function Write-Info($msg) { Write-Host "[install] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[install] $msg" -ForegroundColor Yellow }
function Write-Error-Custom($msg) { Write-Host "[install] $msg" -ForegroundColor Red }

# Header
Write-Host @"
  ____  _will _ _  ____       _     _            
 / ___|| | _(_) ||  _ \ _ __(_) __| | __ _  ___ 
 \___ \| |/ / | || |_) | '__| |/ _\` |/ _\` |/ _ \
  ___) |   <| | ||  _ <| |  | | (_| | (_| |  __/ 
 |____/|_|\_\_|_||_| \_\_|  |_|\__,_|\__, |\___| 
                                     |___/       
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

# 3. Dependencies: jq & qmd
if (!(Test-Path $BIN_DIR)) { New-Item -ItemType Directory -Path $BIN_DIR | Out-Null }

# jq
if (!(Get-Command jq -ErrorAction SilentlyContinue)) {
    Write-Info "Downloading jq..."
    $jqUrl = "https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe"
    Invoke-WebRequest -Uri $jqUrl -OutFile "$BIN_DIR\jq.exe"
}

# qmd
if (!(Get-Command qmd -ErrorAction SilentlyContinue)) {
    Write-Info "Downloading qmd..."
    $qmdUrl = "https://github.com/tobias-walle/qmd/releases/latest/download/qmd-windows-x86_64.exe"
    Invoke-WebRequest -Uri $qmdUrl -OutFile "$BIN_DIR\qmd.exe"
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
