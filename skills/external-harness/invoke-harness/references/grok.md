# Grok

Verified locally with Grok 1.0.3; recheck `grok --help`.

```sh
grok --cwd <dir> -m <model> --sandbox workspace --permission-mode dontAsk -p "<prompt>"
grok --cwd <dir> -m <model> --sandbox workspace --permission-mode dontAsk --prompt-file prompt.txt
```

- **Models:** `-m/--model`; list available models with `grok models`.
- **Directory:** `--cwd`.
- **Prompt:** `-p/--single`, `--prompt-file`, or `--prompt-json`. Prefer `--prompt-file` for long prompts.
- **Sandbox:** `--sandbox off|workspace|read-only|strict|devbox|<custom>`. The default profile can be `off`; specify one explicitly. Custom profiles live in `.grok/sandbox.toml` or `~/.grok/sandbox.toml`.
- **Permissions:** `--permission-mode` controls approvals. `--always-approve` does not add isolation.

The workspace sandbox can block network and paths outside the repository. A custom profile can accidentally broaden access; inspect it before use.

Grok may also install an `agent` compatibility alias. Do not use it: `agent` is also Cursor CLI's documented executable. Always invoke Grok as `grok`.

Source: https://docs.x.ai/build/settings/reference
