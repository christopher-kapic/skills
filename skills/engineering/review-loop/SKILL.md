---
name: review-loop
description: Implement important or complex changes in a git repository through independent review-and-fix cycles. Use when a user asks for an implementation to be repeatedly reviewed, hardened, or iterated until it is ready to ship.
---

# Review Loop

Run an implement → test → independent review → fix loop. The main agent only coordinates; delegate every implementation and review pass to a fresh worker.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); implementation harness/model = current; review harness/model = current; review parallelism = 1; greenfield = false; test lifecycle = `parallel`; max cycles = unlimited; `propose_improvements` = false; `fix_scope` = `root_cause` (alternative: `immediate`).

Treat `greenfield: true` as permission to make breaking changes. Otherwise, preserve compatibility; ask before a breaking change.

“Unwrap the onion” means `fix_scope: root_cause`: solve at the root so extra layers are unnecessary. If the user says that phrase, use `root_cause` even if `immediate` was set earlier.

When `propose_improvements: true`, collect candidate changes to this skill's reusable implementation and review instructions that could prevent similar review findings in future delegated runs. Do not collect them when false. These proposals are advisory only; do not modify the skill or repository instructions unless the user separately asks.

## Clarify decisions

If implementation details require user intent, invoke the `user-decision` skill before proceeding. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire review loop.

## Worker selection

For `current`, use a fresh native subagent when the current harness supports one. Otherwise, invoke a fresh noninteractive process of the current harness through the `invoke-harness` skill. For any named external harness, use `invoke-harness`. Each worker must receive the goal and required context in its initial prompt; do not rely on conversation state shared by a previous worker. State the worker's role (implementer, reviewer, or critic) and that it is performing that pass only. Instruct it not to re-enter this skill, invoke a nested harness, or wait on stdin.

Interpret “review loop with X” as X reviews while the current harness's fresh native subagents implement, unless the user explicitly assigns implementation to X. Honor explicit role assignments such as “X implements; Y reviews.”

## Implementer brief

Include this brief verbatim in every implementation worker prompt:

1. When changing a gate, fence, boundary, shared-state ownership, or crash/restart-sensitive path, include in your response: the enter, exit, bypass, timeout, shutdown, re-entry, and sibling APIs on the same state; the ownership and lock/permit order you rely on; and, for recoverable external effects, the durable intent that precedes each. A terminal or success state is not a lock. Do not add mechanism to stand in for an incomplete inventory.
2. State that must survive a reload or restart must be persisted. First-pass tests cover the empty/default case and the primary action.

## Reviewer brief

Include this brief verbatim in every review worker prompt and in the critic prompt:

1. Review claimed invariants and every production consumer of the changed invariants, not only the hunks. For a persisted state machine, enumerate durable states, transitions, and reachable production callers; cover success, retry, and conflict. A required transition with no reachable production trigger is a blocking finding. If you cannot enumerate the consumers, file a blocking finding: enumeration incomplete. Such a finding may be closed by a documented completeness argument (an exhaustive search, a type- or ownership-based bound), not only by reviewing each consumer individually.
2. For a new or changed gate, fence, or boundary: every operation that can enter, exit, or bypass it — including timeout, shutdown, and re-entry paths, and sibling APIs that touch the same state — is in scope on the first review.
3. For shared-state changes: check object identity vs recycled ids; who owns the write after cancel/timeout; and lock/permit order of both the current code and any remedy. For recoverable external effects, durable intent precedes the effect. Do not treat a terminal or success state as a lock without proving mutual exclusion and ownership. Do not recommend a lock strategy you have not checked against existing acquisition sites. State the invariant and the missing proof, not a patch recipe.
4. For new tests and macros: would this compile, and would it fail on the defect it claims to catch?
5. Do not change established observable ordering (authz, error kind) unless `greenfield` is true or the goal says to.
6. For incremental enforcement mechanisms (ratchets), state what property the mechanism fully closes and what class of violations remains possible. File the remaining class once as documented remaining risk, not as a required item; do not file an endless series of example bypasses.
7. Report each finding at its root cause and name the full class or causal chain it belongs to, with code evidence. When one root cause surfaces across several layers or sites, file it once as a root-cause finding, not a series of surface instances. Reuse the finding ledger's ID when the class matches; otherwise mark it as a new class.

