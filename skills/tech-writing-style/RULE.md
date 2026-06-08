---
schema: 1
name: tech-writing-style
description: House style for all technical prose the agent emits — second person, active voice, present tense, sentence-case headings, serial commas; defer word-list and capitalization rulings to the repo's own guide, else the Google developer documentation style guide, else Chicago.
metadata:
  version: 0.1.0
---

The house style for every piece of technical prose you write — docs, READMEs,
comments, commit bodies, release notes, PR descriptions. Apply it always, not
only when a writing skill is active.

## Tier 1 — guide-agnostic fundamentals

These hold across Google, Microsoft, and Chicago alike, so they govern
regardless of which guide a repo adopts. Check each before you ship prose:

- Address the reader in the second person ("you"), not the first ("we").
- Write in the active voice and name the actor performing the action.
- Use the present tense for behaviour ("the command returns", not "the command
  will return").
- Spell and punctuate consistently throughout a document; do not mix locale
  conventions within one piece. (The specific locale and the serial-comma
  convention are set in Tier 2.)
- Put the conditional clause before the instruction ("To save the file, press
  Ctrl+S"), not after.
- Write titles and section headings in sentence case.
- Use a numbered list for a sequence, a bulleted list for an unordered set, and
  a description list for term/definition pairs.
- Put commands, code, paths, and identifiers in code formatting; write dates
  unambiguously (`2026-06-08` or `8 June 2026`, never `06/08/26`).
- Keep the tone conversational, not frivolous; do not pre-announce content
  ("Below is…", "This section will…") — just write it.
- Write descriptive link text that names the target ("the Google style guide"),
  never "click here" or a bare URL.
- Write accessibly — supply alt text and keep a strict heading hierarchy under a
  single `<h1>` — and write for a global audience by avoiding idiom and regional
  slang.

## Tier 2 — swappable guide pointer (precedence order)

For spelling and punctuation locale (American vs British), the serial comma,
word-list rulings, capitalization, and product-term conventions, defer in
this order:

1. The consumer repo's own house style (its `CONTRIBUTING` file or style guide),
   if one exists — it wins over every general guide below.
2. Otherwise the [Google developer documentation style guide](https://developers.google.com/style)
   and its [word list](https://developers.google.com/style/word-list) (American
   spelling; serial comma) — the default for anything the repo does not rule on.
3. Otherwise the Chicago Manual of Style — the fallback for anything neither the
   repo nor Google covers.

Borrow [Microsoft's bias-free and inclusive-language guidance](https://learn.microsoft.com/style-guide/bias-free-communication)
and its accessibility guidance where they are more developed than the chosen
guide. The optional Vale gate enforces whichever Tier-2 guide the repo picks;
Vale ships both Google and Microsoft packages, so configure the one that matches.

## Why this is a rule, not a skill section

This is a rule — always loaded — because it governs every word you emit, not
only the turns when a writing skill is active. A skill section would load on
demand and miss the prose written outside it.
