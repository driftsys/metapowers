---
schema: 1
name: delegation-classes
description: Give every planned task a class (critical, standard, light, ops) from AGENTS.md, the defaults or the code, before any code is written.
license: MIT
metadata:
  version: 0.1.0
---

Give a class to each task in a plan and to each file change you make, on its
own `Class:` line with its source. Answer questions without a class.

```markdown
1. Add a CSV export to `src/reports/export.py`.
   Class: standard (default: user-facing feature)
2. Add export tests to `tests/test_export.py`.
   Class: standard (tests of standard code)
```

| Class    | If the code is wrong, who finds out, and when   |
| -------- | ----------------------------------------------- |
| critical | A customer, an auditor or an attacker, later    |
| standard | A user, quickly                                 |
| light    | You, right away, and it can fail with no impact |
| ops      | Nobody: no behavior change, tool-checked edits  |

Resolve the class in this order:

1. Use the class that AGENTS.md records for the project or for the path.
2. Otherwise, use the default below for the kind of code.
3. Otherwise, infer it with the question in the table, and state the reason.

Defaults:

- critical: security; authentication and access rights; code that stores,
  sends or shares personal data; payment and billing; data migrations; secrets,
  in CI/CD and elsewhere.
- standard: user-facing features, including screens that display personal data;
  CI/CD; test frameworks; internal tools that hold shared data.
- light: build scripts, prototypes, internal tools with no shared data.

Apply these to every task:

- Give a task the highest class among the code it touches.
- Give tests the class of the code they test.
- When you cannot decide between two classes, choose the higher one.
- When a task displays personal data and no spec says whether privacy applies,
  ask the user, and plan the task as standard until the user answers.
- Use ops only for a change that needs no decision; a change that needs a
  decision takes the class of its code.
- Keep the resolved class until the user lowers it, and record the user's
  decision in the plan.

When the user decides or confirms a class for the project or for a path, offer
to record it in the "Delegation classes" section of AGENTS.md. Save it to memory
instead when the user declines to change AGENTS.md.

Before you dispatch subagents for a task, load the `delegation-routing` skill.
