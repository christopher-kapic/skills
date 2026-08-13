---
name: review-loop
description: For implementing and reviewing important or complex code changes in a git repo.
---

# Review Loop

Use subagents with fresh context to implement and review changes

# User inputs

goal (aka prompt) (default: goal of the conversation prececding review loop, otherwise ask the user)
implementation harness (default: current harness)
implementation model (default: current model)
review harness (default: current harness)
review model (default: current model)
review parallelism (default: 1)
greenfield (default: false)
test lifecycle: parallel|before_review|after_review|skip (default: parallel)
max cycles (default: infinite)

# Pseudocode

```
def implement_changes(goal: `<changes to implement/prompt>`, feedback: [] | null):
  if implementation_harness==current_harness:
    implement_changes_with_implementation_model_subagent(goal, feedback)
  if implementation_harness!=current_harness
    implement_changes_by_invoking_external_harness_noninteractive_with_selected_implementation_model(goal, feedback)

def evaluate_changes(goal: `<changes implemented/original prompt>`,):
  evaluate if the changes are the best long term solution. If the project is greenfield, breaking changes are okay. Boil the ocean. We want the best implementation possible. If the project is not greenfield, then we still want the best long term implementation, but we cannot introduce breaking changes (eg: SQL schema changes that would break old clients) unless the user specifically approves them (if there are breaking changes, ask the user or refer to earlier user input

def review_changes(goal: `<changes implemented/original prompt>`):
  get_git_diff()
  evaluate_changes(goal, diff)

def review_loop(goal: `<changes to implement/prompt>`, feedback: [] | null):
  implement_changes(goal, feedback)
  
```
