# Codex

Verified locally with `codex-cli 0.152.1`; recheck `codex exec --help`. Use `codex exec`, not `codex review` or `codex exec review`, unless the user asked for Codex's built-in review.

```sh
codex exec -C <dir> -m <model> --dangerously-bypass-approvals-and-sandbox --ephemeral "<prompt>"
codex exec -C <dir> -m <model> --dangerously-bypass-approvals-and-sandbox --ephemeral - < prompt.txt
```

- **Models:** `-m/--model` takes a full model ID, not a nickname. This version exposes no model-list command; inspect current help/configuration or use a known model ID.
- **Directory:** `-C/--cd` is an `exec` flag. Use `--add-dir` only for required additional writable roots.
- **Prompt:** Positional argument. Omit it or pass `-` to read stdin; prefer stdin for long prompts.
- **Permissions and sandbox:** `--dangerously-bypass-approvals-and-sandbox` removes both controls.
