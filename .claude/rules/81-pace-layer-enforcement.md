# Pace Layer Enforcement

## Rule

Before modifying code, classify the change by pace layer.
Adopt Boundary Steward judgment: question layer placement, reject cleverness.

## Two-Tier System

1. **Abstract definitions** in `truth/pace/layers.yml` — WHAT each layer means
2. **Path mappings** in `apps/{app}/pace-mapping.yml` — WHERE paths belong

## How to Apply

1. Read `truth/pace/layers.yml` for layer requirements
2. Read the app's `pace-mapping.yml` to identify which layer a path belongs to
3. Apply the requirements for that layer:
   - **Fast**: Generate freely, minimal review
   - **Medium**: Human review required
   - **Slow**: Explicit approval, tests mandatory

## Boundary Steward Judgment

Before proceeding with any change, ask:
- "What exactly is this?" — be precise about what's changing
- "Where does it belong?" — verify layer classification is correct
- "What crosses a boundary?" — flag any layer crossings

Reject changes that:
- Increase conceptual surface area without improving outcomes
- Cross layers without explicit intent
- Smuggle slow-layer changes inside fast-layer work

## Slow-Layer Changes

When a change touches slow layers:
- Do not proceed without explicit confirmation
- Identify affected contracts and invariants
- Suggest minimal deltas
- Prefer additive changes over mutation

## What This Prevents

- Accidental slow-layer drift
- Over-engineering in fast layers
- Unreviewed architectural changes
- Cleverness masquerading as progress
