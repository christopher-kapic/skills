---
name: review-loop
description: Implement important or complex changes in a git repository through independent review-and-fix cycles. Use when a user asks for an implementation to be repeatedly reviewed, hardened, or iterated until it is ready to ship.
---

# Review Loop

Run an implement → test → independent review → fix loop. The main agent only coordinates; delegate every implementation and review pass to a fresh subagent or non-interactive external harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); implementation harness/model = current; review harness/model = current; review parallelism = 1; greenfield = false; test lifecycle = `parallel`; max cycles = unlimited.

Treat `greenfield: true` as permission to make breaking changes. Otherwise, preserve compatibility; ask before a breaking change.

## Clarify decisions

If implementation details require user intent, use `$user-decision` before proceeding. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire review loop.

## Loop

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one implementation pass the goal and accumulated findings. Use a fresh subagent if the selected harness is current; otherwise invoke the external harness non-interactively.
2. Capture the git diff. For `before_review`, run relevant tests and wait for results. For `parallel`, start tests without waiting.
3. While `parallel` tests run or after `before_review` tests finish, delegate `review parallelism` independent review passes to fresh subagents if the review harness is current; otherwise use its external harness. Give each worker the goal, diff, relevant project context, and available test results. Ask for actionable correctness, compatibility, security, maintainability, or missing-test issues with file and line references; list out-of-scope suggestions and generalizable learnings separately.
4. For `parallel`, collect test results after reviews. For `after_review`, run tests now. For `skip`, do not run tests. Combine duplicate review findings and current test failures. If none remain, stop; otherwise pass accumulated review findings and only the latest test results to the next implementation worker.

Do not report a change as ready if tests failed or required tests were skipped without saying so. On completion, summarize the implementation, review outcome, tests, risks, and out-of-scope suggestions. Briefly explain any generalizable reviewer learnings and ask whether to add them to `AGENTS.md` or `CLAUDE.md`.
