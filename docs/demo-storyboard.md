# Truth and Intent Demo: Video Storyboard

## Overview

**Duration:** ~15-20 minutes
**Goal:** Demonstrate the truth-first development workflow by generating a PHP implementation and adding a forfeit feature.

---

## Act 1: The Problem with Traditional Development (2-3 min)

### Scene 1.1: Opening Hook

**Visual:** Code editor with messy, duplicated business logic across files

**Talking Points:**
- "How many times have you seen the same business rule implemented differently across your codebase?"
- "What if I told you there's a way to define your system's identity ONCE, in English, and generate implementations in any language?"
- "Today I'll show you the 'truth and intent' approach—where English IS the programming language."

### Scene 1.2: The Core Principle

**Visual:** Diagram showing `truth/` → multiple `apps/`

**Talking Points:**
- "The fundamental principle: **Truth defines identity. Apps express it.**"
- "Truth is what your system IS—its invariants, contracts, and behaviors"
- "Apps are HOW it runs—disposable, regeneratable implementations"
- "If code can be regenerated without changing what the system IS, it doesn't belong in truth"

---

## Act 2: Anatomy of the Truth Layer (4-5 min)

### Scene 2.1: Intent Documents

**Command:**
```bash
cat truth/intent/tic-tac-toe.md
```

**Talking Points:**
- "Intent documents are the system's identity written in English"
- "Notice the language: 'must', 'must not'—these are absolute claims"
- "Point out key invariants: board is exactly 3×3, X always moves first, marks are immutable"
- "This is NOT documentation—it's specification. Evaluable against running code."

### Scene 2.2: Contracts

**Command:**
```bash
head -50 truth/contracts/openapi.yaml
```

**Talking Points:**
- "Contracts define external promises—API shapes that must never break"
- "Every implementation must conform to these exact endpoints and schemas"
- "Language-agnostic: Go, Python, PHP—all speak the same API"

### Scene 2.3: Scenarios (Key Examples)

**Command:**
```bash
cat truth/evaluations/scenarios/tic-tac-toe.yml
```

**Talking Points:**
- "Gojko Adzic-style specification by example"
- "Human-readable tables that define expected behavior"
- "These become the source of truth for test generation"

### Scene 2.4: Executable Invariants

**Command:**
```bash
ls truth/evaluations/invariants/tic-tac-toe/
cat truth/evaluations/invariants/tic-tac-toe/turn_order_spec.rb
```

**Talking Points:**
- "46 RSpec tests that define what MUST be true"
- "These tests run against ANY implementation—not language-specific"
- "If these fail, the system is invalid. Period."

### Scene 2.5: The Reference Implementation

**Command:**
```bash
ls truth/lib/tic_tac_toe/
```

**Talking Points:**
- "A Ruby reference implementation lives in truth/"
- "This is what the invariant specs test against"
- "New implementations can use this as a model"

---

## Act 3: Existing Implementations (2 min)

### Scene 3.1: Five Languages, One Truth

**Command:**
```bash
ls apps/
```

**Visual:** Show the 5 implementation directories

**Talking Points:**
- "Go, JavaScript, Python, Ruby, Rust—all implementing the SAME tic-tac-toe"
- "Different languages, different styles, IDENTICAL behavior"
- "Each passes the same 46 invariant tests"

### Scene 3.2: Quick Demo

**Command:**
```bash
# Start one implementation
cd apps/go-tictactoe && go run main.go &
# Open browser to localhost:8080
```

**Visual:** Show the game working in browser

**Talking Points:**
- "Every implementation serves a web UI and API"
- "All conform to the same OpenAPI contract"
- "The UI can differ—the RULES cannot"

---

## Act 4: Generating a PHP Implementation (5-6 min)

### Scene 4.1: The Challenge

**Talking Points:**
- "Let's add PHP to our implementation family"
- "We'll use the truth layer to generate a conformant implementation"
- "Watch how the truth guides the generation"

### Scene 4.2: Running the Implementation Generator

**Command (Claude Code):**
```
/implementation-generate

When prompted:
- Language: PHP
- Name: php-tictactoe
- Port: 8085
```

**Talking Points:**
- "The generator reads truth/intent, truth/contracts, and truth/evaluations"
- "It produces code that MUST pass the invariant specs"
- "This isn't magic—it's constraint satisfaction"

### Scene 4.3: Examining the Generated Code

**Command:**
```bash
ls apps/php-tictactoe/
cat apps/php-tictactoe/src/Game.php
```

**Talking Points:**
- "Notice how the invariants map to code"
- "Board is exactly 3×3—hardcoded because truth says so"
- "Turn alternation enforced—because truth demands it"

### Scene 4.4: Verifying Against Truth

**Command:**
```bash
cd truth && make truth:verify
```

**Talking Points:**
- "The moment of truth—does our PHP implementation conform?"
- "These tests run against the reference implementation"
- "For full verification, we'd run API tests against the PHP server"

### Scene 4.5: Testing the PHP Implementation

