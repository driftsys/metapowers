# Metapowers Phase 4: Product Experts & Remaining — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the metapowers registry with 8 remaining skills covering product techniques, safety, and documentation craft.
**Architecture:** Each skill is a SSOT item in `skills/<name>/SKILL.md`. All content must pass `upskill lint --strict` and `upskill fmt`.
**Tech Stack:** Markdown with YAML frontmatter (upskill portable format), validated by `upskill lint`, formatted by `upskill fmt` and `dprint`.

---

## Task 1: Create `atdd` skill

- [ ] Scaffold: `upskill new skill atdd`
- [ ] Write full skill content to `skills/atdd/SKILL.md`
- [ ] Validate: `upskill lint skills/atdd/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add atdd skill"`

### Content spec for `atdd`

**Description:** Use when writing acceptance criteria before implementation, applying spec-by-example, structuring Gherkin scenarios, or connecting ATDD outer loop with TDD inner loop.

**Sections to cover:**

1. **The ATDD Cycle** — Discuss (collaborate on examples with stakeholders) → Distill (formalize into executable specs) → Develop (implement to satisfy specs) → Demo (show passing specs to stakeholders). Each phase has distinct participants and outputs.

2. **Writing Acceptance Tests Before Code** — Tests express business intent, not implementation. Write them during refinement, not after development. One scenario per behavior. Acceptance tests are owned by the team, not just QA.

3. **Gherkin Best Practices**
   - Declarative over imperative: describe WHAT not HOW (`Given a registered user` not `Given I click register and fill in...`)
   - Avoid UI details in scenarios — scenarios survive UI redesigns
   - One behavior per scenario — if you need "and" in the scenario title, split it
   - Background for shared setup, but keep it short (3 lines max)
   - Scenario Outlines for data-driven variations, not for different behaviors
   - Use domain language from the ubiquitous language, never technical jargon

4. **Spec by Example** — Concrete examples drive implementation. Start with key examples (happy path), then boundary examples, then error examples. Examples become living documentation. Use example mapping (rules → examples → questions) to discover missing acceptance criteria.

5. **Living Documentation** — Tests ARE the documentation. They stay current because they break when behavior changes. Organize features by capability, not by sprint. Tag scenarios for traceability (`@epic:payments`, `@story:refund-flow`).

6. **ATDD + TDD Integration** — ATDD is the outer loop (red acceptance test → green acceptance test). TDD is the inner loop (red unit test → green unit test → refactor). Write one failing acceptance test, then TDD your way to green. Never have more than one failing acceptance test at a time.

---

## Task 2: Create `event-storming` skill

- [ ] Scaffold: `upskill new skill event-storming`
- [ ] Write full skill content to `skills/event-storming/SKILL.md`
- [ ] Validate: `upskill lint skills/event-storming/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add event-storming skill"`

### Content spec for `event-storming`

**Description:** Use when discovering domain boundaries, identifying aggregates, mapping business processes, or facilitating collaborative domain modeling sessions.

**Sections to cover:**

1. **Big-Picture Event Storming** — Domain events on a timeline (orange stickies, past tense verbs: "Order Placed", "Payment Received"). Identify hotspots (pink stickies — conflicts, questions, pain points). Find pivotal events (events that change the business process direction). Use swimlanes for parallel processes or different actors.

2. **Design-Level Event Storming** — Add commands (blue — user intentions triggering events), aggregates (yellow — consistency boundaries protecting invariants), policies (lilac — "whenever X happens, do Y" automation), read models (green — data needed to make decisions), external systems (pink — third-party integrations). This level maps directly to code.

3. **Facilitation**
   - Who to invite: domain experts (MUST), developers, product owners, UX. Exclude managers who dominate conversation.
   - Materials: unlimited wall space (or Miro for remote), colored stickies, markers, timer.
   - Time-boxing: big-picture in 2-4 hours, design-level in 1-2 hours per bounded context.
   - Remote facilitation: use Miro/FigJam, enforce turn-taking, break into smaller groups for parallel exploration, reconvene for synthesis.

4. **Outputs** — Bounded context boundaries (where the language changes), aggregate candidates (consistency boundaries), process flows (event chains), integration points (where contexts communicate), and a shared ubiquitous language dictionary.

