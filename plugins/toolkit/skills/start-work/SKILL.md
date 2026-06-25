---
name: start-work
description: Start work from any source — Jira ticket, GitHub issue, Linear task, email, message, or free text. Either kicks off a planning session or produces a branch name.
---

# Start Work

Starting work forks on intent: either plan it here and now, or produce a branch name. The work description can come from any source.

## Flow

### 1. Identify the work

Accept work from any source:

| Source | Example input |
|---|---|
| Jira ticket | `ENG-123`, `ABC-456` |
| GitHub issue | `#123`, `github.com/org/repo/issues/123` |
| Linear task | `ENG-123`, a Linear URL |
| Free text | An email snippet, message, or description pasted by the user |

If the user hasn't provided enough to identify the work, ask.

### 2. Fetch details if possible

Use available tools to retrieve the title and description:

- **Jira** (`[A-Z]+-\d+` key format) — `mcp__claude_ai_Atlassian__getJiraIssue`
- **GitHub issue** (number or URL) — `mcp__github__issue_read`
- **Other / free text** — use the user's input directly as the title; no fetch needed

If a fetch fails or no MCP tool is available for the source, ask the user for the title.

### 3. Ask intent

Ask with `AskUserQuestion`:
- Header: "Intent"
- Question: "Start work on `<title>` — plan it here and now, or just get the branch name?"
- Options: "Plan here and now", "Branch name only"

### 4. Generate the branch name

Build the slug from the title regardless of intent — it's needed for both paths:

1. Lowercase the title
2. Replace spaces and special characters with hyphens
3. Collapse consecutive hyphens to one
4. Strip leading/trailing hyphens
5. Prepend the ticket ID if one exists, then truncate so the full name stays under 60 characters

| Source | Branch name format |
|---|---|
| Jira | `ENG-123-add-user-auth-flow` |
| GitHub issue | `123-add-user-auth-flow` |
| No ticket | `add-user-auth-flow` |

If the title yields an empty slug after processing, use the bare ticket ID or ask the user for a short description.

### 5. Branch on intent

**Plan here and now:**
1. Use the fetched title and description to seed the context.
2. Begin the `plan` skill.

**Branch name only:**
1. Display the branch name.
2. Copy it to the clipboard: `print -rn -- "<branch>" | pbcopy`
   - If `pbcopy` is unavailable, display the name and tell the user to copy it manually.
3. Stop.
