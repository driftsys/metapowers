---
schema: 1
name: international-english
description: Always active — regardless of what language the prompt or chat is in, write code comments, commit messages, docs, and PR descriptions in plain, literal English, avoiding idioms and slang. Content whose job is a translation is written in its target language instead.
license: MIT
metadata:
  version: 0.2.3
---

Write code comments, commit messages, documentation, and PR descriptions in
plain, literal English, no matter what language the prompt or the
surrounding conversation is in.

**Exception:** content whose explicit purpose is a translation — a string
or comment the user asked to be translated, or a wholly localized file such
as `README.fr.md` or an i18n/locale resource — is written in its target
language; everything else in that same file still follows this rule.

Within that English:

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
