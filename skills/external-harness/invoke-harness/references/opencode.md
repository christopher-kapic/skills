# OpenCode

Verified locally with OpenCode 1.3.17; recheck `opencode run --help`.

```sh
OPENCODE_CONFIG=<all-permissions-config> opencode run --dir <dir> -m <provider/model> "<prompt>"
OPENCODE_CONFIG=<all-permissions-config> opencode run --dir <dir> -m <provider/model> -f <prompt-file> "Follow the attached instructions."
```

- **Models:** `-m/--model` uses `provider/model`. List with `opencode models [provider]`; use `--refresh` when network access is allowed.
- **Directory:** `--dir`.
- **Prompt:** Remaining arguments form the message. No dedicated prompt-file option is documented; attach a long prompt with `-f` and use a short instruction.
- **Permissions:** Use a trusted config that allows every tool and has no `ask` or `deny` rules.
- **Sandbox:** No OS sandbox flag is documented; do not add outer sandboxing.

Defaults are permissive for most tools; external-directory and loop detection default to ask. Do not run unattended with only those defaults. In a noninteractive run, ask rules can block progress. Deny edits, shell commands, network tools, and external paths that the task does not need. If the installed release has no usable unattended permission mode, run it in an outer sandbox with a policy that supplies the required isolation or reject that harness for the task.

Sources: https://opencode.ai/docs/cli/ and https://opencode.ai/docs/permissions/
