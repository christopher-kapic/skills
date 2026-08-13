# Claude Code

**Warn the user before invocation: Claude Code consumes Claude usage credits.** Verified locally with Claude Code 2.1.228; recheck `claude --help`.

```sh
claude -p --model <model> --permission-mode dontAsk "<prompt>"
claude -p --model <model> --permission-mode dontAsk < prompt.txt
```

- **Models:** `--model` accepts an alias or full ID. No model-list subcommand is exposed; use interactive `/model`, current documentation, or an organization-approved ID.
- **Directory:** The process working directory is the project root. `--add-dir` grants access to additional directories; it does not replace the working directory.
- **Prompt:** Positional argument or stdin with `-p`; use stdin for long prompts.
- **Permissions:** `--permission-mode dontAsk` rejects operations that need approval, so unattended runs can fail safely. `--dangerously-skip-permissions` bypasses checks and should run only in strong external isolation.
- **Sandbox:** Configure with `--settings`, for example a trusted settings file containing `{"sandbox":{"enabled":true,"failIfUnavailable":true}}`. Without `failIfUnavailable`, Claude can warn and run Bash unsandboxed when sandbox setup fails.

The sandbox confines Bash and its children. Read/Edit/Write use Claude's permission system instead. Sandbox escape retries may run outside isolation unless `allowUnsandboxedCommands` is false. Broad writable paths, allowed domains, Unix sockets, or disabled filesystem isolation can defeat containment.

Source: https://code.claude.com/docs/en/sandboxing
