#!/usr/bin/env bash

# Shared utility functions for Skill Bridge

readonly SB_RED='\033[0;31m'
readonly SB_GREEN='\033[0;32m'
readonly SB_YELLOW='\033[1;33m'
readonly SB_CYAN='\033[0;36m'
readonly SB_NC='\033[0m'

sb_info()    { echo -e "${SB_GREEN}[sb]${SB_NC} $1"; }
sb_warn()    { echo -e "${SB_YELLOW}[sb]${SB_NC} $1"; }
sb_error()   { echo -e "${SB_RED}[sb]${SB_NC} $1" >&2; }
sb_section() { echo -e "\n${SB_CYAN}── $1 ──${SB_NC}"; }

# Check if a binary is available
require_bin() {
    local name="$1"
    if ! command -v "$name" &>/dev/null; then
        sb_error "Required binary not found: '$name'"
        sb_error "Please install '$name' before continuing."
        return 1
    fi
}

# Get the project root: the dir containing .agent/.sb-config.json (or fall back to cwd)
get_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        [[ -f "$dir/.agent/.sb-config.json" ]] && echo "$dir" && return 0
        dir="$(dirname "$dir")"
    done
    echo "$PWD"
}

# Read a field from .agent/.sb-config.json
sb_config_get() {
    local key="$1"
    local root
    root="$(get_project_root)"
    local config="$root/.agent/.sb-config.json"
    [[ -f "$config" ]] && jq -r ".$key // empty" "$config"
}