5. **Common Pitfalls**
   - Too much detail too early — stay at big-picture until boundaries emerge
   - Missing domain experts — developers alone produce technical, not business, models
   - Confusing events with commands — events are facts that happened, commands are intentions
   - Trying to model the entire domain in one session — focus on one core subdomain
   - Premature solutioning — stick to "what happens" before "how we build it"

---

## Task 3: Create `story-mapping` skill

- [ ] Scaffold: `upskill new skill story-mapping`
- [ ] Write full skill content to `skills/story-mapping/SKILL.md`
- [ ] Validate: `upskill lint skills/story-mapping/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add story-mapping skill"`

### Content spec for `story-mapping`

**Description:** Use when planning releases, identifying MVP scope, prioritizing features by user narrative, or decomposing epics into deliverable slices.

**Sections to cover:**

1. **The Backbone** — User activities ordered left-to-right representing the user's journey through the system. These are high-level goals (e.g., "Discover Products", "Place Order", "Track Delivery"). The backbone tells the story of what users do, in roughly chronological order. Keep it at 5-9 activities.

2. **The Body** — User tasks under each activity, ordered top-to-bottom by priority (most essential at top). Tasks are smaller steps within an activity. The top row forms the "walking skeleton" — the minimum tasks needed for the activity to function at all.

3. **Release Slicing** — Draw horizontal lines across the map to define releases. Each slice must be a coherent, deliverable increment. Slice 1 = walking skeleton (proves the architecture works end-to-end). Slice 2 = usable product (real users can accomplish their goals). Slice 3+ = delightful product (polish, edge cases, advanced features).

4. **Walking Skeleton** — The thinnest possible end-to-end slice that exercises all activities in the backbone. It may be ugly, limited, and manual in places — but it proves the system works from start to finish. This is NOT a prototype — it is production code that will be extended.

5. **MVP Identification** — The MVP line sits below the walking skeleton but above nice-to-haves. It represents the minimum viable product that real users would pay for / adopt. Validate MVP scope by asking: "Would a user switch from their current solution to this?" If no, the line is too high.

6. **Narrative Flow** — Read the map left-to-right to tell the user's story. If the narrative doesn't flow, the map is wrong. Use persona-based walkthroughs: "As [persona], I first [activity 1], then [activity 2]..." Multiple personas may have different paths through the same map — mark persona-specific tasks.

---

## Task 4: Create `cuj-analysis` skill

- [ ] Scaffold: `upskill new skill cuj-analysis`
- [ ] Write full skill content to `skills/cuj-analysis/SKILL.md`
- [ ] Validate: `upskill lint skills/cuj-analysis/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add cuj-analysis skill"`

### Content spec for `cuj-analysis`

**Description:** Use when identifying which user journeys matter most, mapping happy paths and failure modes, measuring journey health, or prioritizing fixes by drop-off impact.

**Sections to cover:**

1. **Journey Identification** — Identify journeys by business impact: revenue journeys (checkout, upgrade, renewal), retention journeys (onboarding, first value, habit formation), activation journeys (signup → first meaningful action). Prioritize by: frequency × revenue impact × user frustration. A system typically has 5-10 critical journeys.

2. **Happy Path Mapping** — Document the ideal step-by-step flow from trigger to outcome. Each step has: actor, action, system response, success criteria. Keep steps atomic — one decision or action per step. Include time expectations (e.g., "page loads in <2s", "confirmation within 24h").

3. **Edge Case Discovery** — At each step ask: What if the user goes back? What if they have no data yet? What if they're on mobile? What if they have 10,000 items? What if they lose connectivity? What if the session expires? What if they're a different persona? Categorize: common edge cases (handle gracefully) vs rare edge cases (handle safely).

4. **Failure Mode Analysis** — For each failure: likelihood (how often it occurs) × impact (how much it hurts). Build a 2×2 matrix: high-likelihood + high-impact = fix immediately, high-likelihood + low-impact = reduce friction, low-likelihood + high-impact = add safety nets, low-likelihood + low-impact = document and accept.

5. **Journey Metrics** — Completion rate (% of users who finish the journey), time-to-complete (p50, p90, p99), drop-off points (where users abandon), error rate per step, retry rate (users going back), and satisfaction (post-journey survey or inferred from behavior). Set targets for each metric. Alert when metrics degrade.

