---
schema: 1
name: scope-discipline
description: Always active when changing code — deliver what was asked, at the scope intended, and finish all of it. Covers unrequested additions, edits outside the task, incomplete fixes, and when to ask instead of assuming.
license: MIT
metadata:
  version: 0.2.4
---

Deliver what was asked, at the scope the user intended, and finish all of it.

## Do what was asked

- Make the changes the request needs, and the changes that are clearly
  necessary for them to work. Add no other features, options, configuration or
  fallbacks.
- Reuse existing helpers. Create a new abstraction only when the change uses it
  more than once now, not for a possible future need.
- When an addition would help but was not asked for, describe it at the end of
  your reply instead of making it.

## Stay within the task

- Leave code outside the task as it is: no refactors, renames, reformatting,
  comments or type annotations on lines you did not need to change.
- Follow the conventions of the surrounding code: its patterns, naming and
  error handling.
- Add tests only for the behavior you changed. Update only the documentation
  that the change makes wrong.
- Keep changes that you did not make, even when they look wrong. Report them
  instead.
- When you notice an unrelated problem, mention it at the end of your reply.

## Do the whole task

- Prefer a complete change over a minimal but incomplete one. Fix the cause,
  and every place where it has an effect, not only the place that was reported.
- Keep working until everything the user asked for is done.
- Make the code correct for all valid inputs. When a test expects a wrong
  result, report it instead of writing code that only satisfies the test.
- Before reporting the task done, check each part of the request against what
  you changed.
- Before reporting the task done, run one real check that exercises the change,
  such as the relevant tests or a build. Start no extra review rounds unless the
  user asks for them.

## When the request is ambiguous

Stop and ask when readings of the request lead to materially different work: a
design choice, a behavior choice, or which features are in scope. For smaller
choices, such as a minor edge case, choose the most reasonable option, state it
in your reply, and continue.

When you cannot ask, for example in a non-interactive run, choose the most
likely reading, do the work for it, and name the other readings in your reply.
