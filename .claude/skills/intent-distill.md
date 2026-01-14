# Intent Distillation

Extract truth artifacts from PRDs, stories, and other messy inputs.

## When to Use

- When given a PRD or product requirements document
- When given user stories or feature requests
- When given meeting notes or conversations about system behavior
- When the user asks to "extract intent" or "distill requirements"

## Process

1. **Read the input material** carefully
2. **Identify normative claims** — statements about what the system IS or MUST do
3. **Separate intent from implementation** — filter out procedural plans and framework references
4. **Extract invariants** — find rules that define system legitimacy
5. **Identify non-goals** — find explicit boundaries on what the system is NOT

## Output Format

Produce candidate artifacts for review:

### Candidate Intent (for truth/intent/)

```markdown
## Core Identity

[What this system is — 1-2 sentences]

## Invariants

- [Rule that defines legitimacy]
- [Rule that defines legitimacy]

## Non-Goals

- [What this system must never become]
```

### Candidate Evaluations (for truth/evaluations/)

```markdown
## Observable Outcomes

- Given [context], when [action], then [observable result]
- Given [context], when [action], then [observable result]
```

## Important Rules

- Do NOT include implementation details
- Do NOT include framework references
- Do NOT include speculative language ("might", "could", "eventually")
- Use absolute language ("must", "must not", "always", "never")
- Every claim must be verifiable against a running system

## After Extraction

Present the candidate artifacts to the user for review.
Do NOT write to truth/ without explicit approval.
