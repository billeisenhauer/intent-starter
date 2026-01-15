# The Truth Layer

`truth/` defines the **identity of the system**.

It contains only claims that must remain true regardless of:
- language
- framework
- architecture
- implementation

Truth is not documentation.
Truth is not planning.
Truth is not explanation.

Truth is **binding**.

If a statement here stops being true,
the system has changed identity.

## Structure

```
truth/
├── intent/              # English specifications (the programming language)
│   └── {domain}.md      # Problem, vision, outcomes, principles, non-goals
│
├── contracts/           # Machine-readable API contracts
│   └── openapi.yaml     # API shape before implementation
│
├── algorithms/          # Computation rules (weights, formulas, thresholds)
│   └── {domain}.md      # Magic numbers made explicit
│
├── evaluations/
│   ├── scenarios/       # Key examples (readable)
│   │   └── {feature}.yml
│   └── invariants/      # Executable behavioral specs
│       └── {feature}_spec.rb
│
├── monitoring/          # Observable contracts
│   ├── metrics.md       # How we measure
│   └── slo.md           # What success looks like
│
└── pace/                # Pace layer definitions
    └── layers.yml       # Fast/medium/slow classification
```

## Authoring Workflow

| Step | Skill | Output |
|------|-------|--------|
| 1 | `/intake` | `intent/*.md` candidate |
| 2 | `/intent-distill` | Refined `intent/*.md` |
| 3 | `/contract-author` | `contracts/openapi.yaml` |
| 4 | `/algorithm-spec` | `algorithms/*.md` |
| 5 | `/slo-define` | `monitoring/*.md` |
| 6 | `/scenario-author` | `evaluations/scenarios/*.yml` |
| 7 | `/boundary-classify` | Pace layer classification |
| 8 | `/implementation-generate` | `apps/{lang}-{name}/` |
| 9 | `/truth-verify` | Pass/fail verification |

## Non-Negotiable Rules

- Nothing in `truth/` may depend on application code
- Nothing in `truth/` may reference frameworks (web frameworks, frontend libraries, etc.)
- Nothing in `truth/` may describe *how* something is built
- Everything in `truth/` must be either:
  - a normative claim, or
  - an executable evaluation

If these rules are violated, truth is compromised.

## Enforcement

`truth:verify` is the only authoritative gate.
If truth fails, the system is invalid — regardless of test results elsewhere.

