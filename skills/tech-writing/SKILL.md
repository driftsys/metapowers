---
schema: 1
name: tech-writing
description: Technical writing craft — Diataxis, ADRs, API docs, changelogs, prose clarity
version: 0.1.0
---

## When to use this skill

Use when writing documentation, ADRs, changelogs, API references, READMEs, or
any prose that developers will read.

## The Diataxis Framework

Every piece of documentation serves one of four purposes. Don't mix them.

| Type | Purpose | Oriented to | Example |
|------|---------|-------------|---------|
| **Tutorial** | Learning | Doing (guided) | "Build your first API" |
| **How-to** | Accomplishing | Doing (goal) | "How to add authentication" |
| **Explanation** | Understanding | Thinking (why) | "Why we chose event sourcing" |
| **Reference** | Information | Thinking (what) | "API endpoint specification" |

**Common mistake:** Mixing tutorial content with reference content. A tutorial
says "type this command." A reference says "this command accepts these flags."
They serve different readers at different moments.

## Prose Principles

### 1. Active Voice

| Bad | Good |
|-----|------|
| The request is validated by the middleware | The middleware validates the request |
| Errors are logged by the service | The service logs errors |
| The configuration file is read at startup | The application reads configuration at startup |

### 2. Front-Load Information

Put the most important information first. The reader may stop at any point.

| Bad | Good |
|-----|------|
| After considering various approaches and evaluating trade-offs, we decided to use gRPC | We chose gRPC for service communication |
| In order to ensure that the system maintains consistency... | The system maintains consistency by... |

### 3. One Idea Per Sentence

If a sentence has "and" or "but" joining two independent clauses, split it.

### 4. Concrete Over Abstract

| Bad | Good |
|-----|------|
| The system handles errors appropriately | The system retries transient errors 3 times with exponential backoff, then returns a 503 |
| Performance is acceptable | p99 latency is under 200ms at 1000 RPS |

### 5. Consistent Terminology

Pick one term and use it everywhere. Create a glossary if needed.
Never: "user" in one paragraph, "customer" in the next, "account holder" later.

## Document Types

### ADR (Architecture Decision Record)

```markdown
# NNNN — [Title: Verb Phrase]

## Status
[Proposed | Accepted | Deprecated | Superseded by NNNN]

## Context
[2-5 sentences: what forces exist, what constraints apply, what triggered this]

## Decision
[1-3 sentences: what we will do, stated clearly]

## Consequences
### Positive
- [What becomes easier]

### Negative
- [What becomes harder]

### Risks
- [What could go wrong]
```

### Changelog Entry

Follow Keep a Changelog format:
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

Each entry: imperative mood, one line, issue/PR reference.

### API Documentation

For each endpoint:
1. Method + path
2. One-sentence description
3. Request (headers, params, body with example)
4. Response (status codes, body with example)
5. Error cases (status code + error body)
6. Authentication requirement

### README Structure

1. **Title + one-line description** (what is this?)
2. **Quick start** (how do I use it in 30 seconds?)
3. **Installation** (how do I get it?)
4. **Usage** (common patterns)
5. **Configuration** (what can I change?)
6. **Contributing** (how do I help?)
7. **License**

## Quality Checklist

Before publishing any documentation:
- [ ] Does it serve exactly one Diataxis purpose?
- [ ] Is the audience explicit? (developer, operator, end-user)
- [ ] Can someone follow it without asking clarifying questions?
- [ ] Are all code examples tested/runnable?
- [ ] Is terminology consistent with the glossary?
- [ ] Is it findable? (linked from relevant places, good title)
