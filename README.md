# intent-starter

This repository is a **starter for intent-governed software systems**.

It demonstrates a way of building software where **system identity is explicit, enforceable, and durable**, even as implementations change.

If you are new here, **do not start with the code**.

Start with the manifesto.

👉 **[Read the Manifesto](./MANIFESTO.md)**

---

## What This Repository Contains

This repository is structured around a single distinction:

- `truth/` — the **authoritative identity** of the system
- `apps/` — one or more **temporary implementations** of that identity

Only one of these is allowed to define what the system *is*.

### `truth/`

The `truth/` directory contains binding claims about system identity:

- intent
- invariants
- contracts
- pace rules
- evaluations

Nothing in `truth/` depends on application code or frameworks.

If `truth:verify` fails, the system is considered invalid — regardless of whether applications appear to work.

### `apps/`

The `apps/` directory contains implementations.

They may:
- be regenerated
- be replaced
- be deleted

Their purpose is to satisfy truth, not to preserve history.

Multiple implementations may coexist.

---

## How to Use This Repository

This repo is not meant to be "run" in the usual sense.

It is meant to be **inhabited**.

Typical usage looks like this:

1. Define or modify system intent in `truth/`
2. Enforce identity via evaluations
3. Generate or evolve an implementation under `apps/`
4. Let `truth:verify` decide whether the system is still itself

The workflow is documented here:

👉 **[`docs/WORKFLOW.md`](./docs/WORKFLOW.md)**

---

## AI and Agents

This repository assumes AI-assisted development is normal.

AI is used aggressively where code is disposable and constrained where identity is at stake.

Agent definitions and rules live under `.claude/` and exist to:
- protect truth from erosion
- enforce pace boundaries
- allow fast regeneration without silent drift

AI is treated as an executor, not an authority.

---

## Who This Is For

This repository is for people who:

- expect software to change repeatedly
- care about long-lived systems
- want regeneration to be safe, not scary
- are willing to accept constraints in exchange for clarity

If you are looking for:
- a framework
- a generator
- a productivity shortcut

this repository is not that.

---

## What to Read Next

If you want to understand *why* this exists:

👉 **[`MANIFESTO.md`](./MANIFESTO.md)**

If you want to understand *how* it is used:

👉 **[`docs/WORKFLOW.md`](./docs/WORKFLOW.md)**

If you want to understand *what must never change*:

👉 **[`truth/`](./truth/README.md)**

---

## Final Note

This repository is intentionally opinionated.

It does not attempt to convince everyone.

It exists to make a claim precise and testable:

> **Software identity should be governed, not inferred.**
