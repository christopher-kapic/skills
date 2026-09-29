---
name: ck-plan
description: Create a repository-grounded implementation plan through delegated drafting and independent review cycles. Use when the user asks to plan a feature or complex code change, refine an implementation approach before coding, or write a reviewed plan to a file or display it.
---

# CK Plan

Coordinate fresh worker plan → review → revise passes. Deliver a repository-grounded plan without implementing it; later implementers or review-loop may use it as optional input.

## Inputs

Use user values or defaults: goal = current conversation (ask if absent); planning and review harness = current; model = select by role; review parallelism = 1; `critic: auto`; max cycles = unlimited within the run budget; output = display; `propose_improvements` = false. `critic: always` requires a fresh critic each cycle.

Before launch, record a finite elapsed wall-time allowance, starting at 60 minutes and adjusted to scope. Fit finite pass limits, scouts, revisions, reviews, critics, retries, validation, and reporting inside it. Honor user hard caps; limit tokens only with observable usage. Before a self-estimated allowance expires, permit a recorded finite extension citing concrete progress and remaining work. Never extend user caps or reset no-progress limits. Choose routine budgets autonomously; exhaustion ends incomplete with gaps and next actions.

Always plan the root-cause design so extra layers are unnecessary (“unwrap the onion”). With `propose_improvements: true`, collect advisory reusable instruction changes; modify skills only when separately asked.

## Clarify decisions

When user intent is needed, invoke user-decision before continuing. For explicitly or implicitly noninteractive work, choose the best long-term options. Use quick options only when requested for the entire task.

## Worker selection

Use fresh native subagents for `current` when supported, otherwise invoke-harness; use invoke-harness for named external harnesses. Supply each worker goal, role, focus, decisions, context, artifact index, output destination, and limits. Require one pass without re-entering this skill, nesting a harness, or waiting on stdin.

Honor user model choices. Otherwise choose the cheapest qualified model: lower-cost models for scouts, mechanical revisions, and settled plans; strong reasoning for uncertain root-cause design, security, authorization, concurrency, durability, and disputed evidence. Each substantive cycle needs one independently capable reviewer exploring the repository without a scout bundle. Apply routing to native and external workers. Record actual model ID, harness, supported reasoning setting, and capability basis; confirm external IDs through invoke-harness. Vendor and price alone do not establish capability. Diagnose reasoning, context, tooling, or evidence failures before escalating stalled cheap passes within user settings.

Use explore-offload when repeated exploration costs exceed scout and rendering work; pass small known files directly. Give workers only their focus context, artifact index, and permission to read more; refresh stale bundles. Record observable scout and consumer time, token costs, and context additions; otherwise `unknown`.

Scale reviews to surface and uncertainty within user settings, assigning complementary design, consumer, and lifecycle focuses. All reviewers check invariants and report completion, coverage evidence, and findings or explicit clean result. For empty, interrupted, or malformed passes, inspect partial artifacts, retry once with a fresh worker, then stop incomplete if still invalid.

## Plan and coverage contract

Supply this contract to planners, reviewers, and critics: planners produce artifacts, reviewers verify them, and critics adjudicate triggers.

- Produce ordered steps, affected files, decisions, compatibility concerns, tests, and validation. Identify each changed invariant's enforcement point and how affected paths reach it; checks or warnings suffice only when they prevent prohibited behavior.
- Maintain `affected site and operation | planned change | verification`, including consumers, siblings, and relevant failure and lifecycle paths. Bound completeness with repository search scope, queries, and results or a type or ownership argument. Group only sites sharing proof. Unknown required coverage is a blocker `enumeration incomplete` with unverified evidence.
- Identify repository-supported fast checks and broader tests, their coverage, and when implementation runs them. Mark unverified commands and distinguish planned from executed checks; proposed code cannot claim a pass.
- Report evidenced gaps by root cause and severity. Blockers prevent required outcomes, omit necessary enforcement or affected paths, or risk unauthorized access, data loss, or failed deployment. Majors are substantial defects below that threshold; minors have lower impact. Missing evidence or unbounded inventory remains `unverified` with the unresolved obligation, without reduced severity. Addressed findings need `Class sweep: scope searched; affected sites; enforcement point; verification; remaining exceptions`.
- Update coverage incrementally; reviewers independently check revisions and newly affected sites.

## Loop

Keep `ID | invariant and class | severity | open/closed/deferred | latest evidence`. Reuse class IDs and preserve closure evidence; independent review closes findings and contrary evidence reopens them. Record authorized deferrals and reasons without changing severity. Workers name IDs for current blockers or majors (including proposed closures), disputes at any severity, adjudication requests, reopening, conflicting reports, and unbounded uncertainty.

Cycle until no actionable findings remain, `max cycles` is reached, or budget expires:

1. Delegate a planner the goal, decisions, repository context, current plan, coverage, ledger, and contract. Require repository inspection and root-cause design.
2. Launch fresh independent reviewers within parallelism, supplying the same inputs. Require actionable gaps, sequencing problems, risks, missing tests, and unnecessary scope, supported by `path:line`, symbol, or command result. Label unverified objections as concerns; reuse class IDs and separate out-of-scope suggestions. If improvements are enabled, request reusable instruction changes separately, excluding project-specific advice.
3. Under `critic: auto`, require a fresh critic for:
   - A current open blocker or major, or proposed closure of one.
   - A planner or reviewer dispute over a named finding at any severity, including disagreement with its severity rating.
   - Reviewer-requested adjudication.
   - Security-sensitive work.
   - A reopened finding.
   - Conflicting reports.
   - Reviewer-reported unbounded uncertainty.

   Route from reports and IDs without substituting coordinator judgment or lowering severity; old independently closed findings alone do not trigger. Record trigger and IDs or omission rationale, reevaluating after late evidence. Give the critic focused evidence, plan revision, ledger, coverage, contract, and artifact index with access to more. Require adjudication and missed findings; end with exactly one verdict:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <repository citation or command result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves findings. `DISAGREE_EVIDENCE` may change findings only as its evidence supports. For a concern, delegate one concise evidence-resolution pass under worker-selection rules; retain grounded claims and unresolved gaps, then end debate. Concerns cannot suppress findings.
4. Combine duplicate evidence-backed findings by class; one clean review cannot override another's actionable finding. Accept only with no actionable open findings and valid final-revision coverage from every assigned review and required critic. Evidence gaps require resolution, never omitted scrutiny or a pass. Later substantive edits renew review of affected areas. Otherwise send updated ledger and coverage to the next planner.

Two successive revisions of the same class without new closure evidence require a different approach in the next pass. If it also stalls, stop incomplete with unresolved evidence. Cycle and invalid-pass limits also bind; no stop implies approval.

## Deliver

Make the plan executable without rediscovering its design: baseline revision and dirty inputs; goal and acceptance criteria; decisions and authority; invariant and consumer inventory with evidence; ordered steps; proposed or executed validation; unresolved findings, coverage, and review status. Keep this in the plan, without a duplicate handoff document. Later review-loop runs may validate and reuse it; it starts no implementation, supplies no code validation, and grants no authority. Separate assumptions and out-of-scope suggestions. If enabled, include reusable instruction improvements and the iterations they could prevent. Write the requested file or display the plan; report deferrals, omitted-critic rationale, cost and context metrics, and incomplete stop reasons.
