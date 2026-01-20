# Tic-Tac-Toe Invariant Evaluations

These specifications verify that implementations satisfy the invariants defined in `truth/intent/tic-tac-toe.md`.

## Running Evaluations

```bash
# Against Go implementation (port 8081)
BASE_URL=http://localhost:8081 bundle exec rspec evaluations/invariants/tic-tac-toe

# Against Python implementation (port 8082)
BASE_URL=http://localhost:8082 bundle exec rspec evaluations/invariants/tic-tac-toe
```

## Specification Files

| File | Invariants Tested |
|------|-------------------|
| `initialization_spec.rb` | Game Initialization |
| `turn_order_spec.rb` | Turn Order |
| `move_validity_spec.rb` | Move Validity |
| `win_conditions_spec.rb` | Win Conditions |
| `draw_spec.rb` | Draw Condition |
| `game_termination_spec.rb` | Game Termination |

## Authority

These evaluations are authoritative. If a test fails, the implementation is wrong—not the evaluation.
