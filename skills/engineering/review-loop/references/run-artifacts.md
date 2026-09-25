# Run artifacts and evidence

Keep reports, snapshots, and new review memory in a task-specific artifact location outside the repository by default. Use an in-repo location only when already authorized by the user or project instructions. Do not create a tracking system or publish issues merely to satisfy this format. Sections of one report are sufficient when they remain addressable; for text-only workers, the coordinator preserves returned reports.

## Decisions, ledger, and assignments

- Decisions: `behavior / constraint | decision or assumption | authority | acceptance check`. Feed the same decisions to workers and update them when user intent changes.
- Findings: `ID | invariant / class | canonical surface tags | severity | required? | open / closed / deferred | evidence / revision`. In-scope blockers and code validation failures stay required until independently closed or explicitly deferred. Preserve IDs and original external severity labels. Record who authorized a deferral, why, and the remaining risk; severity is unchanged.
- Trust-boundary fields: `exploitable: yes/no (or unverified); by whom; path and preconditions; impact; evidence`. A “no” needs its rationale. Missing assessment is an evidence gap.
- Assignments: `reviewer | focus | matched watch-lists | snapshot | complete / pending / invalid`. Extra assignments remain within configured concurrency and total budgets. A critic's possession of a list is not reviewer coverage. Carried-forward evidence requires unchanged inputs and unaffected dependencies.

## Evidence states

The coordinator supplies this section to every worker. Coverage rows use `site / operation | obligation | evidence state | proof or missing evidence | revision`, with inventory bounds alongside them:

- `holds (executed)`: the reporting reviewer ran a discriminating test/probe against the actual boundary. Give the command, observed result, and why it could fail on a violation. One execution can cover several rows when its assertions establish each. Cached output, inherited logs, or a mock replacing that boundary cannot establish this state.
- `holds (structural)`: the reviewer independently proves the claim from cited code and an exhaustive bound. State the proposition, all relevant sites, assumptions, enforcement mechanism, and why no bypass exists. Examples include an exhaustive match, a type-enforced constraint with no unchecked escape, or a complete single-call-site inventory. “Looks correct” and repeating an implementer's argument are insufficient. This is a valid completion state for obligations fully established by that proof.
- `reviewed`: an inherently static obligation, such as documentation consistency, checked with citations and reasoning. This does not certify runtime behavior.
- `violates`: code or executed evidence demonstrates a defect; link its finding.
- `unverified`: required evidence or a bound is missing; state what would resolve it.
- `n/a`: a contract-based explanation shows the check is inapplicable.

Timing, concurrent effects, authorization, lifecycle/cancellation, and I/O behavior require execution against the boundary that owns the behavior. Structural evidence can prove a narrower property, such as a lock acquisition graph, but does not establish runtime mutual exclusion, absence of hidden acquisitions, or safe cancellation by itself. Split those obligations instead of using a structural label to waive behavioral checks. Asserted build/type-check success also needs actual check results; a type-based argument is not evidence that a compiler ran.

Closure records use the same evidence states; avoid bare `holds` or `verified` that hides the proof kind. Reviewers re-derive structural evidence and run required behavioral probes themselves. Source-backed defects do not need a successful exploit demonstration to remain open. Missing infrastructure is an evidence gap rather than automatically a code bug, but missing required execution still prevents readiness. Do not manufacture token probes or historical regressions for structurally proven or purely static changes.

Validate report content, whether returned as text or written to a file: scope/revision, assigned coverage, incremental coverage in incremental rounds, appropriate proofs/results, explicit findings/verdict, and completion. File absence alone is not invalid when a complete returned report is available. A skeleton, truncated/empty response, or exit status alone is insufficient. Return unsupported evidence claims for correction under the skill's bounded retry rule. Honest unverified coverage remains a gap; it is not a pass. Liveness guidance does not override a complete report's validity.

## Project memory and severe carry-ins

Read existing project review memory when available. Store new recurring classes and carry-ins with durable external run artifacts by default; link the location in the final report. Creating or updating an in-repo memory file is opt-in, with existing user/project authorization sufficient. Do not ask merely to choose the external default, or silently modify repository guidance. If no durable external location is available, include the entries in the final report and state that cross-run storage was not established.

Record `class ID | invariant / failure pattern | surface tags | affected area | evidence | prevention / probe | status`. Feed relevant entries to workers. Add only classes supported by actual findings; the watch-lists provide general patterns, and memory records where they occurred in this project.

