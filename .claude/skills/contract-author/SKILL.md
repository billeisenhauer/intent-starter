---
name: contract-author
description: Generate OpenAPI contracts from intent documents. Use when creating a new API, when intent documents describe endpoints or data shapes, when user says "create contract", "define API", "write OpenAPI", or "what's the API shape". Reads truth/intent/*.md and outputs truth/contracts/openapi.yaml.
---

# Contract Authoring

Generate machine-readable API contracts from English intent.

## Process

1. Read all `truth/intent/*.md` files
2. Identify API surface: endpoints, request/response shapes, error cases
3. Extract data types and enums from domain language
4. Generate OpenAPI 3.0 specification

## Output Structure

```yaml
# truth/contracts/openapi.yaml
openapi: 3.0.3
info:
  title: {from intent/vision.md}
  version: 0.1.0
  description: {from intent/vision.md problem statement}
paths:
  # Derive from intent documents
components:
  schemas:
    # Derive from domain language in intent
    Error:
      type: object
      required: [error]
      properties:
        error: { type: string }
```

## Extraction Rules

| Intent Pattern | OpenAPI Output |
|----------------|----------------|
| "User can X" | `POST /x` or `GET /x` endpoint |
| "Returns Y" | Response schema |
| "Requires Z" | Request schema with required fields |
| "Must be one of A, B, C" | Enum type |
| "Fails when" | Error response with 4xx status |
| "List of X" | Array type |

## Validation Checklist

Before completing:
- [ ] All endpoints have operationId
- [ ] All request/response bodies have schemas
- [ ] Error schema is consistent
- [ ] Enums match domain language exactly
- [ ] Required fields are marked

## After Generation

Inform user:
- Run `/contract-validate` after implementation to verify conformance
- Update contract when intent changes (contract is derived, not source)
