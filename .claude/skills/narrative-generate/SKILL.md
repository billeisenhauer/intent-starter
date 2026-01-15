---
name: narrative-generate
description: Generate readable prose narratives from intent documents for non-technical stakeholders. Use when someone asks "explain this app", "what does this do", "summarize for stakeholders", "write a description", or needs documentation suitable for executives, users, or marketing. Reads truth/intent/*.md and outputs docs/narratives/{feature}.md.
---

# Narrative Generation

Transform technical intent documents into readable prose for non-technical audiences.

## Purpose

Intent documents are normative ("must", "never", "always"). Narratives are descriptive — they explain what an app does in plain language suitable for:
- Executives and stakeholders
- End users
- Marketing materials
- Onboarding documentation

## Process

1. Read `truth/intent/{feature}.md`
2. Read `truth/evaluations/scenarios/{feature}.yml` if exists
3. Extract the core value proposition and user experience
4. Write prose that answers: "What does this do and why would I care?"

## Output Structure

```markdown
# docs/narratives/{feature}.md

# {Feature Name}

## What It Does

{2-3 sentence summary of core functionality}

## How It Works

{Step-by-step explanation of the user experience}

## Key Features

- {Feature 1}: {One-line description}
- {Feature 2}: {One-line description}

## What Makes It Different

{Unique value proposition, if applicable}

---
*Generated from truth/intent/{feature}.md*
```

## Writing Guidelines

| Do | Don't |
|----|-------|
| Use active voice | Use passive voice |
| Write for humans | Write for machines |
| Explain benefits | List technical specs |
| Tell a story | Enumerate rules |
| Use "you" and "your" | Use "the user" |

## Tone

- **Clear** — No jargon unless defined
- **Concrete** — Examples over abstractions
- **Confident** — State what it does, not what it "tries to" do
- **Concise** — Every sentence earns its place

## Example Transformation

**Intent (normative):**
> "X always moves first. Players alternate turns. A cell can only be marked once."

**Narrative (descriptive):**
> "You start each game as X, making the first move. After you play, your opponent takes their turn, and you continue alternating until someone wins or the board fills up. Once a cell is marked, it stays that way — no take-backs allowed."

## Length Guidelines

| Audience | Length |
|----------|--------|
| Executive summary | 1-2 paragraphs |
| User documentation | 1 page |
| Marketing copy | 3-5 sentences |

Ask for the intended audience if unclear.

## After Generation

- Place output in `docs/narratives/{feature}.md`
- Create `docs/narratives/` directory if it doesn't exist
- Note the source intent document in the footer
