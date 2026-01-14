# Truth Layer Protection

## Rule

Do not modify files under `truth/` unless:
1. The user explicitly requests a truth change
2. The change is justified in identity terms (not convenience)
3. You explain what invariant or contract is affected

## Rationale

Truth defines system identity. Changes to truth are identity mutations,
not routine edits. They require explicit human ratification.

## When Modifying Truth

If you must modify truth:
1. State which truth artifact is changing
2. Explain why the system's identity needs to change
3. Identify affected evaluations
4. Never make incidental truth changes alongside app changes

## What This Prevents

- Accidental contamination of truth with implementation details
- Silent drift of system identity
- "Helpful" additions that weaken truth purity
