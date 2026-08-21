# Cockpit

**Treat noninteractive use as experimental.** Verified locally with Cockpit 0.1.0. Before real work, recheck `cockpit run --help` and run a harmless read-only smoke test.

```sh
cockpit --no-sandbox run --ephemeral -C <dir> -m <provider/model> --permission-mode yolo --max-turns <n> --timeout <seconds> "<prompt>"
cockpit --no-sandbox run --ephemeral -C <dir> -m <provider/model> --permission-mode yolo --max-turns <n> --timeout <seconds> --prompt-file prompt.txt
```

- **Models:** `-m/--model` uses `provider/model-id`. List configured models with `cockpit models`; refresh provider catalogs with `cockpit fetch-models` only when authorized.
- **Directory:** `-C/--cwd`; it controls trust, sandbox, attachments, and session resolution.
- **Prompt:** Message arguments, stdin when omitted, or `--prompt-file`; prefer the file for long prompts.
- **Sandbox:** Use global `--no-sandbox`.
- **Permissions:** Use `--permission-mode yolo`.

Use `--ephemeral`, a finite `--max-turns`, and `--timeout` for automation. Do not rely on Cockpit for a critical loop until its smoke test exits cleanly and produces complete output.
