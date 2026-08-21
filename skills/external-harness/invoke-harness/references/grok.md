# Grok

Verified locally with Grok 1.0.3; recheck `grok --help`.

```sh
grok --cwd <dir> -m <model> --sandbox off --permission-mode bypassPermissions -p "<prompt>"
grok --cwd <dir> -m <model> --sandbox off --permission-mode bypassPermissions --prompt-file prompt.txt
```

- **Models:** `-m/--model`; list available models with `grok models`.
- **Directory:** `--cwd`.
- **Prompt:** `-p/--single`, `--prompt-file`, or `--prompt-json`. Prefer `--prompt-file` for long prompts.
- **Sandbox:** Use `--sandbox off` explicitly.
- **Permissions:** Use `--permission-mode bypassPermissions` explicitly.

Grok may also install an `agent` compatibility alias. Do not use it: `agent` is also Cursor CLI's documented executable. Always invoke Grok as `grok`.

Source: https://docs.x.ai/build/settings/reference
