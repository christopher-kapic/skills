---
name: review-loop
description: Implement important or complex changes in a git repository through independent review-and-fix cycles. Use when a user asks for an implementation to be repeatedly reviewed, hardened, or iterated until it is ready to ship.
---

# Review Loop

Run an implement → test → independent review → fix loop. The main agent only coordinates; delegate every implementation and review pass to a fresh worker.

Run independently from a goal and repository. A reviewed plan from ck-plan or another source is optional input, never a prerequisite or permission to act.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); implementation harness/model = current; review harness/model = current; review parallelism = 1; greenfield = false; test lifecycle = `parallel`; max cycles = unlimited within the run budget; `critic` = `auto` (alternative: `always`); `propose_improvements` = false; `fix_scope` = `root_cause` (alternative: `immediate`).

Treat `greenfield: true` as permission to make breaking changes. Otherwise, preserve compatibility; ask before a breaking change not already authorized by the goal.

“Unwrap the onion” means `fix_scope: root_cause`: solve at the root so extra layers are unnecessary. If the user says that phrase, use `root_cause` even if `immediate` was set earlier.

When `propose_improvements: true`, collect reusable instruction changes that could prevent similar findings. These are advisory; do not modify this skill or repository instructions unless separately asked.

## Before drafting

Before launching workers, read [Evidence states](references/run-artifacts.md#evidence-states) and [prompt assembly](references/worker-briefs.md). Load other procedures when their step applies. If a reviewed plan was supplied, apply the [optional handoff](references/run-artifacts.md#optional-plan-handoff); derive missing or stale inputs locally without requiring another skill.

For a substantive change, have the first implementer inspect the goal, repository, and notes before drafting. Record unresolved product decisions, compatibility constraints, and acceptance criteria. Settle decisions that change behavior before implementation. If user intent is needed, invoke `user-decision`; for explicitly or implicitly noninteractive work, record the best long-term assumptions. Use quick options only when requested for the loop. Reuse settled decisions instead of asking again.

Assess risk from the changed behavior, not file count. Mark security-sensitive work explicitly: authentication, authorization, credentials, untrusted input crossing a trust boundary, or policy enforcement. Identify real dependencies needed to test the affected invariant (database, browser, process, platform). Provision disposable fixtures when supported and authorized; mocks cannot establish properties the substituted dependency owns. Record unavailable evidence before drafting.

Choose reviewable slices along existing behavioral boundaries when the change is too large to enumerate and probe within the worker budget. Preserve cross-slice invariants and acceptance criteria; do not invent a universal line limit. Identify readiness checks and which CI events actually run them, including platform jobs. Run applicable checks on the first stable revision when authorized; do not wait until the end to discover an unsupported platform. Do not publish a branch or PR solely to trigger CI without authorization.

## Worker selection and operation

For `current`, use a fresh native subagent when supported. Otherwise, invoke a fresh noninteractive process of the current harness through `invoke-harness`. For a named external harness, use `invoke-harness`. Interpret “review loop with X” as X reviews while current-harness workers implement, unless explicitly assigned otherwise. Honor user model and role assignments.

Choose the cheapest qualified available model for scouts, mechanical work, and implementation against a settled design. Use strong reasoning for uncertain design, authorization, concurrency, lifecycle, durability, and disputes. Each substantive cycle requires at least one independent, demonstrably qualified and probe-capable reviewer; assign the trust boundary for security-sensitive work. Apply the same policy to native and external workers. Record actual model ID, harness, supported reasoning setting, capability basis, and selection reason; confirm availability with the harness's model-list command or native catalog, without guessing IDs/prices or running a qualification benchmark each time. Prior demonstrated capability suffices; vendor, price tier, or clean verdicts alone do not. Honor explicit assignments; `current` is a default, not an override. Report capability gaps when user settings cannot meet the required role.

Use explore-offload when the expected savings from selecting multi-file context exceed scout/render cost. Route only each worker's focus and matched references; give critics trigger evidence plus an artifact index. Keep one qualified reviewer per substantive cycle unbundled, exploring from the diff; with one reviewer, it is unbundled. A trust-boundary reviewer searches its boundary itself. Bundled logs do not replace independent assessment or required fresh probes.

Scale effort to the surface and uncertainty, honoring user settings; use reasoning controls only if supported. Assign complementary focuses, combining them with fewer reviewers: `correctness` (concurrency, state, durability, lifecycle); `trust boundary` (authorization, input, budgets, egress); `consumers` (callers, contracts, errors, UI, deployment, tests). All reviewers check claimed invariants. Specialize from demonstrated capabilities; do not assign a reviewer an unsupported concurrency brief merely to fill a slot.

Before workers start, record a finite elapsed wall-time allowance (60 minutes is a starting point) and adjust it to the task's scope before launch. Apply any user hard cap; set token limits only when usage is observable. Fit finite worker and pass limits, scouts, retries, checks, final review, validation, and reporting within the remaining allowance. A productive run may receive a recorded finite extension before a self-estimated allowance expires; cite concrete progress and remaining work. Never extend a user hard cap or reset no-progress limits. Give workers the goal, role, context, reporting channel, and limits using the worker briefs. Stagger heavy work within memory and concurrency limits. Stop incomplete with gaps and next actions when a binding limit expires.

## Evidence and severity gates

Apply [Evidence states and report validation](references/run-artifacts.md#evidence-states) and the [common brief's severity calibration](references/worker-briefs.md#common-brief). If required security-boundary probes cannot run, security-sensitive work ends `unverified`, not `CLEAN` or ready, even with complete structural coverage. Isolated tests against the actual boundary can suffice; full application deployment is not inherently required.

Missing or invalid reviews never pass, even with exit status zero. Inspect partial artifacts/edits, retry once with a fresh worker, then stop as incomplete if still invalid. A missing security review requires the assigned boundary review; a correctness review or severity audit cannot substitute.

Speed and deferral policies cannot turn missing evidence into a pass. Record skipped work, its next action, and an incomplete/unverified outcome. This skill grants no commit, merge, or deployment permission.

## Watch-lists and surface tags

Match lists to potential behavioral or contract effects of added, changed, or removed lines, including refactors, static contracts, tests, CI, build, and schemas. Matching precedes proof of a behavior change; a topic mention or unchanged caller alone does not match. `test-adequacy` also matches goal acceptance criteria; cite the criterion and re-assign when its implementation/tests change. Confirm implementer surface citations against the diff, record dropped rows with reasons, and add missed surfaces. Re-select when fixes or reviewers expose new surfaces. Assign each matched list to a reviewer, at most four per assignment, within parallelism and total budgets. Prioritize by focus; additional passes remain sequential when parallelism is 1. Pending coverage cannot rotate out silently: every matched list needs valid coverage of the final candidate. Critics receive only lists relevant to their trigger, never substitute for assigned review coverage.

When matched lists need more than one pass, assign them in this order so blockers surface early: lists tagged on open ledger findings or this project's recurring classes; for security-sensitive work, trust-boundary lists and `auth-libraries`; lists whose cited lines implement an acceptance criterion; remaining focus lists; other `any` lists. Order decides which pass gets a list; focus picks the reviewer within that pass.

From round two, assign every list whose coverage is pending or invalid, and re-assign a covered list when the fix-pass diff touches its surface, a file its evidence cites, or code those files depend on. Record each carried list's source snapshot and checked paths under the carry-forward rule in [run artifacts](references/run-artifacts.md#decisions-ledger-and-assignments). The final security review never carries coverage forward.

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

Before implementation, select the fast gate and broader checks from repository CI, task runners, and hooks. Put applicable bounded local build/type/syntax and drift checks in the fast gate; schedule expensive/platform checks through `test lifecycle`. After each implementation/fix pass, satisfy the fast gate before semantic review using [execution and reuse](references/run-artifacts.md#execution-and-reuse), assigning one runner per selected check. Broader suites follow `before_review`, `parallel`, or `after_review`; reviewers may still run bounded fresh probes. `skip` leaves required execution unverified; structural proof stays structural. Do not invent a gate when none applies.

For each cycle, until no required open items remain, `max cycles` is reached, or the run budget expires:

1. Snapshot the complete task tree, including new files, before launching an implementer. Delegate with the goal, settings, ledger, decisions, recurring classes/carry-ins, coverage artifact, latest results, validation commands, the common and implementer briefs verbatim, and the watch-list table's tag and attach-when columns. Each fix must name its possible inverse failure and regression evidence. Close required items and cheap non-required items within scope.
2. Capture the complete task diff against a fixed baseline and, from round two onward, the fix-pass diff against the pre-fix snapshot. Identify the exact tree tested. Check cited tests exist and selectors execute them. Require replayable fault-patch proofs for security-sensitive or reopened behavioral findings; they are optional elsewhere. Follow the risk-scaled procedure in run artifacts. Collect or run the fast gate; return code failures to implementation before semantic review. Record unavailable gates as unverified. For broader tests, wait with `before_review`, start without waiting with `parallel`, or defer with `after_review`. Do not duplicate valid implementer checks except where independent reviewer evidence is required.
3. Delegate independent reviews with the complete and fix-pass diffs, snapshot, relevant context/settings, ledger, decisions, artifact index, the common and assigned reviewer briefs verbatim, assigned lists, and canonical tag/attach-when table. Designate one consequence tracer (prefer `consumers`): full task diff in round one and final security review; otherwise fix-pass diff plus earlier traces whose sites, intermediate dependencies, or observers may be affected. Preserve full-class coverage; carry inventory/evidence only under the artifact rules. Assign one qualified reviewer to choose and personally run the fresh probe required by [execution and reuse](references/run-artifacts.md#execution-and-reuse). Require claim-appropriate evidence and separate out-of-scope findings. Request advisory proposals only when enabled.
4. Apply the [critic policy](references/run-artifacts.md#critic-policy), recording the trigger or omission. Required critics are fresh workers with focused evidence and access to the artifact index. Resolve concerns through at most one evidence-resolution pass; preserve unresolved gaps.
5. Collect `parallel` results or run `after_review` tests; run none for `skip`. A named probe's failure reopens its closure. Independent assessment is required to upgrade an unverified row; coordinator or implementer assertions do not suffice. Reconcile findings, gaps, and any newly triggered critic; a clean review cannot override a blocker. Accept only with no required open items and valid final-candidate coverage from every assigned review, required critic, matched list, and applicable check. Missing required execution or incomplete proof stays unverified. Pass updated artifacts/results to the next implementer within remaining limits.

When a fix stalls, diagnose reasoning, context, tooling, or evidence failure before routing the next pass. If a cheap fix leaves the same finding without new closure evidence, use a stronger qualified model within user settings or a design pass re-deriving the invariant and enforcement point; repair missing context/tooling too. For other fixes, two successive passes without new evidence require that escalation. Independently confirmed closure of affected sites is progress; assertions or identical re-prompts are not. If the escalated attempt yields no new closure evidence, stop incomplete. Include fast-gate repairs in these limits.

When a class recurs after an instance fix, seek one enforced boundary (wrapper, helper, constraint, or equivalent) and a check proving all relevant sites use it. After two reopenings, require whole-class enumeration and a design pass before another fix: list every resource/actor type against every relevant lifecycle event and path, including consumers outside the diff. Explain why earlier fixes missed them. Under `root_cause`, adopt a class repair within scope and compatibility; otherwise apply **Before drafting**. Under `immediate`, keep the proposal and unresolved siblings explicit. Do not force a wrapper across unrelated policies; justify separate enforcement with an exhaustive inventory. If an adopted design still produces new instances, stop as incomplete. `max cycles` bounds implementation passes, including gate repairs; invalid-pass limits also apply. No stop implies approval.

For security-sensitive work, complete the [final fresh-context review](references/run-artifacts.md#final-security-review) after incremental rounds pass. Any later edit requires renewed review/validation of its effects and, for security-sensitive work, renewed final review.

On completion, summarize implementation, outcome, validation, risks, deferrals, open findings, remaining low-signal tests, and any incomplete stop reason. Give severe out-of-scope findings a durable carry-in destination and list other suggestions separately. Include measured review time and redone/escalated passes when available, distinguishing missing data from zero. If `propose_improvements` is true, add **Potential skill improvements**: reusable instruction change and the iteration it would prevent; watch-list proposals name the list and use question + **Verify:** format. Omit empty or project-specific proposals.
