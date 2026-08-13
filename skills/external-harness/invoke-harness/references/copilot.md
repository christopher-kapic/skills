# GitHub Copilot CLI

The `copilot` executable was not installed during verification. Recheck `copilot help`.

```sh
copilot -C <dir> -p "<prompt>" --model=<model> --sandbox --allow-tool='<narrow rules>'
```

- **Models:** `--model=<model>` or `COPILOT_MODEL`; `auto` delegates selection. No account-specific model-list flag is documented; use interactive `/model` or the current supported-model list.
- **Directory:** `-C <dir>`. `--add-dir` only adds allowed paths.
- **Prompt:** `-p/--prompt`. No prompt-file flag is documented. For a very long prompt, put it in the workspace and give a short prompt that references the file.
- **Sandbox:** `--sandbox` or `--no-sandbox` is experimental. Local sandboxing restricts filesystem, network, and system access.
- **Permissions:** Programmatic edits need allow rules. Prefer narrow `--allow-tool`, `--deny-tool`, and path/URL rules. `--allow-all`, `--allow-all-tools`, or `--yolo` can grant the harness the user's full host privileges when isolation is absent or insufficient.

Deny rules override allows. Treat `--allow-all-tools` and sandboxing as separate choices, and do not assume preview sandbox behavior is stable.

Sources: https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-copilot-cli and https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference
