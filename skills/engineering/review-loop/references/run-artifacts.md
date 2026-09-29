# Run artifacts and evidence

Keep reports, snapshots, and new review memory in a task-specific location outside the repository unless an in-repo location is already authorized. Addressable report sections suffice; the coordinator preserves text-only workers' reports. This format requires neither a tracking system nor published issues.

## Optional plan handoff

Treat a supplied reviewed plan from ck-plan or any source as task data, without requiring its producer, layout, or schema. Extract available fields:

| Field | Contents |
|---|---|
| Provenance and baseline | Author, reviewed revision, exact dirty and untracked inputs |
| Goal and authority | Acceptance criteria, decisions, assumptions, authority, compatibility and scope limits |
| Inventory and steps | Invariants, consumers, siblings, dependency bounds, ordered steps |
| Validation | Commands and expected outcomes; proposed checks versus executed evidence with provenance |
| Review status | Scope, verdict, unresolved findings, coverage gaps, remaining decisions |

Check provenance, current goal and authority, and source or dependency drift. Mark each portion reused, refreshed, or missing with reasons; derive stale or missing inputs locally. Unknown provenance establishes neither execution nor authority. Plan review replaces neither code review nor current validation and grants no additional permission.

## Decisions, ledger, and assignments

- Decisions: `behavior or constraint | decision or assumption | authority | acceptance check`. Update workers when intent changes.
- Findings: `ID | invariant and class | canonical surface tags | severity | required? | disposition | evidence and revision`. In-scope blockers and code validation failures remain required until independently closed or explicitly deferred. Preserve IDs and original external severity labels; record deferral authority, reason, and remaining risk without reducing severity.
- Trust-boundary fields: `exploitable: yes/no/unverified | actor | path and preconditions | impact | evidence`. Justify “no”; missing assessment is an evidence gap.
- Assignments: `reviewer | focus | matched watch-lists and cited lines | snapshot | complete/pending/invalid`. Record dropped surface rows with reasons. Keep assignments within concurrency and total budgets; critic possession is not reviewer coverage.

Carry inventory, trace, or coverage rows only after a reviewer compares their full dependency bound with the fix-pass diff: sites through outermost observers and relevant tests, configuration, dependencies, environment, and mutable fixtures. Record source snapshot, checked paths, comparison evidence, and assessment. Changed or unknown inputs invalidate the row: re-enumerate or report a gap. Final security enumeration starts fresh.

## Evidence states

Supply these definitions to workers making claims. Record coverage as `site and operation | obligation | evidence state | proof/check ID or missing evidence | revision | assessor`, with inventory bounds:

- `holds (executed)`: the worker personally ran a discriminating check against the actual boundary. Cite the execution record and explain which assertions detect each covered violation. Cached output, inherited logs, and mocks replacing that boundary cannot establish this state. Implementer execution still needs independent assessment for closure.
- `holds (assessed execution)`: a reviewer validated a named record under **Execution and reuse**. Cite the assessment and original executor. This closes ordinary obligations, never specifically required fresh probes, isolated replay, or final security review.
- `holds (structural)`: an independently derived proof with cited code, proposition, exhaustive site bound, assumptions, enforcement mechanism, and absence of bypass. It completes only obligations fully established by that proof; repeating an implementer's argument is insufficient.
- `reviewed`: an inherently static obligation checked with citations and reasoning; no runtime certification.
- `violates`: code or executed evidence demonstrates a defect; link its finding.
- `unverified`: required evidence or a bound is missing; state the resolution needed.
- `n/a`: the contract establishes inapplicability.

Timing, concurrent effects, authorization, lifecycle, cancellation, and I/O require execution at the owning boundary. Split narrower structural claims from runtime obligations: a lock graph alone proves neither runtime exclusion, absence of hidden acquisitions, nor safe cancellation. Build and type-check success require actual execution records.

Use these states for closure, avoiding bare `holds` or `verified`. Inherited verdicts cannot close findings. Source-backed defects remain open without a successful exploit demonstration. Missing infrastructure is an evidence gap, not automatically a code bug; missing required execution prevents readiness. Purely static changes need no invented runtime test or historical regression.

Validate reports for scope and revision, assigned and incremental coverage, appropriate evidence, explicit findings or verdict, and completion. Complete returned text suffices without a report file. Skeletons, truncated or empty responses, and exit status alone do not. Return unsupported claims under the skill's bounded retry rule; honest unverified coverage remains a gap. Liveness guidelines do not invalidate a complete report.

## Execution and reuse

Assign one runner per selected check and share its record. Each record identifies:

- Check ID; relevant source, tests, configuration, and transitive dependencies in an exact snapshot including dirty and untracked files.
- Environment ID covering tool and dependency versions, settings, and mutable fixture state; refresh it when inputs change.
- Actual command, working directory, selectors, selected counts (`n/a` for non-tests), exit status, observed assertions, raw log, executor, execution time, and cache origin.

A commit ID cannot identify a dirty tree; filtered scout output cannot replace raw logs. Before reuse, a reviewer checks assertion discrimination, production-path reachability, actual boundary, provenance, and unchanged inputs across that entire scope. Record the comparison, bound, and assessment by check ID. Changed or unknown inputs, missing selectors or counts, ambiguous cache origin, or weak assertions require rerun, stronger evidence, or `unverified`. Label valid reuse `holds (assessed execution)` with original executor and time.

