---
name: boundary-classify
description: Classify changes by pace layer before coding begins. Use before implementing any feature or change, when reviewing a PR or proposed change, when the user asks to "classify" or "check boundaries", or automatically before any code generation. Prevents misclassification which is the primary source of architectural rot.
---

# Boundary Classification

## Process

1. Read the change request — understand what is being asked
2. Identify affected paths — which files or areas will be touched
3. Consult pace mapping — check `apps/{app}/pace-mapping.yml`
4. Apply layer definitions — reference `truth/pace/layers.yml`
5. Report classification — state the layer and requirements

## Output Format

```
## Boundary Classification

**Primary Layer:** [Fast | Medium | Slow]
**Paths Affected:**
- [path/to/file] → [layer]

**Requirements:**
- Human Review: [optional | required]
- Tests: [optional | recommended | mandatory]
- Truth Update: [never | if_contracts_change | required]

**Boundary Crossings:** [None | List any layer crossings]
```

## Layer Definitions

| Layer | Characteristics | Review | Examples |
|-------|-----------------|--------|----------|
| Fast | High churn, presentation, glue | Optional | views, JS, helpers |
| Medium | Workflows, orchestration | Required | services, jobs, policies |
| Slow | Invariants, data shape, contracts | Required + tests | domain, database, config |

## Decision Rules

1. If **any** slow-layer path is touched → require explicit approval
2. If layers are **crossed** → flag the boundary crossing
3. If classification is **unclear** → default to more conservative layer

## After Classification

- **Fast**: Proceed with generation
- **Medium**: Note that human review is required
- **Slow**: Stop and request explicit approval before proceeding
