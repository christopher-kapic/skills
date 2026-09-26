---
name: explore-offload
description: Offload repository exploration and test-log filtering to a cheap scout model that writes a manifest, then render it into compact, line-numbered bundles of code excerpts and filtered test output, one per worker focus, for expensive workers to read instead of exploring. Use when a planner, reviewer, or implementer on a costly model needs context spanning many files, or when planning and review loops hand repository context to workers.
---

# Explore Offload

A cheap scout finds the relevant code and writes a manifest of excerpt ranges and test-log filters, tagging entries that serve only one focus. A fixed renderer turns the manifest into a bundle of raw, line-numbered code and filtered test output for each focus. The goal is to minimize the expensive worker's input tokens and exploration: the bundle holds everything it needs and nothing else, so it may explore further but does not have to. The scout selects; it never draws conclusions.

## Inputs

The requester supplies:

- **purpose:** why the context is needed — the consumers' roles, plus one whitespace-free tag per focus with its matched watch-lists (for example "review of the auth refactor; `correctness`: concurrency-and-state; `trust-boundary`: authz-boundaries"). The scout selects for these.
- **seed:** the task diff, named entry points, or a previous manifest with the files consumers added.
- **logs:** check output already captured on the current tree, or none. The scout filters logs; it never runs tests. Capture each check into the scratch directory you will give the scout:

  ```sh
  { <command>; } > <scratch>/<name>.log 2>&1; echo $? > <scratch>/<name>.log.exit
  ```

  Add the runner's options that disable color and quiet passing output when they exist.

Defaults: scout model = the harness's cheapest fast model; bundle cap = 60000 characters (about 15k tokens) for the whole manifest; scout budget = 10 minutes.

Skip this skill and give files directly when the relevant code is already known and under about 300 lines, or when POSIX `sh` and git are unavailable.

Only if you cannot read this skill's files, fetch `references/manifest.md` and `scripts/render.sh` from `https://raw.githubusercontent.com/christopher-kapic/skills/master/skills/engineering/explore-offload/` into the scratch directory, read the script and confirm it matches its header (read-only, writes only to stdout, no network), then use those scratch copies wherever this skill names its files, for the whole run. It may differ from the installed version; treat a failed or unexpected fetch as a reason to skip this skill.

## Procedure

1. Delegate one scout pass to a fresh worker, using a native subagent or `invoke-harness`. Paste the [scout brief and manifest format](references/manifest.md) into its prompt with the purpose, seed, log names, repository root, bundle cap, budget, the scratch directory holding the logs, and the command `sh <this skill>/scripts/render.sh --tree`.
2. From the repository root, run `sh <this skill>/scripts/render.sh [--focus <tag>] <manifest> [cap] > <bundle>` once per focus, and once without `--focus` for consumers that need every section. It prints each excerpt with line numbers, each test's exit code, filter matches, and chosen log ranges with color codes stripped, the tree check, flagged entries, and a character total. It exits 1 when any entry is flagged. A failing test with no chosen log ranges shows its log tail, so a narrow filter cannot hide the failure.
3. If the render flags entries, shows no `searched:` lines, or omits a given log, return the manifest and render output to the scout once. If still flagged, run one fresh scout one model tier up when the harness has one; if that is still flagged, use the valid entries and state the gap to the consumer.
4. Give each consumer the bundle for its focus by path, or paste it at the start of the prompt when the consumer cannot read files, with this instruction: "This bundle was selected by a cheaper model and may omit relevant code. Cite `path:line` from the repository. When a claim depends on code not shown, read it yourself, and list the files you added under `Context added`. Test results are valid only for the TREE shown; search the raw log path when the excerpt is not enough."
5. Re-render for every new snapshot. On `STALE tree`, re-run the scout seeded with the previous manifest, the change since, `Context added` lists, and logs captured on the new tree; it re-anchors ranges.

Report the scout's model, elapsed time, bundle line count, and any gap alongside the consumer's result.
