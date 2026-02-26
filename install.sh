#!/usr/bin/env bash

# install.sh — Skill Bridge global installer
# Symlinks `sb` into /usr/local/bin (or ~/bin) and sets up ~/.skillbridge

set -euo pipefail

SB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[install]${NC} $1"; }
warn()  { echo -e "${YELLOW}[install]${NC} $1"; }
error() { echo -e "${RED}[install]${NC} $1" >&2; }

# Pick the best install dir on the user's PATH
pick_install_dir() {
    if [[ -d "$HOME/.local/bin" ]]; then
        echo "$HOME/.local/bin"
    elif [[ -d "$HOME/bin" ]]; then
        echo "$HOME/bin"
    elif [[ -w "/usr/local/bin" ]]; then
        echo "/usr/local/bin"
    else
        # Create ~/.local/bin and add to PATH note
        mkdir -p "$HOME/.local/bin"
        echo "$HOME/.local/bin"
    fi
}

install_global_skills() {
    local global_dir="$HOME/.skillbridge"
    local skills_dest="$global_dir/skills"
    local collection="sb-global"

    info "Saving skills globally to $skills_dest"
    mkdir -p "$skills_dest"
    cp -a "$SB_DIR/skills/"* "$skills_dest/" 2>/dev/null || true

    info "Indexing global skills with QMD (collection: ${collection})"
    if qmd collection list 2>/dev/null | grep -q "^${collection}"; then
        warn "QMD collection '${collection}' already exists — re-indexing."
        qmd collection remove "${collection}" 2>/dev/null || true
    fi

    qmd collection add "${skills_dest}" \
        --name "${collection}" \
        --mask "**/*.md"
    
    info "Running QMD embedding pass for global skills..."
    qmd embed
    info "Global skills indexed successfully ✔"
}

main() {
    echo ""
    info "Installing Skill Bridge from: $SB_DIR"

    # Verify required binaries
    for dep in jq qmd; do
        if ! command -v "$dep" &>/dev/null; then
            error "Required binary not found: $dep. Please install it first."
            exit 1
        fi
    done

    local install_dir
    install_dir="$(pick_install_dir)"

    # Symlink `sb`
    local target="${install_dir}/sb"
    if [[ -L "$target" ]]; then
        warn "Removing existing symlink at $target"
        rm "$target"
    fi

    ln -s "${SB_DIR}/bin/sb" "$target"
    chmod +x "${SB_DIR}/bin/sb"
    info "Symlinked: $target → ${SB_DIR}/bin/sb"

    # Make all module scripts executable
    find "${SB_DIR}/src" -name "*.sh" -exec chmod +x {} \;
    info "Made all src/*.sh scripts executable"

    # Set up ~/.skillbridge global config dir
    local global_dir="$HOME/.skillbridge"
    if [[ ! -d "$global_dir" ]]; then
        mkdir -p "$global_dir/skills"
        cat > "$global_dir/config.json" <<JSON
{
  "version": "0.1.0",
  "default_ide": "antigravity",
  "context_max_tokens": 2000
}
JSON
        info "Created global config: $global_dir/config.json"
    else
        warn "~/.skillbridge already exists — skipping global setup."
    fi

    install_global_skills

    echo ""
    info "✅ Skill Bridge installed. Run 'sb help' to get started."
    if [[ "$install_dir" == "$HOME/.local/bin" || "$install_dir" == "$HOME/bin" ]]; then
        warn "Ensure $install_dir is on your PATH."
    fi
}

main "$@"
