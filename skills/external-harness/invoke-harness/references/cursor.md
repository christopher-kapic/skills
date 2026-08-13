# Cursor CLI

The current executable is `agent`; it was not installed during verification. Recheck `agent --help`.

```sh
agent -p --workspace <dir> --model <model> --sandbox enabled --trust "<prompt>"
```

- **Models:** `--model`; list account models with `agent models` or `--list-models`.
- **Directory:** `--workspace`.
- **Prompt:** Positional argument with `-p/--print`. No prompt-file flag is documented. For a very long prompt, place it in a trusted workspace file and give a short instruction to read it.
- **Sandbox:** `--sandbox enabled|disabled`. Specify `enabled` instead of relying on persisted state. `-f/--force` or `--yolo` auto-allows commands but does not mean the sandbox is enabled.

Print mode has access to write and shell tools. Sandbox network access may be disabled, so installs and remote Git operations can fail. `--trust` skips workspace confirmation and must be used only for a trusted directory.

Sources: https://cursor.com/docs/cli/overview and https://cursor.com/docs/cli/reference/parameters
