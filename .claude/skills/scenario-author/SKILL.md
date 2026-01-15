---
name: scenario-author
description: Generate tabular key examples (Specification by Example / Gojko Adzic style) from intent documents. Use when creating test scenarios, when intent describes behaviors that need concrete examples, when user says "create scenarios", "give me examples", "write test cases", "key examples", or "specification by example". Outputs truth/evaluations/scenarios/*.yml files.
---

# Scenario Authoring

Generate readable, executable key examples from intent.

## Philosophy

Scenarios are **illustrative**, not exhaustive. Find the minimal set of examples that:
- Cover all important behaviors
- Reveal edge cases
- Serve as living documentation

## Process

1. Read `truth/intent/*.md` for behaviors
2. Identify key scenarios (happy path, edge cases, errors)
3. Express as tabular examples
4. Output YAML that maps to executable specs

## Output Format

```yaml
# truth/evaluations/scenarios/{feature}.yml
feature: {Feature Name}
description: {One-line summary}

scenarios:
  - name: {Scenario name}
    description: {What this demonstrates}
    given:
      - {precondition}
    when:
      - {action}
    then:
      - {expected outcome}

  # Tabular format for multiple examples of same pattern
  - name: {Pattern name}
    description: {What variations this covers}
    examples:
      | input_a | input_b | expected |
      | value1  | value2  | result1  |
      | value3  | value4  | result2  |
```

## Scenario Selection

Use **key examples** — the minimal set that illustrates all behaviors:

| Scenario Type | Purpose | Example |
|---------------|---------|---------|
| Happy path | Normal success flow | Valid login |
| Boundary | Edge of valid range | Max length input |
| Error | Invalid input handling | Wrong password |
| State transition | Before/after state | Order → Shipped |

## Tabular Example Patterns

When multiple inputs produce predictable outputs:

```yaml
- name: Win detection
  examples:
    | moves                          | winner | winning_line |
    | X:0,0 O:1,1 X:0,1 O:2,2 X:0,2 | X      | top_row      |
    | X:0,0 O:0,1 X:1,1 O:0,2 X:2,2 | X      | diagonal     |
```

## Mapping to Executable Specs

Scenarios are documentation that mirrors executable specs:
- `scenarios/{feature}.yml` = readable key examples
- `invariants/{feature}_spec.rb` = executable tests

Keep them in sync. When intent changes, update both.

## Validation

Before completing:
- [ ] Each scenario has clear given/when/then
- [ ] Tabular examples cover boundary cases
- [ ] Names are descriptive and unique
- [ ] Scenarios match intent language exactly
