# UI Stability

## Rule

UI changes that alter what a user can express, see, or override
must be treated as slow-layer changes.

Presentation changes (layout, styling, visual ordering) may proceed
as fast-layer work.

## The Split

**Slow (Interaction Semantics):**
- Controls that express user intent
- Explanation visibility
- Affordances for dismiss, defer, override
- Preference inputs
- Confirmation flows

**Fast (Presentation):**
- Layout and spacing
- Styling and colors
- Visual ordering
- Animation and transitions
- Copy tone (within bounds)

## Before Semantic UI Changes

1. Identify what user intent is affected
2. Check which invariants depend on this affordance
3. Confirm the change is deliberate

## What This Prevents

- Silent removal of user agency
- Breaking invariants through UI changes
- Exporting system flexibility costs to users
