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

**See [docs/WORKFLOW.md](docs/WORKFLOW.md) for the complete truth-first development workflow with a day-in-the-life example.**

## Development Environment

This repository uses the DX Protocol for containerized development.

```bash
# Build the Docker image
dx/build

# Start the environment
dx/start

# Run commands inside the container
dx/exec make -C truth truth:verify
dx/exec bash

# Stop the environment
dx/stop
```

**Requirements:** Docker only. No Ruby, Node, or other dependencies needed on host.

## Verification

```bash
# On host (if Ruby installed)
make -C truth truth:verify

# In container (no host dependencies)
dx/exec make -C truth truth:verify
```

If truth fails, the system is invalid — regardless of test results elsewhere.

## AI Collaboration

This repository is designed for human-AI collaboration. The system uses **skills** (specialized workflows), **agents** (review personas), and **rules** (automatic guardrails).

### How It Works in Practice

**You don't need to memorize skill names.** Just describe what you want:

| You say... | Claude uses... |
|------------|----------------|
| "I have an idea for a feature" | `/intake` |
| "Generate the API contract" | `/contract-author` |
| "What are the weights and thresholds?" | `/algorithm-spec` |
| "Create test scenarios" | `/scenario-author` |
| "Build this in Go" | `/implementation-generate` |
| "Verify everything works" | `/truth-verify` |
| "Explain this to a stakeholder" | `/narrative-generate` |

Claude matches your intent to the appropriate skill. You can also invoke skills directly with `/skill-name` if you prefer.

### Automatic Guardrails (Rules)

These work silently in the background:

- **Truth Protection** — Claude cannot modify `truth/` without explicit approval
- **Pace Enforcement** — Changes are classified by layer; slow-layer changes require confirmation

### Review Agents

Three agents provide checks and balances. Claude consults them when appropriate:

| Agent | Role | Triggered When |
|-------|------|----------------|
| **Boundary Steward** | Asks "what is this really?" | Architectural decisions |
| **Contract Guardian** | Demands precision and invariants | Slow-layer changes |
| **Fast-Layer Builder** | Executes without over-engineering | UI and glue code |

### Skills Reference

| Skill | Purpose |
|-------|---------|
| `intake` | Turn an idea into truth artifacts |
| `intent-distill` | Extract truth from PRDs and stories |
| `contract-author` | Generate OpenAPI contracts |
| `algorithm-spec` | Define formulas, weights, thresholds |
| `slo-define` | Create metrics and SLOs |
| `scenario-author` | Generate key examples |
| `narrative-generate` | Create prose for stakeholders |
| `boundary-classify` | Classify changes by pace layer |
| `implementation-generate` | Generate apps from truth |
| `truth-verify` | Run verification |

### Getting Started

The simplest workflow:

1. **Describe your idea** — Claude creates intent documents
2. **Review and refine** — Claude helps clarify ambiguities
3. **Generate artifacts** — Contracts, scenarios, implementations
4. **Verify** — Run specs to confirm everything works

See [docs/WORKFLOW.md](docs/WORKFLOW.md) for a complete walkthrough.

## What Matters Most

This repository is not optimized for speed of coding.

It is optimized for **continuity under change**.

