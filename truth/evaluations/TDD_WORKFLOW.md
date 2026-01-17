# TDD Workflow for Implementation Generation

## The Problem

The current implementation-generate workflow produces buggy code because:
1. Tests are written after implementation (or skipped entirely)
2. The truth layer invariants remain abstract and disconnected
3. No red-green-refactor cycle enforces correctness

## The Solution: Truth-Driven TDD

### Phase 1: Test Translation

Before writing any implementation code, translate truth layer artifacts into runnable tests:

```
truth/evaluations/invariants/*.rb   →   apps/{app}/test/invariants/*.rb
truth/evaluations/scenarios/*.yml   →   apps/{app}/test/scenarios/*.rb
```

#### Translation Rules

**Invariant Specs:**
- Each `skip "requires implementation"` becomes a real test
- Tests import actual app classes (models, services)
- Tests use app's test framework (Minitest for Rails, pytest for Python, etc.)
- Tests MUST fail initially (red)

Example:
```ruby
# truth/evaluations/invariants/game_state_spec.rb
it "game is over when a player wins" do
  # Uses HTTP client to test any implementation
end

# Translates to app-specific test:
# apps/rails-app/test/models/game_test.rb
test "game is over when a player wins" do
  game = Game.create!
  game.make_move!(0, 0, :X)
  game.make_move!(1, 0, :O)
  game.make_move!(0, 1, :X)
  game.make_move!(1, 1, :O)
  game.make_move!(0, 2, :X)

  assert game.over?
  assert_equal :X, game.winner
end
```

**Scenario YAMLs:**
- Each scenario becomes an integration test
- Given/When/Then maps to Arrange/Act/Assert
- Tabular examples become parameterized tests

Example:
```yaml
# truth/evaluations/scenarios/tic-tac-toe.yml
- name: X wins with top row
  given:
    board: [X, X, empty, O, O, empty, empty, empty, empty]
    current_player: X
  when:
    action: move
    position: [0, 2]
  then:
    winner: X
    over: true
```

### Phase 2: Red-Green Implementation

For each domain area:

1. **Run tests** - Verify they fail (red)
2. **Write minimal implementation** - Just enough to pass
3. **Run tests again** - Verify they pass (green)
4. **Refactor if needed** - Clean up while keeping green
5. **Move to next test**

#### Implementation Order

Follow pace layers from slow to fast:
1. Models (slow) - Domain objects, validations, associations
2. Services (medium) - Business logic orchestration
3. Controllers (medium) - HTTP concerns only
4. Views (fast) - Presentation

### Phase 3: Scenario Validation

After unit tests pass, run scenario tests for end-to-end validation:

```bash
dx/exec bundle exec rspec truth/evaluations --format documentation
```

## Metrics

Track implementation quality:

- **Truth Coverage**: % of invariants with passing tests
- **Scenario Coverage**: % of scenarios with passing tests
- **Red-to-Green Ratio**: Tests that pass on first implementation attempt
- **Iteration Count**: Average iterations per test to reach green

## Benefits

1. **Bugs caught early** - Tests written before code
2. **Truth alignment** - Implementation matches specification
3. **Confidence** - Green tests prove correctness
4. **Documentation** - Tests explain behavior
5. **Regression protection** - Future changes validated

## Anti-Patterns to Avoid

- Writing tests after implementation
- Skipping scenario tests
- Implementing without running tests
- Multiple features before verifying green
- Ignoring failing tests to "come back later"
