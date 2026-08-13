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

1. Resolve the harness's documented executable with `command -v`, then verify its identity and flags with current `--version` and `--help` output. Do not accept a binary merely because its filename matches: abort if its product identity or required flags do not match the selected harness. Local help overrides these references.
2. Use the harness's noninteractive mode. Set the model and working directory explicitly. Start a fresh session unless the user requests continuation.
3. Pass short prompts as one quoted argument. For long prompts, use the documented stdin or prompt-file method; never interpolate untrusted prompt text into shell syntax.
4. Choose the narrowest sandbox and permissions that can complete the task. Treat approval modes and tool allowlists as separate from OS isolation. Disable isolation only with explicit authorization or a trusted outer sandbox.
5. Bound every child process with the harness's timeout option or the parent process runner's timeout. Capture stdout, stderr, and the exit status. Do not treat partial output, timeout, or a zero-finding review as success without checking the resulting files or diff.

Sandboxes can block network, package caches, temp paths, Git metadata, sibling directories, sockets, or child processes. Add only the access the task needs. Broad write access can expose credentials or executable startup files.

Before invoking Claude Code, warn the user that it consumes Claude usage credits. Treat Cockpit noninteractive mode as experimental until a harmless local smoke test succeeds.

## Executables

Use only these product commands; aliases supplied by a different product do not count:

- Codex: `codex`
- Claude Code: `claude`
- Grok: `grok` (never its compatibility alias `agent`)
- OpenCode: `opencode`
- Cursor CLI: `agent`; reject it if help/version identifies Grok or lacks Cursor's required flags
- GitHub Copilot CLI: `copilot`
- Cockpit: `cockpit`

Cursor does not currently document `cursor` as its CLI executable. Because both Cursor and Grok can provide an `agent` command, identity verification is mandatory before invoking Cursor.
