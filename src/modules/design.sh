#!/usr/bin/env bash

# sb design — Extract design tokens via jq
# Highly optimized for the Skill Bridge array-based JSON "database"

set -euo pipefail

SB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SB_DIR}/src/lib/utils.sh"

DATA_DIR="${SB_DIR}/data/ui-ux"

usage() {
    cat <<EOF
Skill Bridge "Thin Pipe" Design Module

Usage: sb design [options]

Core Options:
  --color <name>   [search] Get a color (e.g. "Primary", "Background")
  --font  <name>   [search] Get a font (e.g. "Heading", "Body")
  --style <name>   [search] Get a style category (e.g. "Glassmorphism")
  --icon  <name>   [search] Get an icon match (e.g. "menu", "search")

Filters:
  --type <type>    Filter results by Product Type (e.g. "SaaS", "E-commerce")
  --query <term>   Universal search across keywords and labels

Utility:
  --list [file]    List all available types/categories in a data file
  --all            Dump all merged design data
  -h, --help       Show this help
EOF
}

# Universal search helper
# $1: file, $2: selector (jq filter), $3: filter value (optional)
query_data() {
    local file="$1"
    local jq_filter="$2"
    local term="${3:-}"

    if [[ ! -f "${DATA_DIR}/${file}" ]]; then
        sb_error "Data file not found: ${file}. Did you run 'sb init'?"
        exit 1
    fi

    if [[ -n "$term" ]]; then
        # Handle search-style filtering
        jq -r ".[] | select((.Keywords // \"\" | ascii_downcase | contains(\"${term,,}\")) or (.[\"Product Type\"] // \"\" | ascii_downcase | contains(\"${term,,}\")) or (.[\"Style Category\"] // \"\" | ascii_downcase | contains(\"${term,,}\"))) | ${jq_filter}" "${DATA_DIR}/${file}"
    else
        # Just grab the first one if no term provided
        jq -r ".[0] | ${jq_filter}" "${DATA_DIR}/${file}"
    fi
}

get_color() {
    local color_prop="${1} (Hex)"
    local term="${2:-}"
    query_data "colors.json" ".[\"${color_prop}\"] // empty" "$term"
}

get_font() {
    local font_prop="${1} Font"
    local term="${2:-}"
    query_data "typography.json" ".[\"${font_prop}\"] // empty" "$term"
}

get_style() {
    local term="$1"
    query_data "styles.json" ". | {Category: .[\"Style Category\"], Colors: .[\"Primary Colors\"], Effects: .[\"Effects & Animation\"]}" "$term"
}

get_icon() {
    local name="$1"
    if [[ ! -f "${DATA_DIR}/icons.json" ]]; then
        sb_error "icons.json not found."
        exit 1
    fi
    jq -r ".[] | select(.[\"Icon Name\"] == \"${name}\" or (.Keywords | contains(\"${name}\"))) | .[\"Icon Name\"] + \" (\" + .Library + \"): \" + .Usage" "${DATA_DIR}/icons.json" | head -n 5
}

list_types() {
    local file="${1:-colors.json}"
    if [[ ! -f "${DATA_DIR}/${file}" ]]; then
        sb_error "File not found: ${file}"
        exit 1
    fi
    sb_info "Available types/categories in ${file}:"
    jq -r ".[] | .[\"Product Type\"] // .[\"Style Category\"] // .[\"Category\"] // empty" "${DATA_DIR}/${file}" | sort -u | sed 's/^/  - /'
}

# ----- Main -----

if [[ $# -eq 0 ]]; then usage; exit 0; fi

SEARCH_TERM=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --query|--type) SEARCH_TERM="$2"; shift 2 ;;
        --color) get_color "$2" "$SEARCH_TERM"; exit 0 ;;
        --font)  get_font  "$2" "$SEARCH_TERM"; exit 0 ;;
        --style) get_style "$2"; exit 0 ;;
        --icon)  get_icon  "$2"; exit 0 ;;
        --list)  list_types "${2:-}"; exit 0 ;;
        --all)
            jq -s 'add' "${DATA_DIR}"/*.json
            exit 0
            ;;
        -h|--help) usage; exit 0 ;;
        *) sb_error "Unknown option: $1"; usage; exit 1 ;;
    esac
done
