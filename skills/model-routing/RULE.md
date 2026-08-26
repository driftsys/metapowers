---
schema: 1
name: model-routing
description: Route bounded mechanical and ops work to Sonnet subagents, keep the main loop on the strong model, and hold multi-agent fan-out behind an explicit request.
license: MIT
metadata:
  version: 0.2.3
---

Delegate bounded mechanical work to a Sonnet subagent — the `Agent` tool with
`model: "sonnet"`. This covers shell and scripting work, `gh` and `git`
interrogation, reproducing a reported failure, mechanical sweeps across many
files, and reading a large artifact to answer one specific question.

Delegate above roughly four tool calls. Below that, a subagent's fresh context
load costs more than running the work inline.

Keep the main loop on the strong model. It holds the conversation and decides
what "done" means, so a cheaper main loop lowers the quality of the decisions
rather than the cost of the work.

Ask before launching a multi-agent workflow or a deep-research run. One
subagent running a sweep is routine; a fan-out spawning many agents is a spend
decision that belongs to the user.

Escalate above the main loop's model only when designing the falsifying
experiment is itself the hard part. Long is a fan-out, unfamiliar is a search,
and a high finding count is usually a structural problem — none of the three is
a reason to escalate.
