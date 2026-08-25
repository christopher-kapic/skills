---
name: ck-plan
description: Create a repository-grounded implementation plan through delegated drafting and independent review cycles. Use when the user asks to plan a feature or complex code change, refine an implementation approach before coding, or write a reviewed plan to a file or display it.
---

# CK Plan

Build a solid implementation plan through fresh plan → review → revise passes. The main agent only coordinates and delivers the result; delegate every planning and review pass to a fresh worker. Do not implement the feature.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); planning harness/model = current; review harness/model = current; review parallelism = 1; max cycles = unlimited; output = display; `propose_improvements` = false.

When `propose_improvements: true`, collect candidate changes to this skill's reusable planning and review instructions that could prevent similar review findings in future delegated runs. Do not collect them when false. These proposals are advisory only; do not modify the skill or repository instructions unless the user separately asks.

## Clarify decisions

At any point, if the plan requires user intent, invoke the `user-decision` skill before continuing. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire planning task.

## Worker selection

For `current`, use a fresh native subagent when the current harness supports one. Otherwise, invoke a fresh noninteractive process of the current harness through the `invoke-harness` skill. For any named external harness, use `invoke-harness`. Each worker must receive the goal and required context in its initial prompt; do not rely on conversation state shared by a previous worker.

## Loop

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one planning pass the goal, relevant user decisions, repository context, current plan, and accumulated findings using the worker-selection rule. Require the worker to inspect the repository and produce a concrete, ordered plan with affected files, key design decisions, compatibility concerns, tests, and validation.
2. Delegate `review parallelism` independent reviews of the plan to fresh workers using the worker-selection rule. Give each worker the goal, plan, and relevant repository context. Ask it to verify assumptions against the repository and report actionable gaps, sequencing problems, risks, missing tests, and unnecessary scope. Require repository evidence (`path:line`, symbol, or command result) for each actionable finding; label anything not yet verifiable as a concern. List out-of-scope suggestions separately. When `propose_improvements` is true, also list separately any generalizable skill-instruction improvements that would have enabled an earlier planning or review worker to avoid the finding; exclude project-specific implementation advice.
3. Have one fresh critic audit the reviews against the plan and repository. Its response must end with exactly one verdict line:

   ```text
   AGREE
   DISAGREE_EVIDENCE: <repository citation or command result>
   DISAGREE_CONCERN: <specific unverified objection>
   ```

   `AGREE` preserves all findings. `DISAGREE_EVIDENCE` may add, revise, or reject findings only as supported by the cited evidence. `DISAGREE_CONCERN` cannot suppress a finding: delegate one concise evidence-resolution pass using the worker-selection rule, then retain only claims grounded in the repository. Do not continue reviewer–critic debate beyond this pass.
4. Combine duplicate evidence-backed findings. If none remain, accept the plan; otherwise accumulate them for the next planning worker.

## Deliver

Include enough detail for an implementation agent to execute without rediscovering the design. Separate assumptions and out-of-scope suggestions from implementation steps. If `propose_improvements` is true, add a concise **Potential skill improvements** section to the end report. Each item must state the reusable instruction change and the category of review iteration it is expected to prevent; omit empty or project-specific suggestions. If the user requested a file, write the final plan there. Otherwise, display it. Report if `max cycles` stopped the loop before approval.
