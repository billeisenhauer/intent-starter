# Truth-First Development Workflow

This guide walks through the complete workflow for building systems using the truth-first approach.

## Philosophy

> "English is the new programming language." — Andrej Karpathy

The truth layer captures **what the system IS** in English. Everything else — contracts, specs, implementations — is derived from that truth. When you change the truth, implementations must follow.

## The Pipeline

```
Human idea
    ↓
/intake              → Draft intent document
    ↓
/intent-distill      → Refined English specification
    ↓
/contract-author     → OpenAPI contract
    ↓
/algorithm-spec      → Formulas and thresholds
    ↓
/slo-define          → Observable contracts
    ↓
/scenario-author     → Key examples
    ↓
Agent review         → Contract Guardian, Boundary Steward
    ↓
/implementation-generate → Working code
    ↓
/truth-verify        → Validation
```

---

## Day-in-the-Life: Building Tic-Tac-Toe

This example walks through building a tic-tac-toe game using the truth-first approach. See the `feature/tic-tac-toe` branch for the complete implementation.

### Step 1: Start with an Idea

You have an idea: "Build a tic-tac-toe game."

```
User: /intake tic-tac-toe game
```

The intake skill asks clarifying questions and produces a draft intent document.

### Step 2: Write the Intent Document

The intent document captures the game's identity in English:

```markdown
# truth/intent/tic-tac-toe.md

# Tic-Tac-Toe

## Problem
Players need a simple, fair two-player game with clear rules.

## Vision
A classic tic-tac-toe implementation that enforces rules correctly.

## Core Rules
- The board is a 3x3 grid
- Two players: X and O
- X always moves first
- Players alternate turns
- A player wins by getting three marks in a row (horizontal, vertical, or diagonal)
- The game ends when someone wins or the board is full (draw)

## Invariants
- A cell can only be marked once
- A player cannot move twice in a row
- No moves are allowed after the game ends
- There is exactly one outcome: X wins, O wins, or draw

## Non-Goals
- AI opponent
- Network multiplayer
- Persistent game history
```

### Step 3: Generate the Contract

```
User: /contract-author
```

The skill reads the intent and produces an OpenAPI specification:

```yaml
# truth/contracts/openapi.yaml
openapi: 3.0.3
info:
  title: Tic-Tac-Toe API
  version: 0.1.0
paths:
  /games:
    post:
      summary: Create a new game
      responses:
        '201':
          description: Game created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Game'
  /game:
    get:
      summary: Get game state
      parameters:
        - name: id
          in: query
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Game state
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Game'
  /game/move:
    post:
      summary: Make a move
      parameters:
        - name: id
          in: query
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Move'
      responses:
        '200':
          description: Move accepted
        '422':
          description: Invalid move
components:
  schemas:
    Game:
      type: object
      properties:
        id:
          type: string
        current_player:
          type: string
          enum: [X, O]
        over:
          type: boolean
        winner:
          type: string
          enum: [X, O]
          nullable: true
        draw:
          type: boolean
        board:
          $ref: '#/components/schemas/Board'
    Board:
      type: object
      properties:
        cells:
          type: array
          items:
            type: string
            enum: [empty, X, O]
        rows:
          type: array
          items:
            type: array
            items:
              type: string
              enum: [empty, X, O]
    Move:
      type: object
      required: [row, col, player]
      properties:
        row:
          type: integer
          minimum: 0
          maximum: 2
        col:
          type: integer
          minimum: 0
          maximum: 2
        player:
          type: string
          enum: [X, O]
    Error:
      type: object
      required: [error]
      properties:
        error:
          type: string
```

### Step 4: Define Key Scenarios

```
User: /scenario-author
```

The skill produces Adzic-style tabular examples:

```yaml
# truth/evaluations/scenarios/tic-tac-toe.yml
feature: Tic-Tac-Toe
description: Key examples of game behavior

scenarios:
  - name: X wins with top row
    given:
      - A new game
    when:
      - Moves are made: X:0,0 O:1,1 X:0,1 O:2,2 X:0,2
    then:
      - X is the winner
      - The game is over

  - name: Draw when board is full
    given:
      - A new game
    when:
      - Moves fill the board with no winner
    then:
      - No winner
      - Draw is true
      - The game is over

  - name: Win detection patterns
    description: All ways to win
    examples:
      | moves                          | winner | pattern      |
      | X:0,0 O:1,1 X:0,1 O:2,2 X:0,2 | X      | top row      |
      | X:1,0 O:0,0 X:1,1 O:0,1 X:1,2 | X      | middle row   |
      | X:0,0 O:0,1 X:1,1 O:0,2 X:2,2 | X      | diagonal     |

  - name: Invalid move rejection
    examples:
      | situation          | move      | error                |
      | X already at 0,0   | X:0,0     | cell already marked  |
      | X's turn           | O moves   | not your turn        |
      | Game over          | any move  | game is over         |
      | Out of bounds      | X:3,0     | position out of bounds |
```