## Loop

Keep a finding ledger with stable IDs and status (open, closed, deferred). Preserve IDs across cycles; assign a new ID only to a new class. Blocking findings and code test failures are required items; they stay open until closed or explicitly deferred. Environment or tooling failures are reported and can block ready, but are not implementation findings. Only the user may defer a required code item; in a noninteractive run the coordinator may defer one, and must record each deferral and its reason in the end report. Non-required open findings do not drive cycles; report them at the end. Do not expand the design while required work from earlier cycles is still sitting there, unless the redesign is a prerequisite. The implementer's artifacts unblock coding; they do not close remaining required items.

For each cycle, until no required open items remain or `max cycles` is reached:

1. Delegate one implementation pass using the worker-selection rule. Give it the goal, `greenfield`, `fix_scope`, the finding ledger with IDs and status, only the latest test results, and the implementer brief verbatim. Instruct it to close required open items, close non-required open items when cheap, and not expand the design unless that expansion is a prerequisite for a required item. By default (`fix_scope: root_cause`) instruct it to fix the root cause and full class of each finding, not only the reported instance; when the immediate fix is the root cause, it must say so with a one-line justification. Completing a required finding down to its root cause is not design expansion. When `fix_scope: immediate`, instruct it to fix only the reported instance and record the remaining layers as deferred required items.
2. Capture the git diff. For `before_review`, run relevant tests and wait for results. For `parallel`, start tests without waiting. Confirm any test filter actually selected that subset; otherwise use the package's own test command or treat the full package suite as the result.
3. While `parallel` tests run or after `before_review` tests finish, delegate `review parallelism` independent review passes to fresh workers using the worker-selection rule. Give each worker the goal, `greenfield`, the diff, the finding ledger with IDs and status, any applicable artifacts from step 1, relevant project context, available test results, and the reviewer brief verbatim. Ask for actionable correctness, compatibility, security, maintainability, or missing-test issues. Require code evidence (`path:line`, symbol, or test result) for each actionable finding; label anything not yet verifiable as a concern. List out-of-scope suggestions separately. If test lifecycle is `skip`, instruct reviewers to widen to an invariant/consumer audit, not shrink to the diff. When `propose_improvements` is true, also list separately any generalizable skill-instruction improvements that would have enabled an earlier implementation or review worker to avoid the finding; exclude project-specific implementation advice.
4. Have one fresh critic audit the reviews against the goal, diff, repository, available test results, the finding ledger, any applicable artifacts from step 1, and the reviewer brief. Its response must end with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <code citation or test result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as supported by the cited evidence. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass using the worker-selection rule, then retain only claims grounded in code or tests. Do not continue reviewer–critic debate beyond this pass.
5. For `parallel`, collect test results after reviews. For `after_review`, run tests now. For `skip`, do not run tests. Combine duplicate evidence-backed findings by class, and code test failures, into the finding ledger. A previously filed residual class is not a required item or a new blocker unless the evidence shows a new class. Take the union of reviewers; a “no blockers” report from one reviewer does not dilute another's blocking finding. If no required open items remain, stop; otherwise pass the ledger and only the latest test results to the next implementation worker.

Do not report a change as ready if tests failed or required tests were skipped without saying so. On completion, summarize the implementation, review outcome, tests, risks, open non-required findings, and out-of-scope suggestions. If `propose_improvements` is true, add a concise **Potential skill improvements** section to the end report. Each item must state the reusable instruction change and the category of review iteration it is expected to prevent; omit empty or project-specific suggestions. Do not add the proposals to `AGENTS.md`, `CLAUDE.md`, or the skill unless the user separately asks.
