---
name: user-decision
description: Reduce excessive, complex, or choice-heavy output to the decisions the user must make. Use when an agent presents too much analysis, too many unresolved choices, or an overwhelming response, or when the user asks to simplify decisions, establish intent, or provide long-term and quick options.
---

# User Decision

Turn analysis into a short decision queue. Preserve the choices needed to establish user intent; remove background that does not help the user choose.

## Prepare

1. Identify only decisions that require user intent. Do not ask about choices the agent can safely resolve from context.
2. Merge dependent or duplicate decisions. Order the remaining decisions by dependency and impact.
3. Identify the viable options for each decision. Do not invent options to fill the list.
4. Rank options in this order:
   - **Best long term:** The most durable option. State why.
   - **Quick:** The best immediate option, only if different. State what it achieves now and the required follow-up.
   - Other viable options, best first. State important tradeoffs.

## Ask

Present at most five decisions per batch. Wait for the user's answers before sending the next batch. Use Simplified Technical English: common words, short sentences, active voice, and one idea per sentence.

Use this format:

```markdown
1. How do you want to handle <decision>?
   - **Best long term:** <option>. <reason>
   - **Quick:** <option>. <immediate result>. Follow up with <action>.
   - <other option>. <important tradeoff>.
```

Keep each option concise but specific enough for an informed choice. Do not hide material cost, risk, compatibility, or follow-up work. If only one reasonable option exists, recommend it and ask for confirmation instead of listing weak alternatives.
