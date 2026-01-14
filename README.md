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

- Begin new work by reading `truth/`
- Modify `truth/` only with explicit intent
- Let `truth:verify` be the final authority
- Treat app code as disposable

## What Matters Most

This repository is not optimized for speed of coding.

It is optimized for **continuity under change**.