For a severe out-of-scope finding, retain `finding ID | severity / evidence | affected area | next-touch reassessment | suggested action | destination / status`. Before a pass touches that area, reassess it against the current goal and changed invariants. Import it as required only if it now breaks that goal/invariant or the user has explicitly included it. Otherwise keep it visible as unresolved out-of-scope work without blocking, expanding the task, or requesting the same scope decision again. Reuse recorded scope decisions; ask about expansion only when necessary to fulfill the goal and not already settled. Close carry-ins with independent evidence. Routing them to external artifacts does not authorize sending messages or creating tickets.

## Snapshots and fix verification

Before each implementation/fix worker, make a recoverable copy of the tracked and untracked files needed by the task, preserving existing edits. An ordinary archive/copy that preserves file types, modes, and symlink targets is sufficient; a custom hash manifest or launch script is not required. Record the copied scope, baseline revision, and git status. Keep snapshots outside the repository, preserve staged/unstaged state, and do not use stash, checkout, reset, or index mutations to create them. A plain `git diff` misses untracked files. Use `git --no-optional-locks` for read-only inspection. Reuse repository snapshot tooling if available.

After a pass, capture the full task diff from the starting tree and the incremental diff from the pre-fix copy, including additions/deletions. The starting tree may differ from `HEAD` in a dirty repository. Keep unrelated user edits distinguishable and inspect unexpected git-state changes; never restore blindly over newer work.

For ordinary fixes, confirm cited tests exist and selectors run them, execute relevant regression checks, and record the command, context, result, and discriminating assertion. Historical before/after runs and saved replay artifacts are optional; targeted scratch mutations in matched watch-lists, such as TA2 and TA9, remain the default checks for test discrimination. Those use a disposable copy without the full replay protocol. Structural and static obligations use their corresponding proof rules. Do not claim a historical failure unless observed.

For **security-sensitive or reopened behavioral findings**, require a replayable proof:

1. In isolation, show the regression test fails for the intended defect on the pre-fix implementation and passes on the candidate. If the old revision cannot run the test, use a focused fault patch as the failure demonstration and record that historical reproduction was unavailable. Setup or dependency failures do not count.
2. Save a `.patch` beside the report that reintroduces the defect into the candidate, referenced by finding ID. Record candidate identity, patch direction/application/reversal commands, test selector, and expected failing assertion. Keep new regression tests in the candidate snapshot, not in the deliberate break.
3. The coordinator or verifier replays it in a fresh isolated copy: check the base, apply the patch, observe the intended failure, reverse it, confirm the source tree matches the base byte-for-byte including file types/modes/symlink targets and additions/deletions, and confirm the restored test passes. Keep declared build/output paths outside that comparison; unexpected source changes fail restoration.

Bypass task-result caches for executions claimed as new evidence. Never apply deliberate breaks to the live reviewed tree. When optional replay is used, follow the same isolation/restoration safeguards. A missing mandatory proof stays unverified; ordinary fixes do not become unverified merely because optional replay was omitted. Replaying an implementer proof does not replace the reviewer's independent assessment of the boundary and inverse failure. Use existing automation when available, otherwise record explicit commands; no specific test runner or harness procedure is assumed.

## Final security review

After incremental rounds pass, review the whole security-sensitive candidate in fresh contexts. Supply the goal, settings, common + reviewer briefs, **Evidence states**, decisions, baseline, full diff/tree, matched watch-lists, and relevant project memory. Withhold this run's verdicts, closure assertions, and fix narratives until independent enumeration and probes finish; this phase starts a new inventory rather than inheriting fix-pass coverage.

Keep assignments within the four-list cap, configured parallelism, and total budgets. Review the committed tree if committing was authorized, otherwise the frozen candidate; this step grants no commit permission. Reconcile results with the ledger and critic under the normal gates. New required findings or evidence gaps return to the loop within its limits. Any subsequent edit needs renewed review/validation of its effects and renewed final security review.

## Effort and stop record

Where measurements are available, record `pass | role / model | elapsed | complete / invalid / redone / escalated | reason | snapshot`. Distinguish summed reviewer time from elapsed wall time when workers overlap. Track redone fixes and escalations as well as findings; mark unavailable timing as unknown, not zero. Respect cycle, invalid-pass, no-progress, and user resource limits. An incomplete stop preserves findings, gaps, and next actions without implying approval.
