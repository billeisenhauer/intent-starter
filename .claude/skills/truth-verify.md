# Truth Verification

Run the full truth verification workflow with formatted summary.

## When to Use

- After making changes to verify system identity is preserved
- Before committing or creating a PR
- When the user asks to "verify truth" or "check truth"
- As a final gate before any merge

## Process

1. **Run truth:lint** — check for forbidden patterns
2. **Run truth:spec** — execute evaluations (if specs exist)
3. **Summarize results** — provide clear pass/fail status

## Commands

```bash
# Run lint only
make -C truth truth:lint

# Run full verification (lint + spec)
make -C truth truth:verify
```

## Output Format

### On Success

```
## Truth Verification: PASSED ✓

**Lint:** Passed (no forbidden patterns)
**Specs:** [Passed | Skipped (no specs yet)]

System identity preserved.
```

### On Failure

```
## Truth Verification: FAILED ✗

**Lint:** [Passed | Failed]
**Specs:** [Passed | Failed]

### Violations

- [file]: [violation description]
- [file]: [violation description]

### Required Actions

1. [Action to fix violation]
2. [Action to fix violation]
```

## Interpretation

| Result | Meaning |
|--------|---------|
| **PASSED** | System identity preserved — safe to proceed |
| **FAILED** | System identity compromised — must fix before proceeding |

## Important

- A passing verification is the **only** authority for system validity
- Test results elsewhere do NOT override truth verification
- If truth fails, the system is invalid — regardless of other factors

## After Verification

- On **PASSED**: Report success, proceed with next steps
- On **FAILED**: Report violations, suggest fixes, do NOT proceed until resolved
