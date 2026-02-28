# 🚀 Product Requirements Document: Skill Bridge

### 1. Executive Summary
Skill Bridge is a high-performance, token-efficient CLI transformation engine designed for AI-native development. It shifts the paradigm from static prompt libraries to a deterministic local data pipeline. By replacing legacy Python scripts and CSV-heavy agent folders with a lean Bash/jq/JSON architecture and QMD-powered local RAG, Skill Bridge provides sub-second local context retrieval. This drastically reduces token overhead, enabling the use of cheaper, faster AI models for both IDEs (Google Antigravity, Cursor) and CLI-based AI agents (Claude Code, Gemini CLI, OpenClaw, Codex).
### 2. Problem Statement
- **Token Bloat:** Current AI tools dump thousands of tokens of generic documentation into prompts, saturating context windows and causing hallucinations.
- **Startup Latency:** Heavy Node.js dependencies and Python-based validation scripts create friction and slow down fast-paced development workflows.
- **Cost & Rate Limit Bottlenecks:** Premium AI models enforce strict rate limits and high token costs. Relying on them to parse massive, static files is inefficient and expensive.
- **Ecosystem Fragmentation:** Context is often siloed within a specific IDE; developers lack a unified way to inject deterministic architectural rules into terminal-based AI agents.
### 3. Functional Requirements
#### 3.1 CLI Onboarding & Configuration (`skillbridge init`)
- **Environment Selection:** An interactive CLI onboarding flow where users can select their primary interfaces, supporting both IDEs (e.g., Google Antigravity) and CLI Agents (e.g., Claude Code, Gemini CLI).
- **Dependency Verification:** Verifies paths for required native binaries (`jq`, `bash`, `qmd`).
- **Configuration Hierarchy:**
    - _Global (`~/.skillbridge/`):_ Stores environment preferences, overarching agent Markdown skills (indexed by QMD), and global JSON rule sets.
    - _Project-Specific:_ Lightweight config files within a project repository to override global rules.
#### 3.2 Core Architecture (The "Thin Pipe")
- **Legacy Replacement:** Fully replace the old Python/CSV architecture with high-speed JSON arrays and `jq` filtering.
- **QMD-Powered Local RAG:** Utilize `tobi/qmd` to transform all global narrative Markdown files into a locally searchable RAG database. Instead of passing whole documents, the CLI queries QMD to extract only the semantically relevant fragments.
- **Dumb-to-Smart Pipeline:** Use `jq` for deterministic find-and-replace (syntax mappings, design tokens) and `qmd` for narrative context retrieval before involving an LLM.
#### 3.3 Data Stack

| **Component**        | **Technology** | **Role**                                                                   |
| -------------------- | -------------- | -------------------------------------------------------------------------- |
| Orchestrator         | Bash / Zsh     | Zero-dependency CLI interface (`sb` command).                              |
| Logic Engine         | jq             | High-speed filtering for design systems and syntax mappings.               |
| Structured Data      | JSON           | Replaces legacy CSVs for UI/UX rules; maps framework migrations.           |
| Narrative Docs       | Markdown       | High-level architectural rules and persona definitions.                    |
| Retrieval Engine | QMD        | On-device semantic search for Markdown RAG, minimizing token payloads. |

#### 3.4 Target Workflows
- `/design`: Uses `jq` to instantly pull specific JSON design tokens (colors, typography) based on the current component.
- `/migrate`: Auto-scans a directory and generates a deterministic migration plan based on JSON mapping rules.
- `/audit`: Runs a zero-latency security/linting check using Bash/jq.
- `/context`: Takes the user's current task, queries the QMD local database for relevant Markdown fragments, parses relevant JSON via `jq`, and generates a highly minified `.sb-context.md`.
#### 3.5 Proposed Skill Bridge Repository Structure
```plaintext
skillbridge/
├── bin/
│   └── sb                 # Core Bash/Zsh orchestrator (The "Thin Pipe")
├── src/                   # CLI Source Logic
│   ├── onboarding/
│   │   └── init.sh        # Interactive setup: binary checks (jq, qmd), IDE choice
│   ├── modules/           # Replatformed Workflows (Deterministic logic)
│   │   ├── design.sh      # Replacing ui-ux-pro-max scripts
│   │   ├── migrate.sh     # Framework transition logic (e.g., Next.js -> Svelte 5)
│   │   ├── context.sh     # The QMD + jq pipeline for sub-second retrieval
│   │   └── audit.sh       # Zero-latency linting using jq
│   └── lib/
│       └── utils.sh       # Shared helpers (validation, color formatting)
├── data/                  # Deterministic JSON "Rosetta Stones"
│   ├── ui-ux/             # Converted from legacy CSVs
│   │   ├── colors.json
│   │   ├── typography.json
│   │   └── web-interface.json
│   └── migrations/        # Syntax mapping for framework shifts
├── skills/                # Global Markdown "Skills" (Indexed by QMD)
│   ├── backend/           # Core specialist personas
│   ├── devops/            # Infrastructure and CI/CD rules
│   └── testing/           # TDD and QA patterns
├── web/                   # Documentation & Registry (Hosted on GH Pages)
│   ├── src/               # SvelteKit/Astro source
│   ├── public/            # Static assets and logos
│   └── registry.json      # Machine-readable index of all Skills/Data for the CLI
├── install.sh             # Global installer (Symlinks 'sb' and sets up ~/.skillbridge)
├── .github/workflows/     # CI/CD for building Web and updating the Registry
└── README.md
```
#### 5. Environment Integration (The Bridge)
- **CLI Agent Native:** Seamless piping of the generated `.sb-context.md` directly into terminal agents. For example, piping Skill Bridge output directly into a `gemini` or `claude` CLI command execution.
- **IDE Native:** Deep integration tailored for IDEs like Google Antigravity, ensuring context is fetched locally and passed seamlessly without bloating the IDE's built-in memory. Support for `.cursorrules` or equivalent local files to instruct IDE agents to use the `sb` CLI for fact-fetching.
#### 6. Success Metrics
- **Model Democratization:** Users can achieve premium-level refactoring and UI generation using lower-tier, cheaper models.
- **Token Reduction:** Average 75% reduction in prompt size.
- **Execution Speed:** Sub-second time-to-first-token for AI tasks across both IDEs and terminals.
- **Developer Experience:** Zero-clutter projects (no heavy `.agent` folders or Python scripts in the git history).