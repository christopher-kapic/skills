---
name: ck-plan
description: Create a repository-grounded implementation plan through delegated drafting and independent review cycles. Use when the user asks to plan a feature or complex code change, refine an implementation approach before coding, or write a reviewed plan to a file or display it.
---

# CK Plan

Build a solid implementation plan through fresh plan → review → revise passes. The main agent only coordinates and delivers the result; delegate every planning and review pass to a fresh worker. Do not implement the feature.

This skill uses only portable Agent Skills metadata and refers to other skills by name in plain language. Do not assume that `$name` or `/name` invocation syntax works in every harness.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); planning harness/model = current; review harness/model = current; review parallelism = 1; max cycles = unlimited; output = display.

## Clarify decisions

At any point, if the plan requires user intent, invoke the `user-decision` skill before continuing. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire planning task.

## Worker selection

For `current`, use a fresh native subagent when the current harness supports one. Otherwise, invoke a fresh noninteractive process of the current harness through the `invoke-harness` skill. For any named external harness, use `invoke-harness`. Each worker must receive the goal and required context in its initial prompt; do not rely on conversation state shared by a previous worker.

## Loop

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one planning pass the goal, relevant user decisions, repository context, current plan, and accumulated findings using the worker-selection rule. Require the worker to inspect the repository and produce a concrete, ordered plan with affected files, key design decisions, compatibility concerns, tests, and validation.
2. Delegate `review parallelism` independent reviews of the plan to fresh workers using the worker-selection rule. Give each worker the goal, plan, and relevant repository context. Ask it to verify assumptions against the repository and report actionable gaps, sequencing problems, risks, missing tests, and unnecessary scope. List out-of-scope suggestions separately.
3. Combine duplicate findings. If none remain, accept the plan; otherwise accumulate them for the next planning worker.

## Deliver

Include enough detail for an implementation agent to execute without rediscovering the design. Separate assumptions and out-of-scope suggestions from implementation steps. If the user requested a file, write the final plan there. Otherwise, display it. Report if `max cycles` stopped the loop before approval.
