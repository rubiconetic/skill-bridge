# Project Plan: Aligning with Antigravity Kit (`.agent` Directory)

This plan details how to update Skill Bridge to store workspace configuration and bridge files within a `.agent` directory instead of the project root. This structure mirrors the familiar Antigravity Kit approach while keeping the core skills in the newly minted `skills` folder.

## 🎯 Success Criteria
- **Clean Root Level**: Move `GEMINI.md` and `.sb-config.json` inside a `.agent` directory.
- **Backward Compatibility**: `sb` commands gracefully handle the new config path.
- **Installer and Init**: `sb init` successfully creates the `.agent` directory and creates configuration files there.

## 🛠️ Files to Modify
- `src/onboarding/init.sh`: Where default config and `GEMINI.md` are generated.
- `src/lib/utils.sh`: Where `get_project_root` checks for `.sb-config.json`.
- `bin/sb` or `src/modules/context.sh` / `src/modules/skill.sh`: Ensure config lookups work seamlessly.

## 📋 Task Breakdown

### Phase 1: Update `sb init` (Configuration Creation)
- **Task 1.1**: Update `init.sh` to scaffold `.agent/` directory.
- **Task 1.2**: Update `init.sh` to write `.sb-config.json` into `.agent/`.
- **Task 1.3**: Update `init.sh` to write `GEMINI.md` into `.agent/`.

### Phase 2: Update Utility Functions (Path Resolution)
- **Task 2.1**: Update `get_project_root` in `src/lib/utils.sh` to look for `.agent/.sb-config.json` instead of `.sb-config.json` at the project root.
- **Task 2.2**: Ensure that `sb_config_get` reflects this new path correctly.

### Phase 3: Cleanup Current Workspace
- **Task 3.1**: Move existing `GEMINI.md` and `.sb-config.json` in the current `skill-bridge` project to `.agent/` to match the new convention and clean up the root.

## ✅ Verification
1. `sb init` creates `.agent/GEMINI.md` and `.agent/.sb-config.json`.
2. Existing commands (`sb context`, `sb design`, `sb skill`) function without errors, correctly pulling configuration from `.agent/.sb-config.json`.
3. Root directory is clean of config files.
