# Skill Bridge Context

This project uses **Skill Bridge** for local, token-efficient AI context injection.

## Usage

Before implementing any feature, run:

```bash
sb context "<your task description>"
```

This generates `.sb-context.md` containing only the semantically relevant
skill fragments. Include it in your prompt instead of the full `.agent/` tree.
