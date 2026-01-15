---
name: implementation-generate
description: Generate application implementations from the truth layer (intent + contracts + algorithms + scenarios). Use when creating a new implementation in a specific language, when user says "implement in Go/Rust/Python/Ruby/JavaScript", "generate the app", "create implementation", or "build it in {language}". Reads truth/ and outputs to apps/{language}-{name}/.
---

# Implementation Generation

Generate complete implementations from truth layer artifacts.

## Process

1. Read truth layer:
   - `truth/intent/*.md` — understand purpose and behaviors
   - `truth/contracts/openapi.yaml` — API shape (if exists)
   - `truth/algorithms/*.md` — computation rules (if exists)
   - `truth/evaluations/scenarios/*.yml` — key examples (if exists)

2. Determine target:
   - Language/framework from user request
   - Output directory: `apps/{language}-{name}/`

3. Generate implementation:
   - Domain models from intent
   - API handlers from contracts
   - Business logic from algorithms
   - Dockerfile for containerization

4. Verify:
   - Run existing evaluations against new implementation
   - All specs must pass before declaring complete

## Output Structure

```
apps/{language}-{name}/
├── Dockerfile
├── {dependency file}     # go.mod, Cargo.toml, requirements.txt, etc.
├── {domain models}       # game.go, game.rs, game.py, etc.
├── {api handlers}        # main.go, main.rs, main.py, etc.
└── public/              # Static assets (if UI needed)
    └── index.html
```

## Language-Specific Patterns

| Language | Framework | Dependency File | Entry Point |
|----------|-----------|-----------------|-------------|
| Go | net/http | go.mod | main.go |
| Rust | Actix-web | Cargo.toml | src/main.rs |
| Python | FastAPI | requirements.txt | main.py |
| Ruby | Sinatra | Gemfile | app.rb |
| JavaScript | Express | package.json | server.js |

## Contract Conformance

If `truth/contracts/openapi.yaml` exists:
- Endpoint paths must match exactly
- Request/response schemas must conform
- Error format must match Error schema
- Status codes must be correct

## Algorithm Implementation

If `truth/algorithms/*.md` exists:
- Implement formulas exactly as specified
- Use parameter values from spec
- Add comments referencing algorithm spec

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

Port allocation: Start at 8080, increment for each implementation.

## Verification

After generation:
1. Build the Docker image
2. Start the container
3. Run `truth/evaluations/` against it
4. All specs must pass

Do not declare complete until verification passes.
