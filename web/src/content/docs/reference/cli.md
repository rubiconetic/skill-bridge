---
title: CLI Reference
description: Detailed reference for Skill Bridge CLI commands.
---

Detailed reference for all available `sb` commands.

## Command Overview

| Command | Description |
| :--- | :--- |
| `sb init` | Initialize the current workspace and check dependencies. |
| `sb context` | Generate minified context (`.sb-context.md`) using QMD + jq. |
| `sb design` | Instantly extract design tokens (colors, typography) via jq. |
| `sb audit` | Lightning-fast, regex-based code validator. |
| `sb skill` | Manage and index global/local AI skills. |
| `sb uninstall` | Safely remove Skill Bridge from your system. |

---

## `sb init`

Initialize a new workspace for Skill Bridge. This command checks for required dependencies (`jq`, `bash`, `qmd`) and sets up the local configuration.

```bash
sb init
```

## `sb context`

Generates a minified `.sb-context.md` file based on your current task. It uses QMD for semantic retrieval of markdown fragments and `jq` for extracting structured data.

```bash
sb context "your task description"
```

## `sb design`

Extracts design tokens (colors, typography, etc.) from the project's data files.

```bash
sb design
```

## `sb audit`

Performs a fast, regex-based validation of the codebase.

```bash
sb audit
```

## `sb skill`

Manages and indexes AI skills.

```bash
sb skill [action]
```

## `sb uninstall`

Removes Skill Bridge symlinks and global configuration from your system.

```bash
sb uninstall
```
