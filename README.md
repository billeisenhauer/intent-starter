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

## What Matters Most

This repository is not optimized for speed of coding.

It is optimized for **continuity under change**.

