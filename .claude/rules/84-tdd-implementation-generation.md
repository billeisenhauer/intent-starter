# TDD Implementation Generation

## Rule

When generating implementations, follow Test-Driven Development.
Never write implementation code before tests exist and fail.

## Trigger

Any request to:
- Generate an implementation
- Create an app in a specific language
- "implement in {language}"
- "build it in {language}"

## Required Workflow

### Phase 1: Test Translation (Before Any Code)

1. **Read truth evaluations** from `truth/evaluations/invariants/`
2. **Translate to app-specific tests** in `apps/{app}/test/`
3. **Use canonical testing framework** for the language:

| Language | Test Framework | Test Directory | Command |
|----------|----------------|----------------|---------|
| Go | testing | *_test.go | `go test ./...` |
| Rust | #[test] | src/*.rs | `cargo test` |
| Python | pytest | test_*.py | `pytest` |
| Ruby | Minitest | test/*.rb | `ruby -Itest test/*.rb` |
| JavaScript | Jest/Vitest | *.test.js | `npm test` |

4. **Run tests** — they MUST fail (red)
5. **Do not proceed** if tests pass (indicates translation error)

### Phase 2: Red-Green Implementation

For each failing test:
1. Write minimal code to make it pass
2. Run tests
3. If still red, iterate on implementation
4. If green, move to next test
5. Never implement ahead of tests

### Phase 3: Verification

After all tests pass:
1. Run truth layer evaluations against HTTP API
2. Both app tests AND truth evaluations must pass
3. Only then declare implementation complete

## Canonical Language Patterns

Use idiomatic patterns for each language:

**Go:**
- Structs for domain models
- Methods with receivers
- Error returns, not exceptions
- `http.Handler` interface

**Rust:**
- Structs with impl blocks
- Result<T, E> for errors
- Ownership/borrowing patterns
- Actix-web handlers

**Python:**
- Dataclasses or Pydantic models
- Type hints everywhere
- FastAPI dependency injection
- pytest fixtures

**Ruby:**
- Plain Ruby classes
- Minitest assertions
- Sinatra routes
- rack/test for HTTP tests

**JavaScript:**
- ES6 classes or factory functions
- Express middleware pattern
- Jest/Vitest for testing
- async/await for promises

## Forbidden

- Writing implementation before tests
- Skipping test translation phase
- Declaring complete before green
- Using non-idiomatic patterns for the language
- Copying implementation patterns between languages

## Rationale

TDD ensures implementations match truth. Tests translated from invariants
prove the implementation satisfies system identity. Non-TDD implementations
drift from truth and require expensive correction.
