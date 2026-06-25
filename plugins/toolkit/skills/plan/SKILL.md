---
name: plan
description: The process every Claude planning session must follow — read this before producing any plan
---

# Plan

Every Claude planning session must follow this skill. Read it before producing any plan.

## How planning works

Plan in **plan mode** by writing a new plan file, revealed **one section at a time**: write a section, stop, let the user review it, then move on. The plan is built top-down under strict rules:

1. **One purpose** — each section serves a single purpose; no two cover the same ground.
2. **Increasing detail** — each section is more concrete than the one above; the top is the highest altitude.
3. **Depends up, feeds down** — each section follows from those above it and sets up those below it.
4. **Implementation last** — no implementation details anywhere except the final section.
5. **Cascade** — if a section changes, re-analyze and update every section below it so the document stays coherent and gap-free.
6. **Numbered lists** — every list is a numbered list, never bullets or loose sentences.
7. **Mnemonics** — every list item, at every level including nested sub-steps, begins with a **bold mnemonic** of 1–3 words. It aids scanning while reading; it is not a phrase or sentence summarizing the point.

### About mnemonics

The numbered lists throughout this skill are themselves examples of rule 7 — each item leads with a bold mnemonic. A mnemonic is a short handle, not a mini-summary:

1. **Good** — `**Out of scope**`, `**Shared key**`, `**CLI args**`: 1–3 words, instantly scannable.
2. **Bad** — `**What the plan deliberately excludes**`: a full phrase restating the point, not a handle.

When you write any list in a plan, lead each item the same way.

## Sections

| # | Section | Purpose |
|---|---------|---------|
| 1 | Context | The problem **or** the goal — never both. Highest altitude. |
| 2 | Approach | General direction, from the user. No specifics. |
| 3 | Project Requirements | Hard guardrails the plan must satisfy. |
| 4 | Use Cases | How it should behave, as `trigger: outcome`. |
| 5 | Functional Requirements | The system's logic and behavior — the design. |
| 6 | Components | Every part the design touches. |
| 7 | Contracts | Critical shared behaviors between components. |
| 8 | Implementation | How it gets built — the only section with implementation. |

### 1. Context

State **either** the problem/current situation **or** the goal — never both. Write it succinctly: clear, complete, short. Cut filler, restatement, and unnecessary definite articles.

### 2. Approach

A very short, **very general** direction — not a map. Zero specifications, requirements, or implementation. It comes from the **user**, not from investigation, e.g. "new mise tasks for X and Y, supporting skills, and setup changes for credentials." How those parts work is not explored here.

### 3. Project Requirements

Hard guardrails the rest of the plan must satisfy — **not** a description of the implementation. Keep them high-level: hard, non-obvious constraints only. No implementation detail, no restated goals, and no expected behaviors (those are Use Cases).

This is **new information**, largely from an **interview with the user**; surface requirements even when they already live in `CLAUDE.md` or other skills. Never assume — ask. A simple numbered list: no subsections, no grouping.

1. **In scope** — what the plan covers. Infer candidates, but confirm with the user.
2. **Out of scope** — what it deliberately excludes. (Scope is two separate points, never one combined.)
3. **Constraints** — other hard guardrails, e.g. auth or security. Never assume these — interview the user.

### 4. Use Cases

A flat numbered list — no subsections — of how the implementation should **behave**. Behavior only: no technical or implementation detail. Cover edge cases, not just the happy path. Written by **Claude after deep thinking**; interview the user wherever behavior is unclear — don't guess.

Each item takes the form **trigger**: outcome — the event or user intent before the colon (bold), what the system does after. Avoid indefinite articles ("a"/"an") and keep each item succinct.

### 5. Functional Requirements

The true design section — where the logic lives and most of the work goes. **Technical but free of implementation details**: describe the **behavior of the system** as a coherent, logical whole for both human and AI analysis, and keep it easy for a human to read. Name the technical components that act or are affected (this feeds Components and Implementation), but stop at what the system does and how its parts relate — never how the code is written.

No walls of text: break dense prose into discrete points. Each point gets a **bold mnemonic** and stays succinct without losing clarity.

### 6. Components

A simple numbered list of every component the design touches — new or existing — each with a **super short description of its role**. List at the **concept level, not the file level**: each new task, each service, each skill to update; group several into one line when individual detail doesn't matter (e.g. "all these kinds of skills"). Almost entirely inferable from Functional Requirements — derive it, don't interview.

### 7. Contracts

Only the **key interactions** — the underlying, often hidden behaviors components depend on from one another. A contract is critical shared behavior, not what a component does on its own. Almost entirely inferable from Functional Requirements — derive it, don't interview.

1. **Shared key** — a system built around a unique key shared across components is a contract.
2. **Depended-on script** — a script others rely on to play a key role is a contract.
3. **CLI args** — command-line arguments are **not** contracts.
4. **Self-description** — what a script does that merely describes its own function is **not** a contract.

### 8. Implementation

A normal Claude implementation plan — **the only section with implementation details**. It is informed by every section above: it realizes the Functional Requirements, touches exactly the Components, honors the Contracts, satisfies the Use Cases, stays within Project Requirements, follows the Approach, and serves the Context. It must **not** replay any section above — no restating context, no redefining requirements, no redesigning the system. It only fills in how the design is built.
