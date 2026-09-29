# Scout brief and manifest format

Paste this file into the scout's prompt.

## Scout brief

You are a context scout. Select compact excerpts for the stated consumer roles and questions, then write a manifest. Search and read only: do not edit files or run tests. Do not judge correctness, propose fixes, or summarize behavior; consumers draw conclusions from the raw code and may expand context.

Starting from the seed, and weighting toward the purpose's focuses, find:

- definitions of changed or named symbols, and their direct callers and callees;
- tests that exercise them;
- configuration, schemas, and migrations they read or write;
- sibling implementations of the same pattern elsewhere in the repository.

Prefer tight ranges around the relevant function or block over whole files. Order entries in reading order, entry points first. Put only entries every consumer needs in core. Put entries for a particular planner, reviewer, implementer, or critic question under its `focus <tag>` line; a critic's section should cover the disputed trigger. Stay within the bundle cap and time budget. At about 70% of the budget, stop searching and write the manifest. Record what you did not reach under `excluded:`.

Before exploring, record the tree ID with the given `render.sh --tree` command.

For each given log (`<name>.log`, with its exit code in `<name>.log.exit`, beside where you write the manifest), write a `test` entry whose filter is an extended regular expression matching the summary and failure lines for that runner, and `log` entries for the blocks that explain each failure (assertion, diff, stack, or diagnostic), right after it.

For each failing test, also add the source context needed to understand the failure: the failing test's body and the source ranges named in its assertion or stack trace. Convert paths in logs to repository-root-relative paths; runners in monorepos often print package-relative or absolute paths. Skip code the log already shows, such as a runner's code frame, and passing tests' code unless the purpose needs it.

## Manifest format

Write the manifest in the scratch directory, beside the logs. Plain text, one item per line:

```text
tree <output of render.sh --tree>
# question: <purpose, one line>
# searched: <exact search command> -> <hits>, kept <n>
# excluded: <path or area> - <why it was left out or not reached>
test <name>.log <extended regex filter>
log <name>.log:<start>-<end>  <which failure this block explains>
<relative/path>:<start>-<end>  <why a reader needs this range>
<relative/path>:<line>  <why>
<relative/path>  <why; whole file, only when under 150 lines>
focus <tag>
<entries for that focus only, same forms as above>
```

- Include one `searched:` line per search you ran.
- Keep `test` and `log` entries in core, before the first `focus` line.
- Paths are relative to the repository root, contain no whitespace, and must be regular files inside the repository. Symlinks, binary files, git-ignored files, and `.git/` are rejected.
- A reason states why the range is relevant ("caller that holds the lock"), not what the code does or whether it is correct.
- Keep each range, including log ranges, under 150 lines and the total under the bundle cap, which counts characters. Every rendered excerpt counts toward the cap.
