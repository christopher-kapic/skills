---
name: ck-plan
description: Create a repository-grounded implementation plan through delegated drafting and independent review cycles. Use when the user asks to plan a feature or complex code change, refine an implementation approach before coding, or write a reviewed plan to a file or display it.
---

# CK Plan

Build a solid implementation plan through fresh plan → review → revise passes. The main agent only coordinates and delivers the result; delegate every planning and review pass to a fresh worker. Do not implement the feature.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); planning harness/model = current; review harness/model = current; review parallelism = 1; max cycles = unlimited; output = display; `propose_improvements` = false.

“Unwrap the onion” means plan the root-cause design so extra implementation layers are unnecessary. Always do this.

When `propose_improvements: true`, collect candidate changes to this skill's reusable planning and review instructions that could prevent similar review findings in future delegated runs. Do not collect them when false. These proposals are advisory only; do not modify the skill or repository instructions unless the user separately asks.

## Clarify decisions

At any point, if the plan requires user intent, invoke the `user-decision` skill before continuing. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire planning task.

## Worker selection

For `current`, use a fresh native subagent when the current harness supports one. Otherwise, invoke a fresh noninteractive process of the current harness through the `invoke-harness` skill. For any named external harness, use `invoke-harness`. Each worker must receive the goal and required context in its initial prompt; do not rely on conversation state shared by a previous worker. State the worker's role (planner, reviewer, or critic) and that it is performing that pass only. Instruct it not to re-enter this skill, invoke a nested harness, or wait on stdin.

Scale review effort to the affected surface and uncertainty, honoring user settings; use reasoning controls only if supported. With multiple reviewers, assign complementary focuses (design correctness; affected consumers and lifecycle paths), while all check the claimed invariants. Require explicit completion, coverage evidence, and findings or an explicit clean result for reviews. Empty, interrupted, or malformed output is an invalid pass: inspect any partial artifacts, retry once with a fresh worker, then stop as incomplete if still invalid.

## Plan and coverage contract

Give planners and reviewers this contract; planners produce the artifacts, reviewers verify them:

- Produce an ordered plan with affected files, design decisions, compatibility concerns, tests, and validation. For each changed invariant, identify its enforcement point and how affected paths reach it; checks or warnings suffice only if they prevent the prohibited behavior.
- Maintain a compact table: `affected site / operation | planned change | verification`. Include consumers, siblings, and failure/lifecycle paths where relevant. Support completeness with the repository search scope, queries and results, or a type/ownership bound. Group sites only when one argument covers them. Unknown coverage is an actionable `enumeration incomplete` finding; assertions of exhaustiveness are insufficient.
- Identify repository-supported fast validation commands and broader tests, what they cover, and when implementation should run them. Mark unverified commands; do not claim that proposed code passes checks.
- Report all evidenced gaps in the current pass, grouped by root cause. For each addressed finding, provide `Class sweep: scope searched; affected sites; enforcement point; verification; remaining exceptions`. Distinguish planned verification from executed checks.
- Update the coverage artifact incrementally. Reviewers verify its evidence independently and inspect the effects of revisions, including newly affected sites.

## Loop

Keep a cumulative ledger: `ID | invariant/class | open, closed, or deferred | latest evidence`. Assign a new ID only to a new class; retain closure evidence and reopen the same ID when disproved. Close findings only after independent review; record authorized deferrals and reasons separately from closure.

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one planning pass the goal, relevant user decisions, repository context, current plan, coverage artifact, ledger, and plan and coverage contract. Require repository inspection and root-cause design.
2. Delegate `review parallelism` independent reviews to fresh workers. Give each the goal, plan, relevant repository context, ledger, coverage artifact, and plan and coverage contract. Ask for actionable gaps, sequencing problems, risks, missing tests, and unnecessary scope. Require repository evidence (`path:line`, symbol, or command result); label unverified objections as concerns. Reuse matching class IDs. List out-of-scope suggestions separately. When `propose_improvements` is true, separately propose reusable instruction changes that would have prevented findings; exclude project-specific advice.
3. Have one fresh critic adjudicate findings, closure evidence, and coverage gaps against the plan, repository, ledger, and plan and coverage contract; it may also raise missed findings. Its response must end with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <repository citation or command result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as supported by the cited evidence. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass using the worker-selection rule, then retain only claims grounded in the repository. Do not continue reviewer–critic debate beyond this pass.
4. Combine duplicate evidence-backed findings by class; one clean review cannot override another's actionable finding. Accept only when no actionable open findings remain and all assigned reviews and the critic validly cover the final plan revision. Any later substantive edit requires renewed review of its effects. Otherwise pass the updated ledger and coverage artifact to the next planner.

If the same class remains unresolved across two successive revisions without new closure evidence, require a different approach in the next planning pass. If that pass also makes no progress, stop as incomplete with the unresolved evidence. `max cycles` and invalid-pass limits also stop the loop; none imply approval.

## Deliver

Include enough detail for an implementation agent to execute without rediscovering the design. Separate assumptions and out-of-scope suggestions from implementation steps. If `propose_improvements` is true, add a concise **Potential skill improvements** section to the end report. Each item must state the reusable instruction change and the category of review iteration it is expected to prevent; omit empty or project-specific suggestions. If the user requested a file, write the final plan there. Otherwise, display it. Report any deferrals or reason the loop stopped before approval.
