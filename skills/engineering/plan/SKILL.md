---
name: plan
description: Create a repository-grounded implementation plan through delegated drafting and independent review cycles. Use when the user asks to plan a feature or complex code change, refine an implementation approach before coding, or write a reviewed plan to a file or display it.
---

# Plan

Build a solid implementation plan through fresh plan → review → revise passes. The main agent only coordinates and delivers the result; delegate every planning and review pass to a fresh subagent or non-interactive external harness. Do not implement the feature.

## Inputs

Use user values or these defaults: goal = current conversation (ask only if absent); planning harness/model = current; review harness/model = current; review parallelism = 1; max cycles = unlimited; output = display.

## Clarify decisions

At any point, if the plan requires user intent, use `$user-decision` before continuing. If the user explicitly or implicitly requests noninteractive work, choose each best long-term option without asking. Use quick options only when the user requests them for the entire planning task.

## Loop

For each cycle, until no actionable findings remain or `max cycles` is reached:

1. Delegate one planning pass the goal, relevant user decisions, repository context, current plan, and accumulated findings. Use a fresh subagent if the selected harness is current; otherwise invoke the external harness non-interactively. Require the worker to inspect the repository and produce a concrete, ordered plan with affected files, key design decisions, compatibility concerns, tests, and validation.
2. Delegate `review parallelism` independent reviews of the plan to fresh subagents if the review harness is current; otherwise use its external harness. Give each worker the goal, plan, and relevant repository context. Ask it to verify assumptions against the repository and report actionable gaps, sequencing problems, risks, missing tests, and unnecessary scope. List out-of-scope suggestions separately.
3. Combine duplicate findings. If none remain, accept the plan; otherwise accumulate them for the next planning worker.

## Deliver

Include enough detail for an implementation agent to execute without rediscovering the design. Separate assumptions and out-of-scope suggestions from implementation steps. If the user requested a file, write the final plan there. Otherwise, display it. Report if `max cycles` stopped the loop before approval.
