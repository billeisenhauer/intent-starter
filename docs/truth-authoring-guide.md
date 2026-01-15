# Truth Authoring Guide

This document explains how to work with the truth layer.
It is commentary, not binding claims.

Binding claims live in `truth/`.
This document lives in `docs/`.

---

## Workflow

| Step | Skill | Output |
|------|-------|--------|
| 1 | `/intake` | `intent/*.md` candidate |
| 2 | `/intent-distill` | Refined `intent/*.md` |
| 3 | `/contract-author` | `contracts/openapi.yaml` |
| 4 | `/algorithm-spec` | `algorithms/*.md` |
| 5 | `/slo-define` | `monitoring/*.md` |
| 6 | `/scenario-author` | `evaluations/scenarios/*.yml` |
| 7 | `/boundary-classify` | Pace layer classification |
| 8 | `/implementation-generate` | `apps/{lang}-{name}/` |
| 9 | `/truth-verify` | Pass/fail verification |

---

## Why Each Truth Subdirectory Exists

### Intent

Intent captures **what the system is** in natural language.
It is the programming language of truth.

Questions intent answers:
- What problem does this system exist to solve?
- What must it never become?
- What rules define its legitimacy?
- What outcomes must users always observe?

### Contracts

Contracts define **external promises** — what others are allowed to rely on.

These matter because if someone depends on something and it changes,
the system has broken trust.

### Algorithms

"Magic numbers" buried in code are:
- Hard to find and audit
- Changed without review
- Inconsistent across implementations

Algorithmic specs make computation rules:
- Explicit and reviewable
- Consistent across languages
- Part of system identity

**Example:**

```markdown
# Recommendation Scoring

## Recency Decay

**Formula:**
weight = 0.5^(days_elapsed / 21)

**Parameters:**
| Name | Value | Rationale |
|------|-------|-----------|
| base | 0.5 | Halves weight each period |
| half_life | 21 days | Recent activity matters more |
```

### Evaluations

Evaluations decide whether a system is still itself.
They pass or fail. They do not explain.

### Monitoring

Truth isn't just about behavior — it's about outcomes.
Observable contracts answer:
- How do we measure success?
- What thresholds indicate problems?
- When should we alert?

**Example metrics.md:**

```markdown
## recommendation_pick_rate
- **Source:** recommendation_lists, consumption_events
- **Definition:** sessions starting from recommendation / total sessions
- **Unit:** percentage
```

**Example slo.md:**

```markdown
## Recommendation Quality
- recommendation_pick_rate >= 30% over 7 days
- Alert when: drops below 25% for 24 hours
```

### Pace

Pace defines permission to change, not implementation paths.
Path mappings live in each app's `pace-mapping.yml`.

---

## Relationship Between Truth Components

| Truth Layer | Question Answered |
|-------------|-------------------|
| Intent | What is the system? |
| Contracts | What is the API shape? |
| Algorithms | How are things computed? |
| Evaluations | What must always be true? |
| Monitoring | How do we know it's working? |
| Pace | What may change and when? |

---

## Pace Layer Guidelines

Algorithms and monitoring specs are **medium pace** — they change more often than core identity but require review before modification.

Intent and contracts are **slow pace** — changes here alter system identity.

---

## Common Mistakes

**Putting implementation details in intent:**
Intent describes what, not how. Framework names, database choices, and architectural patterns belong in apps.

**Skipping evaluations:**
If a truth claim cannot be evaluated against a running system, it is not truth — it is aspiration.

**Over-specifying algorithms:**
Only specify computation rules that define system behavior. Internal optimizations belong in apps.
