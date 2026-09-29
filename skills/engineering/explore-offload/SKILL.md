---
name: explore-offload
description: Offload repository exploration and test-log filtering to a cheap scout model that writes a manifest, then render compact, line-numbered excerpts and filtered logs for costly workers. Use when repeated exploration across many files is likely to cost more than scouting and focused bundles.
---

# Explore Offload

A cheap scout selects relevant code ranges and test-log filters by consumer focus. A fixed renderer makes raw, line-numbered bundles. The scout selects context; consumers inspect the repository and own conclusions.

## Inputs

The requester supplies:

- **purpose:** why context is needed; each consumer's role, question, and one whitespace-free focus tag; matched watch-lists only for consumers that need them. The scout selects for these.
- **seed:** the task diff, named entry points, or a previous manifest with the files consumers added.
- **logs:** check output already captured on the current tree, or none. The scout filters logs; it never runs tests. Capture each check into the scratch directory you will give the scout:

  ```sh
  { <command>; } > <scratch>/<name>.log 2>&1; echo $? > <scratch>/<name>.log.exit
  ```

  Add the runner's options that disable color and quiet passing output when they exist.

Defaults: scout model = the cheapest fast model known capable of accurate context selection; bundle cap = 60000 characters (about 15k tokens) for the whole manifest; scout budget = 10 minutes.

Estimate the scout, rendering, and bundle-reading cost against repeated exploration avoided. Skip this skill when savings are unlikely, including known context under about 300 lines; give those files directly. Skip when POSIX `sh` or git is unavailable.

Only if you cannot read this skill's files, fetch `references/manifest.md` and `scripts/render.sh` from `https://raw.githubusercontent.com/christopher-kapic/skills/master/skills/engineering/explore-offload/` into the scratch directory, read the script and confirm it matches its header (read-only, writes only to stdout, no network), then use those scratch copies wherever this skill names its files, for the whole run. It may differ from the installed version; treat a failed or unexpected fetch as a reason to skip this skill.

## Procedure

1. Delegate one scout pass to a fresh worker, using a native subagent or `invoke-harness`. Paste the [scout brief and manifest format](references/manifest.md) into its prompt with the purpose, seed, log names, repository root, bundle cap, budget, the scratch directory holding the logs, and the command `sh <this skill>/scripts/render.sh --tree`.
2. From the repository root, run `sh <this skill>/scripts/render.sh [--focus <tag>] <manifest> [cap] > <bundle>` for each needed focus. Render without `--focus` only when a consumer actually needs every section. It prints line-numbered excerpts, test exit codes and filtered log evidence, tree checks, flagged entries, and a character total; it exits 1 for flagged entries. A failing test with no chosen log ranges shows its log tail.
3. If the render flags entries, shows no `searched:` lines, or omits a given log, inspect whether the cause is stale context, invalid ranges, tooling, or selection. Return the manifest and render output to the scout once. If a selection failure remains, try one fresh capable scout on a stronger model within the budget; otherwise use valid entries and state the gap to the consumer.
4. Give each consumer its focused bundle by path, or paste it when the consumer cannot read files, with this instruction: "A cheaper model selected this context and may have omitted relevant code. Cite `path:line` from the repository. Read additional source when needed and list it under `Context added`. Test results apply only to the TREE shown; inspect raw logs when excerpts are insufficient." Give a short index of manifest, raw log, and other relevant artifact paths so the consumer can expand without receiving every bundle.
5. Re-render for every new snapshot. On `STALE tree`, re-run the scout seeded with the previous manifest, the change since, `Context added` lists, and logs captured on the new tree; it re-anchors ranges.

Report the scout's actual model ID, harness, elapsed time, bundle size, consumer time/token cost and `Context added` where available, and any gaps. Mark unavailable cost metrics `unknown`; compare with the initial savings estimate for the next routing decision.
