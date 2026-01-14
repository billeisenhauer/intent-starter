---
name: intake
description: Turn an idea or issue into truth artifacts directly. Use when starting new work, when given a feature request or issue, or when the user says "intake" followed by a feature name or description. Skips intermediate PRD/story layers and writes directly to truth/ candidates.
---

# Intake → Truth

## Context

Gather before proceeding:
- Branch: `git branch --show-current`
- Status: `git status --porcelain=v1`

## Process

1. **Parse the input** — Extract the core idea from the argument
2. **Generate slug** — Create a kebab-case identifier (e.g., `user-authentication`)
3. **Create candidate intent** — Write to `truth/intent/<slug>.md`
4. **Create candidate evaluations** — Write outline to `truth/evaluations/invariants/<slug>/`
5. **Update focus tracker** — Update `truth/pace/now.md`
6. **Classify boundaries** — Determine pace layer implications
7. **Output results** — Paths, next actions, classification

## File Templates

### Candidate Intent (`truth/intent/<slug>.md`)

```markdown
# <Feature Name>

## Problem

[What problem exists that this feature solves]

## Core Identity

[What this feature IS — 1-2 sentences]

## Invariants

- [ ] [Rule that defines correctness]
- [ ] [Rule that defines correctness]

## Non-Goals

- [What this feature must NOT become]

## Status

- [ ] Intent reviewed
- [ ] Evaluations written
- [ ] Implementation started
```

### Candidate Evaluation Directory (`truth/evaluations/invariants/<slug>/`)

Create directory with `README.md`:

```markdown
# <Feature Name> Invariants

Evaluations for <slug> feature.

## Planned Specs

- [ ] `<aspect>_spec.rb` — [What it verifies]
- [ ] `<aspect>_spec.rb` — [What it verifies]

## Observable Outcomes

- Given [context], when [action], then [result]
```

### Focus Tracker (`truth/pace/now.md`)

```markdown
# Current Focus

**Feature:** <slug>
**Intent:** truth/intent/<slug>.md
**Evaluations:** truth/evaluations/invariants/<slug>/
**Started:** <date>

## Next Actions

1. [ ] Review and refine intent
2. [ ] Write first evaluation spec
3. [ ] Begin implementation
```

## Output Format

```
## Intake Complete

**Feature:** <name>
**Slug:** <slug>

### Created

- `truth/intent/<slug>.md`
- `truth/evaluations/invariants/<slug>/README.md`
- Updated `truth/pace/now.md`

### Boundary Classification

**Primary Layer:** [Likely Slow — new intent]
**Requires:** Intent review before implementation

### Next Actions

1. [ ] Review candidate intent — refine invariants
2. [ ] Write first evaluation spec
3. [ ] Get approval before implementation touches slow layers
```

## Rules

- All intake artifacts are CANDIDATES until reviewed
- Do NOT begin implementation until intent is approved
- Use absolute language in invariants ("must", "must not")
- Every invariant must be testable
