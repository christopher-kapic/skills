# AGENTS.md

## What this repository is

A collection of portable Agent Skills. Each skill is one directory containing a `SKILL.md` with `name` and `description` frontmatter, plus optional `references/`, `scripts/`, and `agents/` siblings. There is no build step, no package manifest, and no test suite. The Markdown is the product.

## Layout rules

Organize skills under a domain directory that reflects the kind of work the skill does:

```
skills/<domain>/<skill-name>/SKILL.md
```

The domain directory is organizational; the skill directory name is the identifier that harnesses use, so it must match the `name` field in frontmatter.

## Authoring conventions

These are load-bearing. Existing skills follow them, and reviewers check for them.

1. **Frontmatter carries `name` and `description`, and nothing else that is harness-specific.** The `description` states what the skill does and the situations that trigger it, because that field drives automatic invocation. Keep the body free of `$name` or `/name` invocation syntax; refer to sibling skills by name in plain language, so the skill works in any harness that implements the format.
2. **Write instructions for a worker with no shared context.** Skills here are consumed by delegated subagents and by external processes launched through `invoke-harness`. A worker may never see the conversation that produced the task, so a skill must supply the goal, role, context, and reporting format in the prompt itself. Never assume conversation state carries over.
3. **Prefer single-agent coordination over in-process reasoning.** The pattern across these skills is that the main agent coordinates while fresh workers perform every implementation, review, or planning pass. When you extend a skill, preserve that separation rather than folding work back into the coordinator.
4. **Make every requirement observable.** Ask for concrete evidence — a command and its result, a cited `path:line`, a named artifact — rather than a summary of what the worker believes. Requirements that cannot be checked tend to be silently dropped.
5. **State limits explicitly.** Workers run with finite time, memory, and concurrency budgets, and a worker that exceeds them should report the gap rather than fabricate a pass. Name the budget and the required behavior when the budget runs out.
6. **Keep severity and disposition separate.** A finding's severity describes the defect; deferral describes whether work is scheduled now. Do not let a deferral reduce severity, and do not treat a clean review as approval.
7. **Write affirmative instructions.** Tell the agent what to do. Reach for a prohibition only where a specific action must be prevented, and say what to do instead.
8. **Treat token cost and model price as design constraints.** See [Token and model efficiency](#token-and-model-efficiency).

## Token and model efficiency

Skills are read on every invocation and often re-pasted into worker prompts, so verbosity is a recurring cost. Keep text that changes outcomes; cut the rest.

### Token efficiency

- **Earn every line.** A line is worth its tokens only if it changes what the agent does. Delete restatement, motivation, hedging, and anything the agent can infer from the task or the repository. Prefer one precise rule to three examples of the same rule.
- **Load context lazily.** Keep the `SKILL.md` body to the loop, the inputs, and the tables needed to route work. Put checklists and procedures in `references/` and tell the reader when to open each file. `review-loop` is the model: its `SKILL.md` holds the loop and a watch-list table, while each checklist lives in `references/watch/<tag>.md`, so a reader who never matches a watch-list never pays for it.
- **Route with tables, prose for procedures.** Surface tags, watch-lists, and harness flags belong in tables. Do not enumerate the same set twice. Match the density of the surrounding skill.
- **Build each prompt from the parts that worker needs.** Supply that worker's settings, focus, and matched references — not the whole corpus. Attach a watch-list only when the diff touches its surface.
- **Reference by path.** Link between files with repository-relative paths (`references/watch/web-ui.md`) instead of quoting contents. Duplicated content drifts and doubles the token cost.
- **Keep fallbacks narrow.** A skill whose coordinator may be unable to read `references/` may also give the raw GitHub URL on the `master` branch, used as one canonical source per run, as `review-loop` does for its watch-lists. It is not a second copy of every file.

### Model efficiency

- **Match model capability to the pass.** Expensive, high-reasoning models belong where judgment is the binding constraint: root-cause design, security-boundary work, authorization and concurrency fixes, and adjudicating disputed findings. Cheaper models suit mechanical edits, formatting, documentation, tests against a settled design, and context gathering.
- **Offload exploration.** Route context gathering through `explore-offload`: a cheap scout selects excerpts and filters captured test logs, and each expensive worker starts from the part tagged for its focus instead of exploring from scratch. The expensive worker still owns every conclusion, and one strong reviewer per substantive cycle works without a bundle so a scout omission cannot blind every reviewer.
- **Do not infer capability from a vendor name or a price tier.** Establish what a model can actually do, and keep one probe-capable reviewer in any substantive cycle regardless of tier.
- **Escalate only when the cheap pass stalls.** Re-run on a stronger model, within the user's settings, when the same finding survives a fix pass without new closure evidence.
- **Name real model IDs.** Give identifiers that resolve in the target harness, not marketing nicknames, and instruct the reader to confirm them with the harness's model-list command, which `invoke-harness` records per harness.

## Changing or adding a skill

Before editing, read the full skill and any reference files it points to. A change to a `SKILL.md` body often invalidates a claim in a reference file, and vice versa.

When adding a skill:

1. Create `skills/<domain>/<skill-name>/SKILL.md` with `name` matching the directory and a trigger-rich `description`.
2. Add `agents/openai.yaml` alongside it if the skill should expose a display name and default prompt to harnesses that read that file. Follow the existing three-field shape (`interface.display_name`, `short_description`, `default_prompt`).
3. Update the skill table in `README.md`.

When removing a skill, delete the whole directory and its README row. Skills reference each other by name in plain language — `ck-plan` names `user-decision`, and `review-loop` names `invoke-harness` — so run `grep -rn '<skill-name>'` and repair any dangling reference before deleting.

## Validating a change

There is no test suite. Validate by reading and by checking the mechanical properties:

- Frontmatter parses and `name` matches the directory name.
- Every relative link inside the changed skill resolves to a file that exists.
- Any watch-list tag in a `SKILL.md` matches a filename in `references/watch/` exactly.
- The skill body still reads correctly for a worker with no conversation context.
- No text is duplicated between a `SKILL.md` and its `references/` files, and no prompt assembly instruction pulls in material the worker does not need.
- Every model identifier a skill names resolves in its target harness.
- Any changed script runs against a sample input.

For a substantive change to a skill's instructions, run the change through `review-loop` or obtain an independent review before pushing.
