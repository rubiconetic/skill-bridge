#!/usr/bin/env bash

# install.sh — Skill Bridge universal installer
# Supports: Linux, macOS (Intel/Silicon)
# One-liner: curl -fsSL https://raw.githubusercontent.com/rubiconetic/skill-bridge/main/install.sh | bash

set -euo pipefail

# Constants
REPO_URL="https://github.com/rubiconetic/skill-bridge.git"
INSTALL_BASE="$HOME/.skill-bridge"
BIN_DIR="$INSTALL_BASE/bin"
SKILLS_DIR="$INSTALL_BASE/skills"
VERSION="0.1.0"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[install]${NC} $1"; }
warn()  { echo -e "${YELLOW}[install]${NC} $1"; }
error() { echo -e "${RED}[install]${NC} $1" >&2; }

# Dependency installation functions
install_jq() {
    if ! command -v jq &>/dev/null; then
        info "Installing jq..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y jq
            elif command -v yum &>/dev/null; then
                sudo yum install -y jq
            else
                warn "Unsupported Linux distro for auto-jq. Please install manually."
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v brew &>/dev/null; then
                brew install jq
            else
                warn "Homebrew not found. Please install jq manually."
            fi
        fi
    fi
}

install_qmd() {
    if ! command -v qmd &>/dev/null; then
        info "Installing qmd..."
        local arch
        arch=$(uname -m)
        local os="linux"
        [[ "$OSTYPE" == "darwin"* ]] && os="macos"
        
        # Determine binary name based on OS/Arch
        # This assumes a release naming pattern on GitHub
        local release_url="https://github.com/tobias-walle/qmd/releases/latest/download/qmd-${os}-${arch}"
        
        mkdir -p "$BIN_DIR"
        if curl -fsSL "$release_url" -o "$BIN_DIR/qmd"; then
            chmod +x "$BIN_DIR/qmd"
            info "qmd installed to $BIN_DIR"
        else
            error "Failed to download qmd. Please install it manually from https://github.com/tobias-walle/qmd"
        fi
    fi
}

# PATH management
setup_path() {
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi

    # Pick an install dir for the symlink that is on the PATH
    local user_bin="$HOME/.local/bin"
    if [[ -w "/usr/local/bin" ]]; then
        user_bin="/usr/local/bin"
    fi
    mkdir -p "$user_bin"

    if [[ ":$PATH:" != *":$user_bin:"* ]]; then
        info "Adding $user_bin to PATH in $shell_config"
        echo "export PATH=\"\$PATH:$user_bin\"" >> "$shell_config"
        warn "Please restart your shell or run: source $shell_config"
    fi
    
    # Create symlink in the user_bin directory
    ln -sf "$INSTALL_BASE/bin/sb" "$user_bin/sb"
    info "Symlinked: $user_bin/sb -> $INSTALL_BASE/bin/sb"

    # Also add current session path for immediate use
    export PATH="$PATH:$user_bin"
}

main() {
    echo -e "${GREEN}"
    echo "  ____  _will _ _  ____       _     _            "
    echo " / ___|| | _(_) ||  _ \ _ __(_) __| | __ _  ___ "
    echo " \___ \| |/ / | || |_) | '__| |/ _\` |/ _\` |/ _ \\"
    echo "  ___) |   <| | ||  _ <| |  | | (_| | (_| |  __/"
    echo " |____/|_|\_\_|_||_| \_\_|  |_|\__,_|\__, |\___|"
    echo "                                     |___/       "
    echo -e "${NC}"
    info "Starting Skill Bridge installation v${VERSION}..."

    # 1. Handle Bootstrap (Repo check)
    if [[ ! -d "$INSTALL_BASE/.git" ]]; then
        info "Cloning Skill Bridge to $INSTALL_BASE..."
        if [[ -d "$INSTALL_BASE" ]]; then
            warn "Destination $INSTALL_BASE exists but is not a git repo. Moving items..."
            mv "$INSTALL_BASE" "${INSTALL_BASE}_old_$(date +%s)"
        fi
        git clone "$REPO_URL" "$INSTALL_BASE"
    else
        info "Existing installation found at $INSTALL_BASE. Updating..."
        cd "$INSTALL_BASE" && git pull
    fi

    # 2. Dependencies
    install_jq
    install_qmd

    # 3. Core Setup
    chmod +x "$INSTALL_BASE/bin/sb"
    find "$INSTALL_BASE/src" -name "*.sh" -exec chmod +x {} \;

    # 4. Global Config
    local global_config="$HOME/.skillbridge"
    mkdir -p "$global_config"
    if [[ ! -f "$global_config/config.json" ]]; then
        cat > "$global_config/config.json" <<JSON
{
  "version": "${VERSION}",
  "default_ide": "antigravity",
  "context_max_tokens": 2000
}
JSON
        info "Created global config at $global_config/config.json"
    fi

    # 5. Global Skills Indexing
    info "Initializing global skills..."
    # Run from the install base to ensure dependencies are found
    (cd "$INSTALL_BASE" && ./bin/sb skill index --global)

    # 6. PATH & Symlinks
    setup_path

    echo ""
    info "✅ Skill Bridge successfully installed!"
    info "Run 'sb help' to get started."
    echo ""
}

main "$@"
