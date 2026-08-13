# Codex

Verified locally with `codex-cli 0.147.0`; recheck `codex exec --help`.

```sh
codex exec -C <dir> -m <model> -s workspace-write --ephemeral "<prompt>"
codex exec -C <dir> -m <model> -s workspace-write --ephemeral - < prompt.txt
```

- **Models:** `-m/--model`. This version exposes no model-list command; inspect current help/configuration or use a known model ID.
- **Directory:** `-C/--cd`. Use `--add-dir` only for required additional writable roots.
- **Prompt:** Positional argument. Omit it or pass `-` to read stdin; prefer stdin for long prompts.
- **Sandbox:** `-s read-only|workspace-write|danger-full-access`. `--dangerously-bypass-approvals-and-sandbox` removes both controls; use only inside adequate external isolation. `--approve-for-me` adds automated approval review and forces `workspace-write`.

Sandbox failures commonly affect network access, dependency caches, and writes outside the workspace. `danger-full-access` is not equivalent to the combined bypass flag because approval policy can still apply.
