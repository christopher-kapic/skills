---
name: review-loop
description: Implement important or complex changes in a git repository through independent review-and-fix cycles. Use when a user asks for an implementation to be repeatedly reviewed, hardened, or iterated until it is ready to ship.
---

# Review Loop

Run an implement → test → independent review → fix loop. The main agent only coordinates; delegate every implementation and review pass to a fresh worker.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); implementation harness/model = current; review harness/model = current; review parallelism = 1; greenfield = false; test lifecycle = `parallel`; max cycles = unlimited; `propose_improvements` = false.

Treat `greenfield: true` as permission to make breaking changes. Otherwise, preserve compatibility; ask before a breaking change.

When `propose_improvements: true`, collect candidate changes to this skill's reusable implementation and review instructions that could prevent similar review findings in future delegated runs. Do not collect them when false. These proposals are advisory only; do not modify the skill or repository instructions unless the user separately asks.

## Clarify decisions

If implementation details require user intent, invoke the `user-decision` skill before proceeding. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire review loop.

## Worker selection

For `current`, use a fresh native subagent when the current harness supports one. Otherwise, invoke a fresh noninteractive process of the current harness through the `invoke-harness` skill. For any named external harness, use `invoke-harness`. Each worker must receive the goal and required context in its initial prompt; do not rely on conversation state shared by a previous worker.

Interpret “review loop with X” as X reviews while the current harness's fresh native subagents implement, unless the user explicitly assigns implementation to X. Honor explicit role assignments such as “X implements; Y reviews.”

## Reviewer brief

Include this brief verbatim in every review worker prompt and in the critic prompt:

1. Review claimed invariants and every production consumer of the changed invariants, not only the hunks. If you cannot enumerate the consumers, file a blocking finding: enumeration incomplete. Such a finding may be closed by a documented completeness argument (an exhaustive search, a type- or ownership-based bound), not only by reviewing each consumer individually.
2. For a new gate, fence, or boundary: every operation that can enter, exit, or bypass it — including timeout, shutdown, and re-entry paths, and sibling APIs that touch the same state — is in scope on the first review.
3. For shared-state changes: check object identity vs recycled ids; who owns the write after cancel/timeout; and lock/permit order of both the current code and any remedy. Do not recommend a lock strategy you have not checked against existing acquisition sites. State the invariant and the missing proof, not a patch recipe.
4. For new tests and macros: would this compile, and would it fail on the defect it claims to catch?
5. Do not change established observable ordering (authz, error kind) unless `greenfield` is true or the goal says to.
6. For incremental enforcement mechanisms (ratchets), state what property the mechanism fully closes and what class of violations remains possible. File the remaining class once; do not file an endless series of example bypasses.

## Loop

Keep an accumulated open-finding list with status (open, closed, deferred). Blocking findings and current test failures are required items; they stay open until closed or explicitly deferred. Only the user may defer a required item; in a noninteractive run the coordinator may defer one, and must record each deferral and its reason in the end report. Do not expand the design while required work from earlier cycles is still sitting there, unless the redesign is a prerequisite. A reviewed consumer list or acquisition-order table unblocks coding; it does not close remaining required items.

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one implementation pass using the worker-selection rule. Give it the goal, `greenfield`, the open-finding list with status, and only the latest test results. Instruct it to close required open items and not expand the design unless that expansion is a prerequisite for a required item. If a prior cycle's findings showed the implementation did not know all consumers or lock orderings, instruct it to include in its response a short consumer list and the lock/permit acquisition order it relies on, rather than adding new mechanism to compensate.
2. Capture the git diff. For `before_review`, run relevant tests and wait for results. For `parallel`, start tests without waiting.
3. While `parallel` tests run or after `before_review` tests finish, delegate `review parallelism` independent review passes to fresh workers using the worker-selection rule. Give each worker the goal, `greenfield`, the diff, any consumer list or acquisition-order table from step 1, relevant project context, available test results, and the reviewer brief verbatim. Ask for actionable correctness, compatibility, security, maintainability, or missing-test issues. Require code evidence (`path:line`, symbol, or test result) for each actionable finding; label anything not yet verifiable as a concern. List out-of-scope suggestions separately. If test lifecycle is `skip`, instruct reviewers to widen to an invariant/consumer audit, not shrink to the diff. When `propose_improvements` is true, also list separately any generalizable skill-instruction improvements that would have enabled an earlier implementation or review worker to avoid the finding; exclude project-specific implementation advice.
4. Have one fresh critic audit the reviews against the goal, diff, repository, available test results, any consumer list or acquisition-order table, and the reviewer brief. Its response must end with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <code citation or test result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as supported by the cited evidence. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass using the worker-selection rule, then retain only claims grounded in code or tests. Do not continue reviewer–critic debate beyond this pass.
5. For `parallel`, collect test results after reviews. For `after_review`, run tests now. For `skip`, do not run tests. Combine duplicate evidence-backed findings and current test failures into the open-finding list. Take the union of reviewers; a “no blockers” report from one reviewer does not dilute another's blocking finding. If none remain, stop; otherwise pass the list and only the latest test results to the next implementation worker.

Do not report a change as ready if tests failed or required tests were skipped without saying so. On completion, summarize the implementation, review outcome, tests, risks, and out-of-scope suggestions. If `propose_improvements` is true, add a concise **Potential skill improvements** section to the end report. Each item must state the reusable instruction change and the category of review iteration it is expected to prevent; omit empty or project-specific suggestions. Do not add the proposals to `AGENTS.md`, `CLAUDE.md`, or the skill unless the user separately asks.
