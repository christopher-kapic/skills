---
name: review-loop
description: Implement important or complex changes in a git repository through independent review-and-fix cycles. Use when a user asks for an implementation to be repeatedly reviewed, hardened, or iterated until it is ready to ship.
---

# Review Loop

Run an implement → test → independent review → fix loop. The main agent only coordinates; delegate every implementation and review pass to a fresh worker.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); implementation harness/model = current; review harness/model = current; review parallelism = 1; greenfield = false; test lifecycle = `parallel`; max cycles = unlimited; `propose_improvements` = false; `fix_scope` = `root_cause` (alternative: `immediate`).

Treat `greenfield: true` as permission to make breaking changes. Otherwise, preserve compatibility; ask before a breaking change not already authorized by the goal.

“Unwrap the onion” means `fix_scope: root_cause`: solve at the root so extra layers are unnecessary. If the user says that phrase, use `root_cause` even if `immediate` was set earlier.

When `propose_improvements: true`, collect reusable instruction changes that could prevent similar findings. These are advisory; do not modify this skill or repository instructions unless separately asked.

## Before drafting

Before launching workers, read [Evidence states](references/run-artifacts.md#evidence-states) and the common + assigned-role [worker briefs](references/worker-briefs.md). Read the other artifact procedures when their step applies, including snapshots before implementation and the final-review procedure for security-sensitive work. Paste the required instructions into prompts; workers must not depend on access to this skill's files.

For a substantive change, have the first implementer inspect the goal, repository, and notes before drafting. Record unresolved product decisions, compatibility constraints, and acceptance criteria. Settle decisions that change behavior before implementation. If user intent is needed, invoke `user-decision`; for explicitly or implicitly noninteractive work, record the best long-term assumptions. Use quick options only when requested for the loop. Reuse settled decisions instead of asking again.

Assess risk from the changed behavior, not file count. Mark security-sensitive work explicitly: authentication, authorization, credentials, untrusted input crossing a trust boundary, or policy enforcement. Identify real dependencies needed to test the affected invariant (database, browser, process, platform). Provision disposable fixtures when supported and authorized; mocks cannot establish properties the substituted dependency owns. Record unavailable evidence before drafting.

Choose reviewable slices along existing behavioral boundaries when the change is too large to enumerate and probe within the worker budget. Preserve cross-slice invariants and acceptance criteria; do not invent a universal line limit. Identify readiness checks and which CI events actually run them, including platform jobs. Run applicable checks on the first stable revision when authorized; do not wait until the end to discover an unsupported platform. Do not publish a branch or PR solely to trigger CI without authorization.

## Worker selection and operation

For `current`, use a fresh native subagent when supported. Otherwise, invoke a fresh noninteractive process of the current harness through `invoke-harness`. For a named external harness, use `invoke-harness`. Interpret “review loop with X” as X reviews while current-harness workers implement, unless explicitly assigned otherwise. Honor user model and role assignments.

Prefer a strong reasoning model for the initial substantive implementation and for fixes involving authorization, credentials, locks, async ordering, lifecycle, or durable state. Use cheaper workers for mechanical edits, docs, formatting, or tests against a settled design. Keep at least one strong or demonstrably probe-capable reviewer in each substantive cycle; security-sensitive work needs a reviewer assigned the trust boundary. Do not infer capability from a vendor name or from clean verdicts by weaker reviewers. If the requested configuration cannot provide the needed expertise or probes, report the limitation rather than silently upgrading models or declaring readiness.

Scale effort to the surface and uncertainty, honoring user settings; use reasoning controls only if supported. Assign complementary focuses, combining them with fewer reviewers: `correctness` (concurrency, state, durability, lifecycle); `trust boundary` (authorization, input, budgets, egress); `consumers` (callers, contracts, errors, UI, deployment, tests). All reviewers check claimed invariants. Specialize from demonstrated capabilities; do not assign a reviewer an unsupported concurrency brief merely to fill a slot.

Give every worker the goal, role, initial context, reporting channel, resource limits, and common worker brief. Choose finite pass budgets where the harness can enforce them. Each worker performs only its assigned pass: no recursive review loop, nested harness, or waiting on stdin. Stagger workers or heavy checks to stay within available memory. Make a recoverable copy of tracked and untracked task files before each implementation worker starts. Reviewers and critics keep source read-only; use scratch locations for probes and file reports when supported.

For harnesses with clock and file access, aim for a report skeleton within the first 10% of the budget, capped at five minutes, append evidence as it arrives, and stop new exploration around 70% to finish the report. These are liveness guidelines, not validity thresholds. Text-only workers return their report through the available channel and state unfinished work. The coordinator preserves that response as the artifact. A skeleton or missing response never counts as a completed review.

## Evidence and severity gates

Apply [Evidence states and report validation](references/run-artifacts.md#evidence-states) and the [common brief's severity calibration](references/worker-briefs.md#common-brief). If required security-boundary probes cannot run, security-sensitive work ends `unverified`, not `CLEAN` or ready, even with complete structural coverage. Isolated tests against the actual boundary can suffice; full application deployment is not inherently required.

Missing or invalid reviews never pass, even with exit status zero. Inspect partial artifacts/edits, retry once with a fresh worker, then stop as incomplete if still invalid. A missing security review requires the assigned boundary review; a correctness review or severity audit cannot substitute.

Speed and deferral policies cannot turn missing evidence into a pass. Record skipped work, its next action, and an incomplete/unverified outcome. This skill grants no commit, merge, or deployment permission.

## Watch-lists and surface tags

Select lists from the task's touched surfaces and re-select when a fix adds one. Each matched list must be assigned to at least one reviewer, not only to the critic. Give each reviewer at most four lists per assignment, preferring its focus. Extra assignments mean extra review passes within the configured parallelism limit: with parallelism 1 and six lists, run assignments sequentially, never launch a second concurrent reviewer. Honor total pass/time budgets too; if coverage cannot fit, report it pending rather than exceeding them. Rotation across cycles is allowed only with coverage left explicitly pending: all matched lists must have valid reviewer coverage of the final candidate before acceptance. Give the critic the union. Never attach the whole catalog indiscriminately.

Paste list contents into prompts. Only if the coordinator cannot read `references/`, provide `https://raw.githubusercontent.com/christopher-kapic/skills/master/skills/engineering/review-loop/references/watch/<list>.md`; it may differ from the installed version, so use one source per run and treat a failed or unexpected fetch as missing coverage.

The list names below are the canonical surface tags for findings, recurring classes, and miss analysis. Use these exact spellings; multiple tags are allowed. Normalize aliases such as `input validation`/`input-validation` to `input-and-text`, and `resource budgets` to `resource-budgets`. Use `review-process` only for workflow or evidence gaps, not as a substitute for a code surface.

| List / canonical tag | Attach when the diff touches | Focus |
|---|---|---|
| [concurrency-and-state](references/watch/concurrency-and-state.md) | locks, leases, CAS, idempotency keys, claims, shared state | correctness |
| [state-machines](references/watch/state-machines.md) | persisted status, retries, expiry, reapers, reconcile | correctness |
| [durability-and-recovery](references/watch/durability-and-recovery.md) | crash-sensitive writes, external effects, recovery, GC | correctness |
| [lifecycle-and-shutdown](references/watch/lifecycle-and-shutdown.md) | workers, live connections, deadlines, cancellation, shutdown | correctness |
| [pagination-and-sweeps](references/watch/pagination-and-sweeps.md) | cursors, batch scans, outbox polling, sweeps | correctness |
| [authz-boundaries](references/watch/authz-boundaries.md) | authn/authz, grants, capabilities, sessions, composed policies | trust boundary |
| [input-and-text](references/watch/input-and-text.md) | external input, rich text, paths, argv, regex, parsers, redaction | trust boundary |
| [resource-budgets](references/watch/resource-budgets.md) | limits, quotas, size caps, queues, attacker-sized input | trust boundary |
| [network-egress](references/watch/network-egress.md) | server fetches, user-influenced URLs, SSRF guards, TLS | trust boundary |
| [errors-and-contracts](references/watch/errors-and-contracts.md) | error mapping, wire protocols, schemas, APIs, client helpers | consumers |
| [web-ui](references/watch/web-ui.md) | browser-rendered forms, navigation, async UI state, error copy, risky settings | consumers |
| [containers-and-deployment](references/watch/containers-and-deployment.md) | images, entrypoints, CI/CD, deploy-time SQL | consumers |
| [test-adequacy](references/watch/test-adequacy.md) | tests, goal acceptance criteria | consumers |
| [sql-databases](references/watch/sql-databases.md) | SQL, ORMs, migrations | any |
| [javascript-node](references/watch/javascript-node.md) | JavaScript/TypeScript runtime code | any |
| [unix-processes](references/watch/unix-processes.md) | child processes, signals, PIDs, pipes, sockets, file modes | any |
| [rust](references/watch/rust.md) | Rust, conditional compilation, async runtimes | any |
| [git-plumbing](references/watch/git-plumbing.md) | git plumbing, tree or ref validation | any |
| [auth-libraries](references/watch/auth-libraries.md) | auth libraries, OAuth, bootstrap admin | any |
| [email-mime](references/watch/email-mime.md) | email composition, MIME, address headers | any |

## Loop

Keep a cumulative finding ledger, coverage artifact, and recorded decisions. Reuse relevant recurring classes/carry-ins using [run artifacts and evidence](references/run-artifacts.md); store new memory outside the repository unless an in-repo location is already authorized. A carry-in prompts reassessment and becomes required only when it breaks the current goal or changed invariant, or the user has included it in scope. Preserve IDs and closure evidence; independent review must confirm closure. Only the user may defer required code items, except the coordinator may do so in noninteractive runs; record the reason. `fix_scope: immediate` bounds the repair but does not itself authorize deferring required siblings. Non-required findings do not drive cycles. Do not expand the design while required work remains unless redesign is a prerequisite.

Select repository-supported fast build/type/syntax checks and broader relevant tests before implementation. Serialize heavy checks. Reuse valid results only for unchanged inputs; runs claimed as new fix evidence must execute, bypassing task-result caches using the runner's supported option. The fast gate runs after each implementation/fix pass before semantic review. `test lifecycle` schedules broader suites; reviewers may run bounded targeted probes during review unless execution is explicitly skipped. `skip` leaves execution-dependent obligations unverified; a valid structural proof remains structural. Do not invent a gate when none applies.

For each cycle, until no required open items remain or `max cycles` is reached:

1. Snapshot the complete task tree, including new files, before launching an implementer. Delegate with the goal, settings, ledger, decisions, recurring classes/carry-ins, coverage artifact, latest results, validation commands, and common + implementer briefs. Each fix must name its possible inverse failure and regression evidence. Close required items and cheap non-required items within scope.
2. Capture the complete task diff against a fixed baseline and, from round two onward, the fix-pass diff against the pre-fix snapshot. Identify the exact tree tested. Check cited tests exist and selectors execute them. Require replayable fault-patch proofs for security-sensitive or reopened behavioral findings; they are optional elsewhere. Follow the risk-scaled procedure in run artifacts. Collect or run the fast gate; return code failures to implementation before semantic review. Record unavailable gates as unverified. For broader tests, wait with `before_review`, start without waiting with `parallel`, or defer with `after_review`. Do not duplicate valid implementer checks except where independent reviewer evidence is required.
3. Delegate independent reviews with the complete and fix-pass diffs, reviewed snapshot, repository context, settings, ledger, decisions, recurring classes/carry-ins, available results, common + reviewer briefs, and assigned watch-lists. Keep full-class enumeration alongside incremental regression review. Require evidence appropriate to each claim and a separate out-of-scope list. When `propose_improvements` is true, request reusable proposals separately.
4. Have a fresh critic adjudicate severity, findings, closure evidence, and coverage gaps. Supply the goal, settings, current snapshot and diffs, repository context, decisions, recurring classes, ledger, coverage, and available reports/results. Use the critic brief in [worker briefs](references/worker-briefs.md). Every critic checks severity and each major's exploitability; scale the rest of its work to risk and disputes. Independently test the riskiest claim requiring execution, or re-derive a structural proof when sufficient. The critic cannot supply a missing assigned review. It ends with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <code citation or test result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as the evidence supports. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass, then retain claims grounded in code or tests and preserve unresolved evidence gaps. Do not continue debate beyond this pass. Merge findings only if a shared remedy provably closes both; otherwise retain separate IDs linked to their common class.
5. Collect `parallel` results or run `after_review` tests; run none for `skip`. A named probe's failure reopens its closure. Coordinator or implementer claims do not upgrade a reviewer's unverified row without independent evidence. Reconcile required findings and evidence gaps; one clean review cannot override another's blocker. Accept only when no required open items remain and every assigned review, critic, matched watch-list, and applicable check validly covers the final revision. Missing required execution or an incomplete structural proof means unverified, not ready. A valid structural proof is sufficient only for the obligation it establishes. Pass updated artifacts and results to the next implementer when further work is possible.

If the same finding remains unresolved across two successive fix passes without new closure evidence, the next attempt must use a stronger model within the user's settings or a dedicated design pass that re-derives the invariant and enforcement point. Independently confirmed closure of some affected sites is progress; an implementer assertion is not. Continue a productive approach while recording remaining sites. Re-prompting the same worker without a new approach is not escalation. If the escalated attempt also produces no new closure evidence, stop as incomplete. This includes fast-gate repairs.

When a class recurs after an instance fix, seek one enforced boundary (wrapper, helper, constraint, or equivalent) and a check proving all relevant sites use it. After two reopenings, require whole-class enumeration and a design pass before another fix: list every resource/actor type against every relevant lifecycle event and path, including consumers outside the diff. Explain why earlier fixes missed them. Under `root_cause`, adopt a class repair within scope and compatibility; otherwise apply **Before drafting**. Under `immediate`, keep the proposal and unresolved siblings explicit. Do not force a wrapper across unrelated policies; justify separate enforcement with an exhaustive inventory. If an adopted design still produces new instances, stop as incomplete. `max cycles` bounds implementation passes, including gate repairs; invalid-pass limits also apply. No stop implies approval.

For security-sensitive work, complete the [final fresh-context review](references/run-artifacts.md#final-security-review) after incremental rounds pass. Any later edit requires renewed review/validation of its effects and, for security-sensitive work, renewed final review.

On completion, summarize implementation, outcome, validation, risks, deferrals, open findings, remaining low-signal tests, and any incomplete stop reason. Give severe out-of-scope findings a durable carry-in destination and list other suggestions separately. Include measured review time and redone/escalated passes when available, distinguishing missing data from zero. If `propose_improvements` is true, add **Potential skill improvements**: reusable instruction change and the iteration it would prevent; watch-list proposals name the list and use question + **Verify:** format. Omit empty or project-specific proposals.
