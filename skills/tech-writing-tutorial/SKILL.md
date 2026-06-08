---
schema: 1
name: tech-writing-tutorial
description: Use when tech-writing has classified the document as tutorial — a tutorial, getting-started guide, or quickstart.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-writing` classified this document as **tutorial**. A
tutorial teaches by doing: a guaranteed-to-work guided experience for a
**newcomer**. You, the author, take responsibility for the reader's success —
every step works, every time, from a clean start.

Reader's stance: **action + acquisition** — doing, in order to learn. The reader
does not yet know the domain and is not trying to accomplish their own goal; they
are following your lesson to build a first working result and the confidence that
comes with it.

## The shape

A tutorial is the standard shape for a tutorial, a getting-started guide, and a
quickstart. Build every one this way:

1. **Numbered, linear steps that always work.** A single ordered sequence the
   reader follows top to bottom. Every step succeeds; the reader never hits a dead
   end.
2. **Concrete and specific.** Real names, real values, real commands — not
   placeholders the newcomer cannot resolve.
3. **Expected output at meaningful steps.** Show what the reader should see after
   the steps that matter, so they can confirm they are on track and self-correct.
4. **One happy path.** A single route from start to a working result.

## Do

- **Guarantee success from a clean start.** Make the tutorial reproducible from
  nothing — fresh checkout, fresh environment — so a newcomer cannot fall off the
  path.
- **Put the conditional clause before the instruction.** "When the server is
  running, open the page", not "open the page when the server is running".
- **Keep it concrete.** Specific, copy-able steps over general advice.

## Don't

- **No choices.** Do not offer "you could also" alternatives — every fork is a
  chance for the newcomer to take the wrong branch. Alternatives belong in a
  how-to.
- **No theory or explanation digressions.** Do not stop to explain why something
  works; it breaks the flow and the reader is here to do, not study. Link out to
  an explanation instead — see `tech-writing-explanation`.
- **No error-handling rabbit holes.** Do not document what to do when each step
  fails — keep the path clean and the failures out.

## Where the boundary blurs

- **vs `tech-writing-howto`.** A tutorial serves a **newcomer** whose goal is
  **learning**, on a single guaranteed path with no choices; a how-to serves a
  **competent** reader chasing a **specific goal**, and may branch on the reader's
  situation. If the reader already knows the domain and wants to get one task
  done, it is a how-to — see `tech-writing-howto`.

## Verify

Apply the cross-cutting verify checklist in the `tech-writing` umbrella (§5):
mode purity, house style, accessibility, and the no-drift checks — every command
runnable and matching the current API, reproducible from a clean start, ships
with the code.
