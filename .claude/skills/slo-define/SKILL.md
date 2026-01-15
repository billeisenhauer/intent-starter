---
name: slo-define
description: Define metrics and service level objectives from intent documents. Use when creating monitoring contracts, when intent describes success criteria or measurable outcomes, when user says "define SLOs", "what should we measure", "create metrics", "how do we know it's working", or "observable contracts". Outputs truth/monitoring/metrics.md and truth/monitoring/slo.md.
---

# SLO Definition

Create observable contracts that define what success looks like.

## Process

1. Read `truth/intent/*.md` for outcomes and success criteria
2. Identify measurable behaviors from invariants
3. Define metrics with computation rules
4. Set SLO targets with thresholds

## Output Files

### truth/monitoring/metrics.md

```markdown
# Metrics Catalog

Define how metrics are computed for consistency across monitoring and evaluations.

## {Category}

### {metric_name}
- **Source:** {data sources}
- **Definition:** {computation formula}
- **Unit:** {percentage, count, duration, etc.}
```

### truth/monitoring/slo.md

```markdown
# Service Level Objectives

## {Category}

- {metric_name} {operator} {threshold} over {window}
- Alert when: {condition}
```

## Metric Categories

| Category | What It Measures | Example |
|----------|------------------|---------|
| **Quality** | Correctness of outputs | error_rate <= 1% |
| **Freshness** | Data staleness | staleness_rate <= 10% |
| **Availability** | System uptime | uptime >= 99.9% |
| **Latency** | Response time | p99_latency <= 500ms |
| **Throughput** | Capacity | requests_per_second >= 100 |

## Derivation Rules

| Intent Pattern | Metric Type |
|----------------|-------------|
| "Must always X" | Quality metric with near-100% target |
| "Should usually X" | Quality metric with 90-99% target |
| "Within N days/hours" | Freshness metric |
| "Responds with" | Latency metric |
| "Handles N concurrent" | Throughput metric |

## SLO Target Guidelines

- Start conservative (easier targets)
- Tighten based on actual performance
- Include error budget (100% - target)
- Define escalation thresholds

## Validation

Before completing:
- [ ] Every metric has a clear computation definition
- [ ] Every SLO has a measurable threshold
- [ ] Alert conditions are actionable
- [ ] Metrics can be computed from available data sources