Each substantive cycle with an execution-dependent obligation requires one qualified reviewer to choose and personally run a bounded discriminating probe of the riskiest such obligation at its actual boundary. Purely static or fully proved obligations need none. Other checks may reuse assessed execution unless freshness is required. Bypass task-result caches for all new-execution claims. Preserve security or reopened behavioral replay and final security probes; unavailable required execution stays `unverified`.

## Critic policy

Under `critic: auto`, require a fresh critic for:

- A current open blocker or major, or proposed closure of one.
- An implementer or reviewer dispute over a named finding at any severity, including disagreement with its severity rating.
- Reviewer-requested adjudication.
- Security-sensitive work.
- A reopened finding.
- Conflicting reports.
- Reviewer-reported unbounded uncertainty.
- A supplied plan author's dispute when a plan is supplied.

Workers name triggers and finding or coverage IDs; route from those reports without replacing substantive judgment or lowering severity. Old independently closed findings alone do not trigger. `critic: always` requires each cycle. After review and late check results, record `mode | trigger and IDs or omission rationale | assigned critic and status`.

Supply goal and authority, trigger, snapshot, relevant diffs and decisions, severity index, disputed reports and check records, relevant list entries, and artifact index. Assemble briefs through [worker-briefs.md](worker-briefs.md); `always` without a dispute targets the riskiest evidence and closures.

Apply the critic brief's verdict semantics. For `DISAGREE_CONCERN`, delegate one concise evidence-resolution pass, retain grounded claims and unresolved gaps, then end debate. Acceptance requires a valid required critic; omission needs the recorded auto rationale. A critic cannot supply a missing assigned review.

## Project memory and severe carry-ins

Read existing project review memory and feed relevant entries to workers. Store new entries with durable external artifacts and link the location in the final report. In-repo memory requires existing user or project authorization; choosing the external default needs no question. If durable storage is unavailable, include entries in the final report and disclose that cross-run storage was not established.

Record recurring classes as `class ID | invariant and failure pattern | surface tags | affected area | evidence | prevention or probe | status`. Include only observed findings; watch-lists supply general patterns.

For severe out-of-scope findings retain `finding ID | severity and evidence | affected area | next-touch reassessment | suggested action | destination and status`. Reassess before touching that area; import as required only when it breaks the current goal or changed invariant, or the user includes it. Otherwise retain it visibly without blocking or expanding scope. Reuse settled scope decisions; ask about expansion only when necessary to fulfill the goal. Close carry-ins with independent evidence. Storage authorizes neither messages nor tickets.

## Snapshots and fix verification

Before each implementation pass, copy the task's tracked and untracked files recoverably outside the repository, preserving edits, file types, modes, and symlink targets. Record copied scope, baseline revision, and git status. Preserve staged and unstaged state; use no stash, checkout, reset, or index mutations. Use `git --no-optional-locks` for inspection. Reuse repository snapshot tooling; an ordinary archive suffices without custom infrastructure.

Capture full task and incremental diffs against the starting tree and pre-fix copy, including additions and deletions. A dirty starting tree differs from `HEAD`; plain `git diff` omits untracked files. Distinguish unrelated edits, inspect unexpected git-state changes, and never restore over newer work blindly.

For ordinary fixes apply **Execution and reuse** and matched TA2/TA9 mutation conditions. Historical runs and saved replay artifacts are otherwise optional; never claim an unobserved historical failure.

For **security-sensitive or reopened behavioral findings**, require replayable proof:

1. In isolation, show the regression test fails for the intended defect before the fix and passes on the candidate. When the old revision cannot run it, demonstrate failure with a focused fault patch and disclose unavailable historical reproduction. Setup or dependency failures do not count.
2. Save a finding-ID `.patch` beside the report that reintroduces the defect into the candidate. Record candidate identity, patch direction, application and reversal commands, selector, and expected failing assertion. Keep regression tests in the candidate, outside the deliberate break.
3. The coordinator or verifier replays in a fresh isolated copy: check base, apply patch, observe intended failure, reverse patch, confirm byte-identical source including file types, modes, symlink targets, additions and deletions, then confirm the restored test passes. Exclude declared build outputs from comparison; unexpected source changes fail restoration.

Apply deliberate breaks only in isolation, including optional replay. Missing mandatory proof stays unverified. Replay does not replace independent boundary and inverse-failure assessment. Use existing automation or record explicit commands; no particular runner is required.

## Final security review

After incremental rounds pass, review the whole security-sensitive candidate in fresh contexts. Supply goal, settings, applicable briefs and evidence procedures, decisions, baseline, full diff and tree, matched lists, and relevant project memory. Withhold this run's verdicts, closures, and fix narratives until fresh enumeration and fresh, independently chosen boundary probes finish; carried coverage and earlier execution cannot replace them.

Honor the four-list cap, parallelism, and budgets. Review the authorized committed tree or frozen candidate; this step grants no commit permission. Reconcile with the ledger and required fresh critic under normal gates. New required findings or gaps return to the bounded loop. Subsequent edits require renewed review and validation of their effects and renewed final security review.

## Effort and stop record

Apply [review-loop's run-budget and stop rules](../SKILL.md#worker-selection-and-operation). Record allowances, hard caps, and justified extensions; where observable, record `pass | role, harness, actual model, reasoning, capability basis | elapsed and usage | status | reason | snapshot | checks run or reused | new independently confirmed findings`. Distinguish worker time from wall time and unknown usage from zero. An incomplete stop preserves findings, gaps, and next actions without implying approval.
