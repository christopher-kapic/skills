# Cursor CLI

The documented executable is `agent`; Cursor does not currently document a `cursor` CLI command. It was not installed during verification. Resolve `agent`, then check `agent --version` and `agent --help`. Abort if they identify Grok/xAI or if help lacks Cursor flags such as `--workspace`, `--sandbox`, and `--trust`.

```sh
agent -p --workspace <dir> --model <model> --sandbox disabled --trust --yolo "<prompt>"
```

- **Models:** `--model`; list account models with `agent models` or `--list-models`.
- **Directory:** `--workspace`.
- **Prompt:** Positional argument with `-p/--print`. No prompt-file flag is documented. For a very long prompt, place it in a trusted workspace file and give a short instruction to read it.
- **Sandbox:** Use `--sandbox disabled` explicitly.
- **Permissions:** Use `--yolo` (or `--force` when current help documents it).

Print mode has access to write and shell tools. Sandbox network access may be disabled, so installs and remote Git operations can fail. `--trust` skips workspace confirmation and must be used only for a trusted directory.

Grok also ships an `agent` compatibility alias. Never use that alias for Cursor, and never use it to invoke Grok; invoke Grok with `grok`.

Sources: https://cursor.com/docs/cli/overview and https://cursor.com/docs/cli/reference/parameters
