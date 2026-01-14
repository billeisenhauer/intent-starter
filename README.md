# This Repository

This repository contains **two different kinds of things**:

- `truth/` — the **authoritative identity** of the system
- `apps/` — one or more **temporary implementations** of that identity

Only one of these is allowed to define what the system *is*.

## Core Principle

> **Truth defines identity.  
> Apps express it.**

All applications in `apps/` are replaceable.
Nothing in `truth/` is.

If an implementation can be regenerated without changing system identity,
it does not belong in `truth/`.

If a claim must survive regeneration,
it belongs nowhere *but* `truth/`.

## How to Work Here

1. Begin new work by reading `truth/`
2. Modify `truth/` only with explicit intent
3. Let `truth:verify` be the final authority
4. Treat app code as disposable

## Verification

```bash
make -C truth truth:verify
```

If truth fails, the system is invalid — regardless of test results elsewhere.

## AI Collaboration

This repository is designed for human-AI collaboration with explicit boundaries.

### Agents

Three agents provide checks and balances (see `.claude/agents/`):

| Agent | Role | When to Invoke |
|-------|------|----------------|
| **Boundary Steward** | Architectural conscience | Before coding, before merge |
| **Fast-Layer Builder** | Aggressive executor | Fast/medium pace stories |
| **Contract Guardian** | Conservative reviewer | Any slow-layer change |

### Rules

Two rules govern AI behavior (see `.claude/rules/`):

- **Truth Protection** — AI cannot modify `truth/` without explicit approval
- **Pace Enforcement** — Changes are classified by layer before proceeding

### Skills

| Skill | Purpose |
|-------|---------|
| `intake` | Turn an idea into truth artifacts directly |
| `intent-distill` | Extract truth artifacts from PRDs and stories |
| `boundary-classify` | Classify changes by pace layer |
| `truth-verify` | Run verification with formatted summary |

## What Matters Most

This repository is not optimized for speed of coding.

It is optimized for **continuity under change**.

