# OpenCode

Verified locally with OpenCode 1.3.17; recheck `opencode run --help`.

```sh
opencode run --dir <dir> -m <provider/model> "<prompt>"
opencode run --dir <dir> -m <provider/model> -f <prompt-file> "Follow the attached instructions."
```

- **Models:** `-m/--model` uses `provider/model`. List with `opencode models [provider]`; use `--refresh` when network access is allowed.
- **Directory:** `--dir`.
- **Prompt:** Remaining arguments form the message. No dedicated prompt-file option is documented; attach a long prompt with `-f` and use a short instruction.
- **Permissions:** Configure `allow`, `ask`, and `deny` rules in OpenCode config or `OPENCODE_PERMISSION`. Some releases expose `--auto`; use it only when current help lists it. Deny rules still win.
- **Sandbox:** No OS sandbox flag is documented. Tool permissions are application controls, not containment. Use an outer OS/container sandbox when isolation matters.

Defaults are permissive for most tools; external-directory and loop detection default to ask. In a noninteractive run, ask rules can block progress. Deny edits, shell commands, network tools, and external paths that the task does not need.

Sources: https://opencode.ai/docs/cli/ and https://opencode.ai/docs/permissions/
