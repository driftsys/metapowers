---
schema: 1
name: international-english
description: Always active — write code comments, commit messages, documentation, and PR descriptions in plain, literal English so a non-native English speaker who knows standard software and domain-engineering vocabulary can follow without knowing idiom or slang.
license: MIT
metadata:
  version: 0.2.3
---

Write prose — code comments, commit messages, docs, PR descriptions — in
plain, literal English.

- Use literal phrasing instead of idioms, slang, or figures of speech.
- Standard software and domain-engineering vocabulary is expected
  knowledge — technical terms, acronyms, and jargon stay as-is. Only
  non-technical, idiom-based phrasing gets replaced.
- When a plain phrase and an idiomatic phrase say the same thing, use the
  plain one.

**Never do this:**

> The old retry logic was hammering the downstream service, so a small
> blip turned into a pile-up of retries.

**Do this instead:**

> The old retry logic sent every retry at the same time, which overloaded
> the downstream service.
