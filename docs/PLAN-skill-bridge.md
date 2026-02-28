# 🚀 Project Plan: Skill Bridge

Skill Bridge is a high-performance local context engine that replaces legacy Python/CSV-heavy agent setups with a deterministic Bash/jq/JSON pipeline and QMD-powered local RAG.

## 🎯 Success Criteria
- **IDE native integration**: Context fetched locally and passed to AI agents without bloating memory.
- **Token Efficiency**: ~75% reduction in prompt size via `jq` filtering and semantic `QMD` fragments.
- **Speed**: Sub-second context retrieval.
- **Zero-clutter**: No heavy `.agent` folders in the target project.

## 🛠️ Tech Stack
- **Orchestrator**: Bash / Zsh
- **Logic Engine**: `jq` (JSON processing)
- **RAG Engine**: `QMD` (Semantic search / fragment extraction)
- **Data Layers**: JSON (Deterministic rules), Markdown (Narrative skills)

## 📁 File Structure
```plaintext
skillbridge/
├── bin/sb                 # Core Bash orchestrator
├── src/
│   ├── onboarding/init.sh # Setup & binary checks
│   ├── modules/
│   │   ├── design.sh      # Design token extraction
│   │   ├── migrate.sh     # Framework mapping
│   │   ├── context.sh     # QMD + jq pipeline
│   │   └── audit.sh       # jq-based linting
│   └── lib/utils.sh       # Shared helpers
├── data/                  # JSON Rosetta Stones (Converted from legacy)
├── skills/                # Global Markdown Skills (Indexed by QMD)
├── web/                   # Docs & Registry (Astro/SvelteKit)
└── install.sh             # Global installer
```

## 📋 Task Breakdown

### Phase 1: Context & Core Setup
- **Task 1.1**: Initialize `skillbridge` structure.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Input**: `PRD.md`
  - **Output**: Directory structure created.
  - **Verify**: `ls -R skillbridge/`
- **Task 1.2**: Implement `sb init` (Onboarding).
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Input**: PRD 3.1
  - **Output**: `src/onboarding/init.sh`
  - **Verify**: `./bin/sb init` checks for `jq` and `qmd`, and initializes the local QMD collection for the project (`qmd collection add`).

### Phase 2: IDE-Native Bridge (Priority)
- **Task 2.1**: Design `.sb-context.md` template.
  - **Agent**: `documentation-writer`
  - **Skill**: `documentation-templates`
  - **Output**: Minified context format definition.
- **Task 2.2**: Implement Antigravity/Cursor Rule Bridge.
  - **Agent**: `frontend-specialist`
  - **Skill**: `intelligent-routing`
  - **Output**: `.cursorrules` / `.sb-config.json` templates.
  - **Verify**: Rule file correctly triggers `sb context`.

### Phase 3: "Thin Pipe" Engineering
- **Task 3.1**: QMD Fragment Extraction logic.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Output**: `src/modules/context.sh` (integrating `qmd query`).
  - **Verify**: `sb context "search query"` returns Markdown fragments.
- **Task 3.2**: JQ Design Token Pipeline. [DONE]
  - **Agent**: `backend-specialist`
  - **Skill**: `api-patterns`
  - **Output**: `src/modules/design.sh` + `data/ui-ux/colors.json`.
  - **Verify**: `sb design --color primary` returns hex.

### Phase 4: Data Conversion
- **Task 4.1**: Map legacy `.agent` data to Skill Bridge JSON. [DONE for UI/UX]
  - **Agent**: `code-archaeologist`
  - **Skill**: `clean-code`
  - **Input**: `.agent/.shared/ui-ux-pro-max/data`
  - **Output**: `data/ui-ux/` folder populated with JSON.
  - **Verify**: `ls data/ui-ux/` shows all 13 modules (12 files + stacks).

## ✅ PHASE X: VERIFICATION — COMPLETE
- [x] `sb init` successfully detects environment. (jq ✔ qmd ✔ config ✔)
- [x] `sb context` generates valid `.sb-context.md` — **333ms** (BM25 mode); `--semantic` flag for vector search (~15s).
- [x] QMD index contains all global skills. (117 files in `skill-bridge-skills` collection)
- [x] `jq` filtering accurately extracts design tokens. (`sb design --color Primary` → `#2563EB`)
- [x] Purple ban: colors.json contains reference data from all product types; agent rules govern usage.

---
[OK] Plan created: docs/PLAN-skill-bridge.md
Next steps:
- Review the plan
- Run `/create` to start implementation