6. **Prioritization** — Fix the highest-impact drop-off first. Impact = (number of users reaching that step) × (drop-off rate at that step) × (value of journey completion). Don't optimize steps that few users reach. Don't polish steps with 99% completion. Focus where the biggest gap exists between current and target completion.

---

## Task 5: Create `issue-modeling` skill

- [ ] Scaffold: `upskill new skill issue-modeling`
- [ ] Write full skill content to `skills/issue-modeling/SKILL.md`
- [ ] Validate: `upskill lint skills/issue-modeling/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add issue-modeling skill"`

### Content spec for `issue-modeling`

**Description:** Use when creating issues, triaging backlogs, defining issue templates, establishing severity/priority matrices, or structuring work hierarchies.

**Sections to cover:**

1. **Issue Types** — When to use each:
   - **Epic**: Large body of work decomposed into stories/tasks. Has acceptance criteria defining "done." Spans multiple sprints.
   - **Story**: User-facing requirement ("As a user, I want X so that Y"). Deliverable in one sprint. Has acceptance criteria.
   - **Task**: Technical requirement not directly user-visible (refactor auth module, set up CI pipeline). Deliverable in one sprint.
   - **Debt**: Known shortcuts, review findings, or quality improvements deferred from a prior PR. References the originating context.
   - **Bug**: Unexpected behavior in production or staging. Has reproduction steps, expected vs actual behavior, environment details.

2. **Hierarchy** — Initiative (label-only, groups related epics) → Epic (issue with task list of children) → Story/Task/Debt (leaf work items). Every child references its parent epic in the body (`Epic: #N`). Epics reference their initiative via label (`initiative:<name>`).

3. **Labels** — Type labels (`story`, `task`, `debt`, `bug`, `epic`). Severity labels (`K0` must-have, `K1` should-fix, `K2` nice-to-have). Effort labels (`XS`, `S`, `M`, `L`, `XL`). Priority labels (computed from matrix). Epic membership labels (`epic:<name>`). One type label required. Severity + effort required for prioritization.

4. **Severity × Effort → Priority Matrix**

   |        | XS | S  | M  | L    | XL   |
   | ------ | -- | -- | -- | ---- | ---- |
   | **K0** | P0 | P0 | P0 | P1   | P1   |
   | **K1** | P0 | P1 | P1 | P2   | drop |
   | **K2** | P1 | P2 | P2 | drop | drop |

   P0 = do now, P1 = do next sprint, P2 = backlog, drop = won't do (close with explanation).

5. **Triage Workflow** — New (untriaged, needs labels) → Triaged (has type + severity + effort + priority) → Prioritized (assigned to a milestone/sprint) → Assigned (has an owner) → In Progress (branch created) → In Review (PR open) → Done (merged + verified). Weekly triage meeting: process all "new" issues, close stale items, re-prioritize based on new information.

6. **Templates** — Each issue type has required fields:
   - Story: Epic reference, user story statement, acceptance criteria, out of scope
   - Task: Epic reference, technical description, done criteria, dependencies
   - Debt: Epic reference, origin (PR link or review comment), description, risk if unaddressed
   - Bug: Environment, reproduction steps, expected behavior, actual behavior, severity, screenshots/logs

---

## Task 6: Create `code-safety` skill

- [ ] Scaffold: `upskill new skill code-safety`
- [ ] Write full skill content to `skills/code-safety/SKILL.md`
- [ ] Validate: `upskill lint skills/code-safety/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add code-safety skill"`

### Content spec for `code-safety`

**Description:** Use when writing defensive code, establishing invariants, implementing fail-fast patterns, preventing AI hallucination in generated code, or designing error handling strategies.

**Sections to cover:**

1. **Defensive Coding** — Validate all inputs at system boundaries (API handlers, CLI args, file readers, message consumers). Never trust external data — parse and validate before use. Distinguish between internal boundaries (assert, panic-worthy) and external boundaries (return errors, give feedback). Defense in depth: validate at the boundary AND at the domain layer.

2. **Invariants and Assertions** — Assert preconditions at function entry ("this parameter must be positive"). Assert postconditions before return ("result must satisfy X"). Document assumptions with comments AND runtime checks. Use `debug_assert` for expensive checks that should run in tests but not production. Invariant violations are bugs — crash, don't recover.

