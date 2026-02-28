# 🚀 Project Plan: Skill Migration & Automation

This plan outlines the migration of skills from the legacy `.agent/skills` folder to the project root `./skills` directory, and the implementation of automated skill creation and indexing.

## 🎯 Success Criteria
- **Zero-clutter**: Skills are moved out of `.agent` and into the shippable `./skills` directory.
- **Agent Autonomy**: AI agents can create new skills via `sb skill create`.
- **Fast Indexing**: New skills are immediately indexed by QMD without a full collection re-scan.
- **UX Smoothness**: User is prompted (or notified) about the indexing status.

## 🛠️ Tech Stack
- **Orchestrator**: Bash (sb command)
- **RAG Engine**: QMD
- **Data format**: Markdown (SKILL.md)

## 📁 File Structure (Target)
```plaintext
skillbridge/
├── bin/sb
├── skills/
│   ├── api-patterns/        # (Migrated)
│   ├── clean-code/          # (Migrated)
│   └── [new-skill]/         # (Newly created)
│       └── SKILL.md
└── src/
    └── modules/
        └── skill.sh         # New module for skill management
```

## 📋 Task Breakdown

### Phase 1: Migration & Configuration
- **Task 1.1**: Migrate skills from `.agent/skills` to `./skills`.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Input**: `.agent/skills`
  - **Output**: `./skills` populated; `.sb-config.json` updated.
  - **Verify**: `ls skills/api-patterns/SKILL.md` exists.
- **Task 1.2**: Update `.sb-config.json` default skills path.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Output**: `"skills_path": "skills"` in `.sb-config.json`.
  - **Verify**: `sb context` still works pointing to the new path.

### Phase 2: Skill Management Command
- **Task 2.1**: Implement `src/modules/skill.sh`.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Output**: `sb skill create <name>` logic created.
  - **Verify**: `sb skill help` shows usage.
- **Task 2.2**: Integrate with `bin/sb` orchestrator.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Output**: Case statement added for `skill`.
  - **Verify**: `sb skill` triggers the module.

### Phase 3: Automation & UX
- **Task 3.1**: Implement indexing automation.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **Logic**: After file creation, run `qmd embed` on the specific folder (or update collection).
  - **Verify**: `sb context` finds the newly created skill immediately.
- **Task 3.2**: Add indexing prompt/notification.
  - **Agent**: `backend-specialist`
  - **Skill**: `bash-linux`
  - **UX**: Choice between "Index Now" (blocking) or "Background" (non-blocking).
  - **Verify**: Script appropriately handles the chosen flow.

## ✅ PHASE X: VERIFICATION
- [ ] `./skills` directory is the source of truth (no `.agent/skills` dependency).
- [ ] `sb skill create "test-skill"` successfully creates `./skills/test-skill/SKILL.md`.
- [ ] User is prompted to index upon creation.
- [ ] `sb context "test-skill"` returns the newly created fragment within seconds.
- [ ] Regression: `sb design` and `sb context` (for old skills) still work.
