#!/usr/bin/env bash

# sb skill — Skill management (creation + indexing)
# Usage: sb skill create <name> [options]

set -euo pipefail

SB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SB_DIR}/src/lib/utils.sh"

usage() {
    cat <<EOF
Skill Bridge Skill Management

Usage: sb skill <command> [options]

Commands:
  create <name>   Create a new skill folder and SKILL.md template
  help            Show this help

Create Options:
  --index-now     Index the skill immediately (blocking)
  --index-bg      Index the skill in the background
  -y, --yes       Skip the indexing prompt (default: index now)
EOF
}

# Indexing helper (surgical re-indexing)
index_skill() {
    local mode="${1:-now}" # now, bg

    local collection
    collection="$(sb_config_get "collection")"
    local skills_path
    skills_path="$(sb_config_get "skills_path")"
    
    if [[ -z "$collection" ]]; then
        sb_error "No QMD collection found in config. Run 'sb init' first."
        return 1
    fi

    run_index() {
        sb_info "Surgically re-indexing collection '${collection}'..."
        # Remove and re-add to force a refresh on just this collection
        qmd collection remove "${collection}" 2>/dev/null || true
        qmd collection add "${skills_path}" \
            --name "${collection}" \
            --mask "**/*.md" >/dev/null
        qmd embed >/dev/null
        sb_info "Re-indexing complete."
    }

    if [[ "$mode" == "bg" ]]; then
        sb_info "Indexing in background..."
        (run_index &>/dev/null &)
    else
        run_index
    fi
}

create_skill() {
    local name="$1"
    shift
    
    [[ -z "$name" ]] && { sb_error "No skill name provided."; usage; exit 1; }

    # Parsing options
    local mode=""
    local skip_prompt=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --index-now) mode="now"; shift ;;
            --index-bg)  mode="bg";  shift ;;
            -y|--yes)    skip_prompt=true; shift ;;
            *) sb_error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    local skills_root
    skills_root="$(sb_config_get "skills_path")"
    [[ -z "$skills_root" ]] && skills_root="skills" # Fallback

    local skill_dir="${skills_root}/${name}"
    
    if [[ -d "$skill_dir" ]]; then
        sb_error "Skill '$name' already exists at $skill_dir"
        exit 1
    fi

    sb_section "Creating skill: $name"
    mkdir -p "$skill_dir"
    
    local skill_file="${skill_dir}/SKILL.md"
    cat > "$skill_file" <<EOF
---
name: ${name}
description: Description for ${name}
tags: []
---

# ${name}

> [!NOTE]
> Add context-specific documentation for ${name} here.

## 🏁 Best Practices
- Practice 1
- Practice 2

## 📝 Examples
\`\`\`javascript
// Example code
\`\`\`
EOF

    sb_info "Scaffolded $skill_file"

    # Prompt logic
    if [[ -z "$mode" ]]; then
        if [[ "$skip_prompt" == "true" ]]; then
            mode="now"
        else
            echo -e "${SB_YELLOW}Index this skill now? [y/n/b]${SB_NC} (y: now, n: no, b: background)"
            read -r -p "> " choice
            case "$choice" in
                y|Y) mode="now" ;;
                b|B) mode="bg" ;;
                *)   mode="none" ;;
            esac
        fi
    fi

    if [[ "$mode" != "none" ]]; then
        index_skill "$mode"
    else
        sb_warn "Skipped indexing. Remember to run 'sb init' or 'qmd update' later."
    fi
}

# ----- Main -----

[[ $# -eq 0 ]] && { usage; exit 0; }

command="$1"
shift

case "$command" in
    create)
        create_skill "$@"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        sb_error "Unknown command: $command"
        usage
        exit 1
        ;;
esac