3. **Fail-Fast** — Crash early with clear error messages rather than propagating invalid state. Invalid state that propagates becomes impossible to debug. Return errors immediately — don't accumulate partial results from corrupted inputs. Every error message must answer: what happened, where, and what the user can do about it.

4. **Anti-Hallucination Patterns** — For AI-generated code specifically:
   - Verify before claiming success: run the test, check the output, confirm the file exists
   - Check return values: don't assume an API call succeeded
   - Don't assume APIs/methods exist: verify imports compile, functions are real
   - Don't invent configuration: check docs for actual option names
   - Test edge cases: generated code often handles only the happy path
   - Read error messages: don't guess at fixes, read what the system is telling you

5. **Error Handling** — Use explicit error types (enums, not strings). Never swallow exceptions (`catch {}` is almost always a bug). Propagate context: wrap errors with "what was I trying to do when this failed." Distinguish recoverable (retry, fallback) from unrecoverable (crash with context). Log at the handling site, not the raising site.

6. **Boundary Validation (Parse, Don't Validate)** — Convert unstructured data into typed, validated structures at the boundary. Once parsed, the type system guarantees validity — no re-checking needed downstream. Use newtypes to make illegal states unrepresentable (`EmailAddress` not `String`, `PositiveInt` not `i32`). If you're checking a condition more than once, your types aren't strong enough.

---

## Task 7: Create `privacy-compliance` skill

- [ ] Scaffold: `upskill new skill privacy-compliance`
- [ ] Write full skill content to `skills/privacy-compliance/SKILL.md`
- [ ] Validate: `upskill lint skills/privacy-compliance/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add privacy-compliance skill"`

### Content spec for `privacy-compliance`

**Description:** Use when handling personal data, implementing consent flows, conducting privacy impact assessments, designing data retention policies, or ensuring GDPR/CCPA compliance in system design.

**Sections to cover:**

1. **GDPR Principles** — Lawfulness (legal basis for processing: consent, contract, legitimate interest, legal obligation, vital interest, public task), purpose limitation (collect for specified purposes only), data minimization (only collect what's necessary), accuracy (keep data correct and current), storage limitation (delete when no longer needed), integrity and confidentiality (protect against unauthorized access), accountability (demonstrate compliance with documentation).

2. **Technical Measures** — Encryption at rest (database-level or field-level for sensitive data) and in transit (TLS 1.3 minimum). Pseudonymization (replace identifiers with tokens, store mapping separately). Access controls (principle of least privilege, role-based access, audit who accessed what). Audit logging (who accessed which data, when, for what purpose — but don't log PII in audit logs).

3. **Consent Management** — Consent must be freely given, specific, informed, and unambiguous. Implement granular consent (per purpose, not blanket). Withdrawal must be as easy as granting. Record consent: who, when, what they consented to, which version of the policy. Pre-checked boxes are NOT valid consent. Silence is NOT consent.

4. **Data Subject Rights** — Right of access (provide all data held within 30 days), rectification (correct inaccurate data), erasure ("right to be forgotten" — delete when no legal basis to retain), portability (provide data in machine-readable format), objection (stop processing for direct marketing immediately), restriction (stop processing but retain data during disputes). Build automated self-service where possible; manual processes don't scale.

5. **PII Handling** — Identification: what constitutes PII (name, email, IP address, device IDs, location data, biometric data, any combination that identifies a person). Classification: sensitivity tiers (public, internal, confidential, restricted). Masking in logs: never log raw PII — use hashing, truncation, or replacement. Retention schedules: define per data category, automate deletion, document justification for retention period.

6. **DPIAs (Data Protection Impact Assessments)** — Required when: processing at scale, systematic monitoring, sensitive data, automated decision-making, new technologies. Process: describe processing, assess necessity and proportionality, identify risks to data subjects, define mitigation measures, consult DPO. Document: data flows, risk assessment, controls, residual risk acceptance.

7. **Privacy by Design** — Data flow mapping (know where PII flows through every system). Minimization checklist: do we need this field? Can we derive it instead of storing it? Can we aggregate instead of keeping individual records? Default privacy settings (opt-in, not opt-out). Privacy in architecture: separate PII stores, access layers, anonymization pipelines. Consider privacy at design time, not as a retrofit.

---

## Task 8: Create `typography-and-layout` skill

- [ ] Scaffold: `upskill new skill typography-and-layout`
- [ ] Write full skill content to `skills/typography-and-layout/SKILL.md`
- [ ] Validate: `upskill lint skills/typography-and-layout/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add typography-and-layout skill"`

### Content spec for `typography-and-layout`

**Description:** Use when structuring documents, designing information hierarchy, formatting technical content, or ensuring readable and accessible text layout.

**Sections to cover:**

1. **Heading Hierarchy** — H1 for page/document title only (one per document). H2 for major sections. H3 for subsections within H2. H4 sparingly for sub-subsections. NEVER skip levels (H2 → H4 is wrong). Headings are an outline — if you read only headings, the document structure should be clear. Keep headings short (5-8 words), descriptive, and parallel in structure.

2. **Whitespace Rhythm** — Consistent spacing creates visual hierarchy. One blank line between paragraphs. Two blank lines before H2 sections. One blank line before H3 subsections. No trailing whitespace. Whitespace groups related content and separates unrelated content. Dense walls of text signal poor structure — break them up.

3. **Information Architecture** — Progressive disclosure: most important information first, details later. Inverted pyramid: conclusion → supporting evidence → background. Scannable structure: readers skim before reading — make skimming productive with clear headings, bold key terms, and front-loaded sentences. Chunk information: 3-7 items per group, use lists for parallel items, use paragraphs for connected reasoning.

4. **Table Design** — Use tables for structured comparisons (rows are items, columns are attributes). Don't use tables for simple lists or sequential steps. Right-align numbers, left-align text. Keep headers short and unambiguous. Use consistent units. If a table exceeds 5-6 columns, consider splitting or restructuring. Empty cells suggest the table structure is wrong.

5. **Code Block Formatting** — Always specify the language for syntax highlighting (`rust,`yaml). Use meaningful variable names in examples (not `foo`, `bar`, `x`). Keep examples focused: show ONE concept per block. Ideal length: 5-20 lines. If longer, break into multiple blocks with explanatory text between. Add comments only for non-obvious lines. Show output/result when it aids understanding.

6. **Lists** — Ordered lists for sequential steps, ranked items, or numbered references. Unordered lists for parallel items with no inherent order. Parallel structure: every item should be the same grammatical form (all nouns, all imperatives, all sentences). Consistent punctuation: either all items end with periods (if sentences) or none do (if fragments). Nested lists: maximum 2 levels deep — deeper nesting signals need for restructuring.

7. **Accessibility** — Alt text for images (describe function, not appearance). Semantic structure (headings for structure, not styling). Color-independent meaning (don't rely on color alone to convey information). Screen reader considerations: link text should be descriptive ("Read the configuration guide" not "click here"), tables need header rows, abbreviations should be expanded on first use. Document language declaration. Sufficient contrast ratios.

---

## Task 9: Update `metapowers.bundle.yaml`

- [ ] Add all 8 new skills to the bundle manifest items list
- [ ] Bump version to `1.0.0` (full registry complete)
- [ ] Validate: `upskill lint metapowers.bundle.yaml --strict`
- [ ] Commit: `git commit -m "feat(bundle): complete metapowers v1.0.0 with all skills"`

---

## Task 10: Final validation and PR

- [ ] Run `upskill fmt` on entire repository
- [ ] Run `upskill lint --strict` on all skills
- [ ] Run `just verify` (if available) or full test suite
- [ ] Push branch
- [ ] Create PR: `gh pr create --title "feat(skills): complete metapowers Phase 4 — product experts & remaining" --body "Adds 8 skills (atdd, event-storming, story-mapping, cuj-analysis, issue-modeling, code-safety, privacy-compliance, typography-and-layout). Completes the metapowers registry at v1.0.0."`

---

## Parallelization Guide

Tasks 1-8 are fully independent and can be dispatched as parallel subagents. Task 9 depends on all 8 skills existing. Task 10 depends on Task 9.

Recommended dispatch: 4 parallel agents, 2 skills each:

- Agent A: `atdd` + `event-storming`
- Agent B: `story-mapping` + `cuj-analysis`
- Agent C: `issue-modeling` + `code-safety`
- Agent D: `privacy-compliance` + `typography-and-layout`
