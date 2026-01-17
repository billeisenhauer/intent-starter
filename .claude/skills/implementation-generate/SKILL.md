---
name: implementation-generate
description: Generate application implementations from the truth layer using TDD. Use when creating a new implementation in a specific language, when user says "implement in Go/Rust/Python/Ruby/JavaScript", "generate the app", "create implementation", or "build it in {language}". Reads truth/ and outputs to apps/{language}-{name}/.
---

# Implementation Generation (TDD)

Generate complete implementations from truth layer artifacts using Test-Driven Development.

## CRITICAL: TDD is Mandatory

Never write implementation code before tests exist and fail.
The workflow is: **Truth → Tests (Red) → Implementation (Green) → Verify**

## Process

### Phase 1: Read Truth Layer

1. `truth/intent/*.md` — understand purpose and behaviors
2. `truth/contracts/openapi.yaml` — API shape (required)
3. `truth/algorithms/*.md` — computation rules (if exists)
4. `truth/evaluations/invariants/` — behavioral specs to translate
5. `truth/evaluations/scenarios/*.yml` — key examples (if exists)

### Phase 2: Scaffold App with Tests FIRST

1. Create app directory: `apps/{language}-{name}/`
2. Set up test infrastructure using canonical framework:

| Language | Framework | Test Setup |
|----------|-----------|------------|
| Go | testing | `*_test.go` files |
| Rust | built-in | `#[cfg(test)]` modules |
| Python | pytest | `test_*.py` + conftest.py |
| Ruby | Minitest | `test/` + test_helper.rb |
| JavaScript | Vitest | `*.test.js` + vitest.config.js |

3. Translate truth evaluations to app-specific tests:
   - Each invariant spec → unit/integration test
   - Each scenario → end-to-end test
   - Use app's domain classes (not HTTP client)

4. **Run tests — verify they FAIL (red)**
   - If tests pass, something is wrong with translation
   - Do not proceed until you have failing tests

### Phase 3: Red-Green Implementation

For each failing test:

1. Write minimal domain code to make test pass
2. Run test
3. If red: iterate on implementation
4. If green: move to next test
5. **Never implement ahead of tests**

Order of implementation:
1. Domain models (slow layer)
2. Business logic (medium layer)
3. HTTP handlers (medium layer)
4. Static assets (fast layer)

### Phase 4: Verification

After all app tests pass:

1. Build Docker image
2. Start container
3. Run `truth/evaluations/` against HTTP API
4. Both app tests AND truth specs must pass
5. Only then declare implementation complete

## Output Structure

```
apps/{language}-{name}/
├── Dockerfile
├── {dependency file}     # go.mod, Cargo.toml, etc.
├── {domain models}       # game.go, game.rs, game.py
├── {api handlers}        # main.go, main.rs, main.py
├── test/                 # App-specific tests
│   ├── {test_helper}     # Setup, fixtures
│   └── {domain}_test.{ext}
└── static/               # UI assets (if needed)
    └── index.html
```

## Canonical Language Patterns

### Go
```go
// Domain model
type Game struct {
    ID     string
    Board  Board
    // ...
}

// Method with receiver
func (g *Game) MakeMove(row, col int, player Player) error {
    // ...
}

// Test
func TestGame_MakeMove(t *testing.T) {
    g := NewGame()
    err := g.MakeMove(0, 0, PlayerX)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}
```

### Rust
```rust
// Domain model
pub struct Game {
    id: String,
    board: Board,
}

impl Game {
    pub fn make_move(&mut self, row: usize, col: usize, player: Player) -> Result<(), GameError> {
        // ...
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_make_move() {
        let mut game = Game::new();
        assert!(game.make_move(0, 0, Player::X).is_ok());
    }
}
```

### Python
```python
# Domain model (dataclass)
@dataclass
class Game:
    id: str
    board: Board

    def make_move(self, row: int, col: int, player: Player) -> None:
        # ...

# Test (pytest)
def test_make_move():
    game = Game.new()
    game.make_move(0, 0, Player.X)
    assert game.board.cell_at(0, 0) == Player.X
```

### Ruby
```ruby
# Domain model
class Game
  attr_reader :id, :board

  def make_move(row, col, player)
    # ...
  end
end

# Test (Minitest)
class GameTest < Minitest::Test
  def test_make_move
    game = Game.new
    game.make_move(0, 0, :X)
    assert_equal :X, game.board.cell_at(0, 0)
  end
end
```

### JavaScript
```javascript
// Domain model (class)
class Game {
  constructor() {
    this.id = crypto.randomUUID();
    this.board = new Board();
  }

  makeMove(row, col, player) {
    // ...
  }
}

// Test (Vitest)
import { describe, it, expect } from 'vitest';

describe('Game', () => {
  it('makes a move', () => {
    const game = new Game();
    game.makeMove(0, 0, 'X');
    expect(game.board.cellAt(0, 0)).toBe('X');
  });
});
```

## Contract Conformance

If `truth/contracts/openapi.yaml` exists:
- Endpoint paths must match exactly
- Request/response schemas must conform
- Error format must match Error schema
- Status codes must be correct

## Docker Requirements

Every implementation must have a Dockerfile:
- Expose port 8080 internally
- Use appropriate base image
- Include all dependencies
- Set proper entry point

## docker-compose Integration

Add service to `docker-compose.dev.yml`:
```yaml
{name}-{language}:
  build:
    context: ./apps/{language}-{name}
    dockerfile: Dockerfile
  ports:
    - "{next_port}:8080"
```

## Forbidden

- Writing implementation before tests
- Skipping test translation phase
- Declaring complete before all tests green
- Using non-idiomatic patterns
- Copying implementation between languages verbatim
