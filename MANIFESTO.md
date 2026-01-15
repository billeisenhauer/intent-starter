# Manifesto: Governing Software by Intent

This repository exists to test and demonstrate a simple claim:

> **Software identity should be governed, not inferred.**

Most software systems do not fail because code is wrong.
They fail because *meaning drifts*.

This repository is an attempt to make meaning explicit, enforceable, and durable —
even as implementations change.

---

## The Problem We Are Addressing

Modern software development suffers from a quiet contradiction:

- Code is cheap to write and rewrite.
- Understanding what a system *is* remains expensive.
- Change accumulates faster than meaning is preserved.

As a result:
- Systems rot without breaking tests.
- Refactors change behavior unintentionally.
- Architecture is explained, not enforced.
- Identity exists only in the heads of maintainers.

AI accelerates this failure mode.
It increases the rate of change without preserving intent.

---

## Our Position

We reject the idea that:

- Code is the primary artifact of software
- Repositories define system identity
- Tests alone capture correctness
- Architecture can be enforced socially

Instead, we assert:

- **Intent defines identity**
- **Implementations are temporary**
- **Evaluation outranks authorship**
- **Change must be governed, not trusted**

---

## What This Repository Is

This repository is a **starter for intent-governed systems**.

It provides:
- A canonical structure for expressing system intent
- Mechanisms to protect intent from erosion
- A way to evaluate whether a system is still itself
- Guardrails for AI-assisted development

It is designed to support:
- Multiple implementations
- Regeneration instead of preservation
- Fast change where safe
- Slow change where dangerous

---

## What This Repository Is Not

This repository is **not**:

- A framework
- A code generator
- A SaaS product
- A replacement for GitHub
- A manifesto against programming languages
- A promise of full automation

It does not attempt to:
- Eliminate design decisions
- Replace human judgment
- Optimize for velocity at all costs

If you are looking for convenience first, this is the wrong tool.

---

## Core Concepts

### Truth
The `truth/` directory defines **system identity**.

It contains only claims that must remain true regardless of:
- language
- framework
- architecture
- implementation

Truth is binding.
If it changes, the system has changed identity.

---

### Intent
Intent describes:
- What the system is
- What it must never become
- What outcomes must always be observable

Intent is normative, not descriptive.

---

### Evaluation
Evaluation decides whether a system is acceptable.

If evaluation fails:
- Code does not matter
- Diffs do not matter
- Opinions do not matter

Evaluation is the final authority.

---

### Pace
Not everything should change at the same speed.

This repository encodes:
- What may change freely
- What requires ceremony
- What must change rarely and deliberately

Pace is permission, not advice.

---

### Implementations
Applications in `apps/` are **expressions**, not definitions.

They are expected to:
- Be regenerated
- Be replaced
- Be deleted

Their value lies in satisfying truth, not in being preserved.

---

## AI Is a First-Class Constraint, Not a Gimmick

This repository assumes AI-assisted development is normal.

As such:
- Truth is protected from AI modification by default
- AI agents are scoped and constrained
- Generation is encouraged where disposable
- Evaluation governs acceptance

AI is treated as a powerful executor, not an authority.

---

## What Success Looks Like

This repository is successful if:

- An implementation can be deleted and rebuilt without fear
- Multiple implementations can coexist without ambiguity
- Identity changes are explicit, reviewable, and rare
- Fast change does not erode slow guarantees
- Meaning survives regeneration

---

## Who This Is For

This repository is for people who:

- Care about long-lived systems
- Expect change, not stability
- Use AI seriously, not casually
- Value clarity over cleverness
- Prefer constraints over explanations

It is not optimized for teams who:
- Want minimal friction
- Avoid explicit commitments
- Treat architecture as informal
- Believe tests alone are sufficient

---

## The Claim, Restated

> **Software should be governed by intent,
> not reconstructed from code after the fact.**

This repository is an experiment in making that governance explicit.

Adopt it, adapt it, or discard it —
but do not mistake it for documentation.

It is a boundary.
