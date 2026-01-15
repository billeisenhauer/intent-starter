---
name: algorithm-spec
description: Define algorithmic specifications — formulas, weights, thresholds, and computation rules that are too precise for prose but should not be buried in code. Use when intent describes scoring, ranking, decay, weighting, or any computation with "magic numbers". Use when user says "define algorithm", "specify weights", "what are the thresholds", or "how is X calculated". Outputs truth/algorithms/*.md files.
---

# Algorithmic Specification

Codify computation rules that define system behavior.

## What Belongs Here

Algorithmic specs capture the **what** of computation without implementation:
- Weights and scores
- Decay functions
- Thresholds and cutoffs
- Ranking formulas
- State transition rules

## Why This Matters

"Magic numbers" buried in code are:
- Hard to find and audit
- Changed without review
- Inconsistent across implementations

Algorithmic specs make them:
- Explicit and reviewable
- Consistent across languages
- Part of system identity (truth)

## Output Format

```markdown
# truth/algorithms/{domain}.md

# {Domain} Algorithms

## {Algorithm Name}

**Purpose:** {What this computes}

**Formula:**
```
result = f(inputs)
```

**Parameters:**
| Name | Value | Rationale |
|------|-------|-----------|
| weight_a | 2.0 | {why this value} |

**Examples:**
| Input | Output |
|-------|--------|
| x=1 | 2.0 |

**Invariants:**
- {constraint that must hold}
```

## Common Patterns

### Weights / Sentiment Mapping

```markdown
## Sentiment Weights

| Sentiment | Weight | Rationale |
|-----------|--------|-----------|
| Loved | +2 | Strong positive signal |
| Liked | +1 | Mild positive |
| Meh | 0 | Neutral |
| Disliked | -1 | Mild negative |
| Hated | -2 | Strong negative signal |
```

### Decay Functions

```markdown
## Recency Decay

**Formula:**
```
weight = base^(days_elapsed / half_life)
```

**Parameters:**
| Name | Value | Rationale |
|------|-------|-----------|
| base | 0.5 | Halves weight each period |
| half_life | 21 days | Recent views matter more |

**Examples:**
| Days | Weight |
|------|--------|
| 0 | 1.0 |
| 21 | 0.5 |
| 42 | 0.25 |
```

### Thresholds

```markdown
## Staleness Threshold

**Rule:** Data older than threshold is marked Unknown

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| staleness_threshold | 120 days | Balance freshness vs coverage |

**State Mapping:**
| Age | Status |
|-----|--------|
| < 120 days | Valid |
| >= 120 days | Unknown |
```

### Composite Scores

```markdown
## Recommendation Score

**Formula:**
```
score = (taste_match * w1) + (availability * w2) + (novelty * w3)
```

**Weights:**
| Component | Weight | Rationale |
|-----------|--------|-----------|
| taste_match | 0.5 | Primary signal |
| availability | 0.3 | Must be watchable |
| novelty | 0.2 | Encourage discovery |

**Constraint:** Weights must sum to 1.0
```

## Validation

Before completing:
- [ ] Every "magic number" has a name and rationale
- [ ] Formulas are implementation-agnostic
- [ ] Examples demonstrate edge cases
- [ ] Invariants constrain valid configurations

## Pace Layer

Algorithmic specs are **medium pace**:
- Slower than UI/presentation
- Faster than core identity
- Require review but not extensive approval
- Should have evaluations that verify implementations match