### Step 5: Write Executable Invariants

The scenarios inform executable specs. These are the actual tests:

```ruby
# truth/evaluations/invariants/tic-tac-toe/turn_order_spec.rb
describe "Turn Order Invariants" do
  describe "first move" do
    it "requires X to move first" do
      game = TicTacToe::Game.create
      expect(game.current_player).to eq("X")
    end

    it "rejects O moving first" do
      game = TicTacToe::Game.create
      expect { game.move(0, 0, "O") }.to raise_error(TicTacToe::NotYourTurn)
    end
  end

  describe "alternating turns" do
    it "switches to O after X moves" do
      game = TicTacToe::Game.create
      game.move(0, 0, "X")
      expect(game.current_player).to eq("O")
    end
  end
end
```

### Step 6: Classify Boundaries

```
User: /boundary-classify
```

Output:
```
## Boundary Classification

**Primary Layer:** Slow
**Paths Affected:**
- truth/intent/tic-tac-toe.md → Slow
- truth/contracts/openapi.yaml → Slow
- truth/evaluations/invariants/ → Medium

**Requirements:**
- Human Review: required
- Tests: mandatory
- Truth Update: this IS a truth update

**Recommendation:** Proceed with explicit approval.
```

### Step 7: Generate Implementations

```
User: /implementation-generate in Go with a web UI
```

The skill reads the truth layer and generates:

```
apps/go-tictactoe/
├── Dockerfile
├── go.mod
├── game/
│   ├── board.go
│   ├── game.go
│   └── errors.go
├── main.go
└── static/
    └── index.html
```

The implementation:
- Follows the OpenAPI contract exactly
- Implements all invariants from the intent
- Runs on port 8080 in Docker

### Step 8: Verify Against Truth

```
User: /truth-verify
```

The verification runs all 46 invariant specs against the implementation:

```
Running truth specs...

Randomized with seed 12345
..............................................

Finished in 0.24 seconds
46 examples, 0 failures
```

### Step 9: Generate More Implementations

The power of truth-first: generate implementations in any language.

```
User: /implementation-generate in Rust
User: /implementation-generate in Python
User: /implementation-generate in Ruby
User: /implementation-generate in JavaScript with React
```

Each implementation:
- Lives in `apps/{language}-tictactoe/`
- Passes the same 46 invariant specs
- Conforms to the same OpenAPI contract
- Has its own themed UI

---

## Handling Changes

### Scenario: Add a New Feature

You want to add "forfeit" — a player can resign.

**Step 1: Update Intent**

```markdown
# truth/intent/tic-tac-toe.md (updated)

## Core Rules
...
- A player can forfeit at any time, ending the game

## Outcomes
- X wins (three in a row or O forfeits)
- O wins (three in a row or X forfeits)
- Draw (board full, no winner)
```

**Step 2: Update Contract**

```yaml
# New endpoint
/game/forfeit:
  post:
    summary: Forfeit the game
    parameters:
      - name: id
        in: query
        required: true
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required: [player]
            properties:
              player:
                type: string
                enum: [X, O]
    responses:
      '200':
        description: Forfeit accepted
```

**Step 3: Add Scenarios**

```yaml
- name: Forfeit ends game
  given:
    - A game in progress
  when:
    - X forfeits
  then:
    - O is the winner
    - The game is over
    - Outcome is "X forfeits"
```

**Step 4: Add Invariants**

```ruby
describe "Forfeit" do
  it "ends the game with opponent as winner" do
    game = TicTacToe::Game.create
    game.move(0, 0, "X")
    game.forfeit("X")
    expect(game.over).to be true
    expect(game.winner).to eq("O")
  end
end
```

**Step 5: Run Verification (Expect Failures)**

```
47 examples, 1 failure

Forfeit ends the game with opponent as winner
  Expected endpoint /game/forfeit to exist
```

**Step 6: Update Implementations**

Update each implementation to add the forfeit endpoint. Run `/truth-verify` until all 47 specs pass.

---

## Key Principles

1. **Truth First** — Change intent before changing code
2. **Derive, Don't Invent** — Contracts and specs come from intent
3. **Verify Always** — No implementation is valid until specs pass
4. **Language Agnostic** — Truth is English; implementations are incidental
5. **Explicit > Implicit** — Magic numbers become algorithm specs

## Quick Reference

| I want to... | Use this skill |
|--------------|----------------|
| Start a new feature | `/intake` |
| Refine messy requirements | `/intent-distill` |
| Generate API contract | `/contract-author` |
| Define formulas/weights | `/algorithm-spec` |
| Create metrics/SLOs | `/slo-define` |
| Write key examples | `/scenario-author` |
| Check pace layer | `/boundary-classify` |
| Generate implementation | `/implementation-generate` |
| Validate everything | `/truth-verify` |
