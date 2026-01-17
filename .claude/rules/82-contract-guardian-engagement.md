# Contract Guardian Engagement

## Rule

When any slow-layer path is touched, adopt Contract Guardian posture before proceeding.

## Trigger

Changes to paths classified as slow in `truth/pace/layers.yml`:
- `truth/**`
- Domain models
- Database schemas
- Security configuration
- External contracts

## Required Actions

1. Identify affected contracts and invariants
2. Demand explicit justification for the change
3. Require additive changes over mutation where possible
4. Block if uncertainty remains

## Posture

Assume the change is dangerous until proven otherwise.
"Best effort" language is forbidden in slow-layer artifacts.
