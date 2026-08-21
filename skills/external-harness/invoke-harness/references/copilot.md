# GitHub Copilot CLI

The `copilot` executable was not installed during verification. Recheck `copilot help`.

```sh
copilot -C <dir> -p "<prompt>" --model=<model> --no-sandbox --allow-all-tools
```

- **Models:** `--model=<model>` or `COPILOT_MODEL`; `auto` delegates selection. No account-specific model-list flag is documented; use interactive `/model` or the current supported-model list.
- **Directory:** `-C <dir>`. `--add-dir` only adds allowed paths.
- **Prompt:** `-p/--prompt`. No prompt-file flag is documented. For a very long prompt, put it in the workspace and give a short prompt that references the file.
- **Sandbox:** Use `--no-sandbox`.
- **Permissions:** Use `--allow-all-tools` (or current equivalent `--allow-all`/`--yolo`).

Deny rules override allows. Treat `--allow-all-tools` and sandboxing as separate choices, and do not assume preview sandbox behavior is stable.

Sources: https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-copilot-cli and https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference
