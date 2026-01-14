# Boundary Classification

Classify changes by pace layer before coding begins.

## When to Use

- Before implementing any feature or change
- When reviewing a PR or proposed change
- When the user asks to "classify" or "check boundaries"
- Automatically before any code generation

## Process

1. **Read the change request** — understand what is being asked
2. **Identify affected paths** — which files or areas will be touched
3. **Consult pace mapping** — check `apps/{app}/pace-mapping.yml`
4. **Apply layer definitions** — reference `truth/pace/layers.yml`
5. **Report classification** — state the layer and requirements

## Output Format

```
## Boundary Classification

**Primary Layer:** [Fast | Medium | Slow]
**Paths Affected:**
- [path/to/file] → [layer]
- [path/to/file] → [layer]

**Requirements:**
- Human Review: [optional | required]
- Tests: [optional | recommended | mandatory]
- Truth Update: [never | if_contracts_change | required]

**Boundary Crossings:** [None | List any layer crossings]
```

## Layer Definitions

### Fast Layer
- High churn, user-facing presentation, glue code
- AI-first, minimal review
- Examples: views, JS, helpers

### Medium Layer
- Business workflows, orchestration logic
- AI-assisted with human review
- Examples: services, jobs, policies

### Slow Layer
- Business invariants, data shape, contracts
- AI constrained, human approval required
- Examples: domain logic, database, config

## Decision Rules

1. If **any** slow-layer path is touched → require explicit approval
2. If layers are **crossed** → flag the boundary crossing
3. If classification is **unclear** → default to more conservative layer

## After Classification

- For **Fast**: Proceed with generation
- For **Medium**: Note that human review is required
- For **Slow**: Stop and request explicit approval before proceeding
