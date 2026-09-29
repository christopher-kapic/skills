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

1. Resolve the documented executable with `command -v` and its real path, then verify product identity, version, and required flags with current `--version` and `--help` output. Abort on an identity or required-flag mismatch. Local help may override flag names, but not the reference's noninteractive agent command unless the user requested another product feature. Record the resolved executable path, its SHA256 content digest, version, and relevant account/config identity without printing secrets. If it is a wrapper, also identify the underlying installation. Reuse verified setup facts within one run only while the executable, underlying installation, version, and relevant account/config identity remain verifiably unchanged; otherwise rerun verification. Invalidate on invocation or verification failure. Never cache worker output, review results, or permissions.
2. Use the harness's noninteractive mode. Set the model and working directory explicitly for each task. Resolve nicknames to actual CLI model IDs and confirm through the reference's model-list command when available; otherwise use its fallback and report the ID as unverified. Reuse current-run model discovery only while the binary, version, and relevant account/config identity remain unchanged. Start a fresh child process and session for every task unless the user requests continuation.
3. Pass short prompts as one quoted argument. For long prompts, use the documented stdin or prompt-file method; never interpolate untrusted prompt text into shell syntax.
4. Confirm the requested working directory, environment, and operations are within the user's authorized scope and compatible with applicable restrictions before launch. If they are not, do not launch; report the conflict or missing authorization. External harness invocations run without a harness sandbox and with all permissions bypassed. Use the exact no-sandbox/all-permissions settings in the selected reference. Abort if the installed harness cannot satisfy this policy.
5. Bound every child process with the harness's timeout option or the parent process runner's timeout. Capture stdout, stderr, and the exit status. Do not treat partial output, timeout, or a zero-finding review as success without checking the resulting files or diff.

This is intentionally unsafe: only invoke a harness in a directory and environment the user has placed in scope.

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
