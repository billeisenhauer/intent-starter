# Monitoring

This directory contains **observable contracts** — metrics definitions and service level objectives that define what success looks like.

## Why This Exists

Truth isn't just about behavior — it's about outcomes. Observable contracts answer:
- How do we measure success?
- What thresholds indicate problems?
- When should we alert?

## What Belongs Here

### metrics.md

Defines **how metrics are computed**:

```markdown
## recommendation_pick_rate
- **Source:** recommendation_lists, consumption_events
- **Definition:** sessions starting from recommendation / total sessions
- **Unit:** percentage
```

### slo.md

Defines **what success looks like**:

```markdown
## Recommendation Quality
- recommendation_pick_rate >= 30% over 7 days
- Alert when: drops below 25% for 24 hours
```

## Relationship to Other Truth

| Truth Layer | Question Answered |
|-------------|-------------------|
| Intent | What is the system? |
| Contracts | What is the API shape? |
| Algorithms | How are things computed? |
| Invariants | What must always be true? |
| **Monitoring** | **How do we know it's working?** |

## Authoring

Use `/slo-define` to generate metrics and SLO definitions from intent documents.

## Pace Layer

Monitoring specs are **medium pace** — SLO targets may be adjusted based on operational experience, but metric definitions are more stable.
