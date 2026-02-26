#!/usr/bin/env bash

# uninstall.sh — Skill Bridge uninstaller

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[uninstall]${NC} $1"; }
warn()  { echo -e "${YELLOW}[uninstall]${NC} $1"; }
error() { echo -e "${RED}[uninstall]${NC} $1" >&2; }

main() {
    echo ""
    warn "This will uninstall the Skill Bridge CLI."

    # Find where sb is installed
    local sb_path=""
    if command -v sb &>/dev/null; then
        sb_path="$(command -v sb)"
    fi
    
    if [[ -z "$sb_path" ]]; then
        # try common locations if not in PATH for some reason
        for p in "$HOME/.local/bin/sb" "$HOME/bin/sb" "/usr/local/bin/sb"; do
            if [[ -L "$p" || -f "$p" ]]; then
                sb_path="$p"
                break
            fi
        done
    fi

    if [[ -n "$sb_path" && -L "$sb_path" ]]; then
        rm "$sb_path"
        info "Removed symlink: $sb_path"
    elif [[ -n "$sb_path" && -f "$sb_path" ]]; then
        rm "$sb_path"
        info "Removed executable: $sb_path"
    else
        warn "Could not find an 'sb' symlink or executable to remove."
    fi

    local global_dir="$HOME/.skillbridge"
    if [[ -d "$global_dir" ]]; then
        read -p "Do you want to remove global configs in $global_dir? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$global_dir"
            info "Removed global configuration: $global_dir"
            if qmd collection list 2>/dev/null | grep -q "^sb-global\b"; then
                qmd collection remove "sb-global" >/dev/null 2>&1 || true
                info "Removed global qmd collection: sb-global"
            fi
        else
            info "Retained global configuration: $global_dir"
        fi
    fi

    # Check for qmd collections ending in '-skills'
    if command -v qmd >/dev/null 2>&1; then
        local collections
        collections=$(qmd collection list 2>/dev/null | grep -o '^[a-zA-Z0-9_-]*-skills\b' || true)
        if [[ -n "$collections" ]]; then
            echo ""
            warn "Found the following Skill Bridge 'qmd' collections:"
            echo "$collections" | sed 's/^/  - /'
            echo ""
            read -p "Do you want to remove these qmd collections? (y/N) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                while IFS= read -r col; do
                    if [[ -n "$col" ]]; then
                        qmd collection remove "$col" >/dev/null 2>&1 || true
                        info "Removed qmd collection: $col"
                    fi
                done <<< "$collections"
            else
                info "Retained qmd collections."
            fi
        fi
    fi

    echo ""
    info "✅ Skill Bridge uninstalled successfully."
    info "You can safely delete the project directory if you wish."
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: sb uninstall"
    echo "Removes the Skill Bridge CLI symlink and optionally global configurations."
    exit 0
fi

main "$@"
