# Christopher Kapic's AI Skills

A collection of Agent Skills for getting reliable engineering work out of coding agents. The skills cover planning, adversarial review, delegation to external harnesses, and pruning analysis down to the decisions a person actually has to make.

Every skill follows the portable Agent Skills format: a directory containing a `SKILL.md` with `name` and `description` frontmatter, plus optional `references/`, `scripts/`, and `agents/` siblings. The content is plain Markdown, so any harness that discovers skills can load it.

## Skills

| Skill | What it does | Triggers |
|---|---|---|
| [review-loop](skills/engineering/review-loop/SKILL.md) | Implements, tests, independently reviews, and fixes a code change through bounded cycles. Runs alone or uses a prior plan as optional input. | "review this until it's ready", "harden this", "iterate on this" |
| [ck-plan](skills/engineering/ck-plan/SKILL.md) | Produces an ordered, repository-grounded implementation plan through independent drafting and review. Runs alone; its plan can optionally inform implementation. | "plan this feature", "write a reviewed plan", "refine the approach" |
| [explore-offload](skills/engineering/explore-offload/SKILL.md) | Uses a cheap scout to select code and test-log ranges into a manifest, then renders line-numbered bundles for each worker's focus. | "gather context cheaply", "offload exploration" |
| [invoke-harness](skills/external-harness/invoke-harness/SKILL.md) | Runs Codex, Claude Code, Grok, OpenCode, Cursor CLI, GitHub Copilot CLI, or Cockpit as a bounded noninteractive worker with an explicit model and scope. | "run this through Codex", "delegate to Claude Code", "review loop with Grok" |
| [user-decision](skills/communication/user-decision/SKILL.md) | Reduces choice-heavy output to a short, ranked decision queue instead of a wall of options. | "what do I need to decide?", "simplify this", "give me options" |

## Repository layout

The tree groups skills by domain. The grouping is organizational only; a skill's directory name is what identifies it.

```
skills/
  communication/     user-decision
  engineering/       ck-plan, explore-offload, review-loop
  external-harness/  invoke-harness
```

`review-loop` carries most of the reference material:

```
skills/engineering/review-loop/
  SKILL.md
  references/
    worker-briefs.md      common and per-role briefs pasted into worker prompts
    run-artifacts.md      evidence states, snapshots, replay proofs, final review
    watch/                surface-specific checklists, one file per tag
```

## Install

These skills are distributed with the [Skills CLI](https://github.com/vercel-labs/skills), which installs them globally and symlinks one canonical copy into each detected agent directory:

```sh
npx skills add christopher-kapic/skills -g
```

Global installs land in `~/.agents/skills/` and are tracked in `~/.agents/.skill-lock.json`, with symlinks created into `~/.grok/skills/`, `~/.claude/skills/`, `~/.cursor/skills/`, and similar locations. To target specific agents or refresh an existing install:

```sh
npx skills add christopher-kapic/skills -g -a claude-code -a grok
npx skills update -g
```

Installing from a published revision means your local copy reflects what was pushed, not uncommitted changes in this working tree. To pick up local edits, either commit and push, or install from the directory with `npx skills add . -g`.

Once installed, skills can be invoked by name (as slash commands in harnesses that support them) and can also be invoked automatically when the task matches their `description`.
