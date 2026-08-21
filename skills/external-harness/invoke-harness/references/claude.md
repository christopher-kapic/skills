# Claude Code

**Warn the user before invocation: Claude Code consumes Claude usage credits.** Verified locally with Claude Code 2.1.228; recheck `claude --help`.

```sh
claude -p --no-session-persistence --model <model> --dangerously-skip-permissions "<prompt>"
claude -p --no-session-persistence --model <model> --dangerously-skip-permissions < prompt.txt
```

- **Models:** `--model` accepts an alias or full ID. No model-list subcommand is exposed; use interactive `/model`, current documentation, or an organization-approved ID.
- **Directory:** The process working directory is the project root. `--add-dir` grants access to additional directories; it does not replace the working directory.
- **Prompt:** Positional argument or stdin with `-p`; use stdin for long prompts.
- **Permissions:** `--dangerously-skip-permissions` bypasses all checks.
- **Sandbox:** Do not configure Claude's sandbox.

Source: https://code.claude.com/docs/en/sandboxing
