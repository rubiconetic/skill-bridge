#!/usr/bin/env bash

# sb init — Onboarding script
# Sets up the current project for Skill Bridge:
#   1. Verifies required binaries (jq, qmd)
#   2. Creates .sb-config.json
#   3. Indexes the project's skills with QMD

set -euo pipefail

SB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SB_DIR}/src/lib/utils.sh"

# ----- Config -----

DEFAULT_COLLECTION_NAME="$(basename "$PWD")-skills"
CONFIG_DIR=".agent"
CONFIG_FILE="${CONFIG_DIR}/.sb-config.json"

# ----- Steps -----

check_binaries() {
    sb_section "Checking required binaries"
    local ok=true
    for dep in jq qmd; do
        if command -v "$dep" &>/dev/null; then
            sb_info "$dep ✔"
        else
            sb_error "Required binary not found: '$dep'"
            ok=false
        fi
    done
    if [[ "$ok" == "false" ]]; then
        sb_error "Install missing binaries then re-run 'sb init'."
        sb_error "  jq:  https://jqlang.github.io/jq/download/"
        sb_error "  qmd: bun install -g @tobilu/qmd  (or npm install -g @tobilu/qmd)"
        exit 1
    fi
}

create_config() {
    sb_section "Creating project config"

    if [[ -f "$CONFIG_FILE" ]]; then
        sb_warn "$CONFIG_FILE already exists — skipping."
        return 0
    fi

    # Create .agent directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"

    # Default skills path
    local skills_path="skills"

    cat > "$CONFIG_FILE" <<JSON
{
  "version": "0.1.0",
  "collection": "${DEFAULT_COLLECTION_NAME}",
  "skills_path": "${skills_path}",
  "ide": "antigravity",
  "context_max_tokens": 2000
}
JSON
    sb_info "Created $CONFIG_FILE"
}

init_qmd_collection() {
    sb_section "Initializing QMD collection"

    local collection
    collection="$(jq -r '.collection' "$CONFIG_FILE")"
    local skills_path
    skills_path="$(jq -r '.skills_path' "$CONFIG_FILE")"

    # Ensure the skills directory exists before indexing
    if [[ ! -d "$skills_path" ]]; then
        sb_info "Creating skills directory: $skills_path"
        mkdir -p "$skills_path"
    fi

    # Check if the collection already exists
    if qmd collection list 2>/dev/null | grep -q "^${collection}"; then
        sb_warn "QMD collection '${collection}' already exists — re-indexing."
        # Remove and re-add only this collection to avoid touching unrelated collections
        qmd collection remove "${collection}" 2>/dev/null || true
        sb_info "Creating QMD collection '${collection}' from '${skills_path}'"
        qmd collection add "${skills_path}" \
            --name "${collection}" \
            --mask "**/*.md"
        sb_info "Running embedding pass..."
        qmd embed
    else
        sb_info "Creating QMD collection '${collection}' from '${skills_path}'"
        qmd collection add "${skills_path}" \
            --name "${collection}" \
            --mask "**/*.md"
        sb_info "Running initial embedding pass..."
        qmd embed
    fi
    sb_info "QMD collection '${collection}' ready ✔"
}

write_ide_bridge() {
    sb_section "Writing IDE bridge and specific workflows"

    # Define paths
    local templates_dir="${SB_DIR}/src/templates"
    local rules_dest="${CONFIG_DIR}/rules"
    local workflows_dest="${CONFIG_DIR}/workflows"
    local agents_dest="${CONFIG_DIR}/agents"

    if [[ ! -d "$templates_dir" ]]; then
        sb_warn "Templates directoy not found at $templates_dir (Skipping)."
        return 0
    fi

    # Create destinations
    mkdir -p "$rules_dest"
    mkdir -p "$workflows_dest"
    mkdir -p "$agents_dest"

    # Copy Rules (GEMINI.md)
    if [[ -d "${templates_dir}/rules" ]]; then
        cp -n -r "${templates_dir}/rules/"* "$rules_dest/" 2>/dev/null || true
        sb_info "Installed IDE rules into $rules_dest"
    fi

    # Copy Workflows (/commands)
    if [[ -d "${templates_dir}/workflows" ]]; then
        cp -n -r "${templates_dir}/workflows/"* "$workflows_dest/" 2>/dev/null || true
        sb_info "Installed IDE workflows into $workflows_dest"
    fi

    # Copy Agents (Personas)
    if [[ -d "${templates_dir}/agents" ]]; then
        cp -n -r "${templates_dir}/agents/"* "$agents_dest/" 2>/dev/null || true
        sb_info "Installed IDE agents into $agents_dest"
    fi
}

# ----- Main -----

main() {
    echo ""
    sb_info "Skill Bridge init — $(pwd)"
    check_binaries
    create_config
    init_qmd_collection
    write_ide_bridge
    echo ""
    sb_info "✅ Done. Run 'sb context \"<task>\"' to generate context."
}

main "$@"
