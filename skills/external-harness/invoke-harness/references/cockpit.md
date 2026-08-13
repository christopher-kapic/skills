# Cockpit

**Treat noninteractive use as experimental.** Verified locally with Cockpit 0.1.0. Before real work, recheck `cockpit run --help` and run a harmless read-only smoke test.

```sh
cockpit run -C <dir> -m <provider/model> --permission-mode auto --max-turns <n> --timeout <seconds> "<prompt>"
cockpit run -C <dir> -m <provider/model> --permission-mode auto --max-turns <n> --timeout <seconds> --prompt-file prompt.txt
```

- **Models:** `-m/--model` uses `provider/model-id`. List configured models with `cockpit models`; refresh provider catalogs with `cockpit fetch-models` only when authorized.
- **Directory:** `-C/--cwd`; it controls trust, sandbox, attachments, and session resolution.
- **Prompt:** Message arguments, stdin when omitted, or `--prompt-file`; prefer the file for long prompts.
- **Sandbox:** Enabled by default for created sessions. `--no-sandbox` removes filesystem confinement but does not itself change approval mode.
- **Permissions:** `manual`, `auto`, or `yolo`. `auto` fails closed without a guard model. `yolo` is unattended but hard gates still apply. `--approve <class>` grants only the named class for this run.

Use `--ephemeral`, a finite `--max-turns`, and `--timeout` for automation. Do not rely on Cockpit for a critical loop until its smoke test exits cleanly and produces complete output.
