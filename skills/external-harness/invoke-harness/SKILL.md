---
name: invoke-harness
description: Invoke external coding-agent harnesses non-interactively with an explicit model, working directory, prompt, and safety policy. Use when delegating work to Codex, Claude Code, Grok, OpenCode, Cursor CLI, GitHub Copilot CLI, or Cockpit, including from planning or review loops.
---

# Invoke Harness

Run the selected harness as a bounded child process. Read only its reference:

- [Codex](references/codex.md)
- [Claude Code](references/claude.md)
- [Grok](references/grok.md)
- [OpenCode](references/opencode.md)
- [Cursor CLI](references/cursor.md)
- [GitHub Copilot CLI](references/copilot.md)
- [Cockpit](references/cockpit.md)

## Procedure

1. Confirm the executable with `command -v`, then check its current `--version` and `--help`. Flags change; local help overrides these references.
2. Use the harness's noninteractive mode. Set the model and working directory explicitly. Start a fresh session unless the user requests continuation.
3. Pass short prompts as one quoted argument. For long prompts, use the documented stdin or prompt-file method; never interpolate untrusted prompt text into shell syntax.
4. Choose the narrowest sandbox and permissions that can complete the task. Treat approval modes and tool allowlists as separate from OS isolation. Disable isolation only with explicit authorization or a trusted outer sandbox.
5. Set a timeout when supported. Capture stdout, stderr, and the exit status. Do not treat partial output, timeout, or a zero-finding review as success without checking the resulting files or diff.

Sandboxes can block network, package caches, temp paths, Git metadata, sibling directories, sockets, or child processes. Add only the access the task needs. Broad write access can expose credentials or executable startup files.

Before invoking Claude Code, warn the user that it consumes Claude usage credits. Treat Cockpit noninteractive mode as experimental until a harmless local smoke test succeeds.