**Command:**
```bash
cd apps/php-tictactoe
php -S localhost:8085 -t public &
# Open browser to localhost:8085
```

**Visual:** PHP implementation running

**Talking Points:**
- "Same game, new language"
- "Same API contract, same invariants"
- "The truth layer made this possible"

---

## Act 5: Adding Forfeit Feature (5-6 min)

### Scene 5.1: The New Requirement

**Talking Points:**
- "A user requests: 'I want players to be able to forfeit'"
- "This is an IDENTITY change—it affects what the game IS"
- "We must start with truth, not code"

### Scene 5.2: Modifying Intent (Slow Layer)

**Talking Points:**
- "The pace layer system classifies this as a SLOW change"
- "Slow changes require explicit confirmation"
- "We're changing system identity"

**Command (Claude Code):**
```
I want to add a forfeit feature. Let me update the truth layer:

1. First, let's update the intent document
```

**Edit to `truth/intent/tic-tac-toe.md`:**
```markdown
## Game State Invariants

- The game must end when a player wins OR the board is full OR a player forfeits
- A player may forfeit at any time during an active game
- When a player forfeits, their opponent wins
- No moves are allowed after a forfeit
```

### Scene 5.3: Updating the Contract

**Edit to `truth/contracts/openapi.yaml`:**
```yaml
/game/forfeit:
  post:
    summary: Current player forfeits the game
    responses:
      '200':
        description: Forfeit accepted, opponent wins
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Game'
      '422':
        description: Game already ended
```

### Scene 5.4: Adding Scenarios

**Edit to `truth/evaluations/scenarios/tic-tac-toe.yml`:**
```yaml
- scenario: Player Forfeit
  description: A player may forfeit, ending the game
  examples:
    - given: X has moved to center (4)
      when: X forfeits
      then: O wins, game over

    - given: Game is already won by X
      when: O attempts to forfeit
      then: Error - game already ended
```

### Scene 5.5: Adding Invariant Tests

**Create `truth/evaluations/invariants/tic-tac-toe/forfeit_spec.rb`:**

**Talking Points:**
- "New invariant tests define the forfeit behavior"
- "These tests will fail until implementations add forfeit"
- "The tests ARE the requirement"

### Scene 5.6: Verifying Truth

**Command:**
```bash
cd truth && make truth:verify
```

**Talking Points:**
- "Truth verification ensures our specs are valid"
- "The reference implementation needs forfeit too"
- "Truth changes cascade to all artifacts"

### Scene 5.7: Regenerating Implementations

**Talking Points:**
- "Now EVERY implementation must add forfeit"
- "We don't manually code it 6 times"
- "The truth layer drives regeneration"

**Command (Claude Code):**
```
Update the PHP implementation to support forfeit based on the updated truth layer
```

### Scene 5.8: Full Verification

**Command:**
```bash
# Run tests against updated implementations
cd truth && make truth:verify
```

**Visual:** All tests passing

**Talking Points:**
- "The system's identity has evolved"
- "All implementations conform to the new truth"
- "One source of truth, many expressions"

---

## Act 6: The Bigger Picture (2 min)

### Scene 6.1: Pace Layers Recap

**Visual:** Diagram of slow/medium/fast layers

**Talking Points:**
- "**Slow layer**: Intent, contracts, invariants—change rarely, require ceremony"
- "**Medium layer**: Business logic, services—evolve with review"
- "**Fast layer**: HTTP handlers, views—regenerate freely"
- "The pace layer protects what matters"

### Scene 6.2: AI Collaboration

**Talking Points:**
- "This approach transforms AI from 'code generator' to 'identity enforcer'"
- "The AI reads truth before writing code"
- "Guardrails prevent truth contamination"
- "Multiple agents provide checks and balances"

### Scene 6.3: Closing

**Talking Points:**
- "Truth and intent isn't about documentation"
- "It's about making system identity explicit, evaluable, and durable"
- "The implementations are disposable. The truth is not."
- "What would YOUR system look like if its identity was this clear?"

---

## Appendix: Commands Quick Reference

```bash
# View truth structure
ls truth/
cat truth/intent/tic-tac-toe.md

# View implementations
ls apps/

# Run truth verification
cd truth && make truth:verify

# Generate new implementation (via Claude Code)
/implementation-generate

# Classify a change by pace layer
/boundary-classify

# Update truth artifacts
/intake
/intent-distill
/contract-author
/scenario-author
```

---

## Notes for Recording

1. **Pre-recording setup:**
   - Clean terminal with large font
   - Browser ready at localhost ports
   - All implementations built and ready to start

2. **Screen recording tips:**
   - Use a tool like OBS or ScreenFlow
   - 1080p minimum, 4K preferred
   - Record terminal and browser in split view

3. **Post-production:**
   - Add diagrams as overlays
   - Speed up long operations (generation, builds)
   - Add captions for code snippets

4. **B-roll suggestions:**
   - Diagram: truth → apps relationship
   - Diagram: pace layers pyramid
   - Animation: one truth, many implementations
