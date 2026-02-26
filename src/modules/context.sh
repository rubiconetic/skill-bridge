#!/usr/bin/env bash

# sb context — QMD + jq thin-pipe context generator
# Usage: sb context "<task description>" [options]
# Outputs: .sb-context.md in the current directory
#
# Search modes:
#   default   BM25 full-text (qmd search)  ~0.3s  ← fast, good for IDE
#   --semantic vector similarity (qmd vsearch) ~15s  ← richer results

set -euo pipefail

SB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${SB_DIR}/src/lib/utils.sh"

OUT_FILE=".sb-context.md"

usage() {
    cat <<EOF
Usage: sb context "<task description>" [options]

Options:
  -n, --num-results <N>   Number of results to include (default: 5)
  -o, --output <file>     Output file (default: .sb-context.md)
  --semantic              Use vector search (slower, higher quality)
  -h, --help              Show this help
EOF
}

# ----- Defaults -----
NUM_RESULTS=5
SEMANTIC=false

# ----- Arg parsing -----
QUERY=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--num-results) NUM_RESULTS="$2"; shift 2 ;;
        -o|--output)      OUT_FILE="$2";    shift 2 ;;
        --semantic)       SEMANTIC=true;    shift   ;;
        -h|--help)        usage; exit 0 ;;
        -*) sb_error "Unknown option: $1"; usage; exit 1 ;;
        *)  QUERY="$1"; shift ;;
    esac
done

[[ -z "$QUERY" ]] && { sb_error "No query provided."; usage; exit 1; }

# ----- Resolve collection -----
COLLECTION="$(sb_config_get "collection")"
[[ -z "$COLLECTION" ]] && {
    sb_warn "No .sb-config.json found. Run 'sb init' first."
    sb_warn "Attempting search without collection filter..."
}

# ----- Build context -----

generate_context() {
    local start_ts
    start_ts=$(date +%s%N)

    # Pick search command based on mode
    local search_cmd="search"
    local mode_label="BM25"
    if [[ "$SEMANTIC" == "true" ]]; then
        search_cmd="vsearch"
        mode_label="vector"
    fi

    {
        echo "# Skill Bridge Context"
        echo "> Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        echo "> Query: \`${QUERY}\`"
        echo "> Mode: ${mode_label}"
        echo ""

        # ── QMD skill fragments ──────────────────────────────────────────────
        echo "## Relevant Skill Fragments"
        echo ""

        local qmd_args=("$search_cmd" "$QUERY" "-n" "$NUM_RESULTS" "--md")
        [[ -n "$COLLECTION" ]] && qmd_args+=("-c" "$COLLECTION")

        if qmd collection list 2>/dev/null | grep -q "^sb-global\b"; then
            qmd_args+=("-c" "sb-global")
        fi

        qmd "${qmd_args[@]}" 2>/dev/null || \
            sb_warn "QMD returned no results for: $QUERY"

        echo ""

    } > "$OUT_FILE"

    local end_ts
    end_ts=$(date +%s%N)
    local elapsed_ms=$(( (end_ts - start_ts) / 1000000 ))

    sb_info "Context written to $OUT_FILE (${elapsed_ms}ms) [${mode_label}]"
    if [[ "$SEMANTIC" == "false" && "$elapsed_ms" -lt 2000 ]]; then
        sb_info "Tip: add --semantic for vector search (higher quality, ~15s)"
    fi
}

generate_context
