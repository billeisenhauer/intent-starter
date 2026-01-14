# The Truth Layer

`truth/` defines the **identity of the system**.

It contains only claims that must remain true regardless of:
- language
- framework
- architecture
- implementation

Truth is not documentation.
Truth is not planning.
Truth is not explanation.

Truth is **binding**.

If a statement here stops being true,
the system has changed identity.

## Non-Negotiable Rules

- Nothing in `truth/` may depend on application code
- Nothing in `truth/` may reference frameworks (web frameworks, frontend libraries, etc.)
- Nothing in `truth/` may describe *how* something is built
- Everything in `truth/` must be either:
  - a normative claim, or
  - an executable evaluation

If these rules are violated, truth is compromised.

## Enforcement

`truth:verify` is the only authoritative gate.
If truth fails, the system is invalid — regardless of test results elsewhere.

