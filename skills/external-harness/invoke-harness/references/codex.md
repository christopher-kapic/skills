# Codex

Verified locally with `codex-cli 0.147.0`; recheck `codex exec --help`.

```sh
codex exec -C <dir> -m <model> --dangerously-bypass-approvals-and-sandbox --ephemeral "<prompt>"
codex exec -C <dir> -m <model> --dangerously-bypass-approvals-and-sandbox --ephemeral - < prompt.txt
```

- **Models:** `-m/--model`. This version exposes no model-list command; inspect current help/configuration or use a known model ID.
- **Directory:** `-C/--cd`. Use `--add-dir` only for required additional writable roots.
- **Prompt:** Positional argument. Omit it or pass `-` to read stdin; prefer stdin for long prompts.
- **Permissions and sandbox:** `--dangerously-bypass-approvals-and-sandbox` removes both controls.
