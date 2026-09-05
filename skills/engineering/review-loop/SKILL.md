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

Scale review effort to the affected surface and uncertainty, honoring user settings; use reasoning controls only if supported. With multiple reviewers, assign complementary focuses (implementation correctness; affected consumers and lifecycle paths), while all check the claimed invariants. Require explicit completion, findings or an explicit clean result for reviews, and the applicable brief's evidence. Empty, interrupted, or malformed output is an invalid pass: inspect any partial edits, retry once with a fresh worker, then stop as incomplete if still invalid.

## Implementer brief

Include this brief verbatim in every implementation worker prompt:

1. For each addressed finding, provide `Class sweep: scope searched; affected sites; enforcement point; verification; remaining exceptions`. Under `root_cause`, fix the full class within the goal's scope. If the instance is the full class, justify that bound. Checks or warnings close a finding only if they prevent the prohibited behavior; otherwise the unmet requirement stays open unless explicitly deferred.
2. Maintain a compact coverage table for each changed invariant: `site / operation | holds, violates, or unknown | evidence`. Include consumers and siblings, plus entry, exit, bypass, failure, timeout, shutdown, and re-entry paths where relevant. Give the search scope, queries and results, or structural bound establishing completeness. Group sites only when the same proof covers them; update the artifact incrementally.
3. For shared-state changes, document ownership and lock/permit order; a terminal state is not a lock. For crash/restart-sensitive changes, persist required state and show durable intent before recoverable external effects. Do not add mechanism to compensate for an incomplete inventory.
4. Run assigned validation commands, honoring `test lifecycle` and `skip`; report commands, results, and gaps. Coordinate resource-heavy commands with the coordinator. First-pass tests cover the empty/default case and primary action; regression checks must exercise the defect.

## Reviewer brief

Include this brief verbatim in every review worker prompt and in the critic prompt:

1. Independently verify coverage for each changed invariant using `site / operation | holds, violates, or unknown | evidence`. Check consumers beyond the diff, and the search scope, queries and results, or structural bound establishing completeness. Group sites only when the same proof covers them. Missing bounds or unknown coverage require a blocking `enumeration incomplete` finding; an assertion of exhaustiveness is insufficient. Report every violating row this pass, grouped by root cause.
2. Include entry, exit, bypass, failure, timeout, shutdown, re-entry, and sibling paths where relevant from the first review. For persisted state machines, cover durable states, transitions, and reachable callers across success, retry, and conflict; a required transition with no production trigger is blocking. Later reviews must also inspect newly changed code and affected consumers, not just prior findings.
3. For shared-state changes: check object identity vs recycled ids; who owns the write after cancel/timeout; and lock/permit order of both the current code and any remedy. For recoverable external effects, durable intent precedes the effect. Do not treat a terminal or success state as a lock without proving mutual exclusion and ownership. Do not recommend a lock strategy you have not checked against existing acquisition sites. State the invariant and the missing proof, not a patch recipe.
4. Use executable validation results for build/type/syntax claims; request a targeted check when needed, and label unavailable checks unverified. Inspect whether tests would fail on the claimed defect, even when they pass now.
5. Do not change established observable ordering (authz, error kind) unless `greenfield` is true or the goal says to.
6. For partial enforcement, distinguish prevented violations from detected or still-possible violations. An unmet required invariant remains required. Attach further bypass evidence to the same class; reopen it if closure is disproved. Only explicit deferral changes a required item to accepted remaining risk.
7. Report each finding at its root cause and name the full class or causal chain it belongs to, with code evidence. When one root cause surfaces across several layers or sites, file it once as a root-cause finding, not a series of surface instances. Reuse the finding ledger's ID when the class matches; otherwise mark it as a new class.

## Loop

Keep a cumulative ledger: `ID | invariant/class | required? | open, closed, or deferred | latest evidence`. Preserve IDs and closure evidence; assign a new ID only to a new class. Independent review must confirm closure. Blocking findings and code validation failures stay required until closed or explicitly deferred. Environment/tooling failures block verified readiness but are not code findings. Only the user may defer required code items, except the coordinator may do so in noninteractive runs; record every deferral and reason. Non-required open findings do not drive cycles. Do not expand the design while required work remains unless the redesign is a prerequisite.

Before implementation, select repository-supported fast build/type/syntax checks covering affected code and changed tests where applicable, plus broader relevant tests. Implementers may run them. Serialize resource-heavy checks when needed and reuse results for unchanged inputs. The fast gate runs after every implementation/fix pass before semantic review; broader tests follow `test lifecycle`. `skip` skips both and must be reported as unverified; do not invent a gate when none applies.

For each cycle, until no required open items remain or `max cycles` is reached:

1. Delegate an implementation pass with the goal, `greenfield`, `fix_scope`, ledger, coverage artifact, validation commands/lifecycle, latest results, and implementer brief verbatim. Close required items and cheap non-required items. Full class repair is not design expansion. For `immediate`, fix only the reported instance and record remaining layers as deferred required items.
2. Capture the complete task diff against a fixed baseline, including new files, and identify the revision/snapshot reviewed and tested. Collect or run the fast gate; return code failures to implementation before semantic review. Record unavailable gates as unverified. For broader tests, wait with `before_review`, start without waiting with `parallel`, or defer with `after_review`. Confirm filters selected the intended tests; otherwise use the package's own command or report full-package results. Do not duplicate valid implementer checks.
3. Delegate `review parallelism` independent reviews with the goal, `greenfield`, complete diff, ledger, coverage artifact, repository context, available validation results, and reviewer brief verbatim. Ask for actionable correctness, compatibility, security, maintainability, or missing-test issues. Require code evidence (`path:line`, symbol, or check result); label unverified objections as concerns. List out-of-scope suggestions separately. When `propose_improvements` is true, separately propose reusable instruction changes that would have prevented findings; exclude project-specific advice.
4. Have one fresh critic adjudicate findings, closure evidence, and coverage gaps against the goal, diff, repository, available validation results, ledger, coverage artifact, and reviewer brief; it may also raise missed findings. Its response must end with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <code citation or test result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as supported by the cited evidence. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass using the worker-selection rule, then retain only claims grounded in code or tests. Do not continue reviewer–critic debate beyond this pass.
5. Collect `parallel` results or run `after_review` tests; run none for `skip`. Merge evidence-backed findings and code validation failures by class; one clean review cannot override another's blocker. Accept only when no required open items remain and all assigned reviews, the critic, and applicable checks validly cover the final revision. If checks were unavailable or skipped, report the review outcome as unverified, not ready. Any later edit requires renewed review and validation of its effects. Otherwise pass the updated ledger, coverage artifact, and latest results to the next implementer.

If the same class remains unresolved across two successive fix passes without new closure evidence, require a different approach in the next pass. If that pass also makes no progress, stop as incomplete with the unresolved evidence. This includes fast-gate repair passes. `max cycles` bounds implementation passes, including gate repairs; invalid-pass limits also apply. None of these stops imply approval.

On completion, summarize the implementation, review outcome, validation, risks, deferrals, open findings, and any incomplete stop reason. List out-of-scope suggestions separately. If `propose_improvements` is true, add a concise **Potential skill improvements** section to the end report. Each item must state the reusable instruction change and the category of review iteration it is expected to prevent; omit empty or project-specific suggestions. Do not add the proposals to `AGENTS.md`, `CLAUDE.md`, or the skill unless the user separately asks.
