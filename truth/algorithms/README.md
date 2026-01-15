# Algorithms

This directory contains **algorithmic specifications** — formulas, weights, thresholds, and computation rules that define system behavior.

## Why This Exists

"Magic numbers" buried in code are:
- Hard to find and audit
- Changed without review
- Inconsistent across implementations

Algorithmic specs make computation rules:
- Explicit and reviewable
- Consistent across languages
- Part of system identity

## What Belongs Here

- **Weights and scores** — Sentiment values, ranking factors
- **Decay functions** — Time-based weight reduction
- **Thresholds** — Cutoffs that trigger state changes
- **Formulas** — Composite score calculations

## Example

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

## Authoring

Use `/algorithm-spec` to generate algorithmic specifications from intent documents.

## Pace Layer

Algorithms are **medium pace** — they change more often than core identity but require review before modification.
